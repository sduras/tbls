(** HTML table renderer.

    Produces an HTML table fragment from a {!Doc.t}. No raw user
    strings reach the output without passing through {!escape}. *)

val escape : string -> string
(** Escape HTML special characters to named entities.
    Handles: less-than, greater-than, ampersand, double-quote. *)

val render : Doc.t -> string
(** Render a document as an HTML table fragment.

    Tables with a header produce thead and tbody sections.
    Tables without a header produce tbody only.
    Column alignment is rendered as an align attribute on th and td elements. *)
