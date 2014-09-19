Config = require "./config"
Dom    = require "./dom"
Event  = require "./event"
utils  = require "./utils"


class Builder

  el: null

  funcStr: []

  args: null
  ignores: null

  incrementer: 0

  ###*
    HTML バインドしてきてなんかする
    @class Builder
  ###
  constructor: (el, vm) ->
    this.el = utils.query el

    this.funcStr = ["var p = [];p.push.apply(p,arguments);"]
    this.args = []
    this.ignores = []


  ###*
    ビルドを実行する
    @method build
    @param vm {Ikari}
  ###
  build: (vm) =>
    dom = this._parseElment this.el, vm
    this._build(dom, this.funcStr, vm)
    return


  ###*
    エレメントをパースする
    @method _parseElement
    @private
    @param el {Node}
    @param vm {Ikari}
    @param parent {Dom}
    @return {Dom}
  ###
  _parseElment: (el, vm, parent) =>
    dom = new Dom(el, vm)
    if parent
      parent.children.push dom
      dom.parent = parent
    else
      dom.isContainer = true
      this.container = dom
    children = el.childNodes
    this.args = dom.bind this.args, this.ignores, parent
    this._parseElment child, vm, dom for child in children
    return dom


  ###*
    ビルドを実行する
    @method _build
    @private
    @param dom {Dom}
    @param funcStrs {Array}
    @param vm {Ikari}
  ###
  _build: (dom, funcStrs, vm) =>
    dom.build(funcStrs)
    funcStrs.push 'return p.join("");'
    str = funcStrs.join("")
    args = [].concat( this.args )
    args.push str
    vm.compiler = new Function( args... )
    vm.isBuilded = true
    localStorage.setItem vm.compilerCacheName, args if vm.cachable

    #event 出す
    vm.emit new Event(Event.BUILDED)
    return


module.exports = Builder