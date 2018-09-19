LanguagePrototxtView = require './language-prototxt-view'
{CompositeDisposable} = require 'atom'

module.exports = LanguagePrototxt =
  languagePrototxtView: null
  subscriptions: null


  activate: (state) ->
    @languagePrototxtView = new LanguagePrototxtView(state.languagePrototxtViewState)

    atom.workspace.open(@languagePrototxtView).then =>
      # the panel would be shown by default
      # we will hide the panel if activate status is turned on, and it was toggled off
      if atom.config.get('language-prototxt.autoReactivate') and not atom.config.get('language-prototxt.active')
        atom.workspace.paneContainerForURI(@languagePrototxtView.getURI()).hide()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'language-prototxt:toggle': => @toggle()

    atom.workspace.onDidStopChangingActivePaneItem @populateOutline.bind(this)




  deactivate: ->
    @subscriptions.dispose()
    @languagePrototxtView.destroy()

  serialize: ->
    languagePrototxtViewState: @languagePrototxtView.serialize()

  toggle: ->
    console.log 'LanguagePrototxt was toggled!'
    atom.workspace.toggle(@languagePrototxtView).then =>
      atom.config.set('language-prototxt.active', atom.workspace.paneContainerForURI(@languagePrototxtView.getURI()).isVisible())

  populateOutline: ->
    editor = atom.workspace.getActiveTextEditor()
    return if not editor
    @languagePrototxtView.onContentsModified(editor)

    editor.getBuffer().onDidStopChanging @languagePrototxtView.onContentsModified.bind(@languagePrototxtView, editor, false)
    editor.onDidChangeCursorPosition (e) =>
      @languagePrototxtView.selectionUpdate() if e.oldBufferPosition.row != e.newBufferPosition.row
