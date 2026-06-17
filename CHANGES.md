### 0.4.0 (2026-06-17)

- Fixed display-width calculation for emoji and symbols in the U+23xx–U+2Bxx range.
- Added `Width.has_wide_chars`.
- Added `Width.map_segments`.
- Improved ANSI-colored text output while preserving native emoji colors.
- Disable color when `NO_COLOR` is set or `TERM=dumb`.
- Markdown separator rows now match column display width.
- Simplified HTML output by removing pre-applied cell padding.
- Added `tbls(1)` CLI for rendering CSV/TSV as text, Markdown, or HTML tables.
- Added RFC 4180 CSV parsing with quoted-field support (multiline fields not supported).
- Added standard exit codes and `tbls(1)` manual page.

## 0.3.0 (2025-03-10)

- Added decimal-point alignment for floating-point columns.
- Added configurable floating-point precision via `float_column ~precision`.
- Added `option_column` for columns containing optional values.
- Added per-column null-value rendering via `~null_str`.
- Added per-column alignment overrides via `~alignment`.
- Added center alignment.

## 0.2.0 (2024-05-20)

- Added Unicode border style using box-drawing characters.
- Added borderless table rendering (`Border.None`).
- Added Markdown and HTML output formats.
- Markdown output supports alignment markers and escaping of pipe characters.
- HTML output uses semantic table elements with proper escaping and alignment attributes.

## 0.1.0 (2024-01-15)

- Initial release.
- Typed table construction from rows or columns.
- Column type inference for integers, floats, and text.
- Automatic alignment based on inferred column type.
- Unicode-aware display-width calculation.
- Text renderer with ASCII borders.
- Typed column constructors: `string_column`, `int_column`, and `float_column`.
