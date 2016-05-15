######################################################
# Author: Rhys Campbell                              #
# Created: 2016-05-15                                #
# Description: A few queries to help out identifying #
# potential issues in the setup and design of a      #
# MariaDB or MySQL database. Split into sections for #
# possible instance configuration issues and then    #
# down to the nity ritty with some database design   #
# type queries.                                      #
######################################################

# Any anonymous users or users without a password?
# Take basic steps to secure your instance
# https://mariadb.com/kb/en/mariadb/mysql_secure_installation/
SELECT *
FROM mysql.user
WHERE Password = '' OR user = '';

# SUPER privilege
SELECT *
FROM mysql.user
WHERE SUPER_PRIV = 'Y';

# What is the value of sql_mode? I like to have this set to TRADITIONAL
# This may be problematic to change on a production system but it's good
# to be aware of this.
# https://mariadb.com/kb/en/mariadb/sql_mode/
SELECT @@SQL_MODE, @@GLOBAL.SQL_MODE;


SELECT t.ENGINE, COUNT(*)
FROM information_schema.TABLES t
WHERE t.TABLE_TYPE = 'BASE TABLE'
AND t.TABLE_SCHEMA = DATABASE()
GROUP BY t.ENGINE;



# Do you have any triggers in your database? 
# What are they doing?
SELECT *
FROM information_schema.TRIGGERS;

# Views are horrible in MySQL? Do you have any? 
# https://www.percona.com/blog/2007/08/12/mysql-view-as-performance-troublemaker/
# Some of the points int he article are now not correct...
# For example MySQL/MariaDB can now create indexes on derived tables
SELECT *
FROM information_schema.VIEWS


# Tables without a PRIMARY KEY
SELECT t.TABLE_NAME, s.INDEX_NAME
FROM information_schema.TABLES t
LEFT JOIN information_schema.statistics s
	ON t.TABLE_SCHEMA = s.TABLE_SCHEMA
    AND t.TABLE_NAME = s.TABLE_NAME
    AND s.INDEX_NAME = 'PRIMARY'
WHERE t.TABLE_TYPE = 'BASE TABLE'
AND s.INDEX_NAME IS NULL;

# Tables without any additional indexes (only PK)
SELECT *
FROM information_schema.TABLES t1
LEFT JOIN information_schema.statistics s1
	ON t1.TABLE_SCHEMA = s1.TABLE_SCHEMA
    AND t1.TABLE_NAME = s1.TABLE_NAME
    AND s1.INDEX_NAME <> 'PRIMARY'
    AND s1.INDEX_NAME IS NULL
WHERE EXISTS (SELECT *
			  FROM information_schema.statistics s
			  WHERE t1.TABLE_SCHEMA = s.TABLE_SCHEMA
			  AND t1.TABLE_NAME = s.TABLE_NAME
			  AND s.INDEX_NAME = 'PRIMARY');

# Do you really need that BIGINT? WOuld an INT do?
# http://dev.mysql.com/doc/refman/5.7/en/storage-requirements.html
SELECT *
FROM information_schema.COLUMNS
WHERE DATA_TYPE = 'BIGINT'
AND TABLE_SCHEMA = DATABASE();

# Stored procedures always run under the sql_mode they were created in.
# Do you have any that were created under a different sql_mode than the current?
SELECT p.db,
	   p.name AS proc_func_name,
       p.type AS proc_func,
	   p.sql_mode AS proc_sql_mode,
       @@global.sql_mode AS global_sql_mode,
       REPLACE(p.sql_mode, @@global.sql_mode, '') AS missing_from_local,
       REPLACE(@@global.sql_mode, p.sql_mode,  '') AS missing_from_global
FROM mysql.proc p
WHERE p.sql_mode <> @@global.sql_mode;
