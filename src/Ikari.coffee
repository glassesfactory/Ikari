define [
  "ikari/utils"
  "ikari/config"
  "ikari/builder"
  "ikari/escaper"
], (
  utils
  Config
  Builder
  escaper
)->


  #ばりゅー
  VAL_RE = /^{{2,3}([\w]+|[\w]+\.\w+)}{2,3}/g


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
      result = @compiler(data)
      dom = utils.erase @builder.el
      console.log dom
      container = document.createElement "div"
      container.innerHTML = result

      children = container.children

      fragment = document.createDocumentFragment()
      for child in children
        fragment.appendChild(child.cloneNode(true)) if child
      @builder.el.appendChild fragment
      return


    ###*
      データを更新する
      @metho update
    ###
    update:(data)=>
      unless @compiler
        throw new Error("準備出来てないじゃないですか?")
      return
