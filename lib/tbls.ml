
module Types    = Types
module Width    = Width
module Encoder  = Encoder
module Table    = Table
module Infer    = Infer
module Layout   = Layout
module Analyze  = Analyze
module Doc      = Doc
module Border   = Border
module Text     = Text
module Markdown = Markdown
module Html     = Html
module Render   = Render
module Cli      = Cli

type 'a column = 'a Encoder.column

type error = Types.error =
  | Column_count_mismatch of { expected : int; got : int }
  | Empty_table
  | Span_not_supported

type format = Render.format =
  | Text     of Border.style
  | Markdown
  | Html

let string_column = Encoder.string_column
let int_column    = Encoder.int_column
let float_column  = Encoder.float_column
let option_column = Encoder.option_column

let ( let* ) = Result.bind

let table cols data fmt =
  let* t  = Table.of_columns cols data in
  let* at = Analyze.analyze t in
  Ok (Render.render fmt (Doc.of_table at))

let table_of_rows ?header rows fmt =
  let* t  = Table.of_rows ?header rows in
  let* at = Analyze.analyze t in
  Ok (Render.render fmt (Doc.of_table at))
