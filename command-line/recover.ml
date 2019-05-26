open Core
open Option

open Record

type t = Record.t String.Table.t Date.Table.t

let (--) date days = Date.add_days date (-days)

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
            Format.eprintf "Warning: duplicate entry for repo!@.";
            Format.eprintf "Date: %s@." !!date;
            Format.eprintf "%s@." (Exn.to_string exc)
        end
      | _, None -> () (* data does not have enough fields *)
    end
  | _ -> failwith "unhandled"

let missing_commit_and_changes table date repo data_after =
  Date.Table.find table (date -- 2) >>= fun t ->
  String.Table.find t repo >>= fun { commits_24h = c1; changes_24h_loc_added = d1; changes_24h_loc_removed = e1; _} ->
  Date.Table.find table (date -- 3) >>= fun t ->
  String.Table.find t repo >>= fun { commits_24h = c2; changes_24h_loc_added = d2; changes_24h_loc_removed = e2; _} ->
  Date.Table.find table (date -- 4) >>= fun t ->
  String.Table.find t repo >>= fun { commits_24h = c3; changes_24h_loc_added = d3; changes_24h_loc_removed = e3; _} ->
  Date.Table.find table (date -- 5) >>= fun t ->
  String.Table.find t repo >>= fun { commits_24h = c4; changes_24h_loc_added = d4; changes_24h_loc_removed = e4; _} ->
  Date.Table.find table (date -- 6) >>= fun t ->
  String.Table.find t repo >>= fun { commits_24h = c5; changes_24h_loc_added = d5; changes_24h_loc_removed = e5; _} ->
  (*Format.eprintf "Total %s: %d@." !!lost_day commits_7d;
    Format.eprintf "Today %s: %d@." !!lost_day commits_24h;
    Format.eprintf "   -2 %s: %d@." !!(date -- 2) c1;
    Format.eprintf "   -3 %s: %d@." !!(date -- 3) c2;
    Format.eprintf "   -4 %s: %d@." !!(date -- 4) c3;
    Format.eprintf "   -5 %s: %d@." !!(date -- 5) c4;
    Format.eprintf "   -6 %s: %d@." !!(date -- 6) c5;*)
  let c = data_after.commits_7d - data_after.commits_24h - c1 -c2 - c3 - c4 - c5 in
  let d = data_after.changes_7d_loc_added - data_after.changes_24h_loc_added - d1 - d2 - d3 - d4 - d5 in
  let e = data_after.changes_7d_loc_removed - data_after.changes_24h_loc_removed - e1 - e2 - e3 - e4 - e5 in
  Some (c, d, e)

let missing_stars_subscribers_forks'
    { stars
    ; forks
    ; watchers
    ; commits_7d
    ; contributors_all_time
    }
    { stars = stars'
    ; forks = forks'
    ; watchers = watchers'
    ; contributors_all_time = contributors_all_time'
    } =
  let stars = if stars = stars' then stars else -1 in
  let watchers = if watchers = watchers' then watchers else -1 in
  let forks = if forks = forks' then forks else -1 in
  let contributors_all_time = if contributors_all_time = contributors_all_time' then contributors_all_time else -1 in
  stars, watchers, forks, contributors_all_time

let missing_stars_subscribers_forks table repo before after_data =
  Date.Table.find table before >>= fun t ->
  String.Table.find t repo >>= fun before_data ->
  return (missing_stars_subscribers_forks' before_data after_data)

let recover table before lost_day after =
  let commit_entries_recovered = ref 0 in
  let stars_entries_recovered = ref 0 in
  Format.eprintf "Recovering data for lost day %s@." !!lost_day;
  let entries_after_lost_day = Date.Table.find_exn table after in
  String.Table.iteri entries_after_lost_day ~f:(fun ~key:repo ~data:({ date; _ } as data) ->
      let missing = missing_commit_and_changes table date repo data in
      match missing with
      | Some (commits_24h, changes_24h_loc_added, changes_24h_loc_removed) ->
        if commits_24h < 0 then
          Format.eprintf "IMPOSSIBLE COMMIT NUM: %s,%s,%d@." !!lost_day repo commits_24h
        else if changes_24h_loc_added < 0 then
          Format.eprintf "IMPOSSIBLE LOC ADDED: %s,%s,%d@." !!lost_day repo changes_24h_loc_added
        else if changes_24h_loc_removed < 0 then
          Format.eprintf "IMPOSSIBLE LOC REMOV: %s,%s,%d@." !!lost_day repo changes_24h_loc_removed
        else begin
          commit_entries_recovered := !commit_entries_recovered + 1;
          let crypto_name, repo_name =
            String.split ~on:',' repo
            |> function
            | a :: b :: [] -> a,b
            | _ -> assert false
          in
          let entry =
            { (Record.null lost_day crypto_name repo_name) with
              commits_24h
            ; changes_24h_loc_added
            ; changes_24h_loc_removed
            ; is_forked = data.is_forked
            ; language = data.language
            ; symbol = data.symbol
            }
          in
          match missing_stars_subscribers_forks table repo before data with
          | None ->
            Format.printf "%s@." (Record.to_string entry)
          | Some (stars, watchers, forks, contributors_all_time) ->
            if forks <> -1 || watchers <> -1 || stars <> -1 then
              stars_entries_recovered := !stars_entries_recovered + 1;
            let entry = { entry with forks; watchers; stars; contributors_all_time } in
            Format.printf "%s@." (Record.to_string entry)
        end
      | None ->
        ()
    );
  !commit_entries_recovered, !stars_entries_recovered

let () =
  let filename = Sys.argv.(1) in
  let lines =
    In_channel.read_lines filename
    |> List.tl_exn
  in
  let table : t = Date.Table.create () in
  List.iter lines ~f:(f table);
  Date.Table.iter_keys table ~f:(fun date ->
      let next_day = Date.add_days date 1 in
      let next_next_day = Date.add_days date 2 in
      if
        Date.Table.mem table next_next_day &&
        not (Date.Table.mem table next_day)
      then
        (* non-contiguous missing data *)
        let n, s = recover table date next_day next_next_day in
        Format.eprintf "Recovered %d (commit) %d (stars) entries for %s@." n s !!next_day;
      else
        ())
