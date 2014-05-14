class Event
  @BUILDED: "builded"
  @UPDATED: "updated"


  type : null

  isPropagate : true


  ###*
    イベントオブジェクト
    @class Event
  ###
  constructor:(@type)->


module.exports = Event