define ( require ) ->

  SectionController = require './section-controller'
  Data = require './data/data-binding'

  class DataBindingController extends SectionController

    view: 'data-binding'
    category: 'Documentation'
    title: 'Data Binding'

    searchEnabled: true
    searchTerm: ''

    bindings: Data

    constructor: ->

    formatSyntax: ( binding ) ->
      syntax = binding.syntax
      for arg in binding.args or []
        syntax = syntax.replace arg.name, """<span class="blue">#{ arg.name }</span>"""
      syntax = syntax.replace( '#{', '#\\{' )
      return syntax

    test: ( binding ) =>
      term = @searchTerm.toLowerCase()
      return true unless @searchTerm
      return true if binding.title.toLowerCase().match( term )
      return true if binding.syntax.toLowerCase().match( term )
      for arg in binding.args or []
        return true if arg.name.toLowerCase().match( term )

    highlight: ( text ) =>
      return text.replace( '#{', '#\\{' ) unless @searchTerm
      regexString = @searchTerm.replace( /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&" )
      regex = new RegExp( regexString, 'gi' )
      newText = text.replace regex, ( match ) -> """<span class="highlight">#{ match }</span>"""
      return newText.replace( '#{', '#\\{' )
