utils = require "./utils"
Config = require "./config"
Parser = require "./parser"

prefix     = Config.prefix

statements = Config.statements

options    = Config.options

singleTags  = Config.singleTags


class Dom

  #オリジナル
  el: null

  vm: null

  tagName: null

  klsName: null

  idName: null

  elName: null

  isSingleTag: false

  #最初
  preStatement: null

  #大体閉じる
  appendStatement: null


  children: null

  hasLoop: false

  hasIf: false

  hasDirective: false

  valOnly: false

  isText: false

  isContainer: false


  parent: null

  inLoop: false


  constructor: (@el, @vm) ->
    this.children = []
    if this.el.nodeType is 3
      this.isText = true
    else
      this.tagName = this.el.tagName.toLowerCase()
      this.isSingleTag = singleTags.indexOf(this.tagName) > -1

      this.klsName = Parser.klsParser this.el.className
      this.idName = this.el.id
      this.elName = this._buildElName()
  ###*
    性格付け
    @metdho bind
  ###
  bind: (args, ignores, parent) =>
    if this.isText
      return args

    attributes = this.el.attributes
    this.attributes = ""
    this.inLoop = true if parent and (parent.hasLoop or parent.inLoop)

    for attr in attributes
      this.attributes += " " + attr.name + '="' + Parser.parseText(attr.value, args, ignores) + '"' unless attr.name.match(prefix + "-")

      hasStatements = statements.indexOf(attr.nodeName.replace(prefix + "-", ""))
      if hasStatements > -1
        statement = statements[hasStatements]
        this.hasLoop = true if statement is "loop"
        this.hasIf   = true if statement is "if"
        this.hasDirective = true if statement is "on"


      hasOptions = options.indexOf(attr.nodeName.replace(prefix + "-", ""))
      if hasOptions > -1
        opt = options[hasOptions]
        this.valOnly = true if opt is "val-only"

    throw new Error("同時に指定はできませんよ。できないんです。勘弁して下さい。") if this.hasLoop and this.hasIf


    #うーむ…
    if this.hasLoop
      str = this.el.getAttribute(prefix + "-" + "loop")
      loopSet = Parser.loop str
      args.push loopSet["key"] if loopSet["key"].indexOf('.') < 0 and not this.inLoop
      unless this.inLoop
        # ルートがコンパイラ引数に登録されているかチェックし、なければ登録する。
        root = loopSet["key"].split('.')[0]
        args.push root if utils._inArray(root, args) < 0
      ignores.push loopSet["item"]
      if loopSet
        counter = "i" + this.vm.builder.incrementer
        this.vm.builder.incrementer++
        this.preStatement = "for( var " + counter + " = 0; " + counter + " < this.datas['" + loopSet["key"] + "'].length; " + counter + "++){ var " + loopSet["item"] + "= this.datas['" + loopSet["key"] + "'][" + counter + "];"
        this.appendStatement = "};"
    if this.hasIf
      str = this.el.getAttribute(prefix + "-" + "if")
      this.preStatement = "if(" + str + "){"
      this.appendStatement = "};"

    #ディレクティブがあるならパースしとく
    this._parseDirective() if this.hasDirective

    return args


  _parseDirective: =>
    #複数指定するときどうするかね
    str = this.el.getAttribute prefix + '-' + 'on'
    directives = str.split(',')
    
    for str in directives
      directive = str.split(':')
      action = directive[0]
      method = directive[1]
      this.vm._methodsMap.push
        path: this._getPath()
        action: action
        method: method
    return


  _getPath: =>
    parent = this.parent
    path = this.elName
    while parent
      path = parent.elName + ' ' + path
      parent = parent.parent

    return path


  _buildElName: =>
    elName = this.tagName
    elName += '#' + this.idName if this.idName
    elName += '.' + this.klsName if this.klsName
    return elName


  ###*
    ラインを組み立てる
    @method build
  ###
  build: (lines) =>
    this._preBuild lines
    # this._preBuild lines unless this.isContainer
    for child in this.children
      child.inLoop = true if this.hasLoop or this.inLoop
      child.build(lines)
    # this._appendBuild lines unless this.isContainer
    this._appendBuild lines
    return


  ###*
    開始
    @method _preBuild
    @private
  ###
  _preBuild: (lines) =>
    # if this.valOnly
    #   return
    #nodeType が 3 だったら
    if this.preStatement
      lines.push this.preStatement
    if this.isText
      #ie8 は textContent がないので nodeValue
      #ややこしい判定も IE8 は hasOwnproperty を Object インスタンスが何故か持っていないのでプロトタイプから直接呼び出し。
      val =  if Object::hasOwnProperty.call(this.el, "textContent") then this.el.textContent else this.el.nodeValue
      lines.push "p.push('" + Parser.parseText(val, this.vm.builder.args, this.vm.builder.ignores) + "');"
    else
      unless this.valOnly
        lines.push "p.push('<" + this.tagName + this.attributes + ">');"

    return


  ###*
    終了
    @method _appendBuild
    @private
  ###
  _appendBuild: (lines) =>
    if this.isText
      return
    unless this.valOnly
      lines.push "p.push('</" + this.tagName + ">');" if not this.isSingleTag
    lines.push this.appendStatement if this.appendStatement
    return


module.exports = Dom
