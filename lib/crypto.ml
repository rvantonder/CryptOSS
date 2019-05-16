open Core
open Github
open Github_t
open Monad
open Sexplib
open Db

let debug = true

let token : Github.Token.t Pervasives.ref =
  ref (Github.Token.of_string "")

module Stats = struct

  type week_t =
    { w : int
    ; a : int
    ; d : int
    ; c : int
    }
  [@@deriving sexp]

  (* Contributor stats for *this* repo only.  It seems that 'total' here from
     "Stats.contributors.total" is the same as:
     Repo.contributors.contributions *)
  type repo_contributor =
    { username : string (* unique login username *)
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
    ; contributors_7d : string list (* author_login *)
    ; total_contributors_up_to_100 : repo_contributor list (* contributors *)

    ; commits_1y_per_week : int list (* one year's commits, tally per week (first is most recent ). participation in github stats *)

    ; changes_1y_per_week : change_with_week list

    ; stars : int
    ; forks : int
    ; watchers : int
    (* ; changes_24h : change FIXME can't comput this yet *)
    }
  [@@deriving sexp]

  let empty : t =
    { last_updated = Time.Span.create ~day:365 ()
    ; commits_24h = 0
    ; commits_7d = 0
    ; changes_24h = (0,0)
    ; changes_7d = (0,0)
    ; contributors_7d = []
    ; total_contributors_up_to_100 = []
    ; commits_1y_per_week = []
    ; changes_1y_per_week = []
    ; stars = 0
    ; forks = 0
    ; watchers = 0
    }

  (** Contributors. Just their user name, so we can find unique.
      Pulls out other stats but unused rn *)
  let get_total_repo_contributors_up_to_100 github repo : repo_contributor list =
    begin
      let open Lwt in
      Stats.contributors ~token:!token ~user:github ~repo ()
      |> Stream.to_list
      |> run
      >>= fun contributors_stats ->
      List.filter_map contributors_stats
        ~f:(fun { repo_contributor_stats_author
                ; repo_contributor_stats_total
                ; repo_contributor_stats_weeks
                } ->
             match repo_contributor_stats_author with
             | Some { user_login; _ } ->
               Some { username = user_login
                    ; total = repo_contributor_stats_total
                    ; weeks = List.map
                          ~f:(fun { repo_contribution_week_w
                                  ; repo_contribution_week_a
                                  ; repo_contribution_week_d
                                  ; repo_contribution_week_c
                                  } ->
                               { w = repo_contribution_week_w
                               ; a = repo_contribution_week_a
                               ; d = repo_contribution_week_d
                               ; c = repo_contribution_week_c
                               }
                             )
                          repo_contributor_stats_weeks
                    }
             | None -> None)
      |> return
    end
    |> fun cmd -> try Lwt_main.run cmd with exn ->
      Format.printf "EXN get_total_repo_contributors_up_to_100: %s@."
      @@ Exn.to_string exn;
      []

  (** It is possible to use commit_activity_stats too. But this is
      easier. Don't know how different they are *)
  let get_commits_1y_per_week github repo : int list =
    begin
      let open Lwt in
      Stats.participation ~token:!token ~user:github ~repo ()
      |> Stream.to_list
      |> run
      >>= fun value ->
      begin
        match value with
        | [] -> []
        | { all; _ } :: tl -> all
      end
      |> return
    end
    |> fun cmd -> try Lwt_main.run cmd with _ -> []

  (** code_frequency *)
  let get_changes_1y_per_week github repo : change_with_week list =
    begin
      let open Lwt in
      Stats.code_frequency ~token:!token ~user:github ~repo ()
      |> Stream.to_list
      |> run
      >>= fun (values: int list list) ->
      (* FIXME what is the order? *)
      begin
        List.filter_map
          values
          ~f:(function
              | [ timestamp; additions; deletions ]  ->
                { added = additions
                ; deleted = deletions
                ; week_timestamp =
                    Time.of_span_since_epoch
                      (Time.Span.of_sec
                         (Int.to_float timestamp))
                }
                |> fun good ->
                Option.some good
              | _ -> None)
      end
      |> return
    end
    |> fun cmd -> try Lwt_main.run cmd with exn ->
      let wtf = Exn.to_string exn in
      Format.printf "EXN %s@." wtf;
      []

  (** Gets commits since 7 days ago *)
  let get_commits github repo_name =
    begin
      let open Lwt in
      let since =
        let time = Time.(sub (now ()) (Time.Span.create ~day:7 ())) in
        Time.to_string_iso8601_basic ~zone:Time.Zone.utc time
      in
      Repo.commits ~token:!token ~since ~user:github ~repo:repo_name ()
      |> Stream.to_list
      |> run
      >>= fun commits -> return commits
    end
    |> fun cmd -> try Lwt_main.run cmd with _ -> []

  let get_commits_24h (commits : Github_t.commit list) : Github_t.commit list =
    List.filter
      commits
      ~f:(fun { commit_url
              ; commit_sha
              ; commit_git = { git_commit_url
                             ; git_commit_author =
                                 { info_date
                                 ; info_email
                                 ; info_name }
                             ; git_commit_message }
              ; commit_author
              ; commit_committer } ->
           let commit_time = Time.of_string info_date in
           let time_one_day_ago =
             Time.(sub (now ()) (Time.Span.create ~hr:24 ())) in
           (* is this commit after one day ago? *)
           commit_time > time_one_day_ago)

  let get_single_commits github repo_name commits : Github_t.single_commit list =
    let open Lwt in
    begin
      List.map
        commits
        ~f:(fun { commit_sha = sha; _ } ->
            let open Monad in
            let thread =
              begin
                run
                  (Repo.get_commit ~token:!token ~user:github ~repo:repo_name ~sha ()
                   >>~ fun single_commit -> return single_commit)
              end
            in
            try Lwt_main.run thread
            with _ -> failwith
              @@ Format.sprintf "inner fail for get_change. Error for:@.%s"
              @@ Format.sprintf "https://api.github.com/repos/%s/%s/commits/%s"
                github repo_name sha
          )
      |> return
    end
    |> fun cmd -> try
      Lwt_main.run cmd with _ ->
      failwith "Get commit failed"

  let get_changes_7d github repo_name (commits : Github_t.single_commit list) : (int * int) =
    List.map
      commits
      ~f:(fun
           {
             single_commit_git = { git_commit_author = { info_date; _ }; _ }
           ; single_commit_stats = { deletions; additions; total }
           } -> (additions, deletions))
    |> List.fold
      ~init:(0,0)
      ~f:(fun (x,y) (x',y') -> x+x', y+y')

  let get_changes_24h github repo_name commits : (int * int) =
    List.filter_map
      commits
      ~f:(fun
           {
             single_commit_git = { git_commit_author = { info_date; _ }; _ }
           ; single_commit_stats = { deletions; additions; total }
           } ->
           let commit_time = Time.of_string info_date in
           let time_one_day_ago =
             Time.(sub (now ()) (Time.Span.create ~hr:24 ())) in
           (* is this commit after one day ago? *)
           if commit_time > time_one_day_ago then Some (additions, deletions)
           else None)
    |> List.fold
      ~init:(0,0)
      ~f:(fun (x,y) (x',y') -> x+x', y+y')

  (** Unique contributors in the last 7 days *)
  let get_contributors_7d (commits_7d : Github_t.commit list) : string list =
    commits_7d
    |> List.filter_map ~f:(fun { commit_author; _ } ->
        match commit_author with
        | Some { user_login } -> Some user_login
        | None -> None)
    |> List.dedup_and_sort ~compare:String.compare

  let to_string
      { last_updated
      ; commits_24h
      ; commits_7d
      ; changes_24h = (changes_24h_add, changes_24h_delete)
      ; changes_7d = (changes_7d_add, changes_7d_delete)
      ; contributors_7d

      ; total_contributors_up_to_100
      ; commits_1y_per_week
      ; changes_1y_per_week
      ; stars
      ; forks
      ; watchers
      } =
    let time_delta = Time.Span.to_string_hum last_updated ~decimals:0 in
    let add, delete =
      (List.fold
         changes_1y_per_week
         ~init:(0,0)
         ~f:(fun (x,y) { added; deleted; _ } -> (x+added, y+deleted))
      )
    in
    Format.sprintf
      "Last Updated: %s@.\
       Commits 24h: %d@.\
       Commits 7d: %d@.\
       Changes 24h: %d, %d@.\
       Changes 7d: %d, %d@.\
       Contributors 7d: %d@.\
       Contributors (max 100): %d@.\
       Commits 1y: %d@.\
       Changes 1y: %d, %d@.\
       Stars: %d@.\
       Forks: %d@.\
       Watchers: %d@."
      time_delta
      commits_24h
      commits_7d
      changes_24h_add changes_24h_delete
      changes_7d_add changes_7d_delete
      (List.length contributors_7d)
      (List.length total_contributors_up_to_100)
      (List.fold commits_1y_per_week ~init:0 ~f:(+))
      add delete
      stars
      forks
      watchers

  let to_string
      { last_updated
      ; commits_24h
      ; commits_7d
      ; changes_24h = (changes_24h_add, changes_24h_delete)
      ; changes_7d = (changes_7d_add, changes_7d_delete)
      ; contributors_7d

      ; total_contributors_up_to_100
      ; commits_1y_per_week
      ; changes_1y_per_week
      ; stars
      ; forks
      ; watchers
      } =
    let time_delta = Time.Span.to_string_hum last_updated ~decimals:0 in
    let add, delete =
      (List.fold
         changes_1y_per_week
         ~init:(0,0)
         ~f:(fun (x,y) { added; deleted; _ } -> (x+added, y+deleted))
      )
    in
    Format.sprintf
      "Last Updated: %s@.\
       Commits 24h: %d@.\
       Commits 7d: %d@.\
       Changes 24h: %d, %d@.\
       Changes 7d: %d, %d@.\
       Contributors 7d: %d@.\
       Contributors (max 100): %d@.\
       Commits 1y: %d@.\
       Changes 1y: %d, %d@.\
       Stars: %d@.\
       Forks: %d@.\
       Watchers: %d@."
      time_delta
      commits_24h
      commits_7d
      changes_24h_add changes_24h_delete
      changes_7d_add changes_7d_delete
      (List.length contributors_7d)
      (List.length total_contributors_up_to_100)
      (List.fold commits_1y_per_week ~init:0 ~f:(+))
      add delete
      stars
      forks
      watchers

  let to_string
      { last_updated
      ; commits_24h
      ; commits_7d
      ; changes_24h = (changes_24h_add, changes_24h_delete)
      ; changes_7d = (changes_7d_add, changes_7d_delete)
      ; contributors_7d
      ; total_contributors_up_to_100
      ; commits_1y_per_week
      ; changes_1y_per_week
      ; stars
      ; forks
      ; watchers
      } =
    let time_delta = Time.Span.to_string_hum last_updated ~decimals:0 in
    let add, delete =
      (List.fold
         changes_1y_per_week
         ~init:(0,0)
         ~f:(fun (x,y) { added; deleted; _ } -> (x+added, y+deleted))
      )
    in
    Format.sprintf
      "Last Updated: %s@.\
       Commits 24h: %d@.\
       Commits 7d: %d@.\
       Changes 24h: %d, %d@.\
       Changes 7d: %d, %d@.\
       Contributors 7d: %d@.\
       Contributors (max 100): %d@.\
       Commits 1y: %d@.\
       Changes 1y: %d, %d@.\
       Stars: %d@.\
       Forks: %d@.\
       Watchers: %d@."
      time_delta
      commits_24h
      commits_7d
      changes_24h_add changes_24h_delete
      changes_7d_add changes_7d_delete
      (List.length contributors_7d)
      (List.length total_contributors_up_to_100)
      (List.fold commits_1y_per_week ~init:0 ~f:(+))
      add delete
      stars
      forks
      watchers


  let to_csv
      { last_updated
      ; commits_24h
      ; commits_7d
      ; changes_24h = (changes_24h_add, changes_24h_delete)
      ; changes_7d = (changes_7d_add, changes_7d_delete)
      ; contributors_7d
      ; total_contributors_up_to_100
      ; commits_1y_per_week
      ; changes_1y_per_week
      ; stars
      ; forks
      ; watchers
      } =
    let time_delta = Time.Span.to_string_hum last_updated ~decimals:0 in
    let add, delete =
      (List.fold
         changes_1y_per_week
         ~init:(0,0)
         ~f:(fun (x,y) { added; deleted; _ } -> (x+added, y+deleted))
      )
    in
    Format.sprintf
      "%s,\
       %d,\
       %d,\
       %d,%d,\
       %d,%d,\
       %d,\
       %d,\
       %d,\
       %d,%d,\
       %d,\
       %d,\
       %d"
      time_delta
      commits_24h
      commits_7d
      changes_24h_add changes_24h_delete
      changes_7d_add changes_7d_delete
      (List.length contributors_7d)
      (List.length total_contributors_up_to_100)
      (List.fold commits_1y_per_week ~init:0 ~f:(+))
      add (delete * -1) (* stupid GH gives delete as a negative number *)
      stars
      forks
      watchers


  let of_repo github repo_info =
    let repo_name = repo_info.repository_name in

    let commits_7d = get_commits github repo_name in
    let commits_24h = get_commits_24h commits_7d in

    (* we have to use the commits' sha1 from above to get the change info, c.f.,
       https://api.github.com/repos/bitcoin/bitcoin/commits?since=2018-01-03T01:24:10.897216Z
       which gets just the list of commits and sha1, almost everything except
       the changes... *)
    let single_commits_7d = get_single_commits github repo_name commits_7d in

    let changes_7d_additions, changes_7d_deletions =
      get_changes_7d github repo_name single_commits_7d in

    let changes_24h_additions, changes_24_deletions =
      get_changes_24h github repo_name single_commits_7d in

    (* updated is stale for stats. use commits if available *)
    let last_updated =
      match commits_7d with
      | [] ->
        Time.of_string repo_info.repository_updated_at
        |> fun time_updated ->
        Time.diff (Time.now ()) time_updated
      | hd :: _ ->
        let { commit_git = { git_commit_author = { info_date } } }  = hd in
        let commit_time =
          Time.of_string info_date
          |> Time.diff (Time.now ())
        in
        let stale =
          Time.of_string repo_info.repository_updated_at
          |> Time.diff (Time.now ())
        in
        Format.printf "commit time: %s ; stats time: %s@."
          (Time.Span.to_string commit_time) (Time.Span.to_string stale);
        if commit_time < stale then commit_time else stale
    in

    { last_updated
    ; commits_24h = List.length commits_24h
    ; commits_7d = List.length commits_7d
    ; changes_7d = (changes_7d_additions, changes_7d_deletions)
    ; changes_24h = (changes_24h_additions, changes_24_deletions)

    ; contributors_7d = get_contributors_7d commits_7d

    ; total_contributors_up_to_100 = get_total_repo_contributors_up_to_100 github repo_name
    ; commits_1y_per_week = get_commits_1y_per_week github repo_name

    ; changes_1y_per_week = get_changes_1y_per_week github repo_name
    ; stars = repo_info.repository_stargazers_count
    ; forks = repo_info.repository_forks_count
    ; watchers =
        match repo_info.repository_subscribers_count with
        | Some x -> x
        | None -> 0
    }

  let diff
      { commits_24h
      ; commits_7d
      ; contributors_7d
      ; total_contributors_up_to_100
      ; commits_1y_per_week
      ; stars
      ; forks
      ; watchers
      ; _
      }
      { commits_24h = commits_24h'
      ; commits_7d = commits_7d'
      ; contributors_7d = contributors_7d'
      ; total_contributors_up_to_100 = total_contributors_up_to_100'
      ; commits_1y_per_week = commits_1y_per_week'
      ; stars = stars'
      ; forks = forks'
      ; watchers = watchers'
      ; _
      } =
    { empty with
      (*
      commits_24h = commits_24h - commits_24h'
    ; commits_7d = commits_7d - commits_7d'
    ; contributors_7d = contributors_7d - contributors_7d'
    ; total_contributors_up_to_100 = total_contributors_up_to_100 - total_contributors_up_to_100'
    ; commits_1y_per_week = commits_1y_per_week - commits_1y_per_week'
*)
      stars = stars - stars'
    ; forks = forks - forks'
    ; watchers = watchers - watchers'
    ; }


  let merge ?(forked=false)
      { last_updated
      ; commits_24h
      ; commits_7d
      ; changes_24h
      ; changes_7d
      ; contributors_7d

      ; total_contributors_up_to_100
      ; commits_1y_per_week
      ; changes_1y_per_week
      ; stars
      ; forks
      ; watchers
      }

      { last_updated = last_updated'
      ; commits_24h = commits_24h'
      ; commits_7d = commits_7d'
      ; changes_24h = changes_24h'
      ; changes_7d = changes_7d'
      ; contributors_7d = contributors_7d'

      ; total_contributors_up_to_100 = total_contributors_up_to_100'
      ; commits_1y_per_week = commits_1y_per_week'
      ; changes_1y_per_week = changes_1y_per_week'
      ; stars = stars'
      ; forks = forks'
      ; watchers = watchers'
      } =

    (* Fork policy: include forks *)
    let last_updated_merged =
      match Time.Span.(last_updated < last_updated') with
      | true -> last_updated
      | false -> last_updated'
    in

    (* Fork policy: include forks *)
    let commits_24h_merged = commits_24h + commits_24h' in

    (* Fork policy: include forks *)
    let commits_7d_merged = commits_7d + commits_7d' in

    (* Fork policy: include forks *)
    let changes_24h_merged =
      (fst changes_24h + fst changes_24h')
    , (snd changes_24h + snd changes_24h')
    in

    (* Fork policy: include forks *)
    let changes_7d_merged =
      (fst changes_7d + fst changes_7d')
    , (snd changes_7d + snd changes_7d')
    in

    (* Fork policy: include forks *)
    let contributors_7d_merged =
      begin
        List.dedup_and_sort
          ~compare:String.compare
          (contributors_7d @ contributors_7d')
      end
    in

    (* Fork policy: exclude forks *)
    let total_contributors_up_to_100_merged =
      let total_contributors_up_to_100' =
        match forked with
        | true -> []
        | false -> total_contributors_up_to_100'
      in
      List.dedup_and_sort
        ~compare:
          (fun { username; _ } { username = username'; _ } ->
             String.compare username username')
        (total_contributors_up_to_100 @ total_contributors_up_to_100')
    in

    (* Fork policy: exclude forks *)
    let commits_1y_per_week_merged =
      let commits_1y_per_week' =
        match forked with
        | true -> []
        | false -> commits_1y_per_week'
      in
      begin
        match commits_1y_per_week, commits_1y_per_week' with
        | [],s when List.length s > 0 -> s
        | s,[] when List.length s > 0 -> s
        | commits_1y_per_week, commits_1y_per_week' ->
          List.map2
            commits_1y_per_week
            commits_1y_per_week'
            ~f:(+)
          |> function
          | Ok x -> x
          | Unequal_lengths ->
            Format.printf "List 1 length: %d@." @@ List.length commits_1y_per_week;
            Format.printf "List 2 length: %d@." @@ List.length commits_1y_per_week';
            failwith "Guaranteed 52 weeks in a year for both lists"
      end
    in

    (* Fork policy: exclude forks *)
    let changes_1y_per_week_merged =
      begin
        let changes_1y_per_week' =
          match forked with
          | true -> []
          | false -> changes_1y_per_week'
        in
        let table = Hashtbl.Poly.create () in
        List.iter
          (changes_1y_per_week @ changes_1y_per_week')
          ~f:(fun { added; deleted; week_timestamp } ->
              Hashtbl.update
                table
                week_timestamp
                ~f:(function
                    | None -> (added, deleted)
                    | Some (added', deleted') ->
                      added+added', deleted+deleted'));
        table
        |> Hashtbl.to_alist
        |> List.map ~f:(fun (week_timestamp, (added, deleted)) ->
            { added; deleted; week_timestamp })
      end
    in

    (* Fork policy: always included *)
    let stars_merged = stars + stars' in
    (* Fork policy: forks excluded *)
    let forks_merged =
      match forked with
      | true -> forks
      | false -> forks + forks'
    in
    (* Fork policy: always included *)
    let watchers_merged =
      watchers + watchers' in

    { last_updated = last_updated_merged
    ; commits_24h = commits_24h_merged
    ; commits_7d = commits_7d_merged
    ; changes_24h = changes_24h_merged
    ; changes_7d = changes_7d_merged
    ; contributors_7d = contributors_7d_merged
    ; total_contributors_up_to_100 = total_contributors_up_to_100_merged
    ; commits_1y_per_week = commits_1y_per_week_merged
    ; changes_1y_per_week = changes_1y_per_week_merged
    ; stars = stars_merged
    ; forks = forks_merged
    ; watchers = watchers_merged
    }
end

module Repo = struct

  (* Contributor info for someone who has committed to this repo (i.e., not
     repo-specific info but contributor specific info).  Repo-specific
     contributor contributions is in Stats. *)
  type contributor_info =
    { username : string (* org.login *)
    ; followers : int (* user_info.followers *)
    ; location : string option (* user_info.location *)
    (* last commit : when and to where *)
    }
  [@@deriving sexp]

  type t =
    { name : string
    ; stats : Stats.t
    (* if it can't be merged, don't put it in stats *)
    ; contributors : contributor_info list
    ; is_forked : bool
    ; language : string option
    }
  [@@deriving sexp]

  (** Disabled. This will potentially generate shit tons of requests without much
      useful info *)
  let contributor_info contributors =
    let enabled = false in
    match enabled with
    | true ->
      let to_contributor contributor =
        begin
          let open Lwt in
          let open Monad in
          run (User.info ~token:!token ~user:contributor ()
               >>~ fun user_info -> return
                 { username = contributor
                 ; followers = user_info.user_info_followers
                 ; location = user_info.user_info_location
                 }
              )
        end
        |> fun cmd -> try Lwt_main.run cmd with _ ->
          failwith "Contributor_info cannot fail!"
      in
      List.map ~f:to_contributor contributors
    | false -> []

  let with_stats github repo =
    Format.printf "Processing repo %s@." repo.repository_name;
    let stats = Stats.of_repo github repo in
    let contributor_usernames =
      List.map
        ~f:(fun { Stats.username; _ } -> username)
        stats.Stats.total_contributors_up_to_100
    in
    { name = repo.repository_name
    ; is_forked = repo.repository_fork
    ; language = repo.repository_language
    ; contributors = contributor_info contributor_usernames
    ; stats
    }
end

type t =
  { name : string
  ; github : string
  ; repos : Repo.t list
  }
[@@deriving sexp]

(** Fixed? User.repositories seems to not have accurate numbers for watchers.
    this will now return it by calling repo info...*)
let get_repos ?blacklist github : Github_t.repository Core.List.t=
  let open Lwt in
  begin
    Stream.to_list (User.repositories ~token:!token ~user:github ())
    |> run >>= fun repos ->
    List.map repos ~f:(fun repo ->
        let open Monad in
        let thread =
          begin
            run (Github.Repo.info
                   ~token:!token ~user:github ~repo:repo.repository_name ()
                 >>~ fun repo_info -> return repo_info)
          end in
        try Lwt_main.run thread
        with _ -> failwith "inner fail for get_repos"
      )
    |> return
  end
  |> fun cmd ->
  try Lwt_main.run cmd
  with
  | Github.Message (code, message) ->
    failwith (Format.sprintf "Error: %s@." message.message_message)
  | _ ->
    Format.printf "Other error@."; []

let get_repo ~github_user ~repo_name =
  let open Lwt in
  let open Monad in
  begin
    run (
      Github.Repo.info ~token:!token ~user:github_user ~repo:repo_name ()
      >>~ fun repo -> return [repo]
    )
  end
  |> fun cmd -> try Lwt_main.run cmd with | _ -> Format.printf "WTF SINGLE fail@."; []

let create_org ?blacklist ~name ~github () : t =
  { name
  ; github
  ; repos =
      get_repos ?blacklist github
      |> List.map ~f:(Repo.with_stats github)
  }

let create_single ~name ~github_user ~github_repo () : t =
  { name
  ; github = github_user
  ; repos =
      get_repo ~github_user ~repo_name:github_repo
      |> List.map ~f:(Repo.with_stats github_user)
  }

let to_file dir filename crypto =
  Out_channel.write_all (filename^".dat") ~data:(Sexp.to_string (sexp_of_t crypto))

let of_file path : t option =
  try
    In_channel.read_all path
    |> Sexp.of_string
    |> t_of_sexp
    |> Option.some
  with _ -> None

let create_and_dump ?blacklist ~name dir : t option =
  let filename_and_github =
    List.filter_map Db.cryptos ~f:(fun (display_name, filename, github) ->
        if name = display_name then
          match filename with
          | Some filename -> Some (filename, github)
          | None -> Some (display_name, github)
        else None)
  in
  match List.nth filename_and_github 0 with
  | Some (filename, github) ->
    begin
      let crypto =
        match github with
        | Org github ->
          Some (create_org ?blacklist ~name ~github ())
        | SingleRepo (github_user, github_repo) ->
          Some (create_single ~name ~github_user ~github_repo ())
        | Invalid _ -> None
      in
      match crypto with
      | Some crypto ->
        Unix.mkdir_p dir;
        to_file dir filename crypto;
        Some crypto
      | None -> None
    end
  | None -> None
