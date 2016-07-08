AWS = require 'aws-sdk'
AWS.config.region = 'us-west-2'
Foundation = require 'art-foundation'
{log} = Foundation
{DynamoDb} = require 'art-aws'

testTableName = 'fooBarTestTable'

suite "Art.Ery.Aws", ->
  @timeout 10000

  dynamoDb = null
  setup ->
    dynamoDb = new DynamoDb endpoint: "http://localhost:8081"
    dynamoDb.listTables()
    .then ({TableNames}) ->
      list = for tableName in TableNames
        if tableName == testTableName
          log "Deleting test table: #{testTableName}"
          dynamoDb.deleteTable TableName: tableName
        else
          throw new Error "not test-table found: #{testTableName}"
      Promise.all list

  test "listTables", ->
    dynamoDb.listTables()
    .then (tables) ->
      assert.eq tables.TableNames, []
      log tables

  test "createTable", ->
    dynamoDb.createTable TableName: testTableName
    .then (tables) ->
      log tables
