(lang dune 3.23)
(name tbls)
(version 0.4.0)
(generate_opam_files true)
(source (codeberg duras/tbls))
(homepage "https://codeberg.org/duras/tbls")
(bug_reports "https://codeberg.org/duras/tbls/issues")
(license ISC)
(authors "Sergiy Duras <sergiy@duras.org>")
(maintainers "Sergiy Duras <sergiy@duras.org>")
(package
 (name tbls)
 (synopsis "Pure OCaml library for rendering tabular data")
 (description 
  "Pure OCaml library for rendering tabular data to plain text, Markdown, or HTML. Accepts typed column descriptors or raw string rows, infers integer and float columns, right-aligns numeric values, and returns a string. No runtime dependencies.")
 (depends
  (ocaml (>= 4.14.0))
  (alcotest (and :with-test (>= 1.7.0)))))
