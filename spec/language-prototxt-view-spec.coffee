LanguagePrototxtView = require '../lib/language-prototxt-view'

describe "LanguagePrototxtView", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('language-prototxt')

  it "has the elements", ->
    expect(workspaceElement.querySelector('.language-prototxt')).toExist()
