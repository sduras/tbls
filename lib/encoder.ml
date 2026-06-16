
type 'a column = {
  label     : string;
  encode    : 'a -> string option;
  alignment : Types.alignment option;
  null_str  : string;
}

let string_column ?alignment ?(null_str = "") label f =
  { label; encode = (fun x -> Some (f x)); alignment; null_str }

let int_column ?alignment ?(null_str = "") label f =
  { label; encode = (fun x -> Some (string_of_int (f x))); alignment; null_str }

let float_column ?alignment ?(null_str = "") ?(precision = 6) label f =
  { label
  ; encode = (fun x -> Some (Printf.sprintf "%.*f" precision (f x)))
  ; alignment
  ; null_str
  }

let option_column ?alignment ?(null_str = "") label f =
  { label; encode = f; alignment; null_str }
