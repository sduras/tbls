
let exit_success     = 0
let exit_bad_args    = 1
let exit_parse_error = 2
let exit_file_error  = 3
let exit_render_fail = 4

type output_format = Fmt_text | Fmt_markdown | Fmt_html

type config = {
  format     : output_format;
  border     : Border.style;
  delimiter  : char;
  has_header : bool;
  null_str   : string;
  files      : string list;
}

let parse_line delim line =
  let n = String.length line in
  let rec parse_quoted i buf =
    if i >= n then
      let s = Buffer.contents buf in
      (( if s = "" then None else Some s), n + 1)
    else if line.[i] = '"' then begin
      let i' = i + 1 in
      if i' < n && line.[i'] = '"' then begin
        Buffer.add_char buf '"';
        parse_quoted (i' + 1) buf
      end else begin
        let j = ref i' in
        while !j < n && line.[!j] <> delim do incr j done;
        let s    = Buffer.contents buf in
        let cell = if s = "" then None else Some s in
        if !j >= n then (cell, n + 1) else (cell, !j + 1)
      end
    end else begin
      Buffer.add_char buf line.[i];
      parse_quoted (i + 1) buf
    end
  in
  let rec go i =
    if i > n then []
    else if i = n then [ None ]
    else if line.[i] = '"' then begin
      let cell, next_i = parse_quoted (i + 1) (Buffer.create 16) in
      cell :: go next_i
    end else begin
      let j = ref i in
      while !j < n && line.[!j] <> delim do incr j done;
      let s    = String.sub line i (!j - i) in
      let cell = if s = "" then None else Some s in
      if !j >= n then [ cell ]
      else cell :: go (!j + 1)
    end
  in
  if n = 0 then []
  else go 0

let parse_channel delim ic =
  let rows = ref [] in
  (try
     while true do
       let raw  = input_line ic in
       let line =
         let len = String.length raw in
         if len > 0 && raw.[len - 1] = '\r'
         then String.sub raw 0 (len - 1)
         else raw
       in
       if String.length line > 0 then
         rows := parse_line delim line :: !rows
     done
   with End_of_file -> ());
  List.rev !rows

let render_format cfg =
  match cfg.format with
  | Fmt_text     -> Render.Text cfg.border
  | Fmt_markdown -> Render.Markdown
  | Fmt_html     -> Render.Html

let parse_args () =
  let format_s  = ref "text" in
  let border_s  = ref "ascii" in
  let delim_s   = ref "," in
  let no_header = ref false in
  let null_s    = ref "" in
  let files     = ref [] in
  let spec =
    [ "--format",
        Arg.Set_string format_s,
        "FORMAT  Output format: text, markdown, html (default: text)"
    ; "--border",
        Arg.Set_string border_s,
        "STYLE   Border style for text output: ascii, unicode, none (default: ascii)"
    ; "--delimiter",
        Arg.Set_string delim_s,
        "CHAR    Field delimiter character (default: ,)"
    ; "--no-header",
        Arg.Set no_header,
        " Treat the first row as data, not as a header"
    ; "--null",
        Arg.Set_string null_s,
        "STRING  Replacement for empty cells (default: empty string)"
    ]
  in
  let usage =
    "Usage: tbls [OPTION]... [FILE]...\nRender CSV or TSV data as a table."
  in
  Arg.parse spec (fun f -> files := !files @ [f]) usage;
  let format =
    match !format_s with
    | "text"     -> Fmt_text
    | "markdown" -> Fmt_markdown
    | "html"     -> Fmt_html
    | s ->
      Printf.eprintf "tbls: invalid format %S\n%!" s;
      exit exit_bad_args
  in
  let border =
    match !border_s with
    | "ascii"   -> Border.ASCII
    | "unicode" -> Border.Unicode
    | "none"    -> Border.None
    | s ->
      Printf.eprintf "tbls: invalid border style %S\n%!" s;
      exit exit_bad_args
  in
  let delimiter =
    match !delim_s with
    | ","   -> ','
    | "\t" | "tab" -> '\t'
    | s when String.length s = 1 -> s.[0]
    | s ->
      Printf.eprintf
        "tbls: invalid delimiter %S (must be a single character)\n%!" s;
      exit exit_bad_args
  in
  { format
  ; border
  ; delimiter
  ; has_header = not !no_header
  ; null_str   = !null_s
  ; files      = !files
  }
