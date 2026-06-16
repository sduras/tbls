(** Typed column descriptors for table construction.

    A column descriptor captures a label, a formatting function from a
    row type ['a] to a string, an optional alignment override, and a
    replacement string for null cells.

    ['a] is erased when columns are used to construct a {!Table.t};
    nothing downstream of [Encoder] is parameterised over ['a]. *)

type 'a column = {
  label     : string;
  encode    : 'a -> string option;
      (** Formats a row value as a display string.
          [None] indicates a null or missing cell. *)
  alignment : Types.alignment option;
      (** Overrides type-inferred alignment. [None] means infer from column type. *)
  null_str  : string;
      (** Replacement string for null cells. Default is the empty string. *)
}
(** A typed column descriptor. *)

val string_column :
  ?alignment:Types.alignment ->
  ?null_str:string ->
  string ->
  ('a -> string) ->
  'a column
(** Column whose values are already strings. [encode] always returns [Some]. *)

val int_column :
  ?alignment:Types.alignment ->
  ?null_str:string ->
  string ->
  ('a -> int) ->
  'a column
(** Column whose values are formatted with [string_of_int]. *)

val float_column :
  ?alignment:Types.alignment ->
  ?null_str:string ->
  ?precision:int ->
  string ->
  ('a -> float) ->
  'a column
(** Column whose values are formatted with [Printf.sprintf "%.*f"].
    [precision] is the number of decimal places; default 6. *)

val option_column :
  ?alignment:Types.alignment ->
  ?null_str:string ->
  string ->
  ('a -> string option) ->
  'a column
(** Column whose encoder may return [None] to indicate a missing value. *)
