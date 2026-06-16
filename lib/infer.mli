(** Column type inference.

    Inference is deterministic and independent of output backend.
    Null cells (represented as empty strings) do not participate in type
    inference and do not downgrade a column's inferred type. *)

val infer_value : string -> Types.column_type
(** Classify a single cell value.

    - [""] → [Missing]
    - Valid integer with no leading zeros (optional [+]/[-] sign) → [Integer]
    - Finite float containing ['.'], ['e'], or ['E'] → [Float]
    - Anything else → [Text]

    ["NaN"], ["Inf"], and strings with leading zeros (["007"]) classify as
    [Text]. *)

val infer_column : string list -> Types.column_type
(** Infer the column type from a list of cell values.

    Empty strings are treated as null and skipped during inference.
    A column of all-empty strings returns [Missing].
    Any mix of types (integers with floats, numbers with text) returns [Text]. *)
