# mrc-sqlhandler
Do common sql queries

EXAMPLE -TODO-


```LUA
--Create a new table via lua
local sqlTable = nil
function GetSQLTable()
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
  sqlTable = SQLTable.LoadTable('some_table_name"
end
```
