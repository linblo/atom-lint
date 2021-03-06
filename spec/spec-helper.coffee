{WorkspaceView} = require 'atom'
path = require 'path'
fs = require 'fs'
temp = require 'temp'

window.prepareWorkspace = (options = {}) ->
  projectPath = temp.mkdirSync('lint-runner-spec-')
  atom.project.setPath(projectPath)

  sampleFilename = 'sample.txt'
  sampleFilePath = path.join(projectPath, sampleFilename)
  fs.writeFileSync(sampleFilePath, 'foo = 1')

  atom.workspaceView = new WorkspaceView
  atom.workspaceView.attachToDom()
  atom.workspaceView.openSync(sampleFilename)

  if options.activatePackage
    waitsForPromise ->
      atom.packages.activatePackage('atom-lint')

  editorView: atom.workspaceView.getActiveView()

window.waitsForEventToBeEmitted = (targetObject, eventName, context) ->
  emitted = false

  targetObject.on eventName, ->
    emitted = true

  context()

  waitsFor ->
    emitted

window.expectEventNotToBeEmitted = (targetObject, eventName, context) ->
  emitted = false

  targetObject.on eventName, ->
    emitted = true

  context()

  waits(100)

  runs ->
    expect(emitted).toBe(false)

window.loadGrammar = (languageName) ->
  # See /usr/local/bin/atom
  atomAppPath = process.env.ATOM_PATH || '/Applications/Atom.app'
  builtinPackageDir = path.join(atomAppPath, 'Contents/Resources/app/node_modules')
  relativeGrammarFilePath = "language-#{languageName}/grammars/#{languageName}.json"
  absoluteGrammarFilePath = path.join(builtinPackageDir, relativeGrammarFilePath)
  atom.syntax.loadGrammarSync(absoluteGrammarFilePath)
