open Tyxml.Html

module B = Bootstrap

let title =
  title (pcdata "CryptoCodeWatch")

let head =
  head title Css.all

let body () =
  body
    [
      B.container [
        B.row [
          B.col_12
            [ Header.title_h1
            ; br ()
            ; h2 ~a:[a_class ["text-center"]] [ pcdata "404: The Page You Are Looking For Does Not Exist" ]
            ]
        ]
      ; hr ()
      ; Footer.foot
      ]
    ]


let page () =
  html
    head
    (body ())
