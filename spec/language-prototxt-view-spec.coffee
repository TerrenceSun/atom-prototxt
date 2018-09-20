LanguagePrototxtView = require '../lib/language-prototxt-view'

describe "LanguagePrototxtView", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('language-prototxt')

  it "has the elements", ->
    # This is an activation event, triggering it causes the package to be
    # activated.
    atom.commands.dispatch workspaceElement, 'language-prototxt:toggle'

    waitsForPromise ->
      activationPromise

    runs ->
      expect(workspaceElement.querySelector('.language-prototxt')).toExist()
