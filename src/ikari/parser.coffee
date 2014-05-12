define [
  "ikari/config"
  ], (
  Config
)->

  VAL_RE   = /\{{2,3}( )*(\w+|\w+\.+\w+)( )*\}{2,3}/g

  _getValName = (val)->
    return val.split("{").join('').split(' ').join('').split("}").join('')

  _valSplitter =(valName, data)->
    vs = valName.split('.').slice(1)
    d = data
    for v in vs
      d = d[v] if d.hasOwnProperty v
    return d

  Parser =

    loop:(str)->
      spacer = str.split(' ')
      #item in
      if spacer and spacer.length > 0
        isForIn = true
        key = spacer[2]
        item = spacer[0]
        return {
          key : key
          item : item
        }

      colon = str.split(':')
      if colon and colon.length > 0
        key = colon[1]
        item = colon[0]
        return {
          key : key
          item : item
        }
      key = str
      return {
        key : key
        item : "item"
      }

    if:(str)->
      console.log str
      return str


    ###*
      本文内にいるやつをパースする
      @method parseText
      @param txt {String} txt
    ###
    parseText:(txt, data, scope)=>
      match = txt.match VAL_RE
      unless match
        return txt
      for valStr in match
        isUnsafe = false
        if valStr.match(/\{{3}/g)
          isUnsafe = true
        val = valStr.split("{").join("").split(" ").join("").split("}").join("")
        insertVal = if isUnsafe then "' + " + val + "+ '" else "'+ safe(" + val + ") + '"
        txt = txt.replace(valStr, insertVal)
      return txt



