
let escape s =
  let b = Buffer.create (String.length s) in
  String.iter
    (fun c ->
       match c with
       | '<' -> Buffer.add_string b "&lt;"
       | '>' -> Buffer.add_string b "&gt;"
       | '&' -> Buffer.add_string b "&amp;"
       | '"' -> Buffer.add_string b "&quot;"
       | c   -> Buffer.add_char b c)
    s;
  Buffer.contents b

let alignment_attr = function
  | Types.Left   -> "left"
  | Types.Right  -> "right"
  | Types.Center -> "center"

let render_th (c : Doc.aligned_text) =
  "<th align=\""
  ^ alignment_attr c.Doc.alignment
  ^ "\">"
  ^ escape (String.trim c.Doc.text)
  ^ "</th>"

let render_td (c : Doc.aligned_text) =
  "<td align=\""
  ^ alignment_attr c.Doc.alignment
  ^ "\">"
  ^ escape (String.trim c.Doc.text)
  ^ "</td>"

let render_tr cell_fn cells =
  "<tr>" ^ String.concat "" (List.map cell_fn cells) ^ "</tr>"

let get_cells = function
  | Doc.Block items -> List.filter_map (function Doc.Cell c -> Some c | _ -> None) items
  | _               -> []

let render_rows cell_fn items =
  List.concat_map
    (function
      | Doc.Block row_items ->
        let cells =
          List.filter_map (function Doc.Cell c -> Some c | _ -> None) row_items
        in
        if cells <> [] then [ render_tr cell_fn cells ]
        else
          List.filter_map
            (function
              | Doc.Block _ as b ->
                let c = get_cells b in
                if c <> [] then Some (render_tr cell_fn c) else None
              | _ -> None)
            row_items
      | _ -> [])
    items

let render doc =
  match doc with
  | Doc.Empty  -> ""
  | Doc.Cell c -> escape (String.trim c.Doc.text)
  | Doc.Line   -> ""
  | Doc.Block items ->
    let rec split acc = function
      | []               -> (List.rev acc, false, [])
      | Doc.Line :: rest -> (List.rev acc, true, rest)
      | x :: rest        -> split (x :: acc) rest
    in
    let before, has_line, after = split [] items in
    let head =
      if not has_line then ""
      else
        "<thead>\n"
        ^ String.concat "\n" (render_rows render_th before)
        ^ "\n</thead>"
    in
    let body_rows =
      render_rows render_td (if has_line then after else before)
    in
    let body = "<tbody>\n" ^ String.concat "\n" body_rows ^ "\n</tbody>" in
    let inner = if head = "" then body else head ^ "\n" ^ body in
    "<table>\n" ^ inner ^ "\n</table>"
