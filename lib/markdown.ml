
let escape_pipe s =
  let b = Buffer.create (String.length s) in
  String.iter
    (fun c -> if c = '|' then Buffer.add_string b "\\|" else Buffer.add_char b c)
    s;
  Buffer.contents b

let sep_marker w = function
  | Types.Left   -> ":" ^ String.make (max 3 (w - 1)) '-'
  | Types.Right  -> String.make (max 3 (w - 1)) '-' ^ ":"
  | Types.Center -> ":" ^ String.make (max 1 (w - 2)) '-' ^ ":"

let render_row cells =
  let texts = List.map (fun (c : Doc.aligned_text) -> escape_pipe c.Doc.text) cells in
  "| " ^ String.concat " | " texts ^ " |"

let render_sep cells =
  let markers =
    List.map
      (fun (c : Doc.aligned_text) ->
         sep_marker (Width.display_width c.Doc.text) c.Doc.alignment)
      cells
  in
  "| " ^ String.concat " | " markers ^ " |"

let get_cells = function
  | Doc.Block items -> List.filter_map (function Doc.Cell c -> Some c | _ -> None) items
  | _               -> []

let render_rows items =
  List.concat_map
    (function
      | Doc.Block row_items ->
        let cells =
          List.filter_map (function Doc.Cell c -> Some c | _ -> None) row_items
        in
        if cells <> [] then [ render_row cells ]
        else
          List.filter_map
            (function
              | Doc.Block _ as b ->
                let c = get_cells b in
                if c <> [] then Some (render_row c) else None
              | _ -> None)
            row_items
      | _ -> [])
    items

let render doc =
  match doc with
  | Doc.Empty  -> ""
  | Doc.Cell c -> escape_pipe c.Doc.text
  | Doc.Line   -> ""
  | Doc.Block items ->
    let rec split acc = function
      | []               -> (List.rev acc, false, [])
      | Doc.Line :: rest -> (List.rev acc, true, rest)
      | x :: rest        -> split (x :: acc) rest
    in
    let before, has_line, after = split [] items in
    if has_line then
      let header_cells = List.concat_map get_cells before in
      String.concat "\n"
        (render_rows before @ [ render_sep header_cells ] @ render_rows after)
    else
      String.concat "\n" (render_rows before)
