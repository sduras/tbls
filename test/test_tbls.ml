
open Tbls

let width_tests =
  let check label expected s =
    Alcotest.test_case label `Quick (fun () ->
      Alcotest.(check int) label expected (Width.display_width s))
  in
  [
    check "empty string" 0 "";
    check "single ASCII letter" 1 "a";
    check "ASCII word" 3 "abc";
    check "printable ASCII range" 1 " ";
    check "printable ASCII tilde" 1 "~";
    check "NUL" 0 "\x00";
    check "TAB" 0 "\x09";
    check "newline" 0 "\x0A";
    check "DEL" 0 "\x7F";
    check "C1 control" 0 "\xC2\x80";
    check "clipboard emoji" 2 "\xF0\x9F\x93\x8B";
    check "bar chart emoji" 2 "\xF0\x9F\x93\x8A";
    check "house emoji" 2 "\xF0\x9F\x8F\xA0";
    check "birthday cake emoji" 2 "\xF0\x9F\x8E\x82";
    check "check mark U+2705" 2 "\xE2\x9C\x85";
    check "hourglass U+23F3" 2 "\xE2\x8F\xB3";
    check "three emoji" 6 "\xF0\x9F\x93\x8B\xF0\x9F\x93\x8A\xF0\x9F\x8F\xA0";
    check "ok + clipboard" 4 "ok\xF0\x9F\x93\x8B";
    check "e + combining acute" 1 "e\xCC\x81";
    check "combining only" 0 "\xCC\x81";
    check "variation selector U+FE0F" 0 "\xEF\xB8\x8F";
    check "invalid lead byte 0xFF" 1 "\xFF";
    check "invalid lead byte 0xFE" 1 "\xFE";
    check "truncated 2-byte" 1 "\xC2";
  ]


let alignment_opt = Alcotest.(option (testable Types.pp_alignment ( = )))

let encoder_tests =
  [
    Alcotest.test_case "string_column label" `Quick (fun () ->
      let open Encoder in
      let col = string_column "Name" Fun.id in
      Alcotest.(check string) "label" "Name" col.label);

    Alcotest.test_case "string_column encode" `Quick (fun () ->
      let open Encoder in
      let col = string_column "Name" Fun.id in
      Alcotest.(check (option string)) "some" (Some "hello") (col.encode "hello"));

    Alcotest.test_case "int_column encode" `Quick (fun () ->
      let open Encoder in
      let col = int_column "Age" Fun.id in
      Alcotest.(check (option string)) "int" (Some "42") (col.encode 42));

    Alcotest.test_case "float_column default precision" `Quick (fun () ->
      let open Encoder in
      let col = float_column "V" Fun.id in
      Alcotest.(check (option string)) "float6" (Some "3.140000") (col.encode 3.14));

    Alcotest.test_case "float_column precision 2" `Quick (fun () ->
      let open Encoder in
      let col = float_column "V" ~precision:2 Fun.id in
      Alcotest.(check (option string)) "float2" (Some "3.14") (col.encode 3.14));

    Alcotest.test_case "float_column precision 0" `Quick (fun () ->
      let open Encoder in
      let col = float_column "V" ~precision:0 Fun.id in
      Alcotest.(check (option string)) "float0" (Some "3") (col.encode 3.14));

    Alcotest.test_case "option_column some" `Quick (fun () ->
      let open Encoder in
      let col = option_column "X" Fun.id in
      Alcotest.(check (option string)) "some" (Some "val") (col.encode (Some "val")));

    Alcotest.test_case "option_column none" `Quick (fun () ->
      let open Encoder in
      let col = option_column "X" Fun.id in
      Alcotest.(check (option string)) "none" None (col.encode None));

    Alcotest.test_case "null_str stored" `Quick (fun () ->
      let open Encoder in
      let col = string_column "X" ~null_str:"N/A" Fun.id in
      Alcotest.(check string) "null_str" "N/A" col.null_str);

    Alcotest.test_case "alignment override stored" `Quick (fun () ->
      let col = Encoder.int_column "N" ~alignment:Types.Right Fun.id in
      Alcotest.(check alignment_opt) "alignment" (Some Types.Right) col.Encoder.alignment);

    Alcotest.test_case "alignment default none" `Quick (fun () ->
      let col = Encoder.string_column "X" Fun.id in
      Alcotest.(check alignment_opt) "alignment" None col.Encoder.alignment);
  ]


let error_t = Alcotest.testable Types.pp_error ( = )

let people_cols =
  [ Encoder.string_column "Name" fst; Encoder.int_column "Age" snd ]

let people_data = [ ("Alice", 30); ("Bob", 25) ]

