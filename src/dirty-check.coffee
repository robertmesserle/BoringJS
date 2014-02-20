shared = require( './shared.coffee' )
root   = window

class DirtyCheck

  @originalMethods: {}
  @instance:        null
  @lastCheck:       0
  @timeout:         null

  @update: ->
    return if @timeout
    now = +new Date()
    waitTime = now - @lastCheck
    @lastCheck = now
    if waitTime > shared.throttle then waitTime = 0
    callback = =>
      @timeout = null
      for set in [ { type: 'write', method: 'write' }, { type: 'read', method: 'update' } ]
        for binding in shared.bindings[ set.type ]
          binding[ set.method ]()
    if waitTime then @timeout = @originalMethods.setTimeout callback, waitTime
    else callback()

  elementList:
    if typeof InstallTrigger isnt 'undefined' then [ HTMLAnchorElement, HTMLAppletElement, HTMLAreaElement, HTMLAudioElement, HTMLBaseElement, HTMLBodyElement, HTMLBRElement, HTMLButtonElement, HTMLCanvasElement, HTMLDataListElement, HTMLDirectoryElement, HTMLDivElement, HTMLDListElement, HTMLElement, HTMLEmbedElement, HTMLFieldSetElement, HTMLFontElement, HTMLFormElement, HTMLFrameElement, HTMLFrameSetElement, HTMLHeadElement, HTMLHeadingElement, HTMLHtmlElement, HTMLHRElement, HTMLIFrameElement, HTMLImageElement, HTMLInputElement, HTMLLabelElement, HTMLLegendElement, HTMLLIElement, HTMLLinkElement, HTMLMapElement, HTMLMediaElement, HTMLMenuElement, HTMLMetaElement, HTMLMeterElement, HTMLModElement, HTMLObjectElement, HTMLOListElement, HTMLOptGroupElement, HTMLOptionElement, HTMLOutputElement, HTMLParagraphElement, HTMLParamElement, HTMLPreElement, HTMLProgressElement, HTMLQuoteElement, HTMLScriptElement, HTMLSelectElement, HTMLSourceElement, HTMLSpanElement, HTMLStyleElement, HTMLTableElement, HTMLTableCaptionElement, HTMLTableColElement, HTMLTableRowElement, HTMLTableSectionElement, HTMLTextAreaElement, HTMLTitleElement, HTMLUListElement, HTMLUnknownElement, HTMLVideoElement ]
    else [ Element ]

  constructor: ->
    return @constructor.instance if @constructor.instance
    @constructor.instance = this
    @bindEvents()
    @overwriteEventListeners()
    @overwriteTimeouts()

  getListener: ( originalMethod ) ->
    ( type, listener ) ->
      args = Array arguments...
      args[ 1 ] = ->
        listener( arguments... )
        if type.indexOf( 'down' ) >= 0 then setTimeout -> DirtyCheck.update()
        else DirtyCheck.update()
      originalMethod.apply( this, args )

  overwriteEventListeners: ->

    for type in @elementList
      originalMethod = type.prototype.addEventListener
      if originalMethod
        type.prototype.addEventListener = @getListener originalMethod
      originalMethod = type.prototype.attachEvent
      if originalMethod
        type.prototype.attachEvent = @getListener originalMethod

  overwriteTimeouts: ->
    for func in [ 'setTimeout', 'setInterval' ]
      originalMethod = root[ func ]
      do ( originalMethod ) =>
        @constructor.originalMethods[ func ] = ->
          originalMethod.apply( root, arguments )
        root[ func ] = ( func, timeout ) ->
          args = Array arguments...
          args[ 0 ] = ->
            func( arguments... )
            DirtyCheck.update()
          originalMethod.apply( root, args )

  bindEvents: ->
    $ ->
      $( document )
        .ajaxComplete( -> DirtyCheck.update() )
        .on( 'load', 'script', -> DirtyCheck.update() )
        .on( 'click keydown', 'label', -> setTimeout -> DirtyCheck.update() )

module.exports = DirtyCheck
