utils   = require "./ikari/utils"
Config  = require "./ikari/config"
Builder = require "./ikari/builder"
escaper = require "./ikari/escaper"
Emitter = require "./ikari/emitter"

class Ikari extends Emitter

  builder : null

  datas : null

  compiler : null

  autoBuild : false
  isBuilded : false

  ###*
    Simple HTML Binding Template Engine.
    @class Ikari
    @param options {Object}
  ###
  constructor:(options={})->
    super()
    el         = utils.kv "el", options
    @datas     = utils.kv "datas", options
    @autoBuild = utils.kv "autoBuild", options, false

    unless el
      throw new Error("エレメントはなんかしていして") # or body?

    @builder = new Builder el, this
    @builder.build this if @autoBuild and not @isBuilded



  ###*
    ビルドする
    @method
  ###
  build:()=>
    @builder.build this
    return



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
    tmp = @compiler(data)
    container = document.createElement "div"
    container.innerHTML = tmp
    children = container.children
    fragment = document.createDocumentFragment()
    fragment.appendChild(child.cloneNode(true)) for child in children when child
    @builder.el.appendChild fragment
    return


do(window)->
  window.Ikari = Ikari
