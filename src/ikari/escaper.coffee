Ikari = require '../Ikari'

safe = (val) ->
  if typeof val is "number"
    return val
  unless val
    return ""
  str = val.replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;')
  .replace(/'/g, '&#39;')
  return str

module.exports = safe