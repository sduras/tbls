(** Plain text table renderer.

    Converts a {!Doc.t} to a string with optional ASCII or Unicode borders.
    All layout decisions are already encoded in the document; this module
    only applies border glyphs and assembles lines. *)

val render : ?border:Border.style -> ?color:bool -> Doc.t -> string
(** Render a document as plain text.

    [border] defaults to {!Border.ASCII}.
    {!Border.None} renders without any border characters; cells are
    separated by a single space.

    When [color] is [true], header cells are rendered in dark orange bold
    and border glyphs are dimmed using ANSI escape sequences. Color output
    does not affect column widths or layout.

    Same input and same [color] always produce identical output. *)
