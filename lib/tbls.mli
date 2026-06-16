(** tbls — pure OCaml library for rendering tabular data.

    Primary entry points: {!table} for typed input, {!table_of_rows} for
    raw string input. All pipeline modules are accessible as sub-modules. *)

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
(** Column descriptor. See {!Encoder} for constructors. *)

type error = Types.error =
  | Column_count_mismatch of { expected : int; got : int }
  | Empty_table
  | Span_not_supported
(** Pipeline error. Returned as [Error e] from {!table} and {!table_of_rows}. *)

type format = Render.format =
  | Text     of Border.style  (** Plain text with the given border style. *)
  | Markdown                  (** GFM Markdown. *)
  | Html                      (** HTML fragment. *)
(** Output format. Passed to {!table} and {!table_of_rows}. *)

val string_column :
  ?alignment:Types.alignment ->
  ?null_str:string ->
  string ->
  ('a -> string) ->
  'a column

val int_column :
  ?alignment:Types.alignment ->
  ?null_str:string ->
  string ->
  ('a -> int) ->
  'a column

val float_column :
  ?alignment:Types.alignment ->
  ?null_str:string ->
  ?precision:int ->
  string ->
  ('a -> float) ->
  'a column

val option_column :
  ?alignment:Types.alignment ->
  ?null_str:string ->
  string ->
  ('a -> string option) ->
  'a column

val table :
  'a column list ->
  'a list ->
  format ->
  (string, error) result
(** Render typed data as a string.
    Returns [Error Empty_table] when [cols] or [data] is empty. *)

val table_of_rows :
  ?header:string list ->
  string option list list ->
  format ->
  (string, error) result
(** Render raw string data as a string.
    [None] cells are rendered as the empty string.
    Returns [Error] on empty or ragged input. *)
