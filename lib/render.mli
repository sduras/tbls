(** Output format selector and render dispatcher.

    The compiler enforces exhaustiveness: adding a new {!format} variant
    requires a corresponding case in {!render}. *)

type format =
  | Text     of Border.style  (** Plain text with the given border style. *)
  | Markdown                  (** GFM Markdown table. *)
  | Html                      (** HTML table fragment. *)

val render : ?color:bool -> format -> Doc.t -> string
(** Dispatch to the appropriate backend.
    [color] is forwarded to {!Text.render}; ignored for Markdown and HTML. *)
