open Core
open Cryptocodewatch
open Tyxml.Html

module B = Bootstrap

let scripts =
  let (!) path = script ~a:[a_src (Xml.uri_of_string path)] (pcdata "") in
  [ !"https://code.jquery.com/jquery-3.2.1.min.js"
  ; !"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"
  ; !"https://cdnjs.cloudflare.com/ajax/libs/jquery.tablesorter/2.29.2/js/jquery.tablesorter.min.js"
  ; !"static/js/custom.js"
  ]

let green_pcdata text =
  a ~a:[ a_class [ "text-success" ] ] [ pcdata text ]

let black_pcdata text =
  a [ pcdata text ]

let orange_pcdata text =
  a ~a:[ a_class [ "text-warning" ] ] [ pcdata text ]

let red_pcdata text =
  a ~a:[ a_class [ "text-warning" ] ] [ pcdata text ]

let blue_pcdata text =
  a ~a:[ a_class [ "text-info" ] ] [ pcdata text ]

let on_fire =
  i ~a:[ a_class [ "fa fa-fire"; "text-danger" ] ] []

(** div make left border *)
let div_nlp = Unsafe.data "<div class=lefty-border>"

let div_nlp' = Unsafe.data "</div>"

let div_nlp_plus = Unsafe.data "<div class=lefty-border-plus>"

let div_nlp_plus' = Unsafe.data "</div>"

let commafy day =
  Time.Span.create ~day ()
  |> Time.Span.to_string_hum ~decimals:0 ~delimiter:','
  |> String.filter ~f:(function | 'a'..'z' -> false | _ -> true)

let title =
  title (pcdata "CryptoCodeWatch")

let head =
  head title Css.all

let empty_row id name =
  tr [ th ~a:[a_scope `Row; a_class ["text-center"] ] [ pcdata id ]
     ; td ~a:[ a_class ["text-left"   ] ] [ pcdata name ]
     ; td ~a:[ a_class [ "text-right"; "no-left-padding"; "full-lefty-border" ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
     ; td ~a:[ a_class [ "text-left"  ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
     ; td ~a:[ a_class [ "text-right"; "no-left-padding"; "full-lefty-border" ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
     ; td ~a:[ a_class [ "text-right" ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
     ; td ~a:[ a_class [ "text-right" ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
     ; td ~a:[ a_class [ "text-right"; "no-left-padding"; "full-lefty-border" ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
     ; td ~a:[ a_class [ "text-right" ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
     ; td ~a:[ a_class [ "text-right"; "no-left-padding"; "full-lefty-border" ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
     ; td ~a:[ a_class [ "text-right" ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
     ; td ~a:[ a_class [ "text-right" ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
     ; td ~a:[ a_class [ "text-right"; "no-left-padding"; "full-lefty-border" ] ] [ i ~a:[ a_class [ "fa fa-minus" ] ] [] ]
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

let row date id name stats =
  let (!) = commafy in
  let path = String.substr_replace_all ~pattern:"/" ~with_:"." name in

  let cell_id = th ~a:[ a_scope `Row; a_class ["text-center"] ] [ pcdata id ] in
  let cell_name =
    let currency_github_link =
      a ~a:[ a_href (Xml.uri_of_string "/"^date^"/currency/"^path) ] [ pcdata name ] in
    td ~a:[ a_class [ "text-left" ] ]
      [ (*on_fire*)
        (*; space ()*)
        currency_github_link
      ]
  in
  let cell_additions =
    let additions = stats.Crypto.Stats.changes_7d |> fst in
    let color = green_pcdata in
    td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ]
      [ color ("+"^(!additions))]
  in
  let cell_deletions =
    let deletions = stats.Crypto.Stats.changes_7d |> snd in
    let color = orange_pcdata in
    td ~a:[ a_class ["text-left"] ] [ color ("-"^(!deletions)) ]
  in
  let cell_commits_24h =
    let value = stats.Crypto.Stats.commits_24h in
    let color = blue_pcdata in
    td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ]
      [ color !value ]
  in
  let cell_commits_7d =
    let value = stats.Crypto.Stats.commits_7d in
    let color = blue_pcdata in
    td ~a:[ a_class ["text-right"] ] [ color !value ]
  in
  let cell_commits_1y =
    let value = stats.Crypto.Stats.commits_1y_per_week |> List.fold ~init:0 ~f:(+) in
    let color = blue_pcdata in
    td ~a:[ a_class ["text-right"] ] [ color !value ]
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
    td ~a:[ a_class ["text-right"] ] [ color text ]
  in
  let cell_stars =
    let value = stats.Crypto.Stats.stars in
    let color = blue_pcdata in
    td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ]
      [ div [color !value
      (*; br ()
        ; diff_text_of_value diff.Crypto.Stats.stars*)
            ] ]
  in
  let cell_forks =
    let value = stats.Crypto.Stats.forks in
    let color = blue_pcdata in
    td ~a:[ a_class ["text-right"] ]
      [ div [ color !value
      (*; br (); diff_text_of_value diff.Crypto.Stats.forks *)
            ] ]
  in
  let cell_watchers =
    let value = stats.Crypto.Stats.watchers in
    let color = blue_pcdata in
    td ~a:[ a_class ["text-right"] ]
      [ div [ color !value;
              (*br (); diff_text_of_value diff.Crypto.Stats.watchers *)
            ] ]
  in
  let cell_last_updated =
    let value = stats.Crypto.Stats.last_updated in
    let text = color_of_time_span value in
    td ~a:[ a_class ["text-right"; "no-left-padding"; "full-lefty-border"] ] text
  in

  tr [
    cell_id
  ; cell_name
  ; cell_additions
  ; cell_deletions
  ; cell_commits_24h
  ; cell_commits_7d
  ; cell_commits_1y
  ; cell_contributors_7d
  ; cell_total_contributors
  ; cell_stars
  ; cell_forks
  ; cell_watchers
  ; cell_last_updated
  ]

