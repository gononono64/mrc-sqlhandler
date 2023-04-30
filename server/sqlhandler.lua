
---------------------------------------------------------------HELPERS---------------------------------------------------------------
function dump(o, beautify)
    if type(o) == 'table' then
        local s = '{\n'
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            local prefix = beautify and '\t' or ''
            s = s .. prefix .. '['..k..'] = ' .. dump(v, beautify) .. ',\n'
        end
        if beautify then
            s = s:sub(1, -3) -- remove the last comma and newline
            s = s .. '\n'
        end
        return s .. '}'
    else
        return tostring(o)
    end
end

local ToSQLDataTypes = {
    ['string'] = function(defaultSize)
        local size = defaultSize or 255
        return "VARCHAR(" .. size.. ")"
    end,
    ['long'] = function()
        return "LONGTEXT"
    end,
    ['float'] = function(defaultSize)
        local size = defaultSize or 24
        return "FLOAT(" .. size .. ")"
    end,
    ['number'] = function(defaultSize)
        local size = defaultSize or 255
        return "INT(" .. size .. ")"
    end,
    ['boolean'] = function()
        return "BOOLEAN"
    end,
    ['table'] = function()
        return "LONGTEXT"
    end,
    ['vector2'] = function()
        return "VARCHAR(50)"
    end,
    ['vector3'] = function()
        return "VARCHAR(50)"
    end,
    ['vector4'] = function()
        return "VARCHAR(50)"
    end
}

function ConvertLuaDataTypeToSQLDataType(dataType, defaultSize)
    assert(ToSQLDataTypes[dataType], "Invalid data type: " .. dataType)
    return ToSQLDataTypes[dataType](defaultSize)
end

local FromSQLDataTypes = {
    ['VARCHAR'] = 'string',
    ['CHAR'] = 'string',
    ['BINARY'] = 'string',
    ['VARBINARY'] = 'string',
    ['TINYBLOB'] = 'string',
    ['BLOB'] = 'string',
    ['MEDIUMBLOB'] = 'string',
    ['LONGBLOB'] = 'string',
    ['TEXT'] = 'string',
    ['TINYTEXT'] = 'string',
    ['MEDIUMTEXT'] = 'string',
    ['LONGTEXT'] = 'string',
    ['ENUM'] = 'string',
    ['SET'] = 'string',
    ['JSON'] = 'table',
    ['BOOL'] = 'boolean',
    ['BOOLEAN'] = 'boolean',
    ['BIT'] = 'number',
    ['TINYINT'] = 'number',
    ['SMALLINT'] = 'number',
    ['MEDIUMINT'] = 'number',
    ['INT'] = 'number',
    ['INTEGER'] = 'number',
    ['BIGINT'] = 'number',
    ['FLOAT'] = 'float',
    ['DOUBLE'] = 'float',
    ['DECIMAL'] = 'float',
    ['DATE'] = 'string',
    ['DATETIME'] = 'string',
    ['TIMESTAMP'] = 'string',
    ['TIME'] = 'string',
    ['YEAR'] = 'number',
    ['POINT'] = 'vector2',
    ['LINESTRING'] = 'string', -- Depending on how you store them, they can be vectors, but it's complicated
    ['POLYGON'] = 'string', -- Same as above
    ['MULTIPOINT'] = 'string', -- Same as above
    ['MULTILINESTRING'] = 'string', -- Same as above
    ['MULTIPOLYGON'] = 'string', -- Same as above
    ['GEOMETRY'] = 'string', -- Same as above
    ['POINTZ'] = 'vector3',
    ['LINESTRINGZ'] = 'string', -- Depending on how you store them, they can be vectors, but it's complicated
    ['POLYGONZ'] = 'string', -- Same as above
    ['MULTIPOINTZ'] = 'string', -- Same as above
    ['MULTILINESTRINGZ'] = 'string', -- Same as above
    ['MULTIPOLYGONZ'] = 'string', -- Same as above
    ['GEOMETRYZ'] = 'string', -- Same as above
    ['POINTM'] = 'vector3',
    ['LINESTRINGM'] = 'string', -- Depending on how you store them, they can be vectors, but it's complicated
    ['POLYGONM'] = 'string', -- Same as above
    ['MULTIPOINTM'] = 'string', -- Same as above
    ['MULTILINESTRINGM'] = 'string', -- Same as above
    ['MULTIPOLYGONM'] = 'string', -- Same as above
    ['GEOMETRYM'] = 'string', -- Same as above
    ['POINTZM'] = 'vector4',
    ['LINESTRINGZM'] = 'string', -- Depending on how you store them, they can be vectors, but it's complicated
    ['POLYGONZM'] = 'string', -- Same as above
    ['MULTIPOINTZM'] = 'string', -- Same as above
    ['MULTILINESTRINGZM'] = 'string', -- Same as above
    ['MULTIPOLYGONZM'] = 'string', -- Same as above
}

