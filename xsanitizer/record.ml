open Core

type t =
  { date : Date.t
  ; cryptocurrency_name : string
  ; repo_name : string
  ; is_forked : string
  ; language : string
  ; last_updated : string
  ; commits_24h : int
  ; commits_7d : int
  ; changes_24h_loc_added : int
  ; changes_24h_loc_removed : int
  ; changes_7d_loc_added : int
  ; changes_7d_loc_removed : int
  ; contributors_7d : int
  ; contributors_all_time : int
  ; commits_1y : int
  ; changes_1y_loc_added : int
  ; changes_1y_loc_removed : int
  ; stars : int
  ; forks : int
  ; watchers : int
  ; symbol : string
  ; market_cap_rank : string
  ; price_usd : string
  ; market_cap_usd : string
  }

let (!!) date =
  let year = Date.year date in
  let month = Date.month date |> Month.to_int in
  let day = Date.day date in
  Format.sprintf "%d-%02d-%02d" year month day

let to_int s =
  try
    Int.of_string s
  with _ ->
    -1

let create date cryptocurrency_name repo_name rest =
  match rest with
  (* with fin data *)
  | is_forked :: language :: last_updated :: commits_24h :: commits_7d :: changes_24h_loc_added :: changes_24h_loc_removed :: changes_7d_loc_added :: changes_7d_loc_removed :: contributors_7d :: contributors_all_time :: commits_1y :: changes_1y_loc_added :: changes_1y_loc_removed :: stars :: forks :: watchers :: symbol :: market_cap_rank :: price_usd :: market_cap_usd :: [] ->
    { date
    ; cryptocurrency_name
    ; repo_name
    ; is_forked
    ; language
    ; last_updated
    ; commits_24h = to_int commits_24h
    ; commits_7d = to_int commits_7d
    ; changes_24h_loc_added = to_int changes_24h_loc_added
    ; changes_24h_loc_removed = to_int changes_24h_loc_removed
    ; changes_7d_loc_added = to_int changes_7d_loc_added
    ; changes_7d_loc_removed = to_int changes_7d_loc_removed
    ; contributors_7d = to_int contributors_7d
    ; contributors_all_time = to_int contributors_all_time
    ; commits_1y = to_int commits_1y
    ; changes_1y_loc_added = to_int changes_1y_loc_added
    ; changes_1y_loc_removed = to_int changes_1y_loc_removed
    ; stars = to_int stars
    ; forks = to_int forks
    ; watchers = to_int watchers
    ; symbol
    ; market_cap_rank
    ; price_usd
    ; market_cap_usd
    }
    |> Option.some
  (* without fin data *)
  | is_forked :: language :: last_updated :: commits_24h :: commits_7d :: changes_24h_loc_added :: changes_24h_loc_removed :: changes_7d_loc_added :: changes_7d_loc_removed :: contributors_7d :: contributors_all_time :: commits_1y :: changes_1y_loc_added :: changes_1y_loc_removed :: stars :: forks :: watchers :: [] ->
    { date
    ; cryptocurrency_name
    ; repo_name
    ; is_forked
    ; language
    ; last_updated
    ; commits_24h = to_int commits_24h
    ; commits_7d = to_int commits_7d
    ; changes_24h_loc_added = to_int changes_24h_loc_added
    ; changes_24h_loc_removed = to_int changes_24h_loc_removed
    ; changes_7d_loc_added = to_int changes_7d_loc_added
    ; changes_7d_loc_removed = to_int changes_7d_loc_removed
    ; contributors_7d = to_int contributors_7d
    ; contributors_all_time = to_int contributors_all_time
    ; commits_1y = to_int commits_1y
    ; changes_1y_loc_added = to_int changes_1y_loc_added
    ; changes_1y_loc_removed = to_int changes_1y_loc_removed
    ; stars = to_int stars
    ; forks = to_int forks
    ; watchers = to_int watchers
    ; symbol = "null"
    ; market_cap_rank = "null"
    ; price_usd = "null"
    ; market_cap_usd = "null"
    }
    |> fun record ->
    Format.eprintf "No fin data For %s,%s@." !!date cryptocurrency_name;
    Some record
  | s ->
    Format.eprintf "Short record: %d fields, expected 17 (without fin data) or 21 (with fin data).@." (List.length s);
    Format.eprintf "For %s,%s,%s" !!date cryptocurrency_name repo_name;
    None


let null date cryptocurrency_name repo_name =
  { date
  ; cryptocurrency_name
  ; repo_name
  ; is_forked = "null"
  ; language = "null"
  ; last_updated = "null"
  ; commits_24h = -1
  ; commits_7d = -1
  ; changes_24h_loc_added = -1
  ; changes_24h_loc_removed = -1
  ; changes_7d_loc_added = -1
  ; changes_7d_loc_removed = -1
  ; contributors_7d = -1
  ; contributors_all_time = -1
  ; commits_1y = -1
  ; changes_1y_loc_added = -1
  ; changes_1y_loc_removed = -1
  ; stars = -1
  ; forks = -1
  ; watchers = -1
  ; symbol = "null"
  ; market_cap_rank = "null"
  ; price_usd = "null"
  ; market_cap_usd = "null"
  }

let to_string
    { date : Date.t
    ; cryptocurrency_name : string
    ; repo_name : string
    ; is_forked : string
    ; language : string
    ; last_updated : string
    ; commits_24h : int
    ; commits_7d : int
    ; changes_24h_loc_added : int
    ; changes_24h_loc_removed : int
    ; changes_7d_loc_added : int
    ; changes_7d_loc_removed : int
    ; contributors_7d : int
    ; contributors_all_time : int
    ; commits_1y : int
    ; changes_1y_loc_added : int
    ; changes_1y_loc_removed : int
    ; stars : int
    ; forks : int
    ; watchers : int
    ; symbol : string
    ; market_cap_rank : string
    ; price_usd : string
    ; market_cap_usd : string
    }
  =
  let (!) v = if v < 0 then "null" else Int.to_string v in
  Format.sprintf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s"
    !!date cryptocurrency_name repo_name is_forked language last_updated !commits_24h !commits_7d !changes_24h_loc_added !changes_24h_loc_removed !changes_7d_loc_added !changes_7d_loc_removed !contributors_7d !contributors_all_time !commits_1y !changes_1y_loc_added !changes_1y_loc_removed !stars !forks !watchers symbol market_cap_rank price_usd market_cap_usd
