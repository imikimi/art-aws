{log} = require 'art-foundation'
{PutItem} = Neptune.Art.Aws.StreamlinedDynamoDbApi

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.PutItem.basic", ->
  test "item required", ->
    assert.throws -> new PutItem()._translateItem {}

  test "item: {}", ->
    assert.eq(
      new PutItem()._translateItem item: {}
      Item: {}
    )

  test "item: foo: 123", ->
    assert.eq(
      new PutItem()._translateItem item: foo: 123
      Item: foo: N: "123"
    )

  test "item: foo: 'bar'", ->
    assert.eq(
      new PutItem()._translateItem item: foo: 'bar'
      Item: foo: S: "bar"
    )