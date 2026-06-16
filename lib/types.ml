
type span = {
  columns : int;
  rows    : int;
}

type cell_content = Lines of string list

type cell = {
  content : cell_content;
  span    : span;
}

type column_type =
  | Integer
  | Float
  | Text
  | Missing

type alignment =
  | Left
  | Right
  | Center

type column_layout = {
  width     : int;
  alignment : alignment;
}

type column_metadata = {
  label         : string option;
  inferred_type : column_type;
  layout        : column_layout;
}

type rendered_cell = {
  text          : string;
  semantic_type : column_type;
}

type error =
  | Column_count_mismatch of { expected : int; got : int }
  | Empty_table
  | Span_not_supported


let pp_span fmt { columns; rows } =
  Format.fprintf fmt "{ columns = %d; rows = %d }" columns rows

let pp_cell_content fmt (Lines lines) =
  Format.fprintf fmt "Lines [%s]"
    (String.concat "; " (List.map (Printf.sprintf "%S") lines))

let pp_cell fmt { content; span } =
  Format.fprintf fmt "{ content = %a; span = %a }"
    pp_cell_content content
    pp_span span

let pp_column_type fmt = function
  | Integer -> Format.pp_print_string fmt "Integer"
  | Float   -> Format.pp_print_string fmt "Float"
  | Text    -> Format.pp_print_string fmt "Text"
  | Missing -> Format.pp_print_string fmt "Missing"

let pp_alignment fmt = function
  | Left   -> Format.pp_print_string fmt "Left"
  | Right  -> Format.pp_print_string fmt "Right"
  | Center -> Format.pp_print_string fmt "Center"

let pp_column_layout fmt { width; alignment } =
  Format.fprintf fmt "{ width = %d; alignment = %a }"
    width pp_alignment alignment

let pp_column_metadata fmt { label; inferred_type; layout } =
  Format.fprintf fmt "{ label = %s; inferred_type = %a; layout = %a }"
    (Option.fold ~none:"None" ~some:(fun s -> Printf.sprintf "Some %S" s) label)
    pp_column_type inferred_type
    pp_column_layout layout

let pp_rendered_cell fmt { text; semantic_type } =
  Format.fprintf fmt "{ text = %S; semantic_type = %a }"
    text pp_column_type semantic_type

let pp_error fmt = function
  | Column_count_mismatch { expected; got } ->
    Format.fprintf fmt "Column_count_mismatch { expected = %d; got = %d }"
      expected got
  | Empty_table        -> Format.pp_print_string fmt "Empty_table"
  | Span_not_supported -> Format.pp_print_string fmt "Span_not_supported"
