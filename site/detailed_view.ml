open Core
open Tyxml.Html

open Cryptoss
open Crypto

let (!!) date =
  let year = Date.year date in
  let month = Date.month date |> Month.to_int in
  let day = Date.day date in
  Format.sprintf "%d-%02d-%02d" year month day

module B = Bootstrap

let green_pcdata text =
  a ~a:[ a_class [ "text-success" ] ] [ pcdata text ]

let orange_pcdata text =
  a ~a:[ a_class [ "text-warning" ] ] [ pcdata text ]

let red_pcdata text =
  a ~a:[ a_class [ "text-warning" ] ] [ pcdata text ]

let blue_pcdata text =
  a ~a:[ a_class [ "text-info" ] ] [ pcdata text ]

let on_fire =
  i ~a:[ a_class [ "fa fa-fire"; "text-danger" ] ] []

let commafy day =
  Time.Span.create ~day ()
  |> Time.Span.to_string_hum ~decimals:0 ~delimiter:','
  |> String.filter ~f:(function | 'a'..'z' -> false | _ -> true)


let scripts =
  let (!) path = script ~a:[a_src (Xml.uri_of_string path)] (pcdata "") in
  [ !"https://code.jquery.com/jquery-3.2.1.min.js"
  ; !"https://cdnjs.cloudflare.com/ajax/libs/jquery.tablesorter/2.29.2/js/jquery.tablesorter.min.js"
  (*  ; !"https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.js"
      ; !"https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.18/c3.js"*)
  ; !"https://code.highcharts.com/stock/highstock.js"
  ; !"https://code.highcharts.com/stock/modules/exporting.js"
  ; !"../static/js/custom.js"
  ]

let title crypto =
  title (pcdata crypto.name)

let head crypto =
  head (title crypto) Css.detailed

let div_nlp = Unsafe.data "<div class=lefty-border>"

let div_nlp' = Unsafe.data "</div>"

