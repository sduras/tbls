
let default_alignment = function
  | Types.Integer -> Types.Right
  | Types.Float   -> Types.Right
  | Types.Text    -> Types.Left
  | Types.Missing -> Types.Left

let width_of_cell null_str = function
  | None   -> Width.display_width null_str
  | Some s -> Width.display_width s

let column_width ~header_cell ~rows ~null_str ~col =
  let hw = width_of_cell null_str header_cell in
  let dw =
    Array.fold_left
      (fun acc row -> max acc (width_of_cell null_str row.(col)))
      0 rows
  in
  max hw dw

let analyze ~header ~rows ~inferred ~overrides ~null_strs =
  let n_cols = Array.length inferred in
  Array.init n_cols (fun col ->
    let header_cell = header.(col) in
    let width =
      column_width ~header_cell ~rows ~null_str:null_strs.(col) ~col
    in
    let alignment =
      match overrides.(col) with
      | Some a -> a
      | None   -> default_alignment inferred.(col)
    in
    { Types.label         = header_cell
    ; Types.inferred_type = inferred.(col)
    ; Types.layout        = { Types.width; Types.alignment }
    })
