utils   = require "./ikari/utils"
Config  = require "./ikari/config"
Builder = require "./ikari/builder"
escaper = require "./ikari/escaper"

class Ikari

  builder : null

  datas : null

  compiler : null

  ###*
    Simple HTML Binding Template Engine.
    @class Ikari
    @param options {Object}
  ###
  constructor:(options={})->
    el     = utils.kv "el", options
    @datas = utils.kv "datas", options

    unless el
      throw new Error("エレメントはなんかしていして") # or body?

    @builder = new Builder el, this


  ###*
    作る
    @method create
  ###
  create:(data)=>
    unless @compiler
      throw new Error("準備出来てないじゃないですか?")
    dom = utils.erase @builder.el
    @_update data, dom
    return


  ###*
    データを更新する
    @metho update
  ###
  update:(data)=>
    unless @compiler
      throw new Error("準備出来てないじゃないですか?")
    dom = @builder.el
    @_update data, dom
    return


  ###*
    @method _update
    @private
  ###
  _update:(data, dom)=>
    container = document.createElement "div"
    tmp = @compiler(data)
    container.innerHTML = tmp

    children = container.children

    fragment = document.createDocumentFragment()
    for child in children
      fragment.appendChild(child.cloneNode(true)) if child
    @builder.el.appendChild fragment
    return


do(window)->
  window.Ikari = Ikari
# module.exports = Ikari