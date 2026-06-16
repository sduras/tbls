
let in_ranges ranges cp =
  let rec go lo hi =
    if lo > hi then false
    else
      let mid = (lo + hi) / 2 in
      let (a, b) = ranges.(mid) in
      if cp < a then go lo (mid - 1)
      else if cp > b then go (mid + 1) hi
      else true
  in
  go 0 (Array.length ranges - 1)

let zero_width_ranges = [|
  (0x0300, 0x036F);
  (0x0483, 0x0489);
  (0x0591, 0x05BD);
  (0x05BF, 0x05BF);
  (0x05C1, 0x05C2);
  (0x05C4, 0x05C5);
  (0x05C7, 0x05C7);
  (0x0610, 0x061A);
  (0x064B, 0x065F);
  (0x0670, 0x0670);
  (0x06D6, 0x06DC);
  (0x06DF, 0x06E4);
  (0x06E7, 0x06E8);
  (0x06EA, 0x06ED);
  (0x1AB0, 0x1ACE);
  (0x1DC0, 0x1DFF);
  (0x20D0, 0x20FF);
  (0xFE00, 0xFE0F);
  (0xFE20, 0xFE2F);
  (0xE0000, 0xE007F);
  (0xE0100, 0xE01EF);
|]

let wide_ranges = [|
  (0x1100, 0x115F);
  (0x2329, 0x232A);
  (0x23E9, 0x23F3);
  (0x23F8, 0x23FA);
  (0x25AA, 0x25AB);
  (0x25B6, 0x25B6);
  (0x25C0, 0x25C0);
  (0x25FB, 0x25FE);
  (0x2600, 0x2604);
  (0x2614, 0x2615);
  (0x2648, 0x2653);
  (0x267F, 0x267F);
  (0x2693, 0x2693);
  (0x26A1, 0x26A1);
  (0x26AA, 0x26AB);
  (0x26BD, 0x26BE);
  (0x26C4, 0x26C5);
  (0x26CE, 0x26CF);
  (0x26D4, 0x26D4);
  (0x26EA, 0x26EA);
  (0x26F2, 0x26F3);
  (0x26F5, 0x26F5);
  (0x26FA, 0x26FA);
  (0x26FD, 0x26FD);
  (0x2702, 0x2702);
  (0x2705, 0x2705);
  (0x2708, 0x270D);
  (0x270F, 0x270F);
  (0x2712, 0x2712);
  (0x2714, 0x2714);
  (0x2716, 0x2716);
  (0x271D, 0x271D);
  (0x2721, 0x2721);
  (0x2728, 0x2728);
  (0x2733, 0x2734);
  (0x2744, 0x2744);
  (0x2747, 0x2747);
  (0x274C, 0x274C);
  (0x274E, 0x274E);
  (0x2753, 0x2755);
  (0x2757, 0x2757);
  (0x2763, 0x2764);
  (0x2795, 0x2797);
  (0x27A1, 0x27A1);
  (0x27B0, 0x27B0);
  (0x27BF, 0x27BF);
  (0x2934, 0x2935);
  (0x2B05, 0x2B07);
  (0x2B1B, 0x2B1C);
  (0x2B50, 0x2B50);
  (0x2B55, 0x2B55);
  (0x2E80, 0x303E);
  (0x3040, 0x33FF);
  (0x3400, 0x4DBF);
  (0x4E00, 0xA4C6);
  (0xA960, 0xA97C);
  (0xAC00, 0xD7A3);
  (0xF900, 0xFAFF);
  (0xFE10, 0xFE19);
  (0xFE30, 0xFE6B);
  (0xFF01, 0xFF60);
  (0xFFE0, 0xFFE6);
  (0x1B000, 0x1B001);
  (0x1F004, 0x1F004);
  (0x1F0CF, 0x1F0CF);
  (0x1F18E, 0x1F18E);
  (0x1F191, 0x1F19A);
  (0x1F1E0, 0x1F1FF);
  (0x1F201, 0x1F202);
  (0x1F21A, 0x1F21A);
  (0x1F22F, 0x1F22F);
  (0x1F232, 0x1F23A);
  (0x1F250, 0x1F251);
  (0x1F300, 0x1F6D7);
  (0x1F6E0, 0x1F6EC);
  (0x1F6F0, 0x1F6FC);
  (0x1F7E0, 0x1F7EB);
  (0x1F7F0, 0x1F7F0);
  (0x1F90C, 0x1F9FF);
  (0x1FA00, 0x1FA53);
  (0x1FA60, 0x1FA6D);
  (0x1FA70, 0x1FAFF);
  (0x20000, 0x2A6DF);
  (0x2A700, 0x2B73F);
  (0x2B740, 0x2B81F);
  (0x2B820, 0x2CEAF);
  (0x2CEB0, 0x2EBEF);
  (0x2F800, 0x2FA1F);
  (0x30000, 0x3134F);
|]