let top_header_row =
  let cell_name = th ~a:[ a_class [ "text-left" ] ] [ pcdata "Repository" ] in
  let cell_changes_24h =
    th ~a:[ a_class [ "text-right"; "no-left-padding" ] ]
      [ div_nlp; pcdata "Changes (24h)"; div_nlp' ]
  in
  let cell_changes_7d =
    th ~a:[ a_class ["text-right"; "no-left-padding" ] ]
      [ div_nlp; pcdata "Changes (7d)"; div_nlp' ]
  in
  let commits_24h =
    th ~a:[ a_class ["text-right"; "no-left-padding" ] ]
      [ div_nlp; pcdata "Commits (24h)"; div_nlp' ]
  in
  let commits_7d =
    th ~a:[ a_class ["text-right"; "no-left-padding" ] ]
      [ div_nlp; Unsafe.data "Commits<br>(7d)"; div_nlp' ]
  in
  let commits_1y =
    th ~a:[ a_class ["text-right"; "no-left-padding" ] ]
      [ div_nlp; Unsafe.data "Commits<br>(1y)"; div_nlp' ]
  in
  let devs_7d =
    th ~a:[ a_class ["text-right"; "no-left-padding" ] ]
      [ div_nlp; pcdata "Devs (7d)"; div_nlp' ]
  in
  let devs_all =
    th ~a:[ a_class ["text-right"; "no-left-padding" ] ]
      [ div_nlp; pcdata "Devs (all)"; div_nlp' ]
  in
  let lang =
    th ~a:[ a_class ["text-center"; "no-left-padding" ] ]
      [ div_nlp; pcdata "Language"; div_nlp' ]
  in
  let cell_stars =
    th ~a:[ a_class ["text-center"; "no-left-padding" ] ] [
      div_nlp
    ; i ~a:[ a_class [ "octicon octicon-star" ] ] []
    ; div_nlp'
    ]
  in
  let cell_forks =
    th ~a:[ a_class ["text-center" ] ] [
      i ~a:[ a_class [ "octicon octicon-repo-forked" ] ] [] ]
  in
  let cell_watchers =
    th ~a:[ a_class ["text-center" ] ] [
      i ~a:[ a_class [ "octicon octicon-eye" ] ] [] ]
  in
  let cell_last_updated =
    th ~a:[ a_class ["text-center"; "no-left-padding"] ]
      [ div_nlp; Unsafe.data "Last Update"; div_nlp' ]
  in

  thead [
    tr [
      cell_name
    ; cell_changes_24h
    ; cell_changes_7d
    ; commits_24h
    ; commits_7d
    ; commits_1y
    ; devs_7d
    ; devs_all
    ; lang
    ; cell_stars
    ; cell_forks
    ; cell_watchers
    ; cell_last_updated
    ]
  ]


let cell_tuple (additions, deletions) =
  let (!) = commafy in
  td [ green_pcdata ("+"^(!additions))
     ; space ()
     ; red_pcdata !deletions
     ]

let cell_single value =
  let (!) = commafy in
  td [
    blue_pcdata !value
  ]


let hidden text =
  a ~a:[ a_class [ "hidden-sort" ] ] [ pcdata text ]

let color_of_time_span span =
  let (!) = Time.Span.to_string_hum ~decimals:0 in
  if Time.Span.(span < Time.Span.create ~day:1 ()) then
    [
      hidden "a";
      green_pcdata "< 1d" ]
  else if Time.Span.(span < Time.Span.create ~day:7 ()) then
    [
      hidden "b";
      blue_pcdata !span ]
  else if Time.Span.(span < Time.Span.create ~day:21 ()) then
    [
      hidden "c";
      orange_pcdata !span ]
  else
    [
      hidden "d";
      red_pcdata (String.substr_replace_all ~pattern:"_" ~with_:"," !span) ]

let repo_table_data crypto =
  let open Crypto.Stats in
  let (!) = commafy in

  let row { Crypto.Repo.name; stats; language ; is_forked; _ } =
    let cell_name =
      th ~a:[ a_scope `Row; a_class ["text-left" ]  ] [
        a ~a:[ a_href
                 (Xml.uri_of_string @@
                  Format.sprintf
                    "https://github.com/%s/%s"
                    crypto.github
                    name)
             ]
          [
            if String.length name > 22 then
              pcdata ((String.prefix name 19)^"...")
            else
              pcdata name
          ]
      ; i ~a:[ a_class [  (match is_forked with
            | true -> "octicon octicon-repo-forked"
            | false -> "") ] ] []
      ]
    in
    let cell_changes_24h =
      let additions, deletions = stats.changes_24h in
      td ~a:[ a_class ["text-right"; "full-lefty-border"; "no-left-padding" ] ]
        [ green_pcdata ("+"^(!additions))
        ; space ()
        ; red_pcdata ("-"^(!deletions))
        ]
    in
    let cell_changes_7d =
      let additions, deletions = stats.changes_7d in
      td ~a:[ a_class ["text-right"; "full-lefty-border"; "no-left-padding" ] ]
        [ green_pcdata ("+"^(!additions))
        ; space ()
        ; red_pcdata ("-"^(!deletions))
        ]
    in
    let cell_commits_24h =
      let value = stats.commits_24h in
      let color = blue_pcdata in
      td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ]
        [ color !value ]
    in
    let cell_commits_7d =
      let value = stats.Crypto.Stats.commits_7d in
      let color = blue_pcdata in
      td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ]
        [ color !value ]
    in
    let cell_commits_1y =
      let value = stats.Crypto.Stats.commits_1y_per_week |> List.fold ~init:0 ~f:(+) in
      let color = blue_pcdata in
      td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ]
        [ color !value ]
    in
    let cell_contributors_7d =
      let value = List.length stats.Crypto.Stats.contributors_7d in
      let color = blue_pcdata in
      td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ] [ color !value ]
    in
    let cell_total_contributors =
      let value = List.length stats.Crypto.Stats.total_contributors_up_to_100 in
      let text = if value > 100 then !value^"+" else !value in
      let color = blue_pcdata in
      td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ] [ color text ]
    in
    let cell_language =
      td ~a:[ a_class ["text-left"; "no-left-padding"; "full-lefty-border"]]  [ blue_pcdata
                                                                                  (match language with
                                                                                   | Some language -> language
                                                                                   | None -> "?")
                                                                              ]
    in
    let cell_stars =
      let value = stats.Crypto.Stats.stars in
      let color = blue_pcdata in
      td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ] [ color !value ]
    in
    let cell_forks =
      let value = stats.Crypto.Stats.forks in
      let color = blue_pcdata in
      td ~a:[ a_class ["text-right"] ] [ color !value ]
    in
    let cell_watchers =
      let value = stats.Crypto.Stats.watchers in
      let color = blue_pcdata in
      td ~a:[ a_class ["text-right"] ] [ color !value ]
    in
    let cell_last_updated =
      let value = stats.Crypto.Stats.last_updated in
      let text = color_of_time_span value in
      td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ] text
    in
    tr [
      cell_name
    ; cell_changes_24h
    ; cell_changes_7d
    ; cell_commits_24h
    ; cell_commits_7d
    ; cell_commits_1y
    ; cell_contributors_7d
    ; cell_total_contributors
    ; cell_language
    ; cell_stars
    ; cell_forks
    ; cell_watchers
    ; cell_last_updated
    ]
  in
  List.map
    crypto.repos
    ~f:row


let repo_table crypto =
  table
    ~a:[ a_id "table"; a_class [ "table table-sm"; "tablesorter" ] ]
    ~thead:(top_header_row)
    (repo_table_data crypto)

let contributor_column_headers_thead () =
  let column_headers =
    [ "User", "", `AlignLeft
    (*; "Last commit", "", `AlignLeft
      ; "Contributions", "", `AlignLeft*)
    ; "Followers", "", `AlignLeft
    ; "Location", "", `AlignLeft
    ]
  in

  thead [
    tr begin
      List.map
        column_headers
        ~f:(fun (label, icon, align) ->
            th ~a:[ a_scope `Col
                  ; a_class
                      [ match align with
                        | `AlignLeft ->  "text-left"
                        | `AlignRight -> "text-right"
                      ]
                  ]
              [ pcdata label
              ; space ()
              ; i ~a:[ a_class [ icon ] ] []
              ])
    end
  ]

let contributor_row followers ?location username =
  let cell_name = th ~a:[ a_scope `Row ] [ pcdata username ] in
  let cell_location =
    td ~a:[ a_class ["no-left-padding"; "full-lefty-border"] ]
      [ pcdata @@ match location with | Some l -> l | None -> "?"  ]
  in
  let cell_followers =
    td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ]
      [ pcdata @@ Int.to_string followers ]
  in
  tr [
    cell_name
  ; cell_location
  ; cell_followers
  ]

let contributors_table_data contributors =
  contributors
  |> List.sort
    ~compare:
      (fun { Repo.followers; _ }
        { Repo.followers = followers' }
        -> Int.compare followers followers'
      )
  |>
  List.map ~f:(fun {Repo.followers; location; username } ->
      contributor_row followers ?location username)

let contributor_table repos =
  Format.printf "Repos size: %d@." @@ List.length repos;
  let dedup_repos =
    List.concat_map repos ~f:(fun { Repo.contributors; _ } ->
        Format.printf "Some contributors:%d@." @@ List.length contributors;
        contributors
      )
    (*    |> List.dedup
          ~compare:(fun { Repo.username; _ }
                     { Repo.username = username'; _ } ->
                     String.compare username username')*)
  in
  Format.printf "Dedup repos size: %d@." @@ List.length dedup_repos;
  [
    B.row [
      table
        ~a:[ a_id "table"; a_class [ "table table-sm"; "tablesorter" ] ]
        ~thead:(contributor_column_headers_thead ())
        (contributors_table_data dedup_repos)
    ]
  ]

let aggregate_stats name data_directory =
  try (* FIXME also IO Coin *)
    In_channel.read_all (data_directory ^/ name ^/ ".agg")
    |> Sexp.of_string
    |> Crypto.Stats.t_of_sexp
    |> Option.some
  with Sys_error _ -> None

let lifetime_changes_chart stats =
  stats
  |> function
  | Some stats
    when List.length stats.Crypto.Stats.changes_1y_per_week > 0 ->
    [ B.row [h3 [ pcdata "Aggregate Changes" ] ]
    ; B.row [
        div ~a: [ a_class ["col-12"] ] [
          div ~a:[ a_id "container" ] []
        ]
      ]
    ;  Chart.changes_highcharts_js stats
    ]
  | _ -> []

(** DISABLED. Commits don't have a timestamp, just 52 entries, so skipping this *)
let lifetime_commits_chart stats =
  [ B.row [h3 [ pcdata "Lifetime Commits" ] ]
  ; B.row [div ~a:[ a_id "chart" ] []]
  ; stats
    |> function
    | Some stats
      when List.length stats.Crypto.Stats.commits_1y_per_week > 0
      -> Chart.commits_js stats
    | _ -> space ()
  ]


(** grab icon from source *)
let body crypto date stats =
  let next_date =
    String.substr_replace_all date ~pattern:"-" ~with_:""
    |> Date.of_string_iso8601_basic ~pos:0
    |> Fn.flip Date.add_days 1
    |> fun x -> !!x
  in
  let prev_date =
    String.substr_replace_all date ~pattern:"-" ~with_:""
    |> Date.of_string_iso8601_basic ~pos:0
    |> Fn.flip Date.add_days (-1)
    |> fun x -> !!x
  in
  body
    begin
      scripts @
      [ br ()
      ; B.container ([
            h1 ~a:[ a_class ["text-center"] ] [
              pcdata crypto.name
            ]
          ; B.row [
              div  ~a:[ a_class [ "col-2"; ] ] [
                p [
                  a ~a:[ a_href (Xml.uri_of_string (Site_prefix.prefix ^/ prev_date ^/ "currency" ^/ crypto.name)) ] [ pcdata "prev" ]
                ; br  ()
                ; pcdata prev_date
                ]
              ]
            ; div  ~a:[ a_class [ "col-10";  "text-right" ] ] [
                p [
                  a ~a:[ a_href (Xml.uri_of_string (Site_prefix.prefix ^/ next_date ^/ "currency" ^/ crypto.name)) ] [ pcdata "next" ]
                ; br ()
                ; pcdata next_date
                ]
              ]
            ]
          ; hr ()
          ; B.row [ repo_table crypto ]
          ; br ()
          ; br ()]
            @ (lifetime_changes_chart stats)
            (* disabled: don't have easy timestamps *)
            (*@ (lifetime_commits_chart stats)*)
            (* contributor_table is disabled because it will generate a shit ton of requests *)
            (*@ (contributor_table crypto.repos)*)
            @ ([ hr () ; Footer.foot])
          )
      ]
    end

let page (crypto_name : string) date data_directory =
  let crypto = (* FIXME see Cryptos.ml, use load_one *)
    match Crypto.of_file (data_directory ^/ crypto_name ^ ".dat") with
    | Some crypto -> crypto
    | None -> { Crypto.name = crypto_name; github = ""; repos = [] }
  in
  let stats = aggregate_stats crypto_name data_directory in
  html
    (head crypto)
    (body crypto date stats)
