util =
  ###*
    対象オブジェクトが指定された key の値を持っていたら返す。
    なければ null を返す
    @method kv
    @param key {String} 取得したい key 文字列
    @param obj {Object} 存在を確認したい Object
  ###
  kv : (key, obj, defaultValue)->
    if obj.hasOwnProperty key
      return obj[key]
    else
      return if defaultValue then defaultValue else null

  ###*
    継承する
  ###
  extend:(obj)->
    len = arguments.length
    arg = slice.call arguments, 1
    # arg = slice arg, 1
    for item in arg
      if item
        for prop of item
          obj[prop] = item[prop]
    return obj


  ###*
    dom の掃除
  ###
  erase:(el)->
    el.removeChild el.firstChild while el.firstChild
    return el


  _inArray:( elem, array )->
    i = 0
    len = array.length
    while i < len
      if array[ i ] is elem
        return i
      i++
    return -1

module.exports = util