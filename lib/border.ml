
type style = ASCII | Unicode | None

type glyphs = {
  top_left  : string;
  top_mid   : string;
  top_right : string;
  top_h     : string;
  mid_left  : string;
  mid_mid   : string;
  mid_right : string;
  bot_left  : string;
  bot_mid   : string;
  bot_right : string;
  bot_h     : string;
  v         : string;
}

let glyphs_of = function
  | ASCII ->
    { top_left  = "+"
    ; top_mid   = "+"
    ; top_right = "+"
    ; top_h     = "-"
    ; mid_left  = "+"
    ; mid_mid   = "+"
    ; mid_right = "+"
    ; bot_left  = "+"
    ; bot_mid   = "+"
    ; bot_right = "+"
    ; bot_h     = "-"
    ; v         = "|"
    }
  | Unicode ->
    { top_left  = "\xe2\x94\x8c"  (* ┌ *)
    ; top_mid   = "\xe2\x94\xac"  (* ┬ *)
    ; top_right = "\xe2\x94\x90"  (* ┐ *)
    ; top_h     = "\xe2\x94\x80"  (* ─ *)
    ; mid_left  = "\xe2\x94\x9c"  (* ├ *)
    ; mid_mid   = "\xe2\x94\xbc"  (* ┼ *)
    ; mid_right = "\xe2\x94\xa4"  (* ┤ *)
    ; bot_left  = "\xe2\x94\x94"  (* └ *)
    ; bot_mid   = "\xe2\x94\xb4"  (* ┴ *)
    ; bot_right = "\xe2\x94\x98"  (* ┘ *)
    ; bot_h     = "\xe2\x94\x80"  (* ─ *)
    ; v         = "\xe2\x94\x82"  (* │ *)
    }
  | None ->
    { top_left  = ""
    ; top_mid   = ""
    ; top_right = ""
    ; top_h     = ""
    ; mid_left  = ""
    ; mid_mid   = ""
    ; mid_right = ""
    ; bot_left  = ""
    ; bot_mid   = ""
    ; bot_right = ""
    ; bot_h     = ""
    ; v         = ""
    }
