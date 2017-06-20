#!/bin/bash
# Author: Gediminas Jančys
# Website: https://blog.jancys.net
# User to login to MySQL server
user="root"
# Database name containing older data than another
older_DB="older_DB"
# Database name containing newer data than another
newer_DB="current_DB"
# Merged database name
merged="merged_DB"
echo "Exporting database structure"
# Exporting database structure
mysqldump -u$user -p --no-data $newer_DB > struct.sql
# Creating new databse
echo "Creating $merged database"
mysql -u$user -p --execute="CREATE DATABASE $merged"
# Filling in database structure
echo "Importing $merged structure"
mysql -u$user -p $merged < struct.sql
# Getting tables in database
echo "Getting database table list"
tables=`mysql -u$user -p $merged --execute="SHOW TABLES;"`
# Generating SQL to merge older data to new database
for table in $tables; do
  if [ $table = "Tables_in_$merged" ]; then
    # Skipping title entry
    continue
  fi
  # Generating SQL staitment
  SQL="INSERT IGNORE INTO $merged.$table\nSELECT *\nFROM $older_DB.$table;";
  # Writting SQL to SQL file
  echo $SQL >> SQL.sql
done
# Generating SQL to merge newer data to new database
for table in $tables; do
  if [ $table = "Tables_in_$merged" ]; then
    # Skipping title entry
    continue
  fi
  # Generating SQL staitment
  SQL="INSERT IGNORE INTO $merged.$table\nSELECT *\nFROM $newer.$table;";
  # Writting SQL to SQL file
  echo $SQL >> SQL.sql
done
# Merging data
echo "Merging data"
mysql -u$user -p $merged < SQL.sql
