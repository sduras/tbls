(** Border glyph sets for the text renderer.

    Adding a new border style requires adding a variant to {!style} and a
    case to {!glyphs_of}. No other module changes. *)

type style = ASCII | Unicode | None
(** Border style selector.
    - [ASCII]: [+] corners, [-] horizontals, [|] verticals.
    - [Unicode]: box-drawing characters (U+2500 block).
    - [None]: all glyphs are empty strings; the renderer omits borders. *)

type glyphs = {
  top_left  : string;  (** Top-left corner. *)
  top_mid   : string;  (** Top junction between columns. *)
  top_right : string;  (** Top-right corner. *)
  top_h     : string;  (** Horizontal fill for the top rule. *)
  mid_left  : string;  (** Left junction on the header separator. *)
  mid_mid   : string;  (** Middle junction on the header separator. *)
  mid_right : string;  (** Right junction on the header separator. *)
  bot_left  : string;  (** Bottom-left corner. *)
  bot_mid   : string;  (** Bottom junction between columns. *)
  bot_right : string;  (** Bottom-right corner. *)
  bot_h     : string;  (** Horizontal fill for the bottom rule. *)
  v         : string;  (** Vertical separator between columns and at edges. *)
}
(** Complete glyph set for one border style. *)

val glyphs_of : style -> glyphs
(** Look up the glyph set for a style. Pure; no allocation beyond the record. *)
