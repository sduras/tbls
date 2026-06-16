
open Tbls

let use_color () =
  match Sys.getenv_opt "NO_COLOR" with
  | Some _ -> false
  | None ->
    (match Sys.getenv_opt "TERM" with Some "dumb" -> false | _ -> true)

let () =
  let cfg   = Cli.parse_args () in
  let color = use_color () in
  let read_ic ic =
    try Cli.parse_channel cfg.Cli.delimiter ic
    with exn ->
      Printf.eprintf "tbls: read error: %s\n%!" (Printexc.to_string exn);
      exit Cli.exit_parse_error
  in
  let rows =
    if cfg.Cli.files = [] then read_ic stdin
    else
      List.concat_map
        (fun file ->
           match (try Ok (open_in file) with Sys_error msg -> Error msg) with
           | Error msg ->
             Printf.eprintf "tbls: %s\n%!" msg;
             exit Cli.exit_file_error
           | Ok ic ->
             let rows = read_ic ic in
             close_in ic;
             rows)
        cfg.Cli.files
  in
  let rows =
    List.map
      (List.map (function None -> Some cfg.Cli.null_str | Some s -> Some s))
      rows
  in
  let header, data =
    if not cfg.Cli.has_header then (None, rows)
    else
      match rows with
      | [] -> (None, [])
      | first :: rest ->
        let hdr = List.filter_map (fun x -> x) first in
        (Some hdr, rest)
  in

  let output_result =
    match Table.of_rows ?header data with
    | Error e -> Error e
    | Ok t ->
      match Analyze.analyze t with
      | Error e -> Error e
      | Ok at ->
        let doc = Doc.of_table at in
        let s =
          match cfg.Cli.format with
          | Cli.Fmt_text     -> Text.render ~border:cfg.Cli.border ~color doc
          | Cli.Fmt_markdown -> Markdown.render doc
          | Cli.Fmt_html     -> Html.render doc
        in
        Ok s
  in
  match output_result with
  | Error e ->
    Format.eprintf "tbls: %a@." Types.pp_error e;
    exit Cli.exit_render_fail
  | Ok output ->
    print_string output;
    print_char '\n'
