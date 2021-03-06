open Tyxml.Html

module B = Bootstrap


let copyright =
  div ~a:[ a_class ["footer-copyright"] ] [
    div ~a:[ a_class ["container-fluid"] ] [
      pcdata "Copyright 2019 CryptoOSS"
    ]
  ]

let row_navigation =
  B.row [
    div ~a:[a_class [ "col-4"; ] ]  []
  ; div ~a:[ a_class [ "col-2"; ] ] [
      p [
        a ~a:[ a_href (Xml.uri_of_string (Site_prefix.prefix ^ "/")) ] [
          pcdata "HOME"
        ]
      ]
    ]
  ; div ~a:[ a_class [ "col-2" ] ] [
      p [
        a ~a:[ a_href (Xml.uri_of_string (Site_prefix.prefix ^ "/faq")) ] [
          pcdata "FAQ"
        ]
      ]
    ]
  ; div ~a:[ a_class [ "col-2" ] ] [
      p [
        a ~a:[ a_href (Xml.uri_of_string (Site_prefix.prefix ^ "/disclaimer")) ] [
          pcdata "DISCLAIMER"
        ]
      ]
    ]
  ]

let row_copyright =
  B.row [
    B.col_12 [
      Unsafe.data "<small>&copy; Copyright CryptoOSS 2019</small>"
    ]
  ]

let foot =
  B.container [
    row_navigation
  ; row_copyright
  ]
