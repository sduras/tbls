(** Column layout analysis.

    Computes display widths and resolves alignments.
    All array arguments must have the same length (the column count). *)

val analyze :
  header:string option array ->
  rows:string option array array ->
  inferred:Types.column_type array ->
  overrides:Types.alignment option array ->
  null_strs:string array ->
  Types.column_metadata array
(** Compute layout metadata for every column.

    [header.(i)] is the label of column [i], or [None] if the table has
    no header. Width is the maximum Unicode display width across the header
    cell and all data cells. [None] cells contribute [null_strs.(i)] width.

    Alignment: [overrides.(i)] takes precedence; otherwise [Integer] and
    [Float] map to [Right]; [Text] and [Missing] map to [Left].

    The returned array has the same length as [inferred]. *)
