open Core
open Format
open Lwt
open Cohttp_lwt_unix
open Opium.Std

let map_ = ref Hmap.empty

let index_key = Hmap.Key.create ()

let index =
  let open Option in
  get "/:date" begin fun request ->
    "date" |> param request |> fun date ->
    match Hmap.find index_key !map_ with
    | Some page ->
      `String page |> respond'
    | None ->
      In_channel.read_all (date ^/ "index.html") |> fun page ->
      `String page |> respond'
  end

let detailed =
  let open Option in
  get "/:date/currency/:currency" begin fun request ->
    "date" |> param request |> fun date ->
    "currency" |> param request |> fun name ->
    In_channel.read_all (date ^/ "currency" ^/ name) |> fun page ->
    `String page |> respond'
  end

let faq =
  let open Option in
  get "/:date/faq" begin fun request ->
    "date" |> param request |> fun date ->
    In_channel.read_all (date ^/ "faq.html") |> fun page ->
    `String page |> respond'
  end

let disclaimer =
  let open Option in
  get "/:date/disclaimer" begin fun request ->
    "date" |> param request |> fun date ->
    In_channel.read_all (date ^/ "disclaimer.html") |> fun page ->
    `String page |> respond'
  end

let all =
  let open Option in
  get "/:date/all" begin fun request ->
    "date" |> param request |> fun date ->
    In_channel.read_all (date ^/ "all.html") |> fun page ->
    `String page |> respond'
  end

let four_oh_four =
  let open Option in
  get "/:date/404" begin fun request ->
    "date" |> param request |> fun date ->
    In_channel.read_all (date ^/ "404.html") |> fun page ->
    `String page |> respond'
  end

let _ =
  (* https://github.com/mirage/ocaml-cohttp/issues/511 *)
  Lwt.async_exception_hook := ignore;
  App.empty
  |> index
  |> detailed
  |> all
  |> faq
  |> disclaimer
  |> four_oh_four
  (*|> App.ssl ~cert:"certs/cert.pem" ~key:"certs/decryptedkey.pem"*)
  |> middleware @@ Middleware.static ~local_path:"./static/css" ~uri_prefix:"/static/css"
  |> middleware @@ Middleware.static ~local_path:"./static/js" ~uri_prefix:"/static/js"
  |> middleware @@ Middleware.static ~local_path:"./static" ~uri_prefix:"/static"
  |> App.run_command
