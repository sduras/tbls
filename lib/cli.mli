(** CLI argument parsing and CSV/TSV parsing. *)

val exit_success     : int  (** 0: success. *)
val exit_bad_args    : int  (** 1: invalid arguments. *)
val exit_parse_error : int  (** 2: input parsing failure. *)
val exit_file_error  : int  (** 3: file access failure. *)
val exit_render_fail : int  (** 4: rendering failure. *)

type output_format = Fmt_text | Fmt_markdown | Fmt_html

type config = {
  format     : output_format;
  border     : Border.style;
  delimiter  : char;
  has_header : bool;
  null_str   : string;
  files      : string list;
}

val parse_line : char -> string -> string option list
(** Parse one CSV/TSV line.
    [parse_line delim s] splits [s] on [delim], returning one element per
    field. Empty fields become [None]. Handles RFC 4180 quoted fields.
    Multiline quoted fields are not supported. *)

val parse_channel : char -> in_channel -> string option list list
(** Read all non-empty rows from a channel.
    Strips trailing CR from CRLF line endings. *)

val render_format : config -> Render.format
(** Convert a config to a {!Render.format}, combining format and border. *)

val parse_args : unit -> config
(** Parse [Sys.argv] and return a validated config.
    Exits with {!exit_bad_args} on invalid arguments. *)