function ConvertSQLDataTypeToLuaDataType(dataType)
    assert(dataType, "Invalid data type: " .. tostring(dataType))
    assert(type(dataType) == "string", "Invalid data type: " .. tostring(dataType))
    dataType = dataType:gsub("%(%d+%)", "")
    dataType = string.upper(dataType)
   
    assert(FromSQLDataTypes[dataType], "Invalid data type: " .. dataType)
    return FromSQLDataTypes[dataType]
end

function isJson(str)
    local success, result = pcall(function() return json.decode(str) end)
    return success and type(result) == 'table'
end  


local ToLuaData = {
    ["string"] = function(value)
        if isJson(value) then
            return json.decode(value)
        end
        return value
    end,
    ["float"] = function(value)
        return value * 1.0
    end,
    ["number"] = function(value)
        return value
    end,
    ["boolean"] = function(value)
        return value == 1
    end,
    ["table"] = function(value)
        return json.decode(value)
    end,
    ["vector2"] = function(value)
        local result = json.decode(value)
        return vector2(result.x or result[1], result.y or result[2])
    end,
    ["vector3"] = function(value)
        local result = json.decode(value)
        return vector3(result.x or result[1], result.y or result[2], result.z or result[3])
    end,
    ["vector4"] = function(value)
        local result = json.decode(value)
        return vector4(result.x or result[1], result.y or result[2], result.z or result[3], result.w or result[4])
    end
}

function ConvertToLuaData(dataType, value)
    assert(ToLuaData[dataType], "Invalid data type: " .. dataType)
    return ToLuaData[dataType](value)
end

----------------------------------------------------------------SQL COLUMN---------------------------------------------------------------

SQLColumn = {}
SQLColumn.__index = SQLColumn

function SQLColumn.New(name, dataType, sqlType, size)
    local tbl = {}
    tbl.name = name
    if sqlType then
        local luaDataType = ConvertSQLDataTypeToLuaDataType(sqlType)
        tbl.dataType = luaDataType
        tbl.sqlType = sqlType
    else
        local sqlDataType = ConvertLuaDataTypeToSQLDataType(dataType, size)
        tbl.dataType = dataType
        tbl.sqlType = sqlDataType
    end
    tbl.size = size
    tbl.type = "SQLColumn"

    function tbl:GetSQLTypeWithSize()
        local str = self.sqlType:upper()
        if self.size and self.size > 0 and str ~= "LONGTEXT" then
            return str .. "(" .. math.floor(self.size) .. ")"
        else
            return str
        end
    end

    return tbl
end
exports("SQLColumn", SQLColumn.New)
---------------------------------------------------------------SQL HANDLER---------------------------------------------------------------
SQLTables = {}
SQLTable = {}
SQLTable.__index = SQLTables


