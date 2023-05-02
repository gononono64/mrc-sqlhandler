# mrc-sqlhandler
Do common sql queries

Requires https://github.com/overextended/oxmysql

EXAMPLE -TODO-


```LUA
--Create a new table via lua
local sqlTable = nil
function CreateSQLTable()
    if sqlTable then return sqlTable end
    local primaryColumn = exports["mrc-sqlhandler"]:SQLColumn("primary_column", "string") --string or number
    local columns = {
        exports["mrc-sqlhandler"]:SQLColumn("column2", "string"),
        exports["mrc-sqlhandler"]:SQLColumn("column3", "vector3"),
        exports["mrc-sqlhandler"]:SQLColumn("column4", "table")
    }
    sqlTable = exports["mrc-sqlhandler"]:SQLTable("some_table_name", primaryColumn, columns) 

    return sqlTable
end

--Load an existing table
function LoadTable()
  sqlTable = SQLTable.LoadTable('some_table_name")
end
```

You could alternatively include this in your manifest:
```lua
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@mrc-sqlhandler/server/sqlhandler.lua'
}
```

and do this:

```lua
if sqlTable then return sqlTable end
local primaryColumn = SQLColumn.New("id", "string")
local columns = {
    SQLColumn.New("model", "string"),
    SQLColumn.New("location", "vector3"),
    SQLColumn.New("targetoption", "string")
}
sqlTable = SQLTable.New("mrc_placedobjects", primaryColumn, columns) 

return sqlTable
```
