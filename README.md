# art-aws
A cleaner API to AWS SDK with Promises and Art.Foundation

### Benefits
* all methods are wrapped in promises
* Streamlined API params
  * dramatic reduction in size
  * reasonable defaults
  * data is always in plain javascript data structures (JSON-compatible data-structures)
    * methods affected: putItem, updateItem, getItem, query, etc...
* lowerCamelCase property names for consistency with JavaScript
* shorter, yet still hopefully clear property names
  * Example:
    ```coffeeScript
    # Streamlined API
    provisioning:
      read: 1
      write: 1

    # Standard API
    ProvisionedThroughput:
      ReadCapacityUnits: 1
      WriteCapacityUnits: 1
    ```

#### createTable example
```coffeescript
# Streamlined API:
dynamoDb.createTable
  table: "fooBarTestTable"
  key: "chatRoom/id"
  attributes:
    id:         "number"
    chatRoom:   "string"
    createdAt:  "number"

  globalIndexes:
    chatsByChatRoomCreatedAt: "chatRoom/createdAt"
.then ->
  # ...

# Standard API:
dynamoDb.createTable
  TableName: "fooBarTestTable"
  GlobalSecondaryIndexes: [
    IndexName: "chatsByChatRoomCreatedAt"
    KeySchema: [
      {AttributeName: "chatRoom", KeyType: "HASH"}
      {AttributeName: "createdAt", KeyType: "RANGE"}
    ]
    Projection: ProjectionType: "ALL"
    ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
  ]
  KeySchema: [
    {AttributeName: "chatRoom", KeyType: "HASH"}
    {AttributeName: "id", KeyType: "RANGE"}
  ]
  AttributeDefinitions: [
    {AttributeName: "id", AttributeType: "N"}
    {AttributeName: "chatRoom", AttributeType: "S"}
    {AttributeName: "createdAt", AttributeType: "N"}
  ]
  ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
.then ->
  # ...
```

#### query example
```coffeescript
# Streamlined API
dynamoDb.query
  table: "fooBarTestTable"
  descending: true
  where:
    chatRoom: "xyz456"
    id: gt: 1
.then ({items}) ->
  # items is an array of plain javascript objects
  # Items is the standard DynamoDb-encoded Items list

# Standard API
dynamoDb.query
  TableName: "fooBarTestTable"
  ScanIndexForward: false
  KeyConditionExpression: "(#attr1 = :val1 AND #attr2 > :val2)"
  ExpressionAttributeNames:
    "#attr1": "chatRoom"
    "#attr2": "id"

  ExpressionAttributeValues:
    ":val1": S: "xyz456"
    ":val2": N: "1"
.then ({items, Items}) ->
  # items is an array of plain javascript objects
  # Items is the standard DynamoDb-encoded Items list
```
### Usage
* Input API
  * you can use the standard DynamoDb API params, OR
  * you can use the Streamlined API params
  * All table methods automatically detect which API you are using with this test:
    * if `params.TableName`
      * DynamoDb API is used
    * else
      * Streamlined API is used
      * NOTE: `params.table` is expected to specify the table-name
* Output API
  * The output object contains the standard DynamoDb response
    * note: DynamoDb uses UpperCamelCase property names
  * The output object may ALSO contain streamlined-api properties
    * example: the 'items' property returned by a 'query' is a list of the result items as plain-javascript objects
    * note: the streamelined-api uses lowerCamelCase property names
