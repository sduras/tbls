
type aligned_text = {
  text      : string;
  alignment : Types.alignment;
}

type t =
  | Empty
  | Cell  of aligned_text
  | Line
  | Block of t list

let pad_cell s w alignment =
  let cur = Width.display_width s in
  let pad = max 0 (w - cur) in
  match alignment with
  | Types.Left   -> s ^ String.make pad ' '
  | Types.Right  -> String.make pad ' ' ^ s
  | Types.Center ->
    let l = pad / 2 in
    String.make l ' ' ^ s ^ String.make (pad - l) ' '

let of_table at =
  let meta  = Analyze.metadata at in
  let arows = Analyze.rows at in
  let n_cols = Array.length meta in
  if n_cols = 0 then Empty
  else begin
    let make_row texts =
      Block
        (List.init n_cols (fun col ->
           let s   = texts.(col) in
           let w   = meta.(col).Types.layout.Types.width in
           let aln = meta.(col).Types.layout.Types.alignment in
           Cell { text = pad_cell s w aln; alignment = aln }))
    in
    let has_header = Option.is_some meta.(0).Types.label in
    let header_block =
      if not has_header then None
      else
        let labels =
          Array.map
            (fun m -> Option.value ~default:"" m.Types.label)
            meta
        in
        Some (make_row labels)
    in
    let data_rows =
      Array.to_list
        (Array.map
           (fun row ->
              make_row (Array.map (fun c -> c.Types.text) row))
           arows)
    in
    let data_block = Block data_rows in
    match header_block with
    | None   -> data_block
    | Some h -> Block [ h; Line; data_block ]
  end
