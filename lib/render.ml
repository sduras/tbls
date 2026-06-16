
type format =
  | Text     of Border.style
  | Markdown
  | Html

let render ?(color = false) format doc =
  match format with
  | Text border -> Text.render ~border ~color doc
  | Markdown    -> Markdown.render doc
  | Html        -> Html.render doc
