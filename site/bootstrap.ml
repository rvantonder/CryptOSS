open Tyxml.Html

let container content =
  div ~a:[ a_class
             [ "container"
             ]
         ] content


let row x =
  div ~a:[ a_class [ "row" ] ] x

let col_12 x =
  div ~a:[ a_class [ "col" ] ] x


let a_data_toggle s =
  Unsafe.string_attrib "data-toggle" s

let a_data_placement s =
  Unsafe.string_attrib "data-placement" s

let a_data_title s =
  Unsafe.string_attrib "title" s
