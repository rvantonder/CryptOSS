open Core

module Stats : sig

  type week_t =
    { w : int
    ; a : int
    ; d : int
    ; c : int
    }
  [@@deriving sexp]

  type repo_contributor =
    { username : string
    ; total : int
    ; weeks : week_t list
    }
  [@@deriving sexp]

  type change_with_week =
    { added : int
    ; deleted : int
    ; week_timestamp : Time.t
    }
    [@@deriving sexp]

  type change = int * int [@@ deriving sexp]

  type t =
    { last_updated : Time.Span.t
    ; commits_24h : int
    ; commits_7d : int
    ; changes_24h : change
    ; changes_7d : change
    ; contributors_7d : string list
    (* A sorted list of the top 100 contributors *)
    ; total_contributors_up_to_100 : repo_contributor list
    (* one year's commits, tally per week (first is most recent ). participation
       in github stats *)
    ; commits_1y_per_week : int list
    ; changes_1y_per_week : change_with_week list
    ; stars : int
    ; forks : int
    ; watchers : int
    }
  [@@deriving sexp]

  (** empty stats *)
  val empty: t

  (** [merge forked stats1 stats2] merges two stats. If forked is
      specified, then the merge of [stats2] is according to the policy for
      merging forks.
  *)
  val merge : ?forked:bool -> t -> t -> t

  (** [diff today yesterday] *)
  val diff : t -> t -> t

  val to_string : t -> string

  val to_csv : t -> string
end

module Repo : sig

  type contributor_info =
    { username : string
    ; followers : int
    ; location : string option
    }
  [@@deriving sexp]

  type t =
    { name : string
    ; stats : Stats.t
    ; contributors : contributor_info list
    ; is_forked : bool
    ; language : string option
    }
  [@@deriving sexp]
end

type t =
  { name : string
  ; github : string
  ; repos : Repo.t list
  }
[@@deriving sexp]


val token : Github.Token.t ref

(** [ to_file dir filename ] writes a crypto to file in [ dir ] *)
val to_file : string -> string -> t -> unit

(** [ of_file path ] reads a crypto from a file at [ path ] *)
val of_file : string -> t option

(** [ create_and_dump blacklist name github dir ] creates a crypto object
    from an initial list of crypto. See hardcoded crypto and github in db.ml.
    [dir] specifies the directory to dump the info *)
val create_and_dump :
  ?blacklist:string
  -> name:string
  -> string
  -> t option