let table_tests =
  [
    Alcotest.test_case "of_columns header" `Quick (fun () ->
      match Table.of_columns people_cols people_data with
      | Error _ -> Alcotest.fail "expected Ok"
      | Ok t ->
        Alcotest.(check (option (array string)))
          "header" (Some [| "Name"; "Age" |]) (Table.header t));

    Alcotest.test_case "of_columns row count" `Quick (fun () ->
      match Table.of_columns people_cols people_data with
      | Error _ -> Alcotest.fail "expected Ok"
      | Ok t -> Alcotest.(check int) "rows" 2 (Array.length (Table.rows t)));

    Alcotest.test_case "of_columns cell encoding" `Quick (fun () ->
      match Table.of_columns people_cols people_data with
      | Error _ -> Alcotest.fail "expected Ok"
      | Ok t ->
        let rows = Table.rows t in
        Alcotest.(check (option string)) "name" (Some "Alice") rows.(0).(0);
        Alcotest.(check (option string)) "age" (Some "30") rows.(0).(1));

    Alcotest.test_case "of_columns null_strs propagated" `Quick (fun () ->
      let cols =
        [ Encoder.string_column "X" ~null_str:"N/A" fst
        ; Encoder.int_column    "Y" snd ]
      in
      match Table.of_columns cols [ ("a", 1) ] with
      | Error _ -> Alcotest.fail "expected Ok"
      | Ok t ->
        Alcotest.(check string) "null_str 0" "N/A" (Table.null_strs t).(0);
        Alcotest.(check string) "null_str 1" ""    (Table.null_strs t).(1));

    Alcotest.test_case "of_columns overrides propagated" `Quick (fun () ->
      let cols =
        [ Encoder.int_column    "X" ~alignment:Types.Left fst
        ; Encoder.string_column "Y" snd ]
      in
      match Table.of_columns cols [ (1, "a") ] with
      | Error _ -> Alcotest.fail "expected Ok"
      | Ok t ->
        Alcotest.(check alignment_opt) "override 0" (Some Types.Left) (Table.overrides t).(0);
        Alcotest.(check alignment_opt) "override 1" None              (Table.overrides t).(1));

    Alcotest.test_case "of_columns empty cols" `Quick (fun () ->
      match Table.of_columns [] [()] with
      | Ok _ -> Alcotest.fail "expected Error"
      | Error e -> Alcotest.(check error_t) "err" Types.Empty_table e);

    Alcotest.test_case "of_columns empty rows" `Quick (fun () ->
      match Table.of_columns people_cols [] with
      | Ok _ -> Alcotest.fail "expected Error"
      | Error e -> Alcotest.(check error_t) "err" Types.Empty_table e);

    Alcotest.test_case "of_rows without header" `Quick (fun () ->
      let data = [ [ Some "Alice"; Some "30" ]; [ Some "Bob"; Some "25" ] ] in
      match Table.of_rows data with
      | Error _ -> Alcotest.fail "expected Ok"
      | Ok t ->
        Alcotest.(check (option (array string))) "header" None (Table.header t);
        Alcotest.(check int) "rows" 2 (Array.length (Table.rows t)));

    Alcotest.test_case "of_rows with header" `Quick (fun () ->
      let data = [ [ Some "Alice"; Some "30" ] ] in
      match Table.of_rows ~header:[ "Name"; "Age" ] data with
      | Error _ -> Alcotest.fail "expected Ok"
      | Ok t ->
        Alcotest.(check (option (array string)))
          "header" (Some [| "Name"; "Age" |]) (Table.header t));

    Alcotest.test_case "of_rows null cell" `Quick (fun () ->
      let data = [ [ None; Some "30" ] ] in
      match Table.of_rows data with
      | Error _ -> Alcotest.fail "expected Ok"
      | Ok t -> Alcotest.(check (option string)) "null" None (Table.rows t).(0).(0));

    Alcotest.test_case "of_rows empty" `Quick (fun () ->
      match Table.of_rows [] with
      | Ok _ -> Alcotest.fail "expected Error"
      | Error e -> Alcotest.(check error_t) "err" Types.Empty_table e);

    Alcotest.test_case "of_rows zero columns" `Quick (fun () ->
      match Table.of_rows [ [] ] with
      | Ok _ -> Alcotest.fail "expected Error"
      | Error e -> Alcotest.(check error_t) "err" Types.Empty_table e);

    Alcotest.test_case "of_rows ragged" `Quick (fun () ->
      let data = [ [ Some "a"; Some "b" ]; [ Some "c" ] ] in
      match Table.of_rows data with
      | Ok _ -> Alcotest.fail "expected Error"
      | Error e ->
        Alcotest.(check error_t) "err"
          (Types.Column_count_mismatch { expected = 2; got = 1 }) e);

    Alcotest.test_case "of_rows header mismatch" `Quick (fun () ->
      let data = [ [ Some "a"; Some "b" ] ] in
      match Table.of_rows ~header:[ "X"; "Y"; "Z" ] data with
      | Ok _ -> Alcotest.fail "expected Error"
      | Error e ->
        Alcotest.(check error_t) "err"
          (Types.Column_count_mismatch { expected = 2; got = 3 }) e);
  ]


let ct = Alcotest.(testable Types.pp_column_type ( = ))