function SQLTable.New(name, primaryColumn, sqlColumns)
    print(dump(SQLTables))
    if SQLTables[name] then print("SQLTable already exists: " .. name) return SQLTables[name] end
    local tbl = {}
    tbl.name = name
    tbl.primaryColumn = primaryColumn
    tbl.sqlColumns = sqlColumns
    tbl.columns = {}
    tbl.rows = {}
    tbl.type = "SQLTable"
    function tbl:CreateTable()
        local sql = "CREATE TABLE IF NOT EXISTS " .. self.name .. " (" .. self.primaryColumn.name .." " ..self.primaryColumn:GetSQLTypeWithSize().." PRIMARY KEY, "
        for i, column in ipairs(self.sqlColumns) do
            sql = sql .. column.name .. " " .. column:GetSQLTypeWithSize()
            if i ~= #self.sqlColumns then
                sql = sql .. ", "
            end
        end
        sql = sql .. ")"
        MySQL.Async.execute(sql, {}, function()
            print("Created table " .. self.name)
        end)
    end
    
    function tbl:RenameTable(newName)
        MySQL.Async.execute("RENAME TABLE " .. self.name .. " TO " .. newName, {}, function()
            print("Renamed table " .. self.name .. " to " .. newName)
        end)
    end
    
    function tbl:CopyTable(newName)
        MySQL.Async.execute("CREATE TABLE " .. newName .. " LIKE " .. self.name, {}, function()
            print("Created table " .. newName .. " as a copy of table " .. self.name)
        end)
    end
    
    function tbl:ClearTable()
        MySQL.Async.execute("TRUNCATE TABLE " .. self.name, {}, function()
            print("Cleared table " .. self.name)
        end)
    end
    
    function tbl:DeleteTable()
        MySQL.Async.execute("DROP TABLE " .. self.name, {}, function()
            print("Dropped table " .. self.name)
        end)
    end
    
    function tbl:Close()
        SQLTables[self.name] = nil
    end
    
    --COLUMNS
    
    function tbl:AlignColumns()
        local result = MySQL.query.await('SELECT * FROM information_schema.columns WHERE table_name = ?', {self.name})
        local columns = {}
        for i, column in ipairs(result) do
            columns[column.COLUMN_NAME] = true
        end
        columns[self.primaryColumn.name] = nil
    
        for i, column in ipairs(self.sqlColumns) do
            if not columns[column.name] then
                MySQL.Async.execute("ALTER TABLE " .. self.name .. " ADD COLUMN " .. column.name .. " " .. column:GetSQLTypeWithSize(), {}, function()
                    print("Added column " .. column.name .. " to table " .. self.name)
                end)
            else
                columns[column.name] = nil
            end
        end
    
        for column, _ in pairs(columns) do
            MySQL.Async.execute("ALTER TABLE " .. self.name .. " DROP COLUMN " .. column, {}, function()
                print("Removed column " .. column .. " from table " .. self.name)
            end)
        end
    
    end
    
    function tbl:ReloadTable()
        local result = MySQL.query.await('SELECT * FROM ' .. self.name)
        for i, row in ipairs(result) do
            local values = {}
            for i, column in ipairs(self.sqlColumns) do
                local value = row[column.name]
                values[column.name] = ToLuaData[column.dataType](value)
                if not self.columns[column.name] then self.columns[column.name] = {} end
                
                self.columns[column.name][row[self.primaryColumn.name]] = ToLuaData[column.dataType](value)
            end
            self.rows[row[self.primaryColumn.name]] = values
        end
    end
    
    
    function tbl:AddColumn(column)
        assert(column.type == "SQLColumn", "Expected SQLCOlumn obj, got "..type(column) .. " with value".. tostring(column))
        MySQL.Async.execute("ALTER TABLE " .. self.name .. " ADD COLUMN IF NOT EXISTS " .. column.name .. " " .. column.sqlType, {}, function()
            self.sqlColumns[#self.sqlColumns + 1] = column
            print("Added column " .. column.name .. " to table " .. self.name)
        end)
    end
    
    function tbl:RenameColumn(column, newName)
        column = column.name or column
        MySQL.Async.execute("ALTER TABLE " .. self.name .. " CHANGE COLUMN " .. column .. " " .. newName .. " " .. self.columns[column].sqlType, {}, function()
            self.columns[newName] = self.columns[column]
            self.columns[column] = nil
            for i, row in pairs(self.rows) do
                row[newName] = row[column]
                row[column] = nil
            end
            print("Renamed column " .. column .. " to " .. newName .. " in table " .. self.name)
        end)
    end
    
    function tbl:GetColumns()
        print("Getting columns")
        return self.columns
    end

    function tbl:GetSQLColumns()
        return self.sqlColumns
    end
    
    function tbl:DeleteColumn(column)
        column = column.name or column
        self.columns[column] = nil
        for i, row in pairs(self.rows) do
            row[column] = nil
        end
        MySQL.Async.execute("ALTER TABLE " .. self.name .. " DROP COLUMN " .. column, {}, function()
            print("Dropped column " .. column .. " from table " .. self.name)
        end)
    end
    
    --ROWS
    function tbl:FindRowWhere(column, value)
        column = column.name or column
        local result = MySQL.query.await('SELECT * FROM ' .. self.name .. ' WHERE ' .. column .. ' = ?', {value})
        return result[1]
    end
    
    function tbl:FindRowsWhere(column, value)
        column = column.name or column
        local result = MySQL.query.await('SELECT * FROM ' .. self.name .. ' WHERE ' .. column .. ' = ?', {value})
        return result
    end
    
    function tbl:FindRowWhereContains(column, value)
        column = column.name or column
        local result = MySQL.query.await('SELECT * FROM ' .. self.name .. ' WHERE ' .. column .. ' LIKE ?', {"%" .. value .. "%"})
        return result[1]
    end
    
    function tbl:FindRowsWhereContains(column, value)
        column = column.name or column
        local result = MySQL.query.await('SELECT * FROM ' .. self.name .. ' WHERE ' .. column .. ' LIKE ?', {"%" .. value .. "%"})
        return result
    end
    
    function tbl:CacheFindRowWhere(column, value)
        column = column.name or column
        for i, row in pairs(self.rows) do
            if row[column] == value then
                return row
            end
        end
        return nil
    end
    
    function tbl:CacheFindRowsWhere(column, value)
        column = column.name or column
        local rows = {}
        for i, row in pairs(self.rows) do
            if row[column] == value then
                rows[#rows+1] = row
            end
        end
        return rows
    end
    
    function tbl:CacheFindRowWhereContains(column, value)
        column = column.name or column
        for i, row in pairs(self.rows) do
            if string.find(row[column], value) then
                return i
            end
        end
        return nil
    end
    
    function tbl:CacheFindRowsWhereContains(column, value)
        column = column.name or column
        local rows = {}
        for i, row in pairs(self.rows) do
            if string.find(row[column], value) then
                rows[#rows+1] = i
            end
        end
        return rows
    end
    
    function tbl:AddRow(row)
        local primaryKey = row[self.primaryColumn.name]
        assert(not self.rows[primaryKey], "Row with primary key " .. primaryKey .. " already exists in table " .. self.name)
        self.rows[primaryKey] = row
        local columns = "(" .. self.primaryColumn.name
        local values = "(@row"
        local i = 1
        for columnName, value in pairs(row) do
            if columnName ~= self.primaryColumn.name then
                columns = columns .. ", " .. columnName
                values = values .. ", @value" .. i
                i = i + 1
            end
        end
        columns = columns .. ")"
        values = values .. ")"
        local parameters = { ['@row'] = primaryKey }
        i = 1
        for columnName, value in pairs(row) do
            if columnName ~= self.primaryColumn.name then
                parameters['@value' .. i] = value
                i = i + 1
            end
        end
        MySQL.Async.execute("INSERT INTO " .. self.name .. " " .. columns .. " VALUES " .. values, parameters, function()
            print("Inserted row " .. primaryKey .. " in table " .. self.name)
        end)
    end
    
    function tbl:DeleteRow(row)
        if self.rows[row] then
            self.rows[row] = nil
            MySQL.Async.execute("DELETE FROM " .. self.name .. " WHERE " .. self.primaryColumn.name .. " = @row", {
                ['@row'] = row
            }, function()
                print("Deleted row " .. row .. " in table " .. self.name)
            end)
        end
    end
    
    function tbl:GetValue(column, row)
        column = column.name or column
        if self.rows[row] then
            return self.rows[row][column]
        end
        return nil
    end
    
    function tbl:SetValue(column, row, value)
        column = column.name or column
        if self.rows[row] then
            self.rows[row][column] = value
            MySQL.Async.execute("UPDATE " .. self.name .. " SET " .. column .. " = @value WHERE " .. self.primaryColumn.name .. " = @row", {
                ['@value'] = value,
                ['@row'] = row
            }, function()
                print("Updated value in column " .. column .. " in row " .. row .. " in table " .. self.name)
            end)
        else
            self.rows[row] = {}
            self.rows[row][column] = value
            local columns = "(" .. self.primaryColumn.name .. ", " .. column .. ")"
            local values = "(@row, @value)"
            for i, col in ipairs(self.columns) do
                if col.name ~= self.primaryColumn.name and col.name ~= column then
                    columns = columns .. ", " .. col.name
                    values = values .. ", NULL"
                end
            end
            MySQL.Async.execute("INSERT INTO " .. self.name .. " " .. columns .. " VALUES " .. values, {
                ['@row'] = row,
                ['@value'] = value
            }, function()
                print("Inserted value in column " .. column .. " in row " .. row .. " with value " .. value .. " in table " .. self.name)
            end)
        end
    end
    
    --PRINTS
    function tbl:PrintTable()
        print("Table " .. self.name .. ":")
        print(dump(self.rows))
    end
    
    function tbl:PrintColumns()
        print(dump(self.columns))
    end
    
    function tbl:PrintRows()
        print(dump(self.rows))
    end
    
    function tbl:PrintColumn(column)
        print(dump(self.columns[column]))
    end
    
    function tbl:PrintRow(row)
        print(dump(self.rows[row]))
    end
    
    function tbl:PrintValue(column, rowKey)
        column = column.name or column
        local row = self.rows[rowKey]
        if not row then print("Row " .. rowKey .. " does not exist in table " .. self.name) return end
        print(row[column])
end
    
    function tbl:PrintColumnNames()
        print("Table " .. self.name .. ":")
        for i, column in ipairs(self.sqlColumns) do
            print("Column " .. column.name)
        end
    end
    
    function tbl:PrintRowKeys()
        print("Table " .. self.name .. ":")
        for row, value in pairs(self.rows) do
            print("Row " .. row)
        end
    end
    
    function tbl:PrintPrimaryColumn()
        print("Table " .. self.name .. ":")
        print("Primary Column: " .. self.primaryColumn.name)
    end
    
    function tbl:PrintColumnTypes()
        print("Table " .. self.name .. ":")
        for i, column in ipairs(self.columns) do
            print("Column " .. column.name .. ": " .. column.dataType)
        end
    end


    tbl:CreateTable()
    tbl:AlignColumns()
    tbl:ReloadTable()
    SQLTables[name] = tbl
    return tbl
end
exports("SQLTable", SQLTable.New)

SQLTable.LoadTable = function(tableName)
    if SQLTables[tableName] then
        return SQLTables[tableName]
    end
    local result = MySQL.query.await([[
        SELECT DISTINCT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, COLUMN_KEY
        FROM information_schema.columns 
        WHERE table_name = ?
        GROUP BY COLUMN_NAME
    ]], {tableName})

    local columns = {}
    local primaryColumn = nil
    for i, column in ipairs(result) do
        local sqlColumn = SQLColumn.New(column.COLUMN_NAME, nil, column.DATA_TYPE, column.CHARACTER_MAXIMUM_LENGTH)
        if column.COLUMN_KEY == "PRI" then
            primaryColumn = sqlColumn
        else
            table.insert(columns, sqlColumn)
        end
    end
    assert(primaryColumn, "No primary column found for table " .. tableName)
    return SQLTable.New(tableName, primaryColumn, columns)
end
exports('SQLLoadTable', function(tableName)
    return SQLTable.LoadTable(tableName)
end)

-- SQLTable.LoadAllTables = function()
--     local result = MySQL.query.await([[
--         SELECT DISTINCT TABLE_NAME
--         FROM information_schema.columns 
--         GROUP BY TABLE_NAME
--     ]])

--     local tables = {}
--     for i, table in ipairs(result) do
--         tables[table.TABLE_NAME] = pcall(function()
--             SQLTable.LoadTable(table.TABLE_NAME)
--         end)
--     end

--     return tables
-- end






















