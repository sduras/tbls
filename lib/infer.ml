
let is_integer s =
  let n = String.length s in
  if n = 0 then false
  else begin
    let i = ref 0 in
    if s.[!i] = '+' || s.[!i] = '-' then incr i;
    if !i >= n then false
    else
      let first = s.[!i] in
      if first < '0' || first > '9' then false
      else if first = '0' then !i + 1 = n
      else begin
        incr i;
        let valid = ref true in
        while !valid && !i < n do
          if s.[!i] < '0' || s.[!i] > '9' then valid := false else incr i
        done;
        !valid
      end
  end

let is_finite f =
  match classify_float f with
  | FP_normal | FP_subnormal | FP_zero -> true
  | FP_infinite | FP_nan               -> false

let is_float s =
  (String.contains s '.' || String.contains s 'e' || String.contains s 'E')
  && not (is_integer s)
  && (match float_of_string_opt s with
      | None   -> false
      | Some f -> is_finite f)

let infer_value s =
  if s = "" then Types.Missing
  else if is_integer s then Types.Integer
  else if is_float s then Types.Float
  else Types.Text

let infer_column values =
  let combine acc v =
    match (acc, infer_value v) with
    | Types.Missing, t              -> t
    | _, Types.Missing              -> acc
    | Types.Integer, Types.Integer  -> Types.Integer
    | Types.Float,   Types.Float    -> Types.Float
    | Types.Text,    Types.Text     -> Types.Text
    | _,             _              -> Types.Text
  in
  List.fold_left combine Types.Missing values
