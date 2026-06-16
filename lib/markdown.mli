(** GFM Markdown table renderer.

    Produces GitHub Flavored Markdown table syntax from a {!Doc.t}.
    No border configuration: Markdown table syntax is fixed.

    Tables with a header produce a valid GFM table including the delimiter
    row with alignment markers. Tables without a header produce rows only,
    which may not render as a table in all Markdown parsers. *)

val render : Doc.t -> string
(** Render a document as a GFM Markdown table.

    Pipe characters ([|]) in cell content are escaped to [\|].
    Alignment markers in the delimiter row are derived from the resolved
    column alignment stored in each {!Doc.Cell}:
    [Left] → [:---], [Right] → [---:], [Center] → [:---:]. *)
