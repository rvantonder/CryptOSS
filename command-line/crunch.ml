open Core
open Cryptoss
open Command.Let_syntax


let option_exn x = Option.value_exn x

let get_limit () =
  Github.Monad.(run begin
      Github.API.get_rate ~token:!Crypto.token ()
      >>= fun rate -> return rate
    end)
  |> Lwt_main.run

let rate_remaining () =
  let { Github_t.rate_remaining; _ } = get_limit () in
  rate_remaining

let limit_to_string { Github_t.rate_limit; rate_remaining; rate_reset } =
  Format.sprintf
    "Rate limit: %d@.\
     Remaining: %d@.\
     Reset: %s@."
    rate_limit
    rate_remaining
    begin
      Time.Span.of_sec rate_reset
      |> Time.of_span_since_epoch
      |> Time.to_string
    end


(**
    footpatch: 5631149a8bd3925137d640aaf68f7e3912629a5f
    rvantonder: e18d1e82982c58795456f60f0adfd54c2a842f11
    cryptocodewatch: 33194e10cae4e3886fbc8729a7289491b1dd8656
*)
let save ?(token' = "02d91fca8d6ab3c92554aa6812015a3332f832b5") cryptos =
  let open Crypto in
  Crypto.token := Github.Token.of_string token';
  let m = ref (rate_remaining ()) in  List.iter cryptos
    ~f:(fun crypto_name ->
        Format.printf "Processing Crypto %s@." crypto_name;
        match Crypto.create_and_dump ~name:crypto_name "." with
        | Some crypto ->
          List.iter crypto.repos ~f:(fun repo ->
              Format.printf "Stats for repo %s@." repo.Repo.name;
              Format.printf "%s@." @@ Crypto.Stats.to_string repo.Repo.stats);
          let rate_remaining' = rate_remaining () in
          Format.printf "@.\t\tCrypto %s used %d@." crypto_name (!m - rate_remaining');
          m := rate_remaining'
        | None -> ())

let filename_of_crypto crypto_name =
  Db.cryptos
  |> List.filter_map ~f:(fun (display_name, filename, _) ->
      if crypto_name = display_name then
        match filename with
        | Some filename -> Some filename
        | None -> Some display_name
      else
        None)
  |> Fn.flip List.nth 0

let load aggregate no_forks csv_format dat_file with_ranks_file with_date =
  let open Crypto in
  let csv_header_prologue =
    match with_ranks_file with
    | None -> ""
    | Some _ -> ",symbol,market_cap_rank,price_usd,market_cap_usd"
  in
  let csv_header =
    "date,\
     cryptocurrency_name,\
     repo_name,\
     is_forked,\
     language,\
     last_updated,\
     commits_24h,\
     commits_7d,\
     changes_24h_loc_added,\
     changes_24h_loc_removed,\
     changes_7d_loc_added,\
     changes_7d_loc_removed,\
     contributors_7d,\
     contributors_all_time,\
     commits_1y,\
     changes_1y_loc_added,\
     changes_1y_loc_removed,\
     stars,\
     forks,\
     watchers"
    ^ csv_header_prologue
  in
  let stats_printer = match csv_format with
    | true -> Crypto.Stats.to_csv
    | false -> Crypto.Stats.to_string
  in
  let ranks_file_json =
    Option.map with_ranks_file ~f:(fun file ->
        try In_channel.with_file file ~f:Yojson.Safe.from_channel
        with _ -> failwith "Could not parse json ranks file.")
  in
  let date =
    match with_date with
    | Some date -> date
    | None -> failwith "Must specify and find a date for CSV generation"
  in
  match Crypto.of_file dat_file with
  | Some crypto ->
    if csv_format then Format.printf "%s@." csv_header;
    List.iter crypto.Crypto.repos ~f:(fun repo ->
        (* add extra metadata not part of the stats type *)
        let prelude =
          if not csv_format then Format.sprintf "Processing repo %s@." repo.Repo.name
          else
            let language =
              match repo.Repo.language with
              | None -> "Unknown"
              | Some s -> s
            in
            Format.sprintf "%s,%s,%s,%b,%s," date crypto.Crypto.name repo.Repo.name repo.Repo.is_forked language
        in
        (* add coin ranking data in prologue *)
        let prologue =
          let open Yojson.Safe.Util in
          begin
            try
              Option.map ranks_file_json ~f:(fun json ->
                  to_list json
                  |> List.find_map ~f:(fun json ->
                      let name = member "name" json |> to_string in
                      if name = crypto.Crypto.name then
                        let symbol = member "symbol" json |> to_string in
                        let rank = member "rank" json |> to_string in
                        let price_usd = member "price_usd" json |> to_string in
                        let market_cap_usd = member "market_cap_usd" json |> to_string in
                        Some (Format.sprintf ",%s,%s,%s,%s" symbol rank price_usd market_cap_usd)
                      else
                        None))
              |> function
              | Some None ->
                Format.eprintf "Warning: ranks for %s does not exist@." crypto.Crypto.name;
                None
              | _ as s ->
                s
            with _ ->
              Format.eprintf "Warning: error looking up a ranks field for %s@." crypto.Crypto.name;
              None
          end
          |> Option.join
          |> Option.value ~default:",null,null,null,null"
        in
        Format.printf "%s%s%s@." prelude (stats_printer repo.Repo.stats) prologue
      );
    let aggregate_stats () =
      if not aggregate then
        None
      else
        begin
          List.filter crypto.repos ~f:(fun { Crypto.Repo.is_forked; _ } ->
              if not no_forks then true
              else not is_forked)
          |> List.map ~f:(fun { Crypto.Repo.stats; _ } -> stats)
          |> function
          | stats :: stats_tl ->
            List.fold stats_tl ~init:stats ~f:Crypto.Stats.merge
          | [] ->
            (* Case when after filtering no forks, there are no repos to aggregate over *)
            Format.eprintf "Warning: No aggregate (crypto is only forks)";
            exit 0
        end
        |> Option.some
    in
    let prelude =
      match (not no_forks), (not csv_format) with
      | true, true -> "Aggregate Stats WITH FORKS@."
      | false, true -> "Aggregate Stats WITHOUT FORKS@."
      | true, false -> "AGGREGATE_WITH_FORKS,"
      | false, false -> "AGGREGATE_NO_FORKS,"
    in
    begin
      match aggregate_stats () with
      | Some aggregates ->
        Format.printf "%s%s@." prelude (stats_printer aggregates)
      | None -> ()
    end
  | None ->
    failwith (Format.sprintf "Could not process crypt from file %s" dat_file)



let aggregate_stats crypto_name repos =
  List.map repos ~f:(fun { Crypto.Repo.stats; is_forked; name; _ } ->
      match crypto_name,name with
      | _,"nixpkgs" -> (stats, true)
      | "Litecoin","litecoin" -> (stats, false)
      | _ -> (stats, is_forked)
    )
  |> fun stats_tl ->
  if List.length stats_tl > 0 then
    Some (
      List.fold
        stats_tl
        ~init:Crypto.Stats.empty
        ~f:(fun stats_acc (stats, is_forked) ->
            Crypto.Stats.merge ~forked:is_forked stats_acc stats)
    )
  else
    None


let aggregate crypto_names dir =
  let open Crypto in
  List.iter
    crypto_names
    ~f:(fun crypto_name ->
        let path = filename_of_crypto crypto_name in
        match path with
        | Some path ->
          begin
            match Crypto.of_file (dir ^/ path ^ ".dat") with
            | Some crypto ->
              begin match aggregate_stats crypto_name crypto.repos with
                | Some stats ->
                  Out_channel.write_all (dir ^/ path ^ ".agg")
                    (Crypto.Stats.sexp_of_t stats |> Sexp.to_string)
                | None -> ()
              end
            | None -> ()
          end
        | None -> ()
      )

let limit?(token' = "02d91fca8d6ab3c92554aa6812015a3332f832b5")  () =
  Crypto.token := Github.Token.of_string token';
  Format.printf "%s@." (get_limit () |> limit_to_string)

let show
    ?(n = List.length Db.cryptos)
    ?(split = List.length Db.cryptos)
    ?dump
    ?(sep="\n")
    () =
  let result =
    begin
      Db.cryptos
      |> List.filter_map
        ~f:(fun (display_name, _, _) ->
            Some display_name)
      |> Fn.flip List.take n
    end
  in

  let result =
    let rec aux acc (hd,tl) =
      match tl with
      | [] -> hd::acc
      | tl' -> aux (hd::acc) (List.split_n tl' split)
    in
    aux [] (List.split_n result split)
  in

  result
  |> List.map ~f:(String.concat ~sep:sep)
  |> List.rev
  |> fun result ->
  match dump with
  | None ->
    List.iter result ~f:(fun s -> Format.printf "%s@." s)
  | Some file ->
    List.iteri result ~f:(fun i data ->
        let filename = file^"-"^(Int.to_string i)^".txt" in
        Out_channel.write_all filename ~data)

let unsupported file =
  In_channel.read_all file
  |> Yojson.Basic.from_string
  |> function
  | `List cryptos_json ->
    let cmc_crypto_names : string List.t =
      List.map cryptos_json ~f:(fun crypto_json ->
          Yojson.Basic.Util.member "name" crypto_json
          |> Yojson.Basic.Util.to_string)
    in
    let supported_cryptos =
      Db.cryptos
      |> List.filter_map
        ~f:(fun (display_name, _, _) ->
            Some display_name)
    in
    List.iter cmc_crypto_names ~f:(fun name ->
        match List.mem supported_cryptos name ~equal:String.equal with
        | true -> ()
        | false -> Format.printf "%s@." name)

  | _ -> failwith "I expect a list"

let () =
  Command.group ~summary:""
    [ "save",
      Command.basic
        ~summary:"Pull GitHub data for a crypto (like \"Bitcoin\"; see `./crunch.exe show` for more) and save in a .dat in the current directory"
        [%map_open
          let crypto_name = anon ("CRYPTO" %: Arg_type.comma_separated string)
          and token' = flag "token" (optional string) ~doc:"Use this token"
          in
          fun () -> save ?token' crypto_name
        ]

    ; "load",
      Command.basic
        ~summary:"Aggregate and display GitHub Data (from .dat)"
        [%map_open
          let dat_file = anon ("FILE" %: string)
          and csv_format = flag "csv" no_arg ~doc:"Dump in CSV format"
          and no_forks = flag "no-forks" no_arg ~doc:"Do not aggregate forked repos"
          and aggregate = flag "aggregate" no_arg ~doc:"Emit aggregation"
          and with_ranks_file = flag "with-ranks" (optional string) ~doc:"Emit CSV with price rank data (CMC format)"
          and with_date = flag "with-date" (optional string) ~doc:"Emit date in CSV based datet" in
          fun () -> load aggregate no_forks csv_format dat_file with_ranks_file with_date
        ]


    ; "limit",
      Command.basic
        ~summary:"rate limit for token"
        [%map_open
          let token' = flag "token" (optional string) ~doc:"Use this token"
          in
          fun () -> limit ?token' ()
        ]

    ; "unsupported",
      Command.basic
        ~summary:"Diff ranks.json and crypto db to determine new cryptos not supported yet"
        [%map_open
          let ranks = flag "file" (required file) ~doc:"ranks file"
          in
          fun () -> unsupported ranks
        ]

    ; "show",
      Command.basic
        ~summary:"show the cryptos"
        [%map_open
          let n = flag "n" (optional int) ~doc:"N Limit to n cryptos"
          and split = flag "split" (optional int) ~doc:"N split into N chunks"
          and dump = flag "dump" (optional file) ~doc:"file Dump to file(s)"
          and sep = flag "sep" (optional string) ~doc:"separator"
          in
          fun () -> show ?n ?split ?dump ?sep ()
        ]


    ; "aggregate",
      Command.basic
        ~summary:"Generate HTML for each crypto"
        [%map_open
          let crypto_names = anon ("CRYPTO" %: Arg_type.comma_separated string)
          and dir = flag "dir" (required string) ~doc:"dir Directory"
            in
          fun () -> aggregate crypto_names dir
        ]
    ]
  |> Command.run
