open Tyxml.Html

module B = Bootstrap


let copyright =
  div ~a:[ a_class ["footer-copyright"] ] [
    div ~a:[ a_class ["container-fluid"] ] [
      pcdata "Copyright 2018 CryptoCodeWatch"
    ]
  ]

let row_navigation =
  B.row [
      div ~a:[ a_class [ "col-2"; ] ] [
        p [
          a ~a:[ a_href (Xml.uri_of_string "/") ] [
            pcdata "HOME"
          ]
        ]
      ]
    ; div ~a:[ a_class [ "col-2" ] ] [
        p [
          a ~a:[ a_href (Xml.uri_of_string "/faq") ] [
            pcdata "FAQ"
          ]
        ]
      ]
    ; div ~a:[ a_class [ "col-2" ] ] [
        p [
          a ~a:[ a_href (Xml.uri_of_string "/disclaimer") ] [
            pcdata "DISCLAIMER"
          ]
        ]
      ]

    ; div ~a:[ a_class [ "col-2"; "text-right" ] ] [
        p [
          a ~a:[ a_href (Xml.uri_of_string "mailto:cryptocodewatch@gmail.com") ] [
            pcdata "CONTACT"
          ]
        ]
      ]
    ; div ~a:[ a_class [ "col-4"; "text-right" ] ] [
        Unsafe.data
          {|<a href="https://twitter.com/CryptoCodeWatch?ref_src=twsrc%5Etfw" class="twitter-follow-button" data-size="large" data-show-count="false">Follow @CryptoCodeWatch</a><script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>|}
    ]
  ]

let row_copyright =
  B.row [
    B.col_12 [
      Unsafe.data "<small>&copy; Copyright CryptoCodeWatch 2018</small>"
    ]
  ]

let foot =
  B.container [
    row_navigation
  ; row_copyright
  ]
