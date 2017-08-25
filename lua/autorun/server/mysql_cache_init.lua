MsgC(Color(255,0,0), "[Mysql Cache] Starting up.\n")
MysqlCache = {}
MysqlCache.Timer = "MySQLCacheSyncTimer"
MysqlCache.DB = {}
--Version Checker
MysqlCache.Version = {1, 1, 0}
timer.Simple(30,function()
http.Fetch("https://raw.githubusercontent.com/andreblue/mysql_cache_gmod/master/version",
function(body, size, headers, code)
  local remotever = string.Split( body, " " )
  if MysqlCache.Version ~= remotever then
    need_update = false
    if MysqlCache.Version[1] < tonumber(remotever[1]) then
      need_update = true
    elseif MysqlCache.Version[2] < tonumber(remotever[2]) then
      need_update = true
    elseif MysqlCache.Version[3] < tonumber(remotever[3]) then
      need_update = true
    end
    if need_update then
      MsgC(Color(255,0,0), "[Mysql Cache] Please update. There is a new version.\n")
    end
  end
end,
function(errorMsg)
  MsgC(Color(255,0,0), "[Mysql Cache] HTTP Error.\n")
  MsgN(errorMsg)
end)
end)



--Basic Functions
function MysqlCache.RegisterDB(database_id, db_obj)
  if MysqlCache.DB[database_id] then
    return false, "Database ID already exists. If you need to update the object, then simply use the UpdateDB function"
  end
  MysqlCache.DB[database_id] = {}
  MysqlCache.DB[database_id].obj = db_obj
  MysqlCache.DB[database_id].filters = {}
  return true, "Added " .. database_id
end
function MysqlCache.UpdateDB(database_id, db_obj)
  if MysqlCache.DB[database_id] then
    MysqlCache.DB[database_id].obj = db_obj
    return true, "Update " .. database_id .. " object"
  else
    return false, "Database ID does not exists. You need to register it first with the RegisterDB function"
  end
end
function MysqlCache.RegisterTable(database_id, table_name)
  if MysqlCache.DB[database_id] then
    if not MysqlCache.DB[database_id].Tables then
      MysqlCache.DB[database_id].Tables = {}
    end
    if MysqlCache.DB[database_id].Tables[table_name] then
      return false, "Table " .. table_name .. " already exists"
    else
      MysqlCache.DB[database_id].Tables[table_name] = true
      MysqlCache.DB[database_id].refresh_time = 60
      MysqlCache.DB[database_id].next_time = CurTime() + 60
      return true, "Table " .. table_name .. " added"
    end
  else
    return false, "Database ID does not exists. You need to register it first with the RegisterDB function"
  end
end
function MysqlCache.UnregisterTable(database_id, table_name)
  if MysqlCache.DB[database_id] then
    if not MysqlCache.DB[database_id].Tables then
      MysqlCache.DB[database_id].Tables = {}
    end
    if MysqlCache.DB[database_id].Tables[table_name] then
      return false, "Table " .. table_name .. " does not exists"
    else
      MysqlCache.DB[database_id].Tables[table_name] = false
      return true, "Table " .. table_name .. " removed"
    end
  else
    return false, "Database ID does not exists. You need to register it first with the RegisterDB function"
  end
end
function MysqlCache.SetRefreshTime(database_id, refresh_time)
  if MysqlCache.DB[database_id] then
    MysqlCache.DB[database_id].refresh_time = refresh_time
    MysqlCache.DB[database_id].next_time = CurTime() + refresh_time
    return true, "Updated time for " .. database_id
  end
  return false, "Database ID does not exists. You need to register it first with the RegisterDB function"
end
function MysqlCache.SetFilter(database_id, table_name, filter)
  if MysqlCache.DB[database_id] then
    MysqlCache.DB[database_id].filters[table_name] = filter
    return true, "Updated filter for " .. table_name .. " on " .. database_id
  end
  return false, "Database ID does not exists. You need to register it first with the RegisterDB function"
end

function MysqlCache.GetTable(database_id, table_name)
  if MysqlCache.DB[database_id] then
    if MysqlCache.DB[database_id].Tables and MysqlCache.DB[database_id].Tables[table_name] then
      if MysqlCache.DB[database_id].Tables[table_name] == true then
        return false, "Table data has not been pulled yet. Try again in a minute or so."
      end
      return MysqlCache.DB[database_id].Tables[table_name]
    else
      return false, "Table does not exists. You need to register it first with the RegisterTable function"
    end
  end
  return false, "Database ID does not exists. You need to register it first with the RegisterDB function"
end

function MysqlCache.RunTimer()
  for database_id, _ in pairs(MysqlCache.DB) do
    if MysqlCache.DB[database_id].next_time and MysqlCache.DB[database_id].next_time <= CurTime() then
      MysqlCache.DB[database_id].next_time = CurTime() + MysqlCache.DB[database_id].refresh_time
      --Update Tables
      for table_name, _ in pairs(MysqlCache.DB[database_id].Tables) do
        local query
        if MysqlCache.DB[database_id].filters[table_name] then
          query = MysqlCache.DB[database_id].obj:query("SELECT * FROM " .. table_name .. " WHERE " .. tostring(MysqlCache.DB[database_id].filters[table_name]))
        else
          query = MysqlCache.DB[database_id].obj:query("SELECT * FROM " .. table_name)
        end
        function query:onSuccess(data)
          MysqlCache.DB[database_id].Tables[table_name] = data
        end
        function query:onError( err, sql )
          MsgC(Color(255,0,0), "[Mysql Cache] Error running query.\n")
          MsgC(Color(255,0,0), "[Mysql Cache] " .. err .. " \n")
          MsgC(Color(255,0,0), "[Mysql Cache] " .. sql .. " \n")
        end
        query:start()

      end
    end
  end
end

timer.Create( MysqlCache.Timer, 1, 0, MysqlCache.RunTimer )
