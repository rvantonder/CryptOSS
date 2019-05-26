open Tyxml.Html

module B = Bootstrap

let head () =
  head (title (pcdata "Disclaimer")) Css.all

let body () =
  body [
    B.container [
      B.row [
        B.col_12
          [ Header.title_h1
          ; br ()
          ]
      ]
    ; h2 ~a:[ a_class ["text-center" ] ] [ pcdata "Disclaimer" ]
    ; br ()
    ; p ~a:[a_class ["text-justify" ] ] [ pcdata
                                            "ALL INFORMATION CONTAINED ON THE \
                                             SITE IS FOR GENERAL INFORMATIONAL \
                                             USE ONLY. ALTHOUGH THE DATA FOUND \
                                             ON THIS SITE HAVE BEEN PRODUCED AND \
                                             PROCESSED FROM SOURCES BELIEVED TO \
                                             BE RELIABLE, NO WARRANTY EXPRESSED \
                                             OR IMPLIED IS MADE REGARDING \
                                             ACCURACY, ADEQUACY, COMPLETENESS, \
                                             LEGALITY, RELIABILITY OR USEFULNESS \
                                             OF ANY INFORMATION. THIS DISCLAIMER \
                                             APPLIES TO BOTH ISOLATED AND \
                                             AGGREGATE USES OF THE \
                                             INFORMATION. THE INFFORMATION IS \
                                             PROVIDED ON AN \"AS IS\" \
                                             BASIS. THIS SITE SHOULD NOT BE \
                                             RELIED UPON BY YOU IN MAKING ANY \
                                             INVESTMENT DECISION. BEFORE MAKING \
                                             ANY INVESTMENT CHOICE YOU SHOULD \
                                             ALWAYS CONSULT A FULLY QUALIFIED \
                                             FINANCIAL ADVISER. NEITHER \
                                             THIS SITE NOR ITS \
                                             CONTRIBUTORS SHALL BE HELD LIABLE \
                                             FOR ANY IMPROPER OR INCORRECT USE \
                                             OF THE INFORMATION DESCRIBED AND/OR \
                                             CONTAINED HEREIN AND ASSUMES NO \
                                             RESPONSIBILITY FOR ANYONE'S USE OF \
                                             THE INFORMATION. IN NO EVENT SHALL \
                                             THIS SITE OR ITS \
                                             CONTRIBUTORS BE LIABLE FOR ANY \
                                             DIRECT, INDIRECT, INCIDENTAL, \
                                             SPECIAL, EXEMPLARY, OR \
                                             CONSEQUENTIAL DAMAGES (INCLUDING, \
                                             BUT NOT LIMITED TO: PROCUREMENT OF \
                                             SUBSTITUTE GOODS OR SERVICES; LOSS \
                                             OF USE, DATA, OR PROFITS; OR \
                                             BUSINESS INTERRUPTION) HOWEVER \
                                             CAUSED AND ON ANY THEORY OF \
                                             LIABILITY, WHETHER IN CONTRACT, \
                                             STRICT LIABILITY, TORT (INCLUDING \
                                             NEGLIGENCE OR OTHERWISE), OR ANY \
                                             OTHER THEORY ARISING IN ANY WAY OUT \
                                             OF THE USE OF THIS SITE, EVEN IF \
                                             ADVISED OF THE POSSIBILITY OF SUCH \
                                             DAMAGE. THIS DISCLAIMER OF \
                                             LIABILITY APPLIES TO ANY DAMAGES OR \
                                             INJURY, WHETHER BASED ON ALLEGED \
                                             BREACH OF CONTRACT, TORTIOUS \
                                             BEHAVIOR, NEGLIGENCE OR ANY OTHER \
                                             CAUSE OF ACTION, INCLUDING BUT NOT \
                                             LIMITED TO DAMAGES OR INJURIES \
                                             CAUSED BY ANY FAILURE OF \
                                             PERFORMANCE, ERROR, OMISSION, \
                                             INTERRUPTION, DELETION, DEFECT, \
                                             DELAY IN OPERATION OR TRANSMISSION, \
                                             COMPUTER VIRUS, COMMUNICATION LINE \
                                             FAILURE, AND/OR THEFT, DESTRUCTION \
                                             OR UNAUTHORIZED ACCESS TO, \
                                             ALTERATION OF, OR USE OF ANY RECORD."
                                        ]
    ]
  ; hr ()
  ; Footer.foot
  ]

let page () =
  html
    (head ())
    (body ())
