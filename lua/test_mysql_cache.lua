--Test File
-- lua_openscript test_mysql_cache.lua
require( "mysqloo" )

db = mysqloo.connect( "127.0.0.1", "root", "password", "usync", 3306 )

function db:onConnected()

    print( "Database has connected!" )

    local q = self:query( "SELECT 5+5" )
    function q:onSuccess( data )

    end

    function q:onError( err, sql )

        print( "Query errored!" )
        print( "Query:", sql )
        print( "Error:", err )

    end

    q:start()

end

function db:onConnectionFailed( err )

    print( "Connection to database failed!" )
    print( "Error:", err )

end

db:connect()

--Test Lines
print(MysqlCache.RegisterDB('usync', db))
print(MysqlCache.RegisterTable('usync', 'usync_users'))
print(MysqlCache.SetRefreshTime('usync', 20))

print(MysqlCache.RegisterDB('usync2', db))
print(MysqlCache.RegisterTable('usync2', 'usync_users'))
print(MysqlCache.SetRefreshTime('usync2', 20))
print(MysqlCache.SetFilter('usync2', 'usync_users', "steam_id = 'STEAM_0:0:3926223613'"))

timer.Simple(1, function()
  local result, message = MysqlCache.GetTable('usync', 'usync_users')
  if result == false then
    print(message)
  else
    PrintTable(result)
  end
end)
timer.Simple(30, function()
  local result, message = MysqlCache.GetTable('usync', 'usync_users')
  if result == false then
    print(message)
  else
    PrintTable(result)
  end
end)
timer.Simple(1, function()
  local result, message = MysqlCache.GetTable('usync2', 'usync_users')
  if result == false then
    print(message)
  else
    PrintTable(result)
  end
end)
timer.Simple(30, function()
  local result, message = MysqlCache.GetTable('usync2', 'usync_users')
  if result == false then
    print(message)
  else
    PrintTable(result)
  end
end)
