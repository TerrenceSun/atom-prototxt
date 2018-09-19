{$, View} = require 'atom-space-pen-views'
module.exports =
class LanguagePrototxtView extends View
  panel: null
  @content: ->
    @div class: 'language-prototxt', =>
      @div class: 'language-prototxt-view-scroller order--center', outlet: 'scroller', =>
        @ol class: 'language-prototxt-view full-menu list-tree focusable-panel', outlet: 'list'

  initialize:(state) ->
    @handleEvents()

  getTitle: -> 'Layer Outline'
  getURI: -> 'atom://language-prototxt'
  getPreferredLocation: -> 'right'
  isPermantDockItem: -> true
  getAllowedLocations: -> ["left", "right"]

  serialize: ->

  destroy: ->

  handleEvents: ->

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
