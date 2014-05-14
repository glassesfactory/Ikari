Config = require "./config"
Parser = require "./parser"

prefix     = Config.prefix

statements = Config.statements

options    = Config.options

singleTags  = Config.singleTags


class Dom

  #オリジナル
  el : null

  vm : null

  tagName : null

  isSingleTag : false

  #最初
  preStatement : null

  #大体閉じる
  appendStatement : null


  children : null

  hasLoop : false

  hasIf   : false

  valOnly : false

  isText : false

  isContainer : false


  parent : null


  constructor:(@el, @vm)->
    @children = []
    if @el.nodeType is 3
      @isText = true
    else
      @tagName = @el.tagName.toLowerCase()
      @isSingleTag = singleTags.indexOf(@tagName) > -1

  ###*
    性格付け
    @metdho bind
  ###
  bind:(args)=>
    if @isText
      return args
    attributes = @el.attributes
    @attributes = ""
    for attr in attributes
      if not attr.name.match(prefix + "-")
        @attributes += " " + attr.name + '="' + Parser.parseText(attr.value) + '"'
      hasStatements = statements.indexOf(attr.nodeName.replace(prefix + "-", ""))
      if hasStatements > -1
        statement = statements[hasStatements]
        @hasLoop = true if statement is "loop"
        @hasIf   = true if statement is "if"


      hasOptions = options.indexOf(attr.nodeName.replace(prefix + "-", ""))
      if hasOptions > -1
        opt = options[hasOptions]
        @valOnly = true if opt is "val-only"



    if @hasLoop and @hasIf
      throw new Error("同時に指定はできませんよ。できないんです。勘弁して下さい。")

    #うーむ…
    if @hasLoop
      str = @el.getAttribute(prefix + "-" + "loop")
      loopSet = Parser.loop str
      args.push loopSet["key"]
      if loopSet
        @preStatement = "for( var i = 0; i < " + loopSet["key"] + ".length; i++){ var " + loopSet["item"] + "= " + loopSet["key"] + "[i];"
        @appendStatement = "};"

    if @hasIf
      str = @el.getAttribute(prefix + "-" + "if")
      @preStatement = "if(" + str + "){"
      @appendStatement = "};"
    return args


  _checkAttr:(el)->
    return


  ###*
    ラインを組み立てる
    @method build
  ###
  build:(lines)=>
    @_preBuild lines unless @isContainer
    child.build(lines) for child in @children
    @_appendBuild lines unless @isContainer
    return


  ###*
    開始
    @method _preBuild
    @private
  ###
  _preBuild:(lines)=>
    if @preStatement
      lines.push @preStatement
    if @valOnly
      return
    #nodeType が 3 だったら
    if @isText
      lines.push "p.push('" + Parser.parseText @el.textContent + "');"
    else
      lines.push "p.push('<" + @tagName + @attributes + ">');"
    # el = @_slimAttr @el.cloneNode()
    return


  ###*
    終了
    @method _appendBuild
    @private
  ###
  _appendBuild:(lines)=>
    if @isText
      return
    lines.push "p.push('</" + @tagName + ">');" if not @isSingleTag
    lines.push @appendStatement if @appendStatement
    return


module.exports = Dom