let infer_tests =
  let v label expected s =
    Alcotest.test_case label `Quick (fun () ->
      Alcotest.(check ct) label expected (Infer.infer_value s))
  in
  let c label expected values =
    Alcotest.test_case label `Quick (fun () ->
      Alcotest.(check ct) label expected (Infer.infer_column values))
  in
  [
    v "empty → Missing" Types.Missing "";
    v "42 → Integer" Types.Integer "42";
    v "0 → Integer" Types.Integer "0";
    v "-7 → Integer" Types.Integer "-7";
    v "+3 → Integer" Types.Integer "+3";
    v "3.14 → Float" Types.Float "3.14";
    v "1e10 → Float" Types.Float "1e10";
    v "1E10 → Float" Types.Float "1E10";
    v ".5 → Float" Types.Float ".5";
    v "3. → Float" Types.Float "3.";
    v "abc → Text" Types.Text "abc";
    v "007 → Text" Types.Text "007";
    v "NaN → Text" Types.Text "NaN";
    v "Inf → Text" Types.Text "Inf";
    v "+ → Text" Types.Text "+";
    v "- → Text" Types.Text "-";
    c "all integers" Types.Integer [ "1"; "2"; "3" ];
    c "null does not downgrade" Types.Integer [ "1"; ""; "3" ];
    c "all null → Missing" Types.Missing [ ""; ""; "" ];
    c "all floats" Types.Float [ "3.14"; "2.71" ];
    c "int + text → Text" Types.Text [ "1"; "abc" ];
    c "int + float → Text" Types.Text [ "1"; "2.5" ];
    c "float + text → Text" Types.Text [ "3.14"; "abc" ];
    c "single integer" Types.Integer [ "42" ];
    c "single float" Types.Float [ "1.5" ];
    c "single text" Types.Text [ "hello" ];
    c "leading zeros → Text" Types.Text [ "007"; "008" ];
  ]


let aln_t = Alcotest.(testable Types.pp_alignment ( = ))

