Foundation = require 'art-foundation'
{
  lowerCamelCase, wordsArray, isPlainObject, log, compactFlatten
  isString, compactFlatten, deepEachAll, uniqueValues
  isNumber
} = Foundation

TableApiBaseClass = require './TableApiBaseClass'

module.exports = class GetItem extends TableApiBaseClass
  ###
  IN: params:
    table:                  string (required)

  ###
  _translateParams: (params) ->
    @_translateKey params
    @_translateOptionalParams params
    @_target

  _translateOptionalParams: (params) ->
    @_translateConsistentRead params
    @_translateConsumedCapacity params
    @_translateSelect params