# generated by Neptune Namespaces v0.3.0
# file: art/aws/index.coffee

(module.exports = require './namespace')
.includeInNamespace(require './_aws')
.addModules
  DynamoDb: require './dynamo_db'