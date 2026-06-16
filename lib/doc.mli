(** Backend-independent document model.

    A [Doc.t] is produced by {!of_table} from a fully analyzed table.
    All padding and alignment are pre-applied; backends emit structure
    and syntax without performing layout computation.

    The type is concrete so backends can pattern-match on it. *)

type aligned_text = {
  text      : string;
      (** Display string, already padded to the column width. *)
  alignment : Types.alignment;
      (** Resolved alignment of the column. Backends use this for
          format-specific alignment markers (e.g. Markdown [:---]). *)
}

type t =
  | Empty
      (** No content. Produced when the table has zero columns. *)
  | Cell  of aligned_text
      (** A single padded cell. *)
  | Line
      (** A horizontal separator, placed between the header and data rows. *)
  | Block of t list
      (** An ordered sequence of nodes. At the table level:
          [Block \[header_row; Line; Block data_rows\]] when a header is
          present, or [Block data_rows] otherwise. Each data row is itself
          a [Block] of [Cell] nodes. *)

val of_table : Analyze.t -> t
(** Convert an analyzed table to a document.

    All cell strings are padded to their column widths using Unicode display
    widths. Alignment is resolved and stored in each {!Cell} node. *)
