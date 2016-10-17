{log} = require 'art-foundation'
{CreateTable} = Neptune.Art.Aws.StreamlinedDynamoDbApi
# { _translateProvisioning, _translateKey, _translateAttributes
#   _translateGlobalIndexes
#   _translateLocalIndexes
#   new CreateTable().translateParams
#   _getKeySchemaAttributes
# } = Neptune.Art.Aws.StreamlinedDynamoDbApi.CreateTable

module.exports = suite:
  translateParams: ->
    test "new CreateTable().translateParams() has defaults", ->
      assert.eq new CreateTable().translateParams(table: "foo"),
        TableName:             "foo"
        AttributeDefinitions:  [AttributeName: "id", AttributeType: "S"]
        KeySchema:             [AttributeName: "id", KeyType: "HASH"]
        ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1

    test "new CreateTable().translateParams() override defaults", ->
      assert.eq new CreateTable().translateParams(
        table:             "foo"
        attributes: myKey: 'string'
        key: 'myKey'
        provisioning: read: 10
      ),
        TableName:             "foo"
        AttributeDefinitions:  [AttributeName: "myKey", AttributeType: "S"]
        KeySchema:             [AttributeName: "myKey", KeyType: "HASH"]
        ProvisionedThroughput: ReadCapacityUnits: 10, WriteCapacityUnits: 1

    test 'createTable regression', ->
      assert.eq(
        CreateTable.translateParams
          table: 'chat'
          attributes:
            id: "string"
            createdAt: "number"
            chatRoom: "string"
          globalIndexes:
            chatsByChatRoom: "chatRoom/createdAt"
      ,
        TableName:              "chat"
        GlobalSecondaryIndexes: [
          IndexName:             "chatsByChatRoom"
          KeySchema: [
            {AttributeName: "chatRoom",  KeyType:       "HASH"}
            {AttributeName: "createdAt", KeyType:       "RANGE"}
          ]
          Projection:            ProjectionType: "ALL"
          ProvisionedThroughput:
            ReadCapacityUnits:  1
            WriteCapacityUnits: 1
        ]
        KeySchema: [
          AttributeName: "id"
          KeyType:       "HASH"
        ]
        AttributeDefinitions: [
          {AttributeName: "chatRoom", AttributeType: "S"}
          {AttributeName: "createdAt", AttributeType: "N"}
          {AttributeName: "id", AttributeType: "S"}
        ]
        ProvisionedThroughput:
          ReadCapacityUnits:  1
          WriteCapacityUnits: 1
      )

  _translateProvisioning: ->
    test "_translateProvisioning() has defaults", ->
      assert.eq new CreateTable()._translateProvisioning(),
        ProvisionedThroughput:
          ReadCapacityUnits: 1
          WriteCapacityUnits: 1

    test "_translateProvisioning provisioning: read: 10, write: 20", ->
      assert.eq new CreateTable()._translateProvisioning(provisioning: read: 10, write: 20),
        ProvisionedThroughput:
          ReadCapacityUnits: 10
          WriteCapacityUnits: 20

  _translateKey: ->
    test "_translateKey()", ->
      assert.eq new CreateTable()._translateKey({}), KeySchema: [AttributeName: "id", KeyType: "HASH"]

    test "_translateKey key: foo: 'hash'", ->
      assert.eq new CreateTable()._translateKey(key: foo: "hash"),
        KeySchema: [AttributeName: "foo", KeyType: "HASH"]

    test "_translateKey key: 'foo'", ->
      assert.eq new CreateTable()._translateKey(key: 'foo'),
        KeySchema: [AttributeName: "foo", KeyType: "HASH"]

    test "_translateKey key: 'foo/bar'", ->
      assert.eq new CreateTable()._translateKey(key: 'foo/bar'),
        KeySchema: [
          {AttributeName: "foo", KeyType: "HASH"}
          {AttributeName: "bar", KeyType: "RANGE"}
        ]

    test "_translateKey key: 'foo-bar'", ->
      assert.eq new CreateTable()._translateKey(key: 'foo-bar'),
        KeySchema: [
          {AttributeName: "foo", KeyType: "HASH"}
          {AttributeName: "bar", KeyType: "RANGE"}
        ]

  _translateAttributes: ->
    test "_translateAttributes()", ->
      assert.eq new CreateTable()._translateAttributes({}, id: true), AttributeDefinitions: [AttributeName: "id", AttributeType: "S"]

    test "Attributes: foo: 'string'", ->
      assert.eq new CreateTable()._translateAttributes(attributes: foo: "string", {foo: true}),
        AttributeDefinitions: [AttributeName: "foo", AttributeType: "S"]

    test "Attributes: all types", ->
      assert.eq new CreateTable()._translateAttributes(
        attributes:
          aString: "string"
          aNumber: "number"
          aBinary: "binary"
        {aString: true, aNumber: true, aBinary: true}
      ), AttributeDefinitions: [
        {AttributeName: "aBinary", AttributeType: "B"}
        {AttributeName: "aNumber", AttributeType: "N"}
        {AttributeName: "aString", AttributeType: "S"}
      ]

    test "only includes attributes in KeySchemas", ->
      assert.eq new CreateTable()._translateAttributes(
        attributes:
          aString: "string"
          aNumber: "number"
          aBinary: "binary"
        {aNumber: true}
      ), AttributeDefinitions: [
        {AttributeName: "aNumber", AttributeType: "N"}
      ]

  _translateGlobalIndexes: ->
    test "_translateGlobalIndexes()", ->
      assert.eq new CreateTable()._translateGlobalIndexes({}), {}

    test "_translateGlobalIndexes globalIndexes: foo:'hashKey'", ->
      assert.eq new CreateTable()._translateGlobalIndexes(globalIndexes: foo:'hashKey'),
        GlobalSecondaryIndexes: [
          IndexName: "foo"
          KeySchema: [
            AttributeName: "hashKey"
            KeyType:       "HASH"
          ]
          Projection:            ProjectionType: "ALL"
          ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
        ]

    test "_translateGlobalIndexes globalIndexes: foo:'hashKey/rangeKey'", ->
      assert.eq new CreateTable()._translateGlobalIndexes(globalIndexes: foo:'hashKey/rangeKey'),
        GlobalSecondaryIndexes: [
          IndexName: "foo"
          KeySchema: [
            {
            AttributeName: "hashKey"
            KeyType:       "HASH"
            }
            AttributeName: "rangeKey"
            KeyType:       "RANGE"
          ]
          Projection:            ProjectionType: "ALL"
          ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
        ]

    test "_translateGlobalIndexes simplest", ->
      assert.eq new CreateTable()._translateGlobalIndexes(
        globalIndexes:
          myIndexName: {}
      ),
        GlobalSecondaryIndexes: [
          IndexName:             "myIndexName"
          KeySchema:             [AttributeName: "id", KeyType: "HASH"]
          Projection:            ProjectionType: "ALL"
          ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
        ]

    test "_translateGlobalIndexes custom key", ->
      assert.eq new CreateTable()._translateGlobalIndexes(
        globalIndexes:
          myIndexName:
            key: 'myHashKeyName'
      ),
        GlobalSecondaryIndexes: [
          IndexName:             "myIndexName"
          KeySchema:             [AttributeName: "myHashKeyName", KeyType: "HASH"]
          Projection:            ProjectionType: "ALL"
          ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
        ]

    test "_translateGlobalIndexes everything", ->
      assert.eq new CreateTable()._translateGlobalIndexes(
        globalIndexes:
          myFirstIndexName: {}
          myIndexName:
            key: 'myHashKeyName, myRangeKeyName'

            projection:
              attributes: ["myNumberAttrName", "myBinaryAttrName"]
              type: 'keysOnly'

            provisioning:
              read: 5
              write: 5
      ),
        GlobalSecondaryIndexes: [
          {
            IndexName:             "myFirstIndexName"
            KeySchema:             [AttributeName: "id", KeyType: "HASH"]
            Projection:            ProjectionType: "ALL"
            ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
          }
          IndexName:             "myIndexName"
          KeySchema: [
            {AttributeName: "myHashKeyName", KeyType: "HASH"}
            {AttributeName: "myRangeKeyName", KeyType: "RANGE"}
          ]
          Projection:            ProjectionType: "KEYS_ONLY", NonKeyAttributes: ["myNumberAttrName", "myBinaryAttrName"]
          ProvisionedThroughput: ReadCapacityUnits: 5, WriteCapacityUnits: 5
        ]

  _translateLocalIndexes: ->
    test "_translateLocalIndexes()", ->
      assert.eq new CreateTable()._translateLocalIndexes({}), {}

    test "_translateLocalIndexes simplest", ->
      assert.eq new CreateTable()._translateLocalIndexes(
        localIndexes:
          myIndexName: {}
      ),
        LocalSecondaryIndexes: [
          IndexName:             "myIndexName"
          KeySchema:             [AttributeName: "id", KeyType: "HASH"]
          Projection:            ProjectionType: "ALL"
        ]

    test "_translateLocalIndexes custom key", ->
      assert.eq new CreateTable()._translateLocalIndexes(
        localIndexes:
          myIndexName:
            key: 'myHashKeyName'
      ),
        LocalSecondaryIndexes: [
          IndexName:             "myIndexName"
          KeySchema:             [AttributeName: "myHashKeyName", KeyType: "HASH"]
          Projection:            ProjectionType: "ALL"
        ]

    test "_translateLocalIndexes everything", ->
      assert.eq new CreateTable()._translateLocalIndexes(
        localIndexes:
          myFirstIndexName: {}
          myIndexName:
            key: "myHashKeyName myRangeKeyName"

            projection:
              attributes: ["myNumberAttrName", "myBinaryAttrName"]
              type: 'keysOnly'

            provisioning:
              read: 5
              write: 5
      ),
        LocalSecondaryIndexes: [
          {
            IndexName:             "myFirstIndexName"
            KeySchema:             [AttributeName: "id", KeyType: "HASH"]
            Projection:            ProjectionType: "ALL"
          }
          IndexName:             "myIndexName"
          KeySchema: [
            {AttributeName: "myHashKeyName", KeyType: "HASH"}
            {AttributeName: "myRangeKeyName", KeyType: "RANGE"}
          ]
          Projection:            ProjectionType: "KEYS_ONLY", NonKeyAttributes: ["myNumberAttrName", "myBinaryAttrName"]
        ]