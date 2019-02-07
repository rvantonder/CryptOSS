open Core
open Crypto
open Db

let get dir =
  List.filter_map
    Db.cryptos
    ~f:(fun (display_name, safe_name, _) ->
        let name = Option.value safe_name ~default:display_name in
        Crypto.create_and_dump ~name dir)

let load dir =
  List.filter_map
    Db.cryptos
    ~f:(fun (display_name, safe_name, github) ->
        let filename = Option.value safe_name ~default:display_name in
        match Crypto.of_file (dir ^/ filename ^ ".dat") with
        | Some crypto -> Some crypto
        | None ->
          Some
            { Crypto.name = filename
            ; github = "doesn't matter"
            ; repos = []
            })

let sort path (cryptos : string list) : string list =
  In_channel.read_all path
  |> Yojson.Basic.from_string
  |> function
  | `List cryptos_json ->
    let sorted_assoc : (string, int) List.Assoc.t =
      List.map cryptos_json ~f:(fun crypto_json ->
          let name =
            Yojson.Basic.Util.member "name" crypto_json
            |> Yojson.Basic.Util.to_string
          in
          let rank =
            Yojson.Basic.Util.member "rank" crypto_json
            |> Yojson.Basic.Util.to_string
            |> Int.of_string
          in
          (name, rank))
    in
    List.sort
      ~compare:(fun c1 c2 ->
          let get_rank name =
            let name = match name with (* FIXME *)
              | "I.O Coin" -> "I/O Coin"
              | s -> s
            in
            match List.Assoc.find sorted_assoc ~equal:String.equal name  with
            | Some rank -> rank
            | None ->
              Format.printf
                "WARNING: Could not find rank for crypto %s@."
                name;
              10000
          in
          if (get_rank c2) < (get_rank c1) then 1
          else -1
        )
      cryptos
  | _ -> failwith "I expect a list"
