open Tyxml.Html

module B = Bootstrap

let head () =
  head (title (pcdata "FAQ")) Css.all

let body () =
  body [
    B.container [
      B.row [
        B.col_12
          [ Header.title_h1
          ; br ()
          ]
      ]
    ; h2 ~a:[ a_class ["text-center" ] ] [ pcdata "Frequently Asked Questions" ]
    ; br ()
    ; h3 [ pcdata "What is this site about?" ]
    ; p [ pcdata
            "This site reports open source development activity of popular \
             cryptocurrency projects on ";
          a ~a:[ a_href (Xml.uri_of_string "https://github.com") ] [pcdata "GitHub"]
        ; pcdata "."
        ]
    ; br ()

    ; h3 [ pcdata "What about cryptocurrencies that don't release open source software? " ]
    ; p [ pcdata
            "We recognize that open source software may not make sense for some \
             cryptocurrency models. Our aim is to make information available for \
             projects that do embrace open source software development."
        ]
    ; br ()

    ; h3 [ pcdata "What do the "
         ; i ~a:[ a_class [ "mega-octicon octicon-star" ] ] []
         ; pcdata " "
         ; i ~a:[ a_class [ "mega-octicon octicon-repo-forked" ] ] []
         ; pcdata " "
         ; i ~a:[ a_class [ "mega-octicon octicon-eye" ] ] []
         ; pcdata " symbols mean?"
         ]
    ; p [ pcdata
            "Stars ( "
        ; i ~a:[ a_class ["octicon octicon-star" ] ] []
        ; pcdata ") generally denote the "
        ; a ~a:[ a_href (Xml.uri_of_string "https://help.github.com/articles/about-stars/") ] [ pcdata "popularity of software repositories"]
        ; pcdata
            ". GitHub users star projects of personal interest. When \
             users star a repository, it can act as a personal \
             bookmark. A GitHub user may star any particular repository \
             only once. "
        ; br ()
        ; br ()
        ; pcdata "A fork ( "
        ; i ~a:[ a_class ["octicon octicon-repo-forked" ] ] []
        ; pcdata ") is a"
        ; a ~a:[ a_href (Xml.uri_of_string "https://help.github.com/articles/about-forks/") ] [ pcdata " copy of another repository of code" ]
        ; pcdata ", managed by a different user or organization than the \
                  original repository. Forks are typically created when a user \
                  or organization wishes to change an existing \
                  codebase. Sometimes the changes are incorporated (merged) back \
                  into the original repository. In other cases, the forked code \
                  becomes an entity of its own. An example of the last case is \
                  LiteCoin, which is a fork of Bitcoin. The number of forks can \
                  indicate how many developers interact with a repository's \
                  code, either for personal use or for extending the original \
                  codebase."
        ; br ()
        ; br ()
        ; pcdata "Subscribers ("
        ; i ~a:[ a_class ["octicon octicon-eye" ] ] []
        ; pcdata ") "
        ; a ~a:[ a_href (Xml.uri_of_string "https://help.github.com/articles/watching-and-unwatching-repositories/") ] [ pcdata " watch repositories " ]
        ; pcdata
            "to receive realtime notifications about new activity in a \
             codebase. Subscribers tend to be actively interested in new \
             developments in the codebase."
        ]
    ; br ()

    ; h3 [ pcdata "How do you calculate aggregate metrics? Aren't forks problematic?" ]
    ; p [ pcdata
            "The main page shows aggregate metrics over multiple repositories \
             managed by a single user or organization. The aggregates include: \
             (a) code additions and deletions, (b) commit activity, (c) \
             contributors, (d) stars, (e) forks, (f) subscribers, and (g) the \
             last updated time. For contributors (c), GitHub provides up to 100 \
             contributors per repository. When we see a repository with 100+ \
             developers, we sum 100 developers to the total count and add a '+' \
             to indicate 'possibly more'. Since a single contributor may \
             contribute to multiple repositories, it is important to remove \
             duplicate cases in our aggregate count (which we do). So, the \
             number of developers is conservatively reported as being at least \
             that amount of unique developers. For (g), we use the most recent \
             repository of all repositories for a particular organization, \
             including forks."
        ; br ()
        ; br ()
        ; pcdata
            "Inclusion and exclusion of forks in the aggregate data generally \
             depends on the time window that we aggregate over. More recent \
             aggregates include forks (i.e., the last 24 hours or 7 days), while \
             we exclude forks for older historic data. This is to ensure that, \
             in general, we do not include forked activity (e.g., a year's \
             Bitcoin activity) for recent cryptocurrencies forking Bitcoin. At \
             the same time, we want to include new, independent developments for \
             forked repositories of derivative cryptocurrencies. As another \
             example, it would be unfair to exclude code additions or stars that \
             are specific to LiteCoin's forked BitCoin repositories. While \
             imperfect, selective inclusion gives a more balanced view of \
             development activity on an individual codebase than either \
             including all or none of fork data in the aggregate."
        ; br ()
        ; pcdata
            "Including some metrics only for a recent time window makes sense \
             where the effect of including historic, unrelated activity is \
             minimized, while attributing fresh activity of a forked repository \
             to the appropriate project."
        ; br ()
        ; br ()
        ; b [pcdata "Commits (b): "]
        ; pcdata "By default, we "
        ; b [pcdata "include commits"]
        ; pcdata
            " to forks in the aggregate "
        ; b [ pcdata "only for the last 24 hours and 7 days," ]
        ; pcdata
            " and "
        ; b [ pcdata "exclude commits to forks within the last year" ]
        ; pcdata
            ". "
        ; br ()
        ; br ()
        ; b [pcdata "Contributors (c): "]
        ; pcdata "Similar to commits, we "
        ; b [pcdata "include contributor activity on forks only in the last 7 \
                     days" ]
        ; pcdata ", and "
        ; b [pcdata "exclude the all time count of developers" ]
        ; pcdata "."
        ; br ()
        ; br ()
        ; b [ pcdata "Code changes (a), stars (d), and subscribers (f) include \
                      forks. " ]
        ; pcdata "Code additions and deletions (a) include forks since these \
                  concern only the most recent 7 days of development; unless a \
                  repository fork is fresh (i.e., within a given week) it does \
                  not contribute to the aggregate counts. "
        ; pcdata "Stars (d) and subscriber counts (f) of forks are included, \
                  since these reset to 0 when a repository is forked. The \
                  current counts, as reported on GitHub, are unique to the owner."
        ; br ()
        ; br ()
        ; b [ pcdata "Forks of forks (e) are excluded:" ]
        ; pcdata " the number of forks of a fork is not reset to 0 when the \
                  repository is forked. Instead, the number of forks is carried \
                  over from the original forked project. Since GitHub does not \
                  expose the number of forks for a project outside the original \
                  one, we do not to include it in the aggregate."
        ; br ()
        ; br ()
        (*
        ; pcdata "Our intention is to be honest and fair about reflecting \
                  activity of open source contributions for a unique \
                  cryptocurrency. On a case-by-case basis, we may manually \
                  revise and adjust inclusion and exclusion of repositories \
                  depending on project maturity and development behavior. At the \
                  moment we have two case-specific rules: (1) exclude cloned and \
                  comitted 'nixpkgs' repositories (see a problematic case \
                 "
        ; a ~a:[ a_href (Xml.uri_of_string (Site_prefix.prefix ^ "/2018-10-13/currency/Santiment%20Network%20Token")) ] [ pcdata "here"]
        ; pcdata " where it doesn't make sense to include nixpkgs) and (2) \
                  include all metrics for the core (forked) repository for \
                  litecoin."
        ; br ()
        ; br()
        ; b [pcdata
               "Regardless of whether you agree with our aggregation choices, \
                raw data for all individual repositories can be judged in the \
                detailed view, without aggregation applied."
            ]
        *)
        ]
    ; br ()

    ; h3 [ pcdata "Do you include commit data, changes, etc., in feature branches?" ]
    ; p [ pcdata
            "Currently, we do not: we only consider the default branch of a \
             repository. It is currently prohibitively expensive to process all \
             branches of all repos, but this may change in the future."
        ]
    ; br ()

    ; h3 [ pcdata "I see some repositories are updated less than a day ago, but \
                   no commits or changes were made. What gives?" ]
    ; p [ pcdata
            "An update can things like a change in a repository's description or \
             wiki pages. We count such activities as updates."
        ]
    ; br ()




    ; h3 [ pcdata "Do these metrics reveal anything about software quality?" ]
    ; p [ pcdata
            "Many commits a good project does not (necessarily) make. Research \
             in evaluating software quality is a longstanding and open problem \
             ["
        ; a ~a:[ a_href (Xml.uri_of_string "http://ieeexplore.ieee.org/document/1703110/") ] [ pcdata "1"]
        ; pcdata ", "
        ; a ~a:[ a_href (Xml.uri_of_string "https://dl.acm.org/citation.cfm?id=280335") ] [ pcdata "2"]
        ; pcdata ", "
        ; a ~a:[ a_href (Xml.uri_of_string "http://ieeexplore.ieee.org/document/6227106/") ] [ pcdata "3"]
        ; pcdata ", "
        ; a ~a:[ a_href (Xml.uri_of_string "http://thesegalgroup.org/wp-content/uploads/2015/02/icse-camera.pdf") ] [ pcdata "4"]
        ; pcdata "]. Metrics such as lines of code and commit history may impact \
                  qualitative attributes such as software maintainability ["
        ; a ~a:[ a_href (Xml.uri_of_string "https://dl.acm.org/citation.cfm?id=620034") ] [ pcdata "5"]
        ; pcdata "], but do not speak directly to quality \
                  attributes. Quantitative measures (such as those on this site) \
                  also miss language-specific attributes (e.g., one line of \
                  Haskell may be more expressive than one line of \
                  Javascript). However, research shows that quantiative metrics \
                  can be useful as covariates for software quality predictors ["
        ; a ~a:[ a_href (Xml.uri_of_string "http://ieeexplore.ieee.org/abstract/document/637174/") ] [ pcdata "6"]
        ; pcdata "]. At the least, our metrics are a good measure of active \
                  developer activity for budding open source cryptocurrency \
                  developments."
        ]
    ; br ()

    ; h3 [ pcdata "Can't these code metrics be artifically influenced?" ]
    ; p [ pcdata
            "We use independent metrics to give a high level view of a project's \
             activity. This helps to avoid data skew and makes it harder to \
             influence the numbers artificially. For example, a single commit \
             could be broken up into 10 smaller commits, but the number of lines \
             would stay the same. Taking it up a level, using a variety of \
             metrics (including number of developers and stars) gives greater \
             confidence that the numbers reflect organic activity."
        ]
    ; br ()

    ; h3 [ pcdata "Some crypto currencies, like Bitcoin Cash, don't have a \
                   reference implementation. What do you do about that?" ]
    ; pcdata
        "It is challenging to collect distributed projects that implement a \
         protocol. For example, Bitcoin Cash has at least four ("
    ; a ~a:[ a_href (Xml.uri_of_string "https://github.com/Bitcoin-ABC/bitcoin-abc") ] [ pcdata "1"]
    ; pcdata ", "
    ; a ~a:[ a_href (Xml.uri_of_string "https://github.com/bitcoinclassic/bitcoinclassic") ] [ pcdata "2"]
    ; pcdata ", "
    ; a ~a:[ a_href (Xml.uri_of_string "https://github.com/bitcoinxt/bitcoinxt") ] [ pcdata "3"]
    ; pcdata ", "
    ; a ~a:[ a_href (Xml.uri_of_string "https://github.com/BitcoinUnlimited/BitcoinUnlimited") ] [ pcdata "4"]
    ; pcdata ") "
    ; pcdata "related client implementations. It also prompts challenges to include projects \
              relating to a protocol, but not strictly part of the reference \
              organization (e.g., should we include the MetaMask project for \
              Ethereum?) Due to these challenges, we (currently) only include \
              projects with a dedicated reference organization or user on \
              GitHub, and are investigating improvements."
    ; br ()
    ; br ()


    (*
    ; h3 [ pcdata "How often do you update the data?" ]
    ; p [ pcdata
            "Data is updated every 24 hours."
        ]
    ; br ()

    ; h3 [ pcdata "Who are you?" ]
    ; p [ pcdata
            "This site is developed by PhD Software Engineering students based \
             in the US. As such, we have no vested interest in promoting any \
             particular cryptocurrency, open source or otherwise, based on the \
             contents of this site."
        ]
    *)
    ; br ()
    ]
  ; hr ()
  ; Footer.foot
  ]

let page () =
  html
    (head ())
    (body ())
