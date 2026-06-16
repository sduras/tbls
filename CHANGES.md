# Changes

## 0.4.0 (2026-06-16)

- Extended East Asian Width table to cover emoji and symbols in the
  U+23xx–U+2Bxx range (✅ U+2705, ⏳ U+23F3, and ~50 related codepoints
  previously misclassified as width 1).
- Added `Width.has_wide_chars`: returns true if a string contains any
  display-width-2 character.
- Added `Width.map_segments`: applies separate transformations to runs of
  wide and narrow characters; used for ANSI coloring that preserves emoji
  native rendering.
- Text renderer: ANSI color applied to header cells (dark orange bold) and
  border characters (dim). Wide-character runs in header cells are excluded
  from foreground coloring so emoji render with their own color.
- Color disabled when `NO_COLOR` is set to any value or `TERM` is `dumb`.
- Markdown separator row now padded to column display width (`:----` for a
  width-5 left-aligned column, not `:---`).
- HTML renderer strips pre-applied cell padding; alignment is expressed via
  the `align` attribute, leaving cell text unpadded.
- CLI utility `tbls(1)`: reads CSV or TSV from files or standard input,
  writes rendered table to standard output.
- CLI flags: `--format text|markdown|html`, `--border ascii|unicode|none`,
  `--delimiter char`, `--no-header`, `--null string`.
- RFC 4180 CSV parser with quoted-field support. Multiline quoted fields
  not supported.
- Exit codes: 0 success, 1 invalid arguments, 2 parse failure, 3 file
  access failure, 4 render failure.
- Man page `tbls(1)`.

## 0.3.0 (2025-03-10)

- Float columns right-aligned; integer portion and fractional portion
  padded independently so decimal separators align across rows.
- `float_column ~precision:int`: controls the number of decimal places
  rendered. Default: 6.
- `option_column ~null_str:string`: constructor for columns whose values
  may be absent. `None` renders as `null_str`.
- `~null_str` parameter on all column constructors: per-column replacement
  string for missing cells. Default: empty string.
- `~alignment` override parameter on all column constructors: overrides
  type-inferred alignment for a specific column.
- Center alignment (`Types.Center`, `~alignment:Center`).

## 0.2.0 (2024-05-20)

- Unicode border style: box-drawing characters
  (`┌`, `─`, `┬`, `┐`, `│`, `├`, `┼`, `┤`, `└`, `┴`, `┘`).
- `Border.None`: columns separated by a single space, no border
  characters.
- `Render.format` type: `Text of Border.style | Markdown | Html`.
- GFM Markdown renderer: `| cell |` rows, separator row with alignment
  markers (`:---`, `---:`, `:---:`). Pipe characters in cell content
  escaped as `\|`.
- HTML renderer: `<table>`, `<thead>`, `<tbody>`, `<tr>`, `<th>`,
  `<td>` with `align` attribute. Cell content escaped: `<`, `>`, `&`,
  `"`.

## 0.1.0 (2024-01-15)

- Core pipeline: `Table.t` → `Analyze.t` → `Doc.t` → renderer. Each
  stage has a distinct type; the compiler enforces ordering.
- `Width.display_width`: UTF-8 decoder with combining mark (width 0) and
  wide character (width 2) classification. Invalid byte sequences treated
  as U+FFFD.
- Column type inference: `Integer`, `Float`, `Text`, `Missing`. Null
  cells do not participate in inference and do not downgrade an inferred
  type.
- Automatic right-alignment for `Integer` and `Float` columns.
  `Text` and `Missing` columns default to left-alignment.
- `Doc.of_table`: all padding and alignment pre-applied before
  rendering; backends receive fully formatted strings.
- Text renderer with ASCII border (`+`, `-`, `|`). Header row separated
  from data by a horizontal rule.
- Typed column constructors: `string_column`, `int_column`,
  `float_column`.
- Raw row construction: `Table.of_rows ?header`.
- `Table.of_columns` and `Table.of_rows` validate column count
  consistency at construction; ragged input returns an error.
- Public: `Tbls.table`, `Tbls.table_of_rows`.