let layout_tests =
  let meta1 ?(header_cell = None) ?(null_str = "") ?(override = None)
      inferred rows =
    let header    = [| header_cell |] in
    let inferred  = [| inferred |] in
    let overrides = [| override |] in
    let null_strs = [| null_str |] in
    let m = Layout.analyze ~header ~rows ~inferred ~overrides ~null_strs in
    m.(0)
  in
  [
    Alcotest.test_case "integer → right-aligned" `Quick (fun () ->
      let rows = [| [| Some "1" |]; [| Some "42" |]; [| Some "123" |] |] in
      let m = meta1 Types.Integer rows in
      Alcotest.(check aln_t) "alignment" Types.Right m.Types.layout.Types.alignment;
      Alcotest.(check int)   "width"     3           m.Types.layout.Types.width);

    Alcotest.test_case "float → right-aligned" `Quick (fun () ->
      let rows = [| [| Some "3.14" |] |] in
      let m = meta1 Types.Float rows in
      Alcotest.(check aln_t) "alignment" Types.Right m.Types.layout.Types.alignment);

    Alcotest.test_case "text → left-aligned" `Quick (fun () ->
      let rows = [| [| Some "Alice" |]; [| Some "Bob" |] |] in
      let m = meta1 ~header_cell:(Some "Name") Types.Text rows in
      Alcotest.(check aln_t) "alignment" Types.Left  m.Types.layout.Types.alignment;
      Alcotest.(check int)   "width"     5           m.Types.layout.Types.width);

    Alcotest.test_case "alignment override" `Quick (fun () ->
      let rows = [| [| Some "hello" |] |] in
      let m = meta1 ~override:(Some Types.Right) Types.Text rows in
      Alcotest.(check aln_t) "alignment" Types.Right m.Types.layout.Types.alignment);

    Alcotest.test_case "header wider than data" `Quick (fun () ->
      let rows = [| [| Some "x" |] |] in
      let m = meta1 ~header_cell:(Some "Long Header") Types.Text rows in
      Alcotest.(check int) "width" 11 m.Types.layout.Types.width);

    Alcotest.test_case "emoji header width" `Quick (fun () ->
      let rows = [| [| Some "x" |] |] in
      let m = meta1 ~header_cell:(Some "\xF0\x9F\x93\x8B") Types.Text rows in
      Alcotest.(check int) "width" 2 m.Types.layout.Types.width);

    Alcotest.test_case "all-null column" `Quick (fun () ->
      let rows = [| [| None |]; [| None |] |] in
      let m = meta1 ~null_str:"N/A" Types.Missing rows in
      Alcotest.(check ct)    "type"      Types.Missing m.Types.inferred_type;
      Alcotest.(check aln_t) "alignment" Types.Left    m.Types.layout.Types.alignment;
      Alcotest.(check int)   "width"     3             m.Types.layout.Types.width);

    Alcotest.test_case "label stored" `Quick (fun () ->
      let rows = [| [| Some "x" |] |] in
      let m = meta1 ~header_cell:(Some "Col") Types.Text rows in
      Alcotest.(check (option string)) "label" (Some "Col") m.Types.label);

    Alcotest.test_case "output length = column count" `Quick (fun () ->
      let n = 4 in
      let header    = Array.make n None in
      let rows      = [| Array.make n (Some "x") |] in
      let inferred  = Array.make n Types.Text in
      let overrides = Array.make n None in
      let null_strs = Array.make n "" in
      let meta = Layout.analyze ~header ~rows ~inferred ~overrides ~null_strs in
      Alcotest.(check int) "length" n (Array.length meta));
  ]


let analyze_tests =
  [
    Alcotest.test_case "typed path column count" `Quick (fun () ->
      match Table.of_columns people_cols people_data with
      | Error _ -> Alcotest.fail "table"
      | Ok t ->
        match Analyze.analyze t with
        | Error _ -> Alcotest.fail "analyze"
        | Ok at ->
          Alcotest.(check int) "cols" 2 (Array.length (Analyze.metadata at)));

    Alcotest.test_case "typed path Name column" `Quick (fun () ->
      match Table.of_columns people_cols people_data with
      | Error _ -> Alcotest.fail "table"
      | Ok t ->
        match Analyze.analyze t with
        | Error _ -> Alcotest.fail "analyze"
        | Ok at ->
          let m = (Analyze.metadata at).(0) in
          Alcotest.(check (option string)) "label" (Some "Name") m.Types.label;
          Alcotest.(check ct)    "type"  Types.Text  m.Types.inferred_type;
          Alcotest.(check aln_t) "align" Types.Left  m.Types.layout.Types.alignment;
          Alcotest.(check int)   "width" 5           m.Types.layout.Types.width);

    Alcotest.test_case "typed path Age column" `Quick (fun () ->
      match Table.of_columns people_cols people_data with
      | Error _ -> Alcotest.fail "table"
      | Ok t ->
        match Analyze.analyze t with
        | Error _ -> Alcotest.fail "analyze"
        | Ok at ->
          let m = (Analyze.metadata at).(1) in
          Alcotest.(check (option string)) "label" (Some "Age")  m.Types.label;
          Alcotest.(check ct)    "type"  Types.Integer m.Types.inferred_type;
          Alcotest.(check aln_t) "align" Types.Right   m.Types.layout.Types.alignment);

    Alcotest.test_case "typed path rendered rows" `Quick (fun () ->
      match Table.of_columns people_cols people_data with
      | Error _ -> Alcotest.fail "table"
      | Ok t ->
        match Analyze.analyze t with
        | Error _ -> Alcotest.fail "analyze"
        | Ok at ->
          let rows = Analyze.rows at in
          Alcotest.(check int)    "row count"  2       (Array.length rows);
          Alcotest.(check string) "cell 0,0"   "Alice" rows.(0).(0).Types.text;
          Alcotest.(check string) "cell 0,1"   "30"    rows.(0).(1).Types.text;
          Alcotest.(check string) "cell 1,0"   "Bob"   rows.(1).(0).Types.text);

    Alcotest.test_case "null cell → null_str in rendered rows" `Quick (fun () ->
      let cols = [ Encoder.option_column "X" ~null_str:"—" Fun.id ] in
      let data = [ Some "hello"; None ] in
      match Table.of_columns cols data with
      | Error _ -> Alcotest.fail "table"
      | Ok t ->
        match Analyze.analyze t with
        | Error _ -> Alcotest.fail "analyze"
        | Ok at ->
          let rows = Analyze.rows at in
          Alcotest.(check string) "present" "hello" rows.(0).(0).Types.text;
          Alcotest.(check string) "null"    "—"     rows.(1).(0).Types.text);

    Alcotest.test_case "alignment override flows through" `Quick (fun () ->
      let cols = [ Encoder.int_column "N" ~alignment:Types.Left Fun.id ] in
      match Table.of_columns cols [ 42 ] with
      | Error _ -> Alcotest.fail "table"
      | Ok t ->
        match Analyze.analyze t with
        | Error _ -> Alcotest.fail "analyze"
        | Ok at ->
          let m = (Analyze.metadata at).(0) in
          Alcotest.(check aln_t) "align" Types.Left m.Types.layout.Types.alignment);

    Alcotest.test_case "raw path no header" `Quick (fun () ->
      let data = [ [ Some "3.14"; Some "1" ]; [ Some "2.71"; Some "2" ] ] in
      match Table.of_rows data with
      | Error _ -> Alcotest.fail "table"
      | Ok t ->
        match Analyze.analyze t with
        | Error _ -> Alcotest.fail "analyze"
        | Ok at ->
          let m0 = (Analyze.metadata at).(0) in
          let m1 = (Analyze.metadata at).(1) in
          Alcotest.(check (option string)) "label 0" None m0.Types.label;
          Alcotest.(check ct) "type 0" Types.Float   m0.Types.inferred_type;
          Alcotest.(check ct) "type 1" Types.Integer m1.Types.inferred_type);
  ]


let make_doc cols data =
  match Table.of_columns cols data with
  | Error _ -> Alcotest.fail "table construction failed"
  | Ok t ->
    match Analyze.analyze t with
    | Error _ -> Alcotest.fail "analysis failed"
    | Ok at   -> Doc.of_table at

