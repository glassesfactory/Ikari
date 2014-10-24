Config =
  prefix: "i"
  statements: [
    "loop"
    "if"
    "on"
  ]
  options: [
    "val-only"
  ]

  #閉じタグ要らない奴
  singleTags: [
    "img"
    "input"
    "br"
    "meta"
    "hr"
    "embed"
    "area"
    "base"
    "col"
    "keygen"
    "link"
    "param"
    "source"
  ]

module.exports = Config
