# generated by Neptune Namespaces v1.x.x
# file: art/aws/index.coffee

module.exports = require './namespace'
.includeInNamespace require './_aws'
.addModules
  Config:   require './Config'  
  DynamoDb: require './DynamoDb'
require './StreamlinedDynamoDbApi'