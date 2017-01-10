Foundation = require 'art-foundation'
{log, isPlainArray, ConfigRegistry} = Foundation
{DynamoDb, config} = require 'art-aws'

testTableName = 'fooBarTestTable'

suite "Art.Ery.Aws.DynamoDb.live", ->
  @timeout 10000

  dynamoDb = null
  setup ->
    dynamoDb = new DynamoDb

    dynamoDb.listTables()
    .then ({TableNames}) ->
      list = for table in TableNames
        if table == testTableName
          log "Deleting test table: #{testTableName}"
          dynamoDb.deleteTable TableName: table
        # else
        #   log "NOT deleting non-test-table: #{table}"
      Promise.all list

  chatRoomId = "xyz456"
  createItems = ->
    Promise.all [
      dynamoDb.putItem table: testTableName, item: chatRoom: chatRoomId, id: 1, message: "Hello!", createdAt: 400
      dynamoDb.putItem table: testTableName, item: chatRoom: chatRoomId, id: 2, message: "world!", createdAt: 300
    ]
  createTable = ->
    dynamoDb.createTable
      table: testTableName
      globalIndexes: chatsByChatRoomCreatedAt: "chatRoom/createdAt"
      attributes:
        id: "number"
        chatRoom:  "string"
        createdAt: "number"
      key: "chatRoom/id"
    .then (result) -> createItems()

  test "listTables", ->
    dynamoDb.listTables()
    .then (tables) ->
      assert.eq true, isPlainArray tables.TableNames
      # log tables

  test "createTable", ->
    dynamoDb.createTable table: testTableName
    # .then (result) ->
    #   log result

  test "create complex table", ->
    dynamoDb.createTable
      table: testTableName
      attributes:
        createdAt: "number"
        chatRoom:  "string"
      key: "chatRoom/createdAt"
    .then (result) ->
      # log createResult: result
      data =
        createdAt: Date.now()
        updatedAt: Date.now()
        user: "abc123"
        chatRoom: "xyz456"
        message: "Hi!"
        id: "lmnop123123"
      dynamoDb.putItem
        table: testTableName
        item: data

  suite "describe", ->
    test "describeTable", ->
      createTable()
      .then -> dynamoDb.describeTable table: testTableName
      .then (res) -> assert.eq res.Table.TableName, testTableName

    test "describeLimits", ->
      createTable()
      .then -> dynamoDb.describeLimits()
      .then (res) -> assert.gt res.AccountMaxReadCapacityUnits, 0

  suite "query", ->

    test "basic primary key", ->
      createTable()
      .then ->
        dynamoDb.query
          table: testTableName
          where: chatRoom: chatRoomId
      .then (result)->
        assert.eq ["Hello!", "world!"], (item.message for item in result.items)
        assert.eq result.items[0],
          id:         1
          message:    "Hello!"
          chatRoom:   "xyz456"
          createdAt:  400

    test "basic global index", ->
      createTable()
      .then ->
        dynamoDb.query
          table: testTableName
          index: "chatsByChatRoomCreatedAt"
          where: chatRoom: chatRoomId
      .then (result)->
        assert.eq ["world!", "Hello!"], (item.message for item in result.items)
        assert.eq result.items[0],
          id:       2
          message:  "world!"
          chatRoom: "xyz456"
          createdAt:  300

    test "select: 'message'", ->
      createTable()
      .then ->
        dynamoDb.query
          table: testTableName
          where: chatRoom: chatRoomId
          select: "message"
      .then (result)->
        assert.eq ["Hello!", "world!"], (item.message for item in result.items)
        assert.eq result.items[0],
          message:  "Hello!"

    test "descending: true", ->
      createTable()
      .then ->
        dynamoDb.query
          table: testTableName
          descending: true
          where: chatRoom: chatRoomId
      .then (result)->
        assert.eq ["world!", "Hello!"], (item.message for item in result.items)

    test "where: id: gt: 1", ->
      createTable()
      .then ->
        dynamoDb.query
          table: testTableName
          descending: true
          where: chatRoom: chatRoomId, id: gt: 1
      .then (result)->
        assert.eq ["world!"], (item.message for item in result.items)

    test "filter: message: beginsWith: 'H'", ->
      createTable()
      .then ->
        dynamoDb.query
          table: testTableName
          descending: true
          where: chatRoom: chatRoomId
          filter: message: beginsWith: 'H'
      .then (result)->
        assert.eq ["world!", "Hello!"], (item.message for item in result.items)

    test 'createTable regression', ->
      dynamoDb.createTable
        table: testTableName
        attributes:
          id: "string"
          createdAt: "number"
          chatRoom: "string"
        globalIndexes:
          chatsByChatRoom: "chatRoom/createdAt"