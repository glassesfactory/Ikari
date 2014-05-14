utils   = require "./ikari/utils"
Config  = require "./ikari/config"
Builder = require "./ikari/builder"
escaper = require "./ikari/escaper"
Emitter = require "./ikari/emitter"
Event   = require "./ikari/event"

class Ikari extends Emitter

  builder : null

  datas : null

  compiler : null

  autoBuild : false

  #ビルドが完了しているかどうか
  isBuilded : false

  compilerCacheName : null

  cachable: false



  ###*
    Simple HTML Binding Template Engine.
    @class Ikari
    @param options {Object}
  ###
  constructor:(options={})->
    super()
    el                 = utils.kv "el", options
    @datas             = utils.kv "datas", options
    @autoBuild         = utils.kv "autoBuild", options, false
    data               = utils.kv "data", options
    renderdCache       = utils.kv "renderdCache", options
    @cachable          = utils.kv "cachable", options
    #コンパイラーのキャッシュ
    @compilerCacheName = utils.kv "compilerCacheName", options
    @_init el, data, renderdCache


  _init:(el, data, renderdCache)=>
    unless el
      throw new Error("エレメントはなんかしていして") # or body?

    if @cachable and not @compilerCacheName

      @compilerCacheName = "ikari-cache" + el

    @builder = new Builder el, this
    if window.localStorage and @compilerCacheName
      cache = localStorage.getItem @compilerCacheName
      @compiler = new Function(cache.split(',')...)
      if @compiler and data and @autoBuild
        @create data
        return
      else
        setTimeout ()=>
          @emit new Event(Event.BUILDED)
        , 1

    if renderdCache
      dom = utils.erase utils.query el
      dom.appendChild renderdCache

    @builder.build this if @autoBuild and not @isBuilded and not @compiler
    #データを初期オプションとして引き渡されていてかつ autoBuild が true になっていたらもうレンダリングまでしてしまう
    if data and @autoBuild
      @builder.build this
      @create data
    return


  ###*
    ビルドする
    @method build
  ###
  build:()=>
    unless @compiler
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
    #ぶっこむ
    @builder.el.appendChild fragment
    #イベント出す
    @emit new Event(Event.UPDATED)
    return


do(window)->
  window.Ikari = Ikari
