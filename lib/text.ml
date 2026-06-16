
let fill_n fill n =
  if fill = "" || n = 0 then ""
  else
    let b = Buffer.create (n * String.length fill) in
    for _ = 1 to n do Buffer.add_string b fill done;
    Buffer.contents b

let ansi color esc s =
  if color && s <> "" then esc ^ s ^ "\x1b[0m" else s

let row_cells = function
  | Doc.Block items ->
    List.filter_map (function Doc.Cell c -> Some c | _ -> None) items
  | _ -> []

let cell_widths cells =
  List.map (fun (c : Doc.aligned_text) -> Width.display_width c.Doc.text) cells

let render ?(border = Border.ASCII) ?(color = false) doc =
  let g = Border.glyphs_of border in
  let dim s = ansi color "\x1b[2m" s in
  let header s =
    if not color then s
    else
      Width.map_segments s
        ~narrow:(fun chunk -> "\x1b[38;5;166m\x1b[1m" ^ chunk ^ "\x1b[0m")
        ~wide:Fun.id
  in
  match doc with
  | Doc.Empty -> ""
  | Doc.Cell c -> c.Doc.text
  | Doc.Line -> ""
  | Doc.Block items ->
    let widths =
      let rec find = function
        | [] -> []
        | (Doc.Block row_items) :: rest ->
          let cells =
            List.filter_map (function Doc.Cell c -> Some c | _ -> None) row_items
          in
          if cells <> [] then cell_widths cells else find rest
        | _ :: rest -> find rest
      in
      find items
    in
    let h_rule ~left ~mid ~right ~fill =
      if fill = "" then ""
      else
        let segs = List.map (fun w -> fill_n fill (w + 2)) widths in
        dim (left ^ String.concat mid segs ^ right)
    in
    let render_row ~is_hdr cells =
      let texts =
        List.map
          (fun (c : Doc.aligned_text) ->
             if is_hdr then header c.Doc.text else c.Doc.text)
          cells
      in
      let v = dim g.v in
      if g.v = "" then String.concat " " texts
      else v ^ " " ^ String.concat (" " ^ v ^ " ") texts ^ " " ^ v
    in
    let render_rows ~is_hdr items =
      List.concat_map
        (function
          | Doc.Block row_items ->
            let cells =
              List.filter_map (function Doc.Cell c -> Some c | _ -> None) row_items
            in
            if cells <> [] then [ render_row ~is_hdr cells ]
            else
              List.filter_map
                (function
                  | Doc.Block _ as b ->
                    let c = row_cells b in
                    if c <> [] then Some (render_row ~is_hdr c) else None
                  | _ -> None)
                row_items
          | _ -> [])
        items
    in
    let rec split acc = function
      | []               -> (List.rev acc, false, [])
      | Doc.Line :: rest -> (List.rev acc, true, rest)
      | x :: rest        -> split (x :: acc) rest
    in
    let before, has_line, after = split [] items in
    let top = h_rule ~left:g.top_left ~mid:g.top_mid ~right:g.top_right ~fill:g.top_h in
    let sep = h_rule ~left:g.mid_left ~mid:g.mid_mid ~right:g.mid_right ~fill:g.top_h in
    let bot = h_rule ~left:g.bot_left ~mid:g.bot_mid ~right:g.bot_right ~fill:g.bot_h in
    let header_lines = if has_line then render_rows ~is_hdr:true before else [] in
    let sep_lines    = if has_line && sep <> "" then [ sep ] else [] in
    let data_lines   = render_rows ~is_hdr:false (if has_line then after else items) in
    let lines =
      (if top = "" then [] else [ top ])
      @ header_lines
      @ sep_lines
      @ data_lines
      @ (if bot = "" then [] else [ bot ])
    in
    String.concat "\n" lines
