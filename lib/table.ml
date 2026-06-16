
type t = {
  header    : string array option;
  rows      : string option array array;
  null_strs : string array;
  overrides : Types.alignment option array;
}

let header    t = t.header
let rows      t = t.rows
let null_strs t = t.null_strs
let overrides t = t.overrides

let ( let* ) = Result.bind

let validate_rows n_cols data =
  let rec go acc = function
    | []           -> Ok (List.rev acc)
    | row :: rest  ->
      let len = List.length row in
      if len <> n_cols
      then Error (Types.Column_count_mismatch { expected = n_cols; got = len })
      else go (Array.of_list row :: acc) rest
  in
  go [] data

let validate_header n_cols = function
  | None   -> Ok None
  | Some h ->
    let hlen = List.length h in
    if hlen <> n_cols
    then Error (Types.Column_count_mismatch { expected = n_cols; got = hlen })
    else Ok (Some (Array.of_list h))

let of_columns cols data =
  match cols with
  | [] -> Error Types.Empty_table
  | _  ->
    begin match data with
    | [] -> Error Types.Empty_table
    | _  ->
      let cols_arr  = Array.of_list cols in
      let header    = Array.map (fun c -> c.Encoder.label) cols_arr in
      let null_strs = Array.map (fun c -> c.Encoder.null_str) cols_arr in
      let overrides = Array.map (fun c -> c.Encoder.alignment) cols_arr in
      let rows      =
        Array.of_list
          (List.map
             (fun row -> Array.map (fun c -> c.Encoder.encode row) cols_arr)
             data)
      in
      Ok { header = Some header; rows; null_strs; overrides }
    end

let of_rows ?header data =
  match data with
  | [] -> Error Types.Empty_table
  | first_row :: _ ->
    let n_cols = List.length first_row in
    if n_cols = 0 then Error Types.Empty_table
    else
      let* rows_arrays = validate_rows n_cols data in
      let* h           = validate_header n_cols header in
      let null_strs    = Array.make n_cols "" in
      let overrides    = Array.make n_cols None in
      Ok { header = h; rows = Array.of_list rows_arrays; null_strs; overrides }
