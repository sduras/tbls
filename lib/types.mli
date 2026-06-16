(** Shared domain types for the tbls pipeline. *)

type span = {
  columns : int;
  rows    : int;
}
(** Cell span. Version 1 requires [columns = 1] and [rows = 1]. *)

type cell_content = Lines of string list
(** Cell content as a list of display lines. Single-line cells have one
    element. Embedded line breaks are normalised at construction. *)

type cell = {
  content : cell_content;
  span    : span;
}
(** A table cell. Contains no rendering or backend-specific information. *)

type column_type =
  | Integer  (** All non-null values parse as integers. *)
  | Float    (** All non-null values parse as floats. *)
  | Text     (** Mixed or non-numeric values. *)
  | Missing  (** All values are null or empty. *)
(** Inferred column type. Determined by [Infer]; independent of output
    backend. Null cells do not participate in type inference. *)

type alignment =
  | Left
  | Right
  | Center
(** Horizontal cell alignment. Fully resolved before document generation. *)

type column_layout = {
  width     : int;
  alignment : alignment;
}
(** Computed layout for one column. [width] is the Unicode display width of
    the widest cell in the column, including the header. *)

type column_metadata = {
  label         : string option;
  inferred_type : column_type;
  layout        : column_layout;
}
(** Per-column metadata produced by [Analyze]. One record per column. *)

type rendered_cell = {
  text          : string;
  semantic_type : column_type;
}
(** A cell after formatting. [text] is the display string; [semantic_type]
    drives alignment inference and may be discarded after layout. *)

type error =
  | Column_count_mismatch of { expected : int; got : int }
      (** A row has a different column count than expected. *)
  | Empty_table
      (** Input contains no data rows. *)
  | Span_not_supported
      (** A cell span larger than 1×1 was supplied; not supported in v1. *)
(** Expected failures across the pipeline. Always returned as [result]
    values; never raised as exceptions. *)

val pp_span            : Format.formatter -> span            -> unit
val pp_cell_content    : Format.formatter -> cell_content    -> unit
val pp_cell            : Format.formatter -> cell            -> unit
val pp_column_type     : Format.formatter -> column_type     -> unit
val pp_alignment       : Format.formatter -> alignment       -> unit
val pp_column_layout   : Format.formatter -> column_layout   -> unit
val pp_column_metadata : Format.formatter -> column_metadata -> unit
val pp_rendered_cell   : Format.formatter -> rendered_cell   -> unit
val pp_error           : Format.formatter -> error           -> unit
(** Pretty-printers for use with [Alcotest.testable]. *)
