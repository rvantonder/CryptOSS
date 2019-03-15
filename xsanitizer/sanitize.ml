open Core
open Yojson

type t = Record.t String.Table.t Date.Table.t

let (!!) date =
  let year = Date.year date in
  let month = Date.month date |> Month.to_int in
  let day = Date.day date in
  Format.sprintf "%d-%02d-%02d" year month day

let f table line =
  match String.split ~on:',' line with
  | date :: cryptocurrency_name :: repo_name :: rest ->
    let date =
      String.substr_replace_all date ~pattern:"-" ~with_:""
      |> Date.of_string_iso8601_basic ~pos:0
    in
    let data = Record.create date cryptocurrency_name repo_name rest in
    begin
      match Date.Table.find table date, data with
      | None, Some data ->
        let inner_table : Record.t String.Table.t = String.Table.create () in
        let key = cryptocurrency_name ^ "," ^ repo_name in
        String.Table.add_exn inner_table ~key ~data;
        Date.Table.add_exn table ~key:date ~data:inner_table
      | Some inner_table, Some data ->
        let key = cryptocurrency_name ^ "," ^ repo_name in
        begin
          try String.Table.add_exn inner_table ~key ~data;
          with exc ->
            Format.eprintf "Warning: duplicate entry for repo!@. Taking first entry.";
            Format.eprintf "Date: %s@." !!date;
            Format.eprintf "%s@." (Exn.to_string exc)
        end
      | _, None -> () (* data does not have enough fields *)
    end
  | _ -> failwith "unhandled"


let () =
  let filename = Sys.argv.(1) in
  let header, lines =
    In_channel.read_lines filename
    |> function
    | header :: lines -> header, lines
    | [] -> assert false
  in
  let table : t = Date.Table.create () in
  List.iter lines ~f:(f table);
  let all_dates = Date.Table.keys table in
  let max_date =
    List.fold all_dates ~init:(List.hd_exn all_dates)
      ~f:(fun max_ date ->
          if Date.(date > max_) then date else max_)
  in
  let min_date =
    List.fold all_dates ~init:(List.hd_exn all_dates)
      ~f:(fun min_ date ->
          if Date.(date < min_) then date else min_)
  in
  let date_range =
    let rec aux acc current =
      if current = max_date then
        max_date :: acc
      else
        aux (current :: acc) (Date.add_days current 1)
    in
    aux [] min_date
    |> List.rev
  in
  let all_repo_keys =
    Date.Table.fold
      table
      ~init:String.Set.empty
      ~f:(fun ~key ~data set ->
          String.Table.fold
            data
            ~init:set
            ~f:(fun ~key ~data set -> String.Set.add set key))
  in
  (* generate null lines for all repos for missing dates *)
  let records_added = ref 0 in
  List.iter date_range ~f:(fun date ->
      let ranks_lookup =
        let open Yojson.Safe.Util in
        let filename = "datastore" ^/ !!date ^/ "ranks.json" in
        try
          In_channel.with_file filename ~f:Yojson.Safe.from_channel
          |> to_list
          |> Option.some
        with _ ->
          Format.printf "%s@." (Format.sprintf "Could not parse json ranks file %s." filename);
          None
      in
      match Date.Table.find table date with
      | None ->
        let repo_table = String.Table.create () in
        String.Set.iter all_repo_keys ~f:(fun key ->
            let crypto, repo_name =
              String.split key ~on:','
              |> function
              | a :: b :: [] -> a, b
              | _ -> assert false
            in
            let ranks_data =
              let open Yojson.Safe.Util in
              let open Option in
              ranks_lookup >>=
              List.find_map ~f:(fun json ->
                  let name = member "name" json |> to_string in
                  if name = crypto then
                    let symbol =
                      try member "symbol" json |> to_string
                      with _ -> "null"
                    in
                    let rank =
                      try member "rank" json |> to_string
                      with _ -> "null"
                    in
                    let price_usd =
                      try member "price_usd" json |> to_string
                      with _ -> "null"
                    in
                    let market_cap_usd =
                      try member "market_cap_usd" json |> to_string
                      with _ -> "null"
                    in
                    (*Format.printf "success@.";*)
                    Some (symbol,rank,price_usd,market_cap_usd)
                  else
                    None)
            in
            let data = Record.null ?ranks_data date crypto repo_name in
            records_added := !records_added + 1;
            String.Table.add_exn repo_table ~key ~data);
        Date.Table.add_exn table ~key:date ~data:repo_table
      | Some repo_table ->
        String.Set.iter all_repo_keys ~f:(fun key ->
            match String.Table.find repo_table key with
            | None ->
              let crypto, repo_name =
                String.split key ~on:','
                |> function
                | a :: b :: [] -> a, b
                | _ -> assert false
              in
              let ranks_data =
                let open Yojson.Safe.Util in
                let open Option in
                ranks_lookup >>=
                List.find_map ~f:(fun json ->
                    let name = member "name" json |> to_string in
                    if name = crypto then
                      let symbol =
                        try member "symbol" json |> to_string
                        with _ -> "null"
                      in
                      let rank =
                        try member "rank" json |> to_string
                        with _ -> "null"
                      in
                      let price_usd =
                        try member "price_usd" json |> to_string
                        with _ -> "null"
                      in
                      let market_cap_usd =
                        try member "market_cap_usd" json |> to_string
                        with _ -> "null"
                      in
                      (*Format.printf "success@.";*)
                      Some (symbol,rank,price_usd,market_cap_usd)
                    else
                      None)
              in
              let data = Record.null ?ranks_data date crypto repo_name in
              records_added := !records_added + 1;
              String.Table.add_exn repo_table ~key ~data
            | Some _ -> ()
          )
    );
  Format.eprintf "Adding %d records@." !records_added;
  Out_channel.with_file "all-sorted-recovered-sanitized.csv" ~f:(fun channel ->
      Out_channel.output_lines channel [header];
      Date.Table.data table
      |>  List.iter ~f:(fun repo_table ->
          String.Table.data repo_table
          |> List.iter ~f:(fun record ->
              Out_channel.output_lines channel [Record.to_string record])))
