(** UTF-8 display width computation.

    All functions operate on byte strings encoded as UTF-8.
    Invalid UTF-8 sequences are treated as replacement character U+FFFD
    with display width 1. *)

val display_width_of_uchar : Uchar.t -> int
(** Display width of a single Unicode character:
    0 for control characters and combining marks;
    2 for wide characters (full-width forms, emoji);
    1 otherwise. *)

val display_width : string -> int
(** Total display width of a UTF-8 string.
    Sum of {!display_width_of_uchar} over all codepoints. *)

val has_wide_chars : string -> bool
(** Returns [true] if [s] contains at least one character with display
    width 2 (wide characters such as emoji).
    Cyrillic, Latin, and other single-width multi-byte characters return
    [false]. *)

val map_segments :
  string ->
  narrow:(string -> string) ->
  wide:(string -> string) ->
  string
(** Segment [s] into maximal runs of wide and non-wide characters, apply
    [narrow] to each non-wide run and [wide] to each wide run, and
    concatenate the results.  Useful for applying ANSI color codes to text
    containing emoji without affecting the emoji's own rendering. *)
