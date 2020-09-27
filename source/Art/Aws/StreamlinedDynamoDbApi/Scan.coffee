{
  lowerCamelCase, wordsArray, isPlainObject, log, compactFlatten
  isString, compactFlatten, deepEachAll, uniqueValues
  isNumber
} = require 'art-standard-lib'

TableApiBaseClass = require './TableApiBaseClass'

module.exports = class Scan extends TableApiBaseClass
  ###
  IN: params:
    table:                  string (required)

  ###
  _translateParams: (params) ->
    @_translateOptionalParams params
    @_target

  _translateOptionalParams: (params) ->
    @_translateLimit params
    @_translateExclusiveStartKey params
