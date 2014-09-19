#ぱてぃーん
VAL_RE     = /\{{2,3}( )*([\w\[\]\(\)]+|([\w\[\]\(\)]+\.)+[\w\[\]\(\),\s]+)( )*\}{2,3}/g

TERNARY_RE = /\{{2,3}( )*([\w"'\[\]\(\)]+|[\w\[\]\(\,\)]+\.+[\w\[\]\(\)]+)( )*([><\=])+( )*([\w\[\]\(\)]+|[\w\[\]\(\)]+\.+[\w\[\]\(\)]+)( )*\?( )*([\w"'\[\]\(\)]+|[\w\[\]\(\)]+\.[\w\[\]\(\)]+)( )*\:( )*([\w"'\[\]\(\)]+|([\w\[\]\(\)]+\.)+[\w\[\]\(\)]+)( )*\}{2,3}/g

_getValName = (val) ->
  return val.split("{").join('').split(' ').join('').split("}").join('')

_valSplitter = (valName, data) ->
  vs = valName.split('.').slice(1)
  d = data
  for v in vs
    d = d[v] if d.hasOwnProperty v
  return d

Parser =

  loop: (str) ->
    spacer = str.split(' ')
    #item in
    if spacer and spacer.length > 0
      isForIn = true
      key = spacer[2]
      item = spacer[0]
      return {
        key: key
        item: item
      }

    colon = str.split(':')
    if colon and colon.length > 0
      key = colon[1]
      item = colon[0]
      return {
        key: key
        item: item
      }
    key = str
    return {
      key: key
      item: "item"
    }

  if: (str) ->
    return str


  ###*
    本文内にいるやつをパースする
    @method parseText
    @param txt {String} txt
  ###
  parseText: (txt, args, ignores, scope) ->
    match = txt.match VAL_RE
    unless match
      return Parser.parseTernary txt, args, ignores, scope
    for valStr in match
      isUnsafe = false
      isUnsafe = true if valStr.match(/\{{3}/g)
      val = valStr.split("{").join("").split(" ").join("").split("}").join("")

      Parser._argsCheck args, ignores, val
      insertVal = if isUnsafe then "' + " + val + "+ '" else "'+ this.safe(" + val + ") + '"
      txt = txt.replace(valStr, insertVal)
    return txt


  parseTernary: (txt, args, ignores, scope) ->
    match = txt.match TERNARY_RE
    unless match
      return txt
    isUnsafe = false if txt.match(/\{{3}/g)
    ternary = txt.split("{").join("").split(" ").join("").split("}").join("")
    if isUnsafe
      txt = "' + " +  txt + "+ '"
    else
      ternaries = ternary.split("?")
      statement = ternaries[0]
      vals      = ternaries[1].split(":")
      Parser._argsCheck args, ignores, val for val in vals
      txt = "' + " + statement + "? this.safe(" + vals[0] + ") : this.safe(" + vals[1] + ") + '"
    return txt


  _argsCheck: (args, ignores, val) ->
    key = val.split('.')[0]
    args.push key if args.indexOf(key) is -1 and key isnt "this" and ignores.indexOf(key) is -1
    return



module.exports = Parser