let doc_tests =
  [
    Alcotest.test_case "doc structure with header" `Quick (fun () ->
      let doc = make_doc people_cols people_data in
      match doc with
      | Doc.Block [ Doc.Block _header; Doc.Line; Doc.Block _rows ] -> ()
      | _ -> Alcotest.fail "unexpected top-level structure");

    Alcotest.test_case "header cells padded" `Quick (fun () ->
      let doc = make_doc people_cols people_data in
      match doc with
      | Doc.Block (Doc.Block header_cells :: _) ->
        (match header_cells with
         | [ Doc.Cell c0; Doc.Cell c1 ] ->
           Alcotest.(check string) "Name padded" "Name " c0.Doc.text;
           Alcotest.(check string) "Age padded"  "Age"   c1.Doc.text
         | _ -> Alcotest.fail "unexpected header cell count")
      | _ -> Alcotest.fail "no header block");

    Alcotest.test_case "data cells padded" `Quick (fun () ->
      let doc = make_doc people_cols people_data in
      match doc with
      | Doc.Block [ _; Doc.Line; Doc.Block (Doc.Block row0 :: _) ] ->
        (match row0 with
         | [ Doc.Cell c0; Doc.Cell c1 ] ->
           Alcotest.(check string) "Alice"  "Alice" c0.Doc.text;
           Alcotest.(check string) " 30"    " 30"   c1.Doc.text
         | _ -> Alcotest.fail "unexpected row cell count")
      | _ -> Alcotest.fail "unexpected structure");

    Alcotest.test_case "text cell left-padded" `Quick (fun () ->
      let doc = make_doc people_cols people_data in
      match doc with
      | Doc.Block [ _; Doc.Line; Doc.Block [ _; Doc.Block row1 ] ] ->
        (match row1 with
         | Doc.Cell c0 :: _ ->
           Alcotest.(check string) "Bob padded" "Bob  " c0.Doc.text
         | _ -> Alcotest.fail "no cell")
      | _ -> Alcotest.fail "unexpected structure");

    Alcotest.test_case "no header doc structure" `Quick (fun () ->
      let data = [ [ Some "1"; Some "2" ] ] in
      match Table.of_rows data with
      | Error _ -> Alcotest.fail "table"
      | Ok t ->
        match Analyze.analyze t with
        | Error _ -> Alcotest.fail "analyze"
        | Ok at ->
          (match Doc.of_table at with
           | Doc.Block [ Doc.Block _ ] -> ()
           | _ -> Alcotest.fail "unexpected no-header structure"));

    Alcotest.test_case "emoji column display width used" `Quick (fun () ->
      let cols = [ Encoder.string_column "\xF0\x9F\x93\x8B" Fun.id ] in
      let doc  = make_doc cols [ "x" ] in
      match doc with
      | Doc.Block (Doc.Block [ Doc.Cell hdr ] :: Doc.Line :: _) ->
        Alcotest.(check string) "header width" "\xF0\x9F\x93\x8B" hdr.Doc.text;
        Alcotest.(check int) "header display width" 2 (Width.display_width hdr.Doc.text)
      | _ -> Alcotest.fail "unexpected structure");

    Alcotest.test_case "alignment stored in cell" `Quick (fun () ->
      let doc = make_doc people_cols people_data in
      match doc with
      | Doc.Block (Doc.Block (Doc.Cell c0 :: Doc.Cell c1 :: _) :: _) ->
        Alcotest.(check aln_t) "Name alignment" Types.Left  c0.Doc.alignment;
        Alcotest.(check aln_t) "Age alignment"  Types.Right c1.Doc.alignment
      | _ -> Alcotest.fail "unexpected structure");
  ]


let border_tests =
  [
    Alcotest.test_case "ASCII corners and separators" `Quick (fun () ->
      let open Border in
      let g = glyphs_of ASCII in
      Alcotest.(check string) "top_left"  "+" g.top_left;
      Alcotest.(check string) "top_mid"   "+" g.top_mid;
      Alcotest.(check string) "top_right" "+" g.top_right;
      Alcotest.(check string) "top_h"     "-" g.top_h;
      Alcotest.(check string) "v"         "|" g.v);

    Alcotest.test_case "Unicode corners and separators" `Quick (fun () ->
      let open Border in
      let g = glyphs_of Unicode in
      Alcotest.(check string) "top_left"  "\xe2\x94\x8c" g.top_left;
      Alcotest.(check string) "top_mid"   "\xe2\x94\xac" g.top_mid;
      Alcotest.(check string) "top_right" "\xe2\x94\x90" g.top_right;
      Alcotest.(check string) "top_h"     "\xe2\x94\x80" g.top_h;
      Alcotest.(check string) "v"         "\xe2\x94\x82" g.v);

    Alcotest.test_case "None all empty" `Quick (fun () ->
      let open Border in
      let g = glyphs_of None in
      List.iter (fun (label, s) -> Alcotest.(check string) label "" s)
        [ "top_left",  g.top_left
        ; "top_mid",   g.top_mid
        ; "top_right", g.top_right
        ; "top_h",     g.top_h
        ; "mid_left",  g.mid_left
        ; "mid_mid",   g.mid_mid
        ; "mid_right", g.mid_right
        ; "bot_left",  g.bot_left
        ; "bot_mid",   g.bot_mid
        ; "bot_right", g.bot_right
        ; "bot_h",     g.bot_h
        ; "v",         g.v
        ]);

    Alcotest.test_case "styles are distinct" `Quick (fun () ->
      let open Border in
      let a = glyphs_of ASCII   in
      let u = glyphs_of Unicode in
      let n = glyphs_of None    in
      if a.top_left = u.top_left then Alcotest.fail "ASCII = Unicode";
      if a.top_left = n.top_left then Alcotest.fail "ASCII = None";
      if u.top_left = n.top_left then Alcotest.fail "Unicode = None");
  ]


let make_text cols data border =
  match Table.of_columns cols data with
  | Error _ -> Alcotest.fail "table"
  | Ok t ->
    match Analyze.analyze t with
    | Error _ -> Alcotest.fail "analyze"
    | Ok at   -> Text.render ~border (Doc.of_table at)

let text_tests =
  [
    Alcotest.test_case "ASCII with header" `Quick (fun () ->
      let expected =
        "+-------+-----+\n\
         | Name  | Age |\n\
         +-------+-----+\n\
         | Alice |  30 |\n\
         | Bob   |  25 |\n\
         +-------+-----+"
      in
      Alcotest.(check string) "ascii" expected
        (make_text people_cols people_data Border.ASCII));

    Alcotest.test_case "Unicode with header" `Quick (fun () ->
      let expected =
        "┌───────┬─────┐\n\
         │ Name  │ Age │\n\
         ├───────┼─────┤\n\
         │ Alice │  30 │\n\
         │ Bob   │  25 │\n\
         └───────┴─────┘"
      in
      Alcotest.(check string) "unicode" expected
        (make_text people_cols people_data Border.Unicode));

    Alcotest.test_case "no border" `Quick (fun () ->
      let expected = "Name  Age\nAlice  30\nBob    25" in
      Alcotest.(check string) "none" expected
        (make_text people_cols people_data Border.None));

    Alcotest.test_case "no header" `Quick (fun () ->
      let data = [ [ Some "Alice"; Some "30" ]; [ Some "Bob"; Some "25" ] ] in
      let expected =
        "+-------+----+\n\
         | Alice | 30 |\n\
         | Bob   | 25 |\n\
         +-------+----+"
      in
      (match Table.of_rows data with
       | Error _ -> Alcotest.fail "table"
       | Ok t ->
         match Analyze.analyze t with
         | Error _ -> Alcotest.fail "analyze"
         | Ok at ->
           Alcotest.(check string) "no header" expected
             (Text.render ~border:Border.ASCII (Doc.of_table at))));

    Alcotest.test_case "empty doc" `Quick (fun () ->
      Alcotest.(check string) "empty" "" (Text.render Doc.Empty));

    Alcotest.test_case "deterministic" `Quick (fun () ->
      let r1 = make_text people_cols people_data Border.ASCII in
      let r2 = make_text people_cols people_data Border.ASCII in
      Alcotest.(check string) "same" r1 r2);
  ]


let make_md cols data =
  match Table.of_columns cols data with
  | Error _ -> Alcotest.fail "table"
  | Ok t ->
    match Analyze.analyze t with
    | Error _ -> Alcotest.fail "analyze"
    | Ok at   -> Markdown.render (Doc.of_table at)

let markdown_tests =
  [
    Alcotest.test_case "GFM with header" `Quick (fun () ->
      let expected =
        "| Name  | Age |\n\
         | :---- | ---: |\n\
         | Alice |  30 |\n\
         | Bob   |  25 |"
      in
      Alcotest.(check string) "gfm" expected (make_md people_cols people_data));

    Alcotest.test_case "left alignment marker" `Quick (fun () ->
      let lines = String.split_on_char '\n' (make_md people_cols people_data) in
      let sep = List.nth lines 1 in
      Alcotest.(check bool) "has :---" true
        (let n = String.length sep in
         let rec find i =
           if i + 4 > n then false
           else if String.sub sep i 4 = ":---" && (i + 4 >= n || sep.[i + 4] <> ':')
           then true
           else find (i + 1)
         in find 0));

    Alcotest.test_case "right alignment marker" `Quick (fun () ->
      let lines = String.split_on_char '\n' (make_md people_cols people_data) in
      let sep = List.nth lines 1 in
      Alcotest.(check bool) "has ---:" true
        (let n = String.length sep in
         let rec find i =
           if i + 4 > n then false
           else if String.sub sep i 4 = "---:" then true
           else find (i + 1)
         in find 0));

    Alcotest.test_case "center alignment marker" `Quick (fun () ->
      let cols = [ Encoder.string_column "X" ~alignment:Types.Center Fun.id ] in
      let lines = String.split_on_char '\n' (make_md cols [ "hello" ]) in
      let sep = List.nth lines 1 in
      Alcotest.(check string) "center sep" "| :---: |" sep);

    Alcotest.test_case "pipe in cell escaped" `Quick (fun () ->
      let cols = [ Encoder.string_column "X" Fun.id ] in
      let lines = String.split_on_char '\n' (make_md cols [ "a | b" ]) in

      let data_row = List.nth lines 2 in
      Alcotest.(check string) "escaped" "| a \\| b |" data_row);

    Alcotest.test_case "header separator present" `Quick (fun () ->
      let lines = String.split_on_char '\n' (make_md people_cols people_data) in
      Alcotest.(check int) "4 lines" 4 (List.length lines);

      let sep = List.nth lines 1 in
      Alcotest.(check bool) "starts with |" true (String.length sep > 0 && sep.[0] = '|'));

    Alcotest.test_case "empty doc" `Quick (fun () ->
      Alcotest.(check string) "empty" "" (Markdown.render Doc.Empty));
  ]