let decode_one s i n =
  let b0 = Char.code (String.unsafe_get s i) in
  if b0 land 0x80 = 0 then
    (b0, 1)
  else if b0 land 0xE0 = 0xC0 then begin
    if i + 1 >= n then (0xFFFD, 1)
    else
      let b1 = Char.code (String.unsafe_get s (i + 1)) in
      if b1 land 0xC0 <> 0x80 then (0xFFFD, 1)
      else
        let cp = ((b0 land 0x1F) lsl 6) lor (b1 land 0x3F) in
        if cp < 0x80 then (0xFFFD, 1)
        else (cp, 2)
  end
  else if b0 land 0xF0 = 0xE0 then begin
    if i + 2 >= n then (0xFFFD, 1)
    else
      let b1 = Char.code (String.unsafe_get s (i + 1)) in
      let b2 = Char.code (String.unsafe_get s (i + 2)) in
      if b1 land 0xC0 <> 0x80 || b2 land 0xC0 <> 0x80 then (0xFFFD, 1)
      else
        let cp =
          ((b0 land 0x0F) lsl 12)
          lor ((b1 land 0x3F) lsl 6)
          lor (b2 land 0x3F)
        in
        if cp < 0x800 || (cp >= 0xD800 && cp <= 0xDFFF) then (0xFFFD, 1)
        else (cp, 3)
  end
  else if b0 land 0xF8 = 0xF0 then begin
    if i + 3 >= n then (0xFFFD, 1)
    else
      let b1 = Char.code (String.unsafe_get s (i + 1)) in
      let b2 = Char.code (String.unsafe_get s (i + 2)) in
      let b3 = Char.code (String.unsafe_get s (i + 3)) in
      if b1 land 0xC0 <> 0x80 || b2 land 0xC0 <> 0x80 || b3 land 0xC0 <> 0x80
      then (0xFFFD, 1)
      else
        let cp =
          ((b0 land 0x07) lsl 18)
          lor ((b1 land 0x3F) lsl 12)
          lor ((b2 land 0x3F) lsl 6)
          lor (b3 land 0x3F)
        in
        if cp < 0x10000 || cp > 0x10FFFF then (0xFFFD, 1) else (cp, 4)
  end
  else (0xFFFD, 1)

let display_width_of_uchar u =
  let cp = Uchar.to_int u in
  if cp < 0x20 || (cp >= 0x7F && cp <= 0x9F) then 0
  else if cp < 0x7F then 1
  else if in_ranges zero_width_ranges cp then 0
  else if in_ranges wide_ranges cp then 2
  else 1

let display_width s =
  let n = String.length s in
  let w = ref 0 in
  let i = ref 0 in
  while !i < n do
    let (cp, advance) = decode_one s !i n in
    w := !w + display_width_of_uchar (Uchar.of_int cp);
    i := !i + advance
  done;
  !w

let has_wide_chars s =
  let n = String.length s in
  let i = ref 0 in
  let found = ref false in
  while not !found && !i < n do
    let cp, advance = decode_one s !i n in
    if display_width_of_uchar (Uchar.of_int cp) = 2 then found := true;
    i := !i + advance
  done;
  !found

let map_segments s ~narrow ~wide =
  let n = String.length s in
  if n = 0 then ""
  else
    let out  = Buffer.create n in
    let seg  = Buffer.create 16 in
    let cur_wide = ref false in
    let flush () =
      if Buffer.length seg > 0 then begin
        let chunk = Buffer.contents seg in
        Buffer.clear seg;
        Buffer.add_string out (if !cur_wide then wide chunk else narrow chunk)
      end
    in
    let i = ref 0 in
    let started = ref false in
    while !i < n do
      let cp, advance = decode_one s !i n in
      let is_wide = display_width_of_uchar (Uchar.of_int cp) = 2 in
      if not !started then begin started := true; cur_wide := is_wide end
      else if is_wide <> !cur_wide then begin flush (); cur_wide := is_wide end;
      for j = !i to !i + advance - 1 do
        Buffer.add_char seg (String.unsafe_get s j)
      done;
      i := !i + advance
    done;
    flush ();
    Buffer.contents out
