open Core
open Cryptoss
open Tyxml.Html

let changes_highcharts_js crypto =
  let changes = crypto.Crypto.Stats.changes_1y_per_week in
  let _dates =
    List.map changes ~f:(fun { Crypto.Stats.week_timestamp; _ } ->
        Time.to_span_since_epoch week_timestamp
        |> Time.Span.to_ms (* ms for highcharts *)
        |> Int.of_float
        |> Int.to_string)
  in
  let _added =
    List.map changes ~f:(fun { Crypto.Stats.added; _ } -> added)
    |> List.map ~f:Int.to_string
  in

  let _deleted =
    List.map changes ~f:(fun { Crypto.Stats.deleted; _ } -> deleted)
    |> List.map ~f:Int.to_string
  in

  let pp l =
    l |>
    List.map
      ~f:(fun (date, num) -> Format.sprintf "[%s,%s]" date num)
    |> String.concat ~sep:","
  in

  let add_data =
    List.zip _dates _added
    |> function
    | Some good ->
      good
      |> List.sort ~compare:(fun  (date,_) (date',_) ->
          String.compare date date')
      |> fun good ->
      Format.sprintf "[%s]" @@ pp good
    | None -> "[]"
  in

  let delete_data =
    List.zip _dates _deleted
    |> function
    | Some good ->
      good
      |> List.sort ~compare:(fun  (date,_) (date',_) ->
          String.compare date date')
      |> fun good ->
      Format.sprintf "[%s]" @@ pp good
    | None -> "[]"
  in

  script (pcdata @@ Format.sprintf
            {|
Highcharts.stockChart('container', {
        rangeSelector: {
            selected: 1
        },

//        title: {
//            text: 'Lifetime Changes'
//        },

        series: [
            {
              name: 'Added',
              data: %s,
              color: '#1e7e34',
              tooltip: {
                valueDecimals: 0
              }
            },
            {
              name: 'Deleted',
              data: %s,
              color: '#d39e00',
              tooltip: {
                valueDecimals: 0
              }
            }
        ]
    });
|}

            add_data
            delete_data)

let changes_js crypto =
  let changes = crypto.Crypto.Stats.changes_1y_per_week in
  let dates =
    List.map changes ~f:(fun { Crypto.Stats.week_timestamp; _ } ->
        Date.of_time ~zone:Time.Zone.utc week_timestamp
        |> Date.to_string)
    |> List.map ~f:(fun s -> Format.sprintf "'%s'" s)
    |> String.concat ~sep:","
  in
  let added =
    List.map changes ~f:(fun { Crypto.Stats.added; _ } -> added)
    |> List.map ~f:Int.to_string
    |> String.concat ~sep:","
  in
  let deleted =
    List.map changes ~f:(fun { Crypto.Stats.deleted; _ } -> deleted)
    |> List.map ~f:Int.to_string
    |> String.concat ~sep:","
  in

  script (pcdata @@ Format.sprintf
            {|
$(document).ready(function() {
    var chart = c3.generate({
    data: {
        x: 'x',
        columns: [
            ['x', %s],
            ['added', %s],
            ['deleted', %s]
        ],
//type: 'bar'
    },
    axis: {
        x: {
            type: 'timeseries',
            tick: {
                format: '%%Y-%%m-%%d'
            }
        }
    }
    });
});
|}
            dates
            added
            deleted
         )

let commits_js crypto =
  let _commits = crypto.Crypto.Stats.commits_1y_per_week in space ()
  (* commits don't have a timestamp, so this is annoying *)
