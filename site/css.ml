open Tyxml.Html

let (!) path = link ~rel:[`Stylesheet] ~href:path ()

let cdn =
  [ !"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
  ; !"https://use.fontawesome.com/releases/v5.0.4/css/all.css"
  ; !"https://cdnjs.cloudflare.com/ajax/libs/octicons/4.4.0/font/octicons.css"
  ] @ [
    Unsafe.data {|<meta name="google" value="notranslate">|}
  ] @ [
    Unsafe.data {|
    <head profile="http://www.w3.org/2005/10/profile">
    <link rel="icon"
        type="image/png"
        href="/static/favicon.png">
    |}
  ]



let analytics =
  {|
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-112826887-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-112826887-1');
</script>
|}

let all =
  [ Unsafe.data analytics ] @
  cdn @ [ !"static/css/custom.css" ]

let detailed =
  [ Unsafe.data analytics ] @
  cdn @
  [ !"../static/css/custom.css"
  ; !"https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.18/c3.min.css"]
