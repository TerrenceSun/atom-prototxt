{$, View} = require 'atom-space-pen-views'
module.exports =
class LanguagePrototxtView extends View
  panel: null
  @content: ->
    @div class: 'language-prototxt-view-resizer tool-panel', 'show-on-right-side': atom.config.get('language-prototxt.show-on-right-side'), =>
      @div "Layer Outline"
      @div class: 'language-prototxt-view-scroller order--center', outlet: 'scroller', =>
        @ol class: 'language-prototxt-view full-menu list-tree focusable-panel', outlet: 'list'
      @div class: 'language-prototxt-view-resize-handle', outlet: 'resizeHandle'

  initialize:(state) ->
    @handleEvents()

  serialize: ->

  destroy: ->


  handleEvents: ->
    @on 'mousedown', '.language-prototxt-view-resize-handle', (e) => @resizeStarted(e)


  resizeStarted: =>
    console.log 'Mouse Down!'
    $(document).on('mousemove', @resizeTreeView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizeTreeView)
    $(document).off('mouseup', @resizeStopped)

  resizeTreeView: ({pageX, which}) =>
    return @resizeStopped() unless which is 1

    if atom.config.get('language-prototxt.show-on-right-side')
      width = @outerWidth() + @offset().left - pageX
    else
      width = pageX - @offset().left
    @width(width)

  onContentsModified: (editor, force = false) ->
    @list.empty()
    return if not editor
    return if editor.getGrammar().name isnt 'PROTOTXT'

    # console.log (editor.getPath())
    if editor != atom.workspace.getActiveTextEditor()
      return
    cursor = editor.getCursorBufferPosition()
    row = cursor.row
    col = cursor.column
    buffer = editor.getBuffer()
    lastChar = buffer.getTextInRange [[row, col - 1], [row, col]]

    @list.empty()
    for layer, id in @layerScan(buffer)
      [row, name] = layer
      $('<li/>').text("Layer #{name}").addClass('language-prototxt-view-list-entry').data('row', row).appendTo(@list)

    @on 'click', '.language-prototxt-view-list-entry', @onClick
    @selectionUpdate()


  onClick: (e) ->
    $('.language-prototxt-view-selected-entry').removeClass('language-prototxt-view-selected-entry')
    $(e.target).addClass("language-prototxt-view-selected-entry")
    row = $(e.target).data('row')
    atom.workspace.getActiveTextEditor().setCursorBufferPosition([row, 1])
    atom.workspace.getActiveTextEditor().scrollToCursorPosition()
    #console.log ("clicked #{e.srcElement} #{e.target} #{row}")

  selectionUpdate: ->
    editor = atom.workspace.getActiveTextEditor()
    return if not editor
    return if editor.getGrammar().name isnt 'PROTOTXT'
    cursor = editor.getCursorBufferPosition()
    row = cursor.row
    entrySelected = false
    for entry in $('.language-prototxt-view-list-entry').get().reverse()
      if $(entry).data('row') <= row && !entrySelected
        entrySelected = true
        if !$(entry).hasClass('language-prototxt-view-selected-entry')
          $('.language-prototxt-view-selected-entry').removeClass('language-prototxt-view-selected-entry')
          $(entry).addClass("language-prototxt-view-selected-entry")

          #$('.language-prototxt-view-scroller').scrollTop($(entry).offset().top - $('.language-prototxt-view-scroller').offset().top + $('.language-prototxt-view-scroller').scrollTop())
          $('.language-prototxt-view-scroller').animate({
            scrollTop: $(entry).offset().top - $('.language-prototxt-view-scroller').offset().top  + $('.language-prototxt-view-scroller').scrollTop() - $('.language-prototxt-view-scroller').height()/2 + $(entry).height()/2
            })

  layerScan: (buffer) ->
    layers = []
    depth = 0
    buffer.scanInRange /(layer)|name\s*:\s*"(.*)"|({)|(})/g, buffer.getRange(), (obj) =>
      if obj.match[1]
        layers.push([obj.range.start.row,"N/A"])
        depth = 0
      if obj.match[2] && depth == 1
        layers[layers.length-1][1] = obj.match[2]
      if obj.match[3]
        depth++
      if obj.match[4]
        depth--
    layers
