Foundation = require 'art-foundation'
{
  lowerCamelCase, wordsArray, isPlainObject, log, compactFlatten
  isString, compactFlatten, deepEachAll, uniqueValues
  isNumber
} = Foundation

TableApiBaseClass = require './TableApiBaseClass'

module.exports = class UpdateItem extends TableApiBaseClass
  ###
  IN: params:
    table:                  string (required)

  ###
  _translateParams: (params) =>
    @_translateKey params
    @_translateUpdateExpression params
    @_translateOptionalParams params
    @_target

  ###
  item: plainObject
    # equivelent to updates: myAttr: set: myValue
    # for myAttr, myValue of plainObject
  OR

  updates:
    attributeName: set: myValue

    myNumberAttr: add: 10 # adds 10 (0 is the default initial value if not already set)
    mySetAttr:    add: <set> # sets mySetAttr to the merged sets

    attributeName: delete: # delete an element from a set
    attributeName: "remove" # remove the attribute
  ###
  _translateUpdateExpression: (params) =>
    {item} = params
    throw new Error "item required" unless item

    actions = for attributeName, attributeValue of item
      uniqueId = @_getNextUniqueExpressionAttributeId @_target
      attributeAlias = "#attr#{uniqueId}"
      valueAlias = ":val#{uniqueId}"
      @_addExpressionAttributeName attributeAlias, attributeName
      @_addExpressionAttributeValue valueAlias, attributeValue
      "#{attributeAlias} = #{valueAlias}"

    @_target.UpdateExpression = "SET #{actions.join ', '}"
    @_target

  ReturnConsumedCapacity: 'INDEXES | TOTAL | NONE',
  ReturnItemCollectionMetrics: 'SIZE | NONE',
  ReturnValues: 'NONE | ALL_OLD | UPDATED_OLD | ALL_NEW | UPDATED_NEW'

  _translateOptionalParams: (params) ->
    @_translateConditionalExpression params
    @_translateConstantParam params, "returnConsumedCapacity"
    @_translateConstantParam params, "returnItemCollectionMetrics"
    @_translateConstantParam params, "returnValues", "updatedNew"