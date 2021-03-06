(** Unix implementation *)

exception Unsupported_file_type

val header_of_file : string -> Pluk_tar.Header.t
(** [header_of_file path] creates header from file [path]. *)

module IO : sig
  type 'a t = 'a
  val bind : 'a -> ('a -> 'b) -> 'b
  val return : 'a -> 'a t

  type in_channel = Unix.file_descr
  type out_channel = Unix.file_descr
  val write : out_channel -> bytes -> int -> int -> int
  val read : in_channel -> bytes -> int -> int -> int
  val close_in : in_channel -> unit
  val close_out : out_channel -> unit
end

module Archive: Pluk_tar.Archive with type in_channel = IO.in_channel
                                      and type out_channel = IO.out_channel
                                      and type 'a t = 'a IO.t

val extract :
  Archive.in_channel ->
  (string -> Unix.file_perm -> string * Unix.file_perm) ->
  unit Archive.t
(** [extract in_channel proc] extracts TAR archive to filesystem calling
    [proc name_in_tar mode_in_tar] for each entry and saves file to
    name/permissions returned by [proc]. *)

val extract_from_file :
  ?mode_proc:(Unix.file_perm -> Unix.file_perm) ->
  string ->
  string ->
  unit Archive.t
(** [extract_from_file file target_directory] extracts TAR archive from [file]
    to [target_directory]. [mode_proc] can be used to rewrite file permissions. *)

val create_from_files :
  Archive.out_channel ->
  (Pluk_tar.Header.t -> Pluk_tar.Header.t) -> string Seq.t -> unit Archive.t
  (** [create_from_files out_channel proc files] creates TAR archive in
      [out_channel] from sequence [files] using [proc] to transform header
      entries. *)

val create_file_from_files :
  ?strip_prefix:string ->
  ?convert:(Pluk_tar.Header.t -> Pluk_tar.Header.t) ->
  string -> string Seq.t -> unit Archive.t
  (** [create_file_from_files tar files] creates TAR archive [tar] from
      sequence [files] stripping [strip_prefix] from their names and calling
      [convert] to transform header entries. *)
