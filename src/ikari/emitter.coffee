utils = require "./utils"


class Emitter
  listeners:{}

  ###*
    イベント機能を提供する
    @class Emitter
    @constructor
  ###
  constructor:()->
    @listeners = {}


  ###
    イベントリスナーを設定する
    @method on
    @param {String} type イベントタイプ
    @param {Function} listener イベントが発生した時に実行するリスナー
  ###
  on:(type, listener)->
    @listeners ?= {}
    if @listeners[ type ] is undefined
      @listeners[ type ] = []

    if utils._inArray(listener, @listeners[type]) < 0
      @listeners[type].push listener
    return


  ###
    イベントリスナーを解除する
    @method off
    @param {type} type 解除したいイベントタイプ
    @param {Function} listener 紐づくリスナー
  ###
  off:(type, listener)->
    len = 0
    len++ for prop of @listeners
    if len < 1
      return
    arr = @listeners[type]
    unless arr
      return
    i = 0
    len = arr.length
    while i < len
      if arr[i] is listener
        if len is 1 then delete @listeners[type] else arr.splice(i,1)
        break
      i++
    return


  ###
    イベントを発火する
    @method emit
    @param {Eventer} 発火するイベントオブジェクト
  ###
  emit:(eventObj)->
    ary = @listeners[ eventObj.type ]
    if ary isnt undefined
      eventObj.target = @
      for handler in ary
        handler.call(@, eventObj) if eventObj.isPropagate and handler
    return


module.exports = Emitter