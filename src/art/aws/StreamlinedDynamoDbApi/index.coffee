# generated by Neptune Namespaces v0.5
# file: art/aws/StreamlinedDynamoDbApi/index.coffee

module.exports = require './namespace'
.includeInNamespace require './_StreamlinedDynamoDbApi'
.addModules
  Common:            require './Common'           
  CreateTable:       require './CreateTable'      
  GetItem:           require './GetItem'          
  PutItem:           require './PutItem'          
  Query:             require './Query'            
  TableApiBaseClass: require './TableApiBaseClass'
  UpdateItem:        require './UpdateItem'       