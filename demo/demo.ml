
open Tbls

let color_enabled =
  match Sys.getenv_opt "NO_COLOR" with
  | Some _ -> false
  | None -> (match Sys.getenv_opt "TERM" with Some "dumb" -> false | _ -> true)

let section title =
  let w   = Width.display_width title + 4 in
  let bar = String.make w '-' in
  Printf.printf "\n%s\n| %s |\n%s\n\n" bar title bar

let analyze_t = function Error e -> Error e | Ok t -> Analyze.analyze t

let show_text ?(border = Border.ASCII) = function
  | Error e ->
    Format.printf "\x1b[31mERROR: %a\x1b[0m@." Types.pp_error e; print_char '\n'
  | Ok at ->
    print_string (Text.render ~border ~color:color_enabled (Doc.of_table at));
    print_char '\n'; print_char '\n'

let show = function
  | Ok s -> print_string s; print_char '\n'; print_char '\n'
  | Error e -> Format.printf "\x1b[31mERROR: %a\x1b[0m@." Types.pp_error e

let () =
  section "1. List of lists -- raw string input";
  show_text
    (analyze_t
       (Table.of_rows
          ~header:[ "Name"; "Age"; "City" ]
          [ [ Some "Sergiy"; Some "21"; Some "Kharkiv" ]
          ; [ Some "Conor";   Some "21"; Some "Dublin" ]
          ; [ Some "Paul"; Some "22"; Some "Berlin" ]
          ]))

type product =
  { name      : string
  ; price     : float
  ; qty       : int
  ; available : bool option }

let products =
  [ { name = "Apple";    price = 1.99;  qty = 100; available = Some true  }
  ; { name = "Orange";    price = 10.95; qty = 3;   available = Some false }
  ; { name = "Pear"; price = 2.5;   qty = 42;  available = None       }
  ]

let product_cols =
  [ string_column "Product" (fun p -> p.name)
  ; float_column  "Price"  ~precision:2 (fun p -> p.price)
  ; int_column    "Qty"    (fun p -> p.qty)
  ; option_column "Available" ~null_str:"N/A"
      (fun p -> Option.map (fun b -> if b then "yes" else "no") p.available)
  ]

let () =
  section "2. Typed columns -- record type";
  show_text (analyze_t (Table.of_columns product_cols products))

let () =
  section "3. Dict-of-lists pattern (column-major to row-major)";
  let dict =
    [ ("Country",    [ "Germany"; "Ukraine"; "Ireland" ])
    ; ("Capital",    [ "Berlin"; "Kyiv"; "Dublin"  ])
    ; ("Population", [ "84M"; "34M"; "7M" ])
    ]
  in
  let headers   = List.map fst dict in
  let col_lists = List.map snd dict in
  let n_rows    = List.length (List.hd col_lists) in
  let rows =
    List.init n_rows (fun i ->
      List.map (fun col -> Some (List.nth col i)) col_lists)
  in
  show_text (analyze_t (Table.of_rows ~header:headers rows))

let () =
  section "4. Numeric detection -- integers and floats auto right-aligned";
  show_text
    (analyze_t
       (Table.of_rows
          ~header:[ "Label"; "Count"; "Ratio" ]
          [ [ Some "alpha"; Some "1";    Some "0.333"   ]
          ; [ Some "beta";  Some "10";   Some "3.14159" ]
          ; [ Some "gamma"; Some "100";  Some "2.71828" ]
          ; [ Some "delta"; Some "1000"; Some "1.0"     ]
          ]))


let () =
  section "5. Custom float formatters -- varying precision";
  show_text
    (analyze_t
       (Table.of_columns
          [ string_column "Constant"  fst
          ; float_column  "Default"   ~precision:6 snd
          ; float_column  "Two d.p."  ~precision:2 snd
          ; float_column  "Integer"   ~precision:0 snd
          ]
          [ ("pi",  3.14159265)
          ; ("e",   2.71828182)
          ; ("phi", 1.61803398)
          ]))

let () =
  section "6. Null / missing values -- custom null_str per column";
  show_text
    (analyze_t
       (Table.of_rows
          ~header:[ "Name"; "Email"; "Phone" ]
          [ [ Some "Anna"; Some "anna@example.com"; None ]
          ; [ Some "Borys";   None;                     Some "+380 44 123 4567" ]
          ; [ Some "John"; Some "john@example.com"; Some "+380 32 123 4567" ]
          ]))


type student = { sid : int; sname : string; score : int }

let students =
  [ { sid = 1; sname = "Anna"; score = 95 }
  ; { sid = 2; sname = "Fionnuala";   score = 87 }
  ; { sid = 3; sname = "John"; score = 92 }
  ]

let () =
  section "7. Alignment overrides -- ID left, Name centered, Score right";
  show_text
    (analyze_t
       (Table.of_columns
          [ int_column    "ID"    ~alignment:Left   (fun s -> s.sid)
          ; string_column "Name"  ~alignment:Center (fun s -> s.sname)
          ; int_column    "Score"                   (fun s -> s.score)
          ]
          students))

let () =
  section "8a. Border: ASCII";
  show_text ~border:Border.ASCII   (analyze_t (Table.of_columns product_cols products));
  section "8b. Border: Unicode";
  show_text ~border:Border.Unicode (analyze_t (Table.of_columns product_cols products));
  section "8c. Border: None";
  show_text ~border:Border.None    (analyze_t (Table.of_columns product_cols products))

let mini_cols = [ string_column "Name" fst; int_column "Score" snd ]
let mini_data = [ ("John", 95); ("Paul", 87) ]

let () =
  section "9a. Output: Text (Unicode)";
  show_text ~border:Border.Unicode (analyze_t (Table.of_columns mini_cols mini_data));
  section "9b. Output: Markdown";
  show (table mini_cols mini_data Markdown);
  section "9c. Output: HTML";
  show (table mini_cols mini_data Html)

let () =
  section "10. Emoji -- display-width-aware alignment";
  show_text
    ~border:Border.Unicode
    (analyze_t
       (Table.of_rows
          ~header:
            [ "\xF0\x9F\x93\x8B Task"
            ; "\xF0\x9F\x94\xA5 Priority"
            ; "\xF0\x9F\x8E\xAF Status"
            ]
          [ [ Some "Write tests"; Some "High";   Some "\xE2\x9C\x85 Done"            ]
          ; [ Some "Review PR";   Some "Medium"; Some "\xF0\x9F\x94\x84 In progress" ]
          ; [ Some "Deploy";      Some "Low";    Some "\xE2\x8F\xB3 Waiting"         ]
          ]))

let () =
  section "11. Minimal API -- one function call";
  show
    (table_of_rows
       ~header:[ "x"; "x^2"; "x^3" ]
       (List.init 5 (fun i ->
          let x = i + 1 in
          [ Some (string_of_int x)
          ; Some (string_of_int (x * x))
          ; Some (string_of_int (x * x * x))
          ]))
       (Text Border.Unicode))
