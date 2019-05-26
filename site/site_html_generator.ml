open Core
open Cryptoss
open Tyxml.Html
open Command.Let_syntax

let inject_table_js n m =
  Format.sprintf
    {|<script>

      $(document).ready(function() {
      // when the table header is clicked for the first time
      // the default sort is descending, not ascending.
        $("#table").tablesorter({
      sortInitialOrder: "desc",
           // sort on the third column, order asc
           sortList: [[%d,%d]]
        });
      });
      </script>
    |} n m


let sorted_names data_directory : string list =
  List.map Db.cryptos ~f:(fun (name,_,_) -> name )
  |> Cryptos.sort (data_directory ^/ "ranks.json")

let detailed_view (data_directory : string) (date : string) (name : string) =
  Detailed_view.page name date data_directory

let index date data_directory =
  View_index.page (sorted_names data_directory |> Fn.flip List.take 10) date data_directory

let all date data_directory =
  View_all.page (sorted_names data_directory) date data_directory

let faq date () =
  Faq.page ()

let four_oh_four date () =
  Four_oh_four.page ()

let disclaimer date () =
  Disclaimer.page ()

(** (dir, page_name, page_html, default_table_sort) *)
let pages date data_directory =
  [ (".", "index.html", (index date data_directory), (0,0))
  ; (".", "all.html", (all date data_directory), (0,0))
    (*  ; (".", "faq.html", (faq date ()), (0,0))  *)
    (* ; (".", "404.html", (four_oh_four date ()), (0,0)) *)
    (* ; (".", "disclaimer.html", (disclaimer date ()), (0,0)) *)
  ]

let write output_dir name sort_by_column direction page =
  Unix.mkdir_p output_dir;
  let path = String.substr_replace_all ~pattern:"/" ~with_:"." name in
  let file_handle = Out_channel.create (output_dir ^/ path) in
  let fmt = Format.formatter_of_out_channel file_handle in
  pp () fmt page;
  Format.fprintf fmt "%s" (inject_table_js sort_by_column direction);
  Format.pp_flush_formatter fmt;
  Out_channel.close file_handle

let emit_page data_directory (output_dir, name, page, (sort_by_column,direction)) =
  write output_dir name sort_by_column direction page

let emit_currency data_directory date name =
  let output_dir = "currency" in
  let page = detailed_view data_directory date name in
  let sort_by_column, direction = 12, 0 in
  write output_dir name sort_by_column direction page

let emit_currencies currencies (date : string) (data_directory : string) =
  currencies |> List.iter ~f:(emit_currency data_directory date)

let main ~dir ?(cryptos=[]) () =
  Format.printf "Processing Repo Data...@.";
  let date = Filename.basename dir in
  let time_start = Time.now () in
  begin
    match cryptos with
    | [] ->
      List.iter ~f:(emit_page dir) (pages date dir);
    | l ->
      let currencies =
        sorted_names dir
        |> List.filter ~f:(List.mem ~equal:String.equal l)
      in
      emit_currencies currencies (date : string) (dir : string)
  end;
  Format.printf
    "Done: %s@."
    (Time.Span.to_string (Time.diff (Time.now ()) time_start))

let () =
  Command.basic
    ~summary:"Directory containing .dat files"
    [%map_open
      let dir = flag "dir" (required string) ~doc:"dir .dat Directory"
      and cryptos =
        flag "cryptos" (optional (Arg_type.comma_separated string))
          ~doc:"only these"
      in
      fun () -> main ~dir ?cryptos ()
    ]
  |> Command.run
