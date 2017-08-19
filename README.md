# MySQL Cache

A simple way to cache MySQL tables.

# Requirements

You need:

    Mysqloo(I used Ver 9)

# Install

Drop into addons file.

# Usage

## MysqlCache.RegisterDB(database_id, db_obj)

### database_id: A Unique String to ID the DB

### db_obj: The Mysqloo Database connected to the MySQL Server

## MysqlCache.UpdateDB(database_id, db_obj)

### database_id: The Unique String of which db you want to update

### db_obj: The new Mysqloo Database connected to the MySQL Server

## MysqlCache.RegisterTable(database_id, table_name)

### database_id:The Unique String of which db you want to update

### table_name: The table name you want to sync

## MysqlCache.UnregisterTable(database_id, table_name)

### database_id:The Unique String of which db you want to update

### table_name: The table name you want to remove

## MysqlCache.SetRefreshTime(database_id, refresh_time)

### database_id: A Unique String to ID the DB

### refresh_time: The new time you want it to query per db in seconds

## MysqlCache.GetTable(database_id, table_name)

### database_id: A Unique String to ID the DB

### table_name: The table name you want to grab

## Returns
Everything returns at least true or false with a message. GetTable will return only the result if it is successful.


