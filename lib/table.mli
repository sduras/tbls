(** Validated raw table.

    A [Table.t] represents user input after column count validation but
    before type inference and layout analysis. The internal representation
    is abstract; construction goes through {!of_columns} or {!of_rows}. *)

type t
(** Abstract table type. *)

val header    : t -> string array option
(** Column labels, or [None] if the table was constructed without a header. *)

val rows      : t -> string option array array
(** Data rows. Each cell is [None] for a missing value or [Some s] for a
    formatted string. Outer array is rows; inner array is columns. *)

val null_strs : t -> string array
(** Per-column null replacement strings. Used for width computation and
    display of [None] cells. One entry per column. *)

val overrides : t -> Types.alignment option array
(** Per-column alignment overrides from column descriptors. [None] means
    use the type-inferred default. One entry per column. *)

val of_columns :
  'a Encoder.column list ->
  'a list ->
  (t, Types.error) result
(** Typed construction path.

    Applies each column's encoder to each row value. Null strings and
    alignment overrides are taken from the column descriptors.
    Returns {!Types.error.Empty_table} if [cols] or [data] is empty. *)

val of_rows :
  ?header:string list ->
  string option list list ->
  (t, Types.error) result
(** Raw construction path.

    Null strings default to [""] and alignment overrides to [None].
    Returns {!Types.error.Empty_table} if [data] is empty or rows have
    zero columns.
    Returns {!Types.error.Column_count_mismatch} for ragged input. *)
