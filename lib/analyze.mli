(** Analysis pipeline: type inference, layout computation, and cell rendering.

    [Analyze.t] is the fully analyzed form of a table. It cannot be
    constructed except by {!analyze}. *)

type t
(** Abstract analyzed table. *)

val metadata : t -> Types.column_metadata array
(** Per-column metadata: labels, inferred types, and resolved layout. *)

val rows : t -> Types.rendered_cell array array
(** Rendered data rows. Each cell contains a display string and the
    column's semantic type. [None] cells have been replaced with the
    per-column null string. Outer array is rows; inner array is columns. *)

val analyze : Table.t -> (t, Types.error) result
(** Analyze a validated table.

    Runs type inference ({!Infer}) and layout analysis ({!Layout}) over
    all columns, then builds the rendered cell matrix.

    Currently always returns [Ok]. The [result] type is retained for
    future pipeline stages that may fail (e.g. span validation). *)
