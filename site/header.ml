open Tyxml.Html

module B = Bootstrap

let title_h1 =
  div [
    br ()
  ; h1 ~a:[ a_class [ "text-center" ] ] [
      i ~a:[ a_class [ "fa fa-angle-right"; "bigass" ] ] []
    ; space ()
    ; pcdata "Crypto Code Watch"
    ]
  ]
