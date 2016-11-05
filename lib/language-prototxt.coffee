LanguagePrototxtView = require './language-prototxt-view'
{CompositeDisposable} = require 'atom'

module.exports = LanguagePrototxt =

  languagePrototxtView: null
  outlinePanel: null
  subscriptions: null

  config:
    "show-on-right-side":
      type: 'boolean'
      default: true
      description: "Check to show the guidline on right side of the window."
    "auto-reactivate":
      type: 'boolean'
      default: true
      description: "Check to reactive guidline window according to last activate status."
    "activated":
      type: 'boolean'
      default: false
      description: "The last activate status."

  activate: (state) ->
    @languagePrototxtView = new LanguagePrototxtView(state.languagePrototxtViewState)
    @outlinePanel = atom.workspace.addRightPanel(item: @languagePrototxtView, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'language-prototxt:toggle': => @toggle()

    atom.workspace.onDidStopChangingActivePaneItem @populateOutline.bind(this)

    if atom.config.get('language-prototxt.auto-reactivate') and atom.config.get('language-prototxt.activated')
      @outlinePanel.show()
      @populateOutline()



  deactivate: ->
    @subscriptions.dispose()
    @outlinePanel.destroy()
    @languagePrototxtView.destroy()

  serialize: ->
    languagePrototxtViewState: @languagePrototxtView.serialize()

  toggle: ->
    console.log 'LanguagePrototxt was toggled!'
    #console.log atom.workspace.getActiveTextEditor().getGrammar().name
    if @outlinePanel.isVisible()
      @outlinePanel.hide()
    else
      @outlinePanel.show()
      @populateOutline()
    atom.config.set('language-prototxt.activated', @outlinePanel.isVisible())

  populateOutline: ->
    editor = atom.workspace.getActiveTextEditor()
    return if not editor
    @languagePrototxtView.onContentsModified(editor)

    editor.getBuffer().onDidStopChanging @languagePrototxtView.onContentsModified.bind(@languagePrototxtView, editor, false)
    editor.onDidChangeCursorPosition (e) =>
      @languagePrototxtView.selectionUpdate() if e.oldBufferPosition.row != e.newBufferPosition.row
