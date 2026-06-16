# tbls

[![License](https://img.shields.io/badge/license-ISC-blue)](https://opensource.org/licenses/ISC)

Pure OCaml library for rendering tabular data to plain text, Markdown, or HTML.

Accepts typed column descriptors or raw string rows, infers integer and float
columns, right-aligns numeric values, and returns a string.

No runtime dependencies.

## Installation

```
opam install tbls
```

Add to your dune file:

```
(libraries tbls)
```

## Quick start

```ocaml
open Tbls

let () =
  table_of_rows ~header:["Name"; "Score"]
    [[Some "John"; Some "99"]; [Some "Paul"; Some "68"]]
    (Text Border.Unicode)
  |> Result.get_ok
  |> print_endline
```

```
┌───────┬───────┐
│ Name  │ Score │
├───────┼───────┤
│ John  │    99 │
│ Paul  │    68 │
└───────┴───────┘
```

* See [EXAMPLES.md](EXAMPLES.md) for usage examples.


The CLI reads CSV from stdin or files:

```sh
printf 'Name,Score\nJohn,99\nPaul,68\n' | tbls --border unicode
```

See `man tbls` for all options and exit codes.

## License

ISC. See [LICENSE](LICENSE).
