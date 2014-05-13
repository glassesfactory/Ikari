Config = require "./config"
Dom    = require "./dom"
Event  = require "./event"


class Builder

  el : null

  funcStr : []

  ###*
    HTML バインドしてきてなんかする
    @class Builder
  ###
  constructor:(el, vm)->
    @el = query el

    @funcStr = ["var p = [];"]
    @args = []


  build:(vm)=>
    dom = @_parseElment @el, vm
    @_build(dom, @funcStr, vm)
    return


  ###*
    エレメントをパースする
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


  _build:(dom, funcStr, vm)=>
    dom.build(funcStr)
    funcStr.push 'return p.join("");'
    str = funcStr.join("")
    args = [].concat(@args)
    args.push str
    vm.compiler = new Function( args... )
    #event 出す
    vm.emit new Event(Event.BUILDED)
    return

###*
  セレクタ取ってくる
  @method query
###
query = (q)->
  return if typeof q is "string" then document.querySelector q else q


module.exports = Builder