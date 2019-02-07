(** get [ dir ] pulls all data and dumps the files in the given dir. Then
    returns cryptos *)
val get : string -> Crypto.t list

(** load [ dir ] loads all the data files and returns the cryptos *)
val load : string -> Crypto.t list

(** sort [ ranking cryptos ] expects a path to a json file containing the ranks
    as per CMC *)
val sort : string -> string list -> string list
