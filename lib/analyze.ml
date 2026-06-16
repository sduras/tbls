
type t = {
  metadata : Types.column_metadata array;
  rows     : Types.rendered_cell array array;
}

let metadata t = t.metadata
let rows t     = t.rows

let analyze tbl =
  let raw_rows  = Table.rows tbl in
  let null_strs = Table.null_strs tbl in
  let overrides = Table.overrides tbl in
  let n_cols = Array.length null_strs in
  let header_arr =
    match Table.header tbl with
    | None   -> Array.make n_cols None
    | Some h -> Array.map (fun s -> Some s) h
  in
  let raw_col_values =
    Array.init n_cols (fun col ->
      Array.to_list
        (Array.map
           (fun row ->
             match row.(col) with
             | None   -> ""
             | Some s -> s)
           raw_rows))
  in
  let inferred = Array.map Infer.infer_column raw_col_values in
  let metadata =
    Layout.analyze ~header:header_arr ~rows:raw_rows ~inferred ~overrides ~null_strs
  in
  let rendered_rows =
    Array.map
      (fun row ->
        Array.init n_cols (fun col ->
          let text =
            match row.(col) with
            | None   -> null_strs.(col)
            | Some s -> s
          in
          { Types.text; Types.semantic_type = inferred.(col) }))
      raw_rows
  in
  Ok { metadata; rows = rendered_rows }