let top_header_row =
  let cell_id = th ~a:[ a_colspan 1 ] [] in
  let cell_name = th ~a:[ a_colspan 1 ] [
      button
        ~a:[
          a_id "toggleEmptyButton"
        ; a_class
            [ "btn btn-sm btn-block btn-v-small btn-outline-primary"]
        ; a_onclick "toggle_hide_empty()"]
        [pcdata "HIDE EMPTY"]
    ] in
  let cell_changes =
    th ~a:[ a_colspan 2
          ; a_class ["text-center"; "no-left-padding"; ]
            (*; B.a_data_toggle "tooltip"
              ; B.a_data_placement "top"
              ; B.a_data_title "XXXXXXXXXXXXXXXXXXXXXXXX"*)
          ] [
      div_nlp; pcdata "Changes (7d)"; div_nlp'
    ]
  in
  let cell_commits =
    th ~a:[ a_colspan 3; a_class ["text-center"; "no-left-padding"] ] [
      div_nlp; pcdata "Commits"; div_nlp'
    ]
  in
  let cell_developers =
    th ~a:[ a_colspan 2; a_class ["text-center";  "no-left-padding"] ]
      [ div_nlp
      ; pcdata "Developers"
      ; space ()
      ; i ~a:[ a_class [ "fa fa-users" ] ] []
      ; div_nlp' ]
  in
  let cell_activity =
    th ~a:[ a_colspan 3; a_class ["text-center";  "no-left-padding"] ]
      [ div_nlp; space (); div_nlp' ]
  in
  let cell_last_updated =
    th ~a:[ a_colspan 1; a_rowspan 2; a_class ["text-center"; "no-left-padding"] ]
      [ div_nlp_plus; Unsafe.data "Last<br>Update&nbsp;"; div_nlp_plus' ]
  in
  tr ~a:[a_class ["top-row"]]
    [ cell_id
    ; cell_name
    ; cell_changes
    ; cell_commits
    ; cell_developers
    ; cell_activity
    ; cell_last_updated
    ]

let top_header_second_row =
  let cell_id = th ~a:[ a_class [ "text-center" ] ] [ pcdata "CMC#" ] in
  let cell_name = th ~a:[ a_class ["text-left" ] ] [ pcdata "Name" ] in
  let cell_added =
    th ~a:[ a_class ["text-right"; "no-left-padding" ] ] [
      div_nlp
    ; i ~a:[ a_class [ "fa fa-plus-square" ] ] []
    ; div_nlp'
    ]
  in
  let cell_deleted =
    th ~a:[ a_class ["text-left" ] ] [
      i ~a:[ a_class [ "fa fa-minus-square" ] ] [] ]
  in
  let cell_commits_24h = th ~a:[ a_class ["text-right"; "no-left-padding" ] ] [
      div_nlp
    ; pcdata "24h"
    ; div_nlp'
    ]
  in
  let cell_commits_7d = th ~a:[ a_class ["text-right" ] ] [ pcdata "7d" ] in
  let cell_commits_1y = th ~a:[ a_class ["text-right" ] ] [ pcdata "1y" ] in
  let cell_developers_7d =th ~a:[ a_class ["text-right"; "no-left-padding" ] ] [
      div_nlp
    ; pcdata "7d"
    ; space ()
    (*; i ~a:[ a_class [ "fa fa-users" ] ] []*)
    ; div_nlp'
    ]
  in
  let cell_developers_all =th ~a:[ a_class ["text-right" ] ] [
      pcdata "all"
    ; space ()
      (*; i ~a:[ a_class [ "fa fa-users" ] ] []*)
    ] in
  let cell_stars =
    th ~a:[ a_class ["text-right"; "no-left-padding" ] ] [
      div_nlp
    ; i ~a:[ a_class [ "octicon octicon-star" ] ] []
    ; div_nlp'
    ]
  in
  let cell_forks =
    th ~a:[ a_class ["text-right" ] ] [
      i ~a:[ a_class [ "octicon octicon-repo-forked" ] ] [] ]
  in
  let cell_watchers =
    th ~a:[ a_class ["text-right" ] ] [
      i ~a:[ a_class [ "octicon octicon-eye" ] ] [] ]
  in
  tr ~a:[a_class ["second-top-row"]]
    [ cell_id
    ; cell_name
    ; cell_added
    ; cell_deleted
    ; cell_commits_24h
    ; cell_commits_7d
    ; cell_commits_1y
    ; cell_developers_7d
    ; cell_developers_all
    ; cell_stars
    ; cell_forks
    ; cell_watchers
    ]

let column_headers_thead =

  thead  [
    top_header_row
  ; top_header_second_row
  ]

(**
   table-responsive needs to be in a parent div, see:
   https://stackoverflow.com/questions/41747667/bootstrap-4-responsive-tables-wont-take-up-100-width
*)
let the_table table_data =
  div ~a:[ a_class [ "table-responsive" ]] [
    table
      ~a:[ a_id "table"; a_class [ "table"; "tablesorter"] ]
      ~thead:column_headers_thead
      table_data
  ]


let body table_data =
  body
    begin
      scripts @ [
        B.container [
          B.row [
            B.col_12
              [ Header.title_h1
              ; br ()
              ]
          ]
        ; B.row [
            the_table table_data
          ]
        ]
      ; hr ()
      ; Footer.foot
      ]
    end

let page (crypto_names : string list) date data_directory =
  let table_data =
    List.mapi
      crypto_names
      ~f:(fun i name ->
          let i = i + 1 in
          try (* FIXME also IO Coin *)
            In_channel.read_all (data_directory ^/ name ^ ".agg")
            |> Sexp.of_string
            |> Crypto.Stats.t_of_sexp
            |> row date (Int.to_string i) name
          with Sys_error _ -> empty_row (Int.to_string i) name
        )
  in
  html
    head
    (body table_data)
