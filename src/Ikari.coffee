utils   = require "./ikari/utils"
Config  = require "./ikari/config"
Builder = require "./ikari/builder"
escaper = require "./ikari/escaper"
Emitter = require "./ikari/emitter"
Event   = require "./ikari/event"


class Ikari extends Emitter

  builder : null

  datas : null

  methods: null

  _methodsMap: null

  compiler : null

  autoBuild : false

  #ビルドが完了しているかどうか
  isBuilded : false

  compilerCacheName : null

  cachable: false

  safe: escaper

  autoAppend: false

  contentOnly : false
  #全部返す
  allContent: false

  helpers: null

  ###*
    Simple HTML Binding Template Engine.
    @class Ikari
    @param options {Object}
  ###
  constructor: (options= {}) ->
    super()
    el                 = utils.kv "el", options
    this.datas = utils.kv "datas", options
    this.autoBuild = utils.kv "autoBuild", options, false
    data  = utils.kv "data", options
    renderdCache = utils.kv "renderdCache", options
    this.cachable = utils.kv "cachable", options
    this.autoAppend = utils.kv "autoAppend", options, false
    this.contentOnly = utils.kv "contentOnly", options, false
    this.allContent = utils.kv "allContent", options, false
    this.methods = utils.kv "methods", options, null
    this._methodsMap = []
    helpers = utils.kv "helpers" , options
    #コンパイラーのキャッシュ
    this.compilerCacheName = utils.kv "compilerCacheName", options
    this._init el, data, renderdCache

    if helpers
      this._bindHelpers helpers


  _init: (el, data, renderdCache) =>
    unless el
      throw new Error("エレメントはなんかしていして") # or body?

    if this.cachable and not this.compilerCacheName
      this.compilerCacheName = "ikari-cache" + el

    this.builder = new Builder el, this
    if window.localStorage and this.compilerCacheName
      cache = localStorage.getItem this.compilerCacheName
      this.compiler = new Function(cache.split(',')...)
      if this.compiler and data and this.autoBuild
        this.create data
        return
      else
        setTimeout =>
          this.emit new Event(Event.BUILDED)
        , 1

    if renderdCache
      dom = utils.erase utils.query el
      dom.appendChild renderdCache

    this.builder.build this if this.autoBuild and not this.isBuilded and not this.compiler
    #データを初期オプションとして引き渡されていてかつ autoBuild が true になっていたらもうレンダリングまでしてしまう
    if data and this.autoBuild
      this.builder.build this
      this.create data
    return


  ###*
    ビルドする
    @method build
  ###
  build: =>
    this.builder.build this unless this.compiler
    return


  ###*
    作る
    @method create
    この時、テンプレートとして指定した element の中身は消去される
  ###
  create: (data) =>
    unless this.compiler
      throw new Error("準備出来てないじゃないですか?")
    dom = utils.erase this.builder.el
    result = this._update data, dom
    return result


  ###*
    データを更新する
    @metho update
    この時、テンプレートとして指定した element の中にデータが追加される
  ###
  update: (data) =>
    unless this.compiler
      throw new Error("準備出来てないじゃないですか?")
    dom = this.builder.el
    result = this._update data, dom
    return result


  ###*
    @method _update
    @private
  ###
  _update: (data, dom) =>
    this.datas = data
    # tmp =  if data instanceof Array then this.compiler data... else this.compiler data
    tmp = this.compiler data
    container   = document.createElement "div"
    container.innerHTML = tmp
    children    = container.children
    fragment    = document.createDocumentFragment()
    fragment.appendChild(child.cloneNode(true)) for child in children when child
    if this.replace
      parent = this.builder.el.parentNode
      parent.removeNode(child) for child in parent.children
      parent.appendChild fragment
    #イベント出す
    this.emit new Event(Event.UPDATED)
    if this.contentOnly
      isSingleNode = (fragment.childNodes[0].childNodes?.length? is 1)
      isTextNode = (fragment.childNodes[0].childNodes[0]?.nodeType? is Node.TEXT_NODE)
      if isSingleNode and isTextNode
        # contentOnlyモードでノードが1つしかなかった場合。ifが深いのであとで直してくだしあ
        return fragment.textContent
      else
        return fragment.childNodes[0].children
    if this.allContent
      return fragment.childNodes

    els = fragment.childNodes[0].children
    #仮
    this.builder.el.appendChild child.cloneNode(true) for child in els when child

    this._bindMethods()

    return fragment.childNodes[0]

  ###*
    helper のバインド
    @method _bindHelper
    @private
  ###
  _bindHelpers: ( helpers ) =>
    for helper of helpers
      func = helpers[helper]
      this[helper] = func if typeof func is "function"
    return


  ###*
    ディレクティブのバインド
    @method _bindMethods
  ###
  _bindMethods: =>
    for directive in this._methodsMap
      continue unless this.methods.hasOwnProperty directive.method
      el = utils.query(directive.path)
      method = this.methods[directive.method]
      el?.removeEventListener directive.action, method
      el?.addEventListener directive.action, method

    return


do(window) -> window.Ikari = Ikari

module.exports = Ikari
