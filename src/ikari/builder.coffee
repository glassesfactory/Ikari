Config = require "./config"
Dom    = require "./dom"
Event  = require "./event"
utils  = require "./utils"


class Builder

  el : null

  funcStr : []

  ###*
    HTML バインドしてきてなんかする
    @class Builder
  ###
  constructor:(el, vm)->
    @el = utils.query el

    @funcStr = ["var p = [];"]
    @args = []


  ###*
    ビルドを実行する
    @method build
    @param vm {Ikari}
  ###
  build:(vm)=>
    dom = @_parseElment @el, vm
    @_build(dom, @funcStr, vm)
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
  _parseElment:(el, vm, parent)=>
    dom = new Dom(el, vm)
    if parent
      parent.children.push dom
      dom.parent = parent
    else
      dom.isContainer = true
    children = el.childNodes
    @args = dom.bind(@args)
    @_parseElment(child, vm, dom) for child in children
    return dom


  ###*
    ビルドを実行する
    @method _build
    @private
    @param dom {Dom}
    @param funcStrs {Array}
    @param vm {Ikari}
  ###
  _build:(dom, funcStrs, vm)=>
    dom.build(funcStrs)
    funcStrs.push 'return p.join("");'
    str = funcStrs.join("")
    args = [].concat(@args)
    args.push str
    vm.compiler = new Function( args... )
    vm.isBuilded = true
    localStorage.setItem vm.compilerCacheName, args if vm.cachable

    #event 出す
    vm.emit new Event(Event.BUILDED)
    return


module.exports = Builder