let make_html cols data =
  match Table.of_columns cols data with
  | Error _ -> Alcotest.fail "table"
  | Ok t ->
    match Analyze.analyze t with
    | Error _ -> Alcotest.fail "analyze"
    | Ok at   -> Html.render (Doc.of_table at)

let html_tests =
  [
    Alcotest.test_case "HTML with header" `Quick (fun () ->
      let expected =
        "<table>\n\
         <thead>\n\
         <tr><th align=\"left\">Name</th><th align=\"right\">Age</th></tr>\n\
         </thead>\n\
         <tbody>\n\
         <tr><td align=\"left\">Alice</td><td align=\"right\">30</td></tr>\n\
         <tr><td align=\"left\">Bob</td><td align=\"right\">25</td></tr>\n\
         </tbody>\n\
         </table>"
      in
      Alcotest.(check string) "html" expected (make_html people_cols people_data));

    Alcotest.test_case "escaping < and &" `Quick (fun () ->
      let cols = [ Encoder.string_column "X" Fun.id ] in
      let result = make_html cols [ "a < b & c" ] in
      let lines  = String.split_on_char '\n' result in
      let data_row = List.nth lines 5 in
      Alcotest.(check string) "escaped"
        "<tr><td align=\"left\">a &lt; b &amp; c</td></tr>"
        data_row);

    Alcotest.test_case "header uses th" `Quick (fun () ->
      let result = make_html people_cols people_data in
      Alcotest.(check bool) "th present" true
        (let n = String.length result in
         let rec find i =
           if i + 4 > n then false
           else if String.sub result i 4 = "<th " then true
           else find (i + 1)
         in find 0));

    Alcotest.test_case "body uses td" `Quick (fun () ->
      let result = make_html people_cols people_data in
      Alcotest.(check bool) "td present" true
        (let n = String.length result in
         let rec find i =
           if i + 4 > n then false
           else if String.sub result i 4 = "<td " then true
           else find (i + 1)
         in find 0));

    Alcotest.test_case "alignment attribute" `Quick (fun () ->
      let result = make_html people_cols people_data in
      Alcotest.(check bool) "right align present" true
        (let needle = "align=\"right\"" in
         let nlen = String.length needle in
         let n = String.length result in
         let rec find i =
           if i + nlen > n then false
           else if String.sub result i nlen = needle then true
           else find (i + 1)
         in find 0));

    Alcotest.test_case "no header uses tbody only" `Quick (fun () ->
      let data = [ [ Some "x" ] ] in
      (match Table.of_rows data with
       | Error _ -> Alcotest.fail "table"
       | Ok t ->
         match Analyze.analyze t with
         | Error _ -> Alcotest.fail "analyze"
         | Ok at ->
           let result = Html.render (Doc.of_table at) in
           Alcotest.(check bool) "no thead" true
             (not (let n = String.length result in
                   let rec find i =
                     if i + 7 > n then false
                     else if String.sub result i 7 = "<thead>" then true
                     else find (i + 1)
                   in find 0));
           Alcotest.(check bool) "has tbody" true
             (let n = String.length result in
              let rec find i =
                if i + 7 > n then false
                else if String.sub result i 7 = "<tbody>" then true
                else find (i + 1)
              in find 0)));

    Alcotest.test_case "empty doc" `Quick (fun () ->
      Alcotest.(check string) "empty" "" (Html.render Doc.Empty));
  ]


let make_doc_people () =
  match Table.of_columns people_cols people_data with
  | Error _ -> Alcotest.fail "table"
  | Ok t ->
    match Analyze.analyze t with
    | Error _ -> Alcotest.fail "analyze"
    | Ok at   -> Doc.of_table at


let render_tests =
  [
    Alcotest.test_case "Text dispatch" `Quick (fun () ->
      let doc = make_doc_people () in
      let via_render = Render.render (Render.Text Border.ASCII) doc in
      let via_text   = Text.render ~border:Border.ASCII doc in
      Alcotest.(check string) "same" via_text via_render);

    Alcotest.test_case "Markdown dispatch" `Quick (fun () ->
      let doc = make_doc_people () in
      let via_render   = Render.render Render.Markdown doc in
      let via_markdown = Markdown.render doc in
      Alcotest.(check string) "same" via_markdown via_render);

    Alcotest.test_case "Html dispatch" `Quick (fun () ->
      let doc = make_doc_people () in
      let via_render = Render.render Render.Html doc in
      let via_html   = Html.render doc in
      Alcotest.(check string) "same" via_html via_render);

    Alcotest.test_case "Empty dispatch" `Quick (fun () ->
      Alcotest.(check string) "text"     "" (Render.render (Render.Text Border.ASCII) Doc.Empty);
      Alcotest.(check string) "markdown" "" (Render.render Render.Markdown Doc.Empty);
      Alcotest.(check string) "html"     "" (Render.render Render.Html Doc.Empty));
  ]


let api_tests =
  [
    Alcotest.test_case "typed path text" `Quick (fun () ->
      let cols = [ string_column "Name" fst; int_column "Age" snd ] in
      let data = [ ("Alice", 30); ("Bob", 25) ] in
      match table cols data (Text Border.ASCII) with
      | Error _ -> Alcotest.fail "unexpected error"
      | Ok s    ->
        Alcotest.(check bool) "non-empty" true (String.length s > 0);
        Alcotest.(check bool) "has rule"  true (String.contains s '+'));

    Alcotest.test_case "typed path markdown" `Quick (fun () ->
      let cols = [ string_column "N" fst; int_column "V" snd ] in
      match table cols [ ("x", 1) ] Markdown with
      | Error _ -> Alcotest.fail "unexpected error"
      | Ok s    ->
        Alcotest.(check bool) "starts with pipe" true (s.[0] = '|'));

    Alcotest.test_case "typed path html" `Quick (fun () ->
      let cols = [ string_column "X" Fun.id ] in
      match table cols [ "hello" ] Html with
      | Error _ -> Alcotest.fail "unexpected error"
      | Ok s    ->
        Alcotest.(check bool) "has table tag" true
          (let n = String.length s in
           let rec find i =
             if i + 7 > n then false
             else if String.sub s i 7 = "<table>" then true
             else find (i + 1)
           in find 0));

    Alcotest.test_case "raw path text" `Quick (fun () ->
      let rows = [ [ Some "Alice"; Some "30" ] ] in
      match table_of_rows ~header:[ "Name"; "Age" ] rows (Text Border.ASCII) with
      | Error _ -> Alcotest.fail "unexpected error"
      | Ok s    ->
        Alcotest.(check bool) "non-empty" true (String.length s > 0));

    Alcotest.test_case "empty cols → error" `Quick (fun () ->
      match table [] [ () ] (Text Border.ASCII) with
      | Ok _    -> Alcotest.fail "expected error"
      | Error e -> Alcotest.(check (testable Types.pp_error ( = ))) "err" Empty_table e);

    Alcotest.test_case "empty rows → error" `Quick (fun () ->
      match table [ string_column "X" Fun.id ] [] (Text Border.ASCII) with
      | Ok _    -> Alcotest.fail "expected error"
      | Error e -> Alcotest.(check (testable Types.pp_error ( = ))) "err" Empty_table e);
  ]


let csv_tests =
  let check label expected delim s =
    Alcotest.test_case label `Quick (fun () ->
      Alcotest.(check (list (option string))) label expected
        (Cli.parse_line delim s))
  in
  [

    check "simple"       [Some "a"; Some "b"; Some "c"]     ',' "a,b,c";
    check "single field" [Some "hello"]                      ',' "hello";
    check "empty string" []                                  ',' "";

    check "leading empty"  [None; Some "b"]                 ',' ",b";
    check "trailing empty" [Some "a"; None]                 ',' "a,";
    check "middle empty"   [Some "a"; None; Some "c"]       ',' "a,,c";
    check "all empty"      [None; None]                     ',' ",";

    check "quoted simple"    [Some "hello"]                  ',' "\"hello\"";
    check "quoted with comma" [Some "a,b"; Some "c"]         ',' "\"a,b\",c";
    check "quoted empty"     [None]                          ',' "\"\"";
    check "escaped quote"    [Some "say \"hi\""]             ',' "\"say \"\"hi\"\"\"";

    check "tsv basic"  [Some "x"; Some "y"; Some "z"]       '\t' "x\ty\tz";
    check "tsv empty"  [Some "a"; None; Some "c"]           '\t' "a\t\tc";
  ]

let () =
  Alcotest.run "tbls"
    [
      ("Width",    width_tests);
      ("Encoder",  encoder_tests);
      ("Table",    table_tests);
      ("Infer",    infer_tests);
      ("Layout",   layout_tests);
      ("Analyze",  analyze_tests);
      ("Doc",      doc_tests);
      ("Border",   border_tests);
      ("Text",     text_tests);
      ("Markdown", markdown_tests);
      ("Html",     html_tests);
      ("Render",   render_tests);
      ("API",      api_tests);
      ("CSV",      csv_tests);
    ]
