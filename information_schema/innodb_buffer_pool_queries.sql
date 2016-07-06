####################################################################
# Author: Rhys Campbell                                            #
# Created: 2016-06-07                                              #
# Description: Queries for inspecting the use of the innodb buffer #
# pool. Originally a blog post...                                  #
# http://www.youdidwhatwithtsql.com/innodbbufferpage-queries/2041/ #
####################################################################


# Buffer pool consumption by database
SELECT bp.POOL_ID, 
	NULLIF(SUBSTRING(bp.TABLE_NAME, 1, LOCATE(".", bp.TABLE_NAME) - 1), '') AS db_name, 
	(COUNT(*) * 16) / 1024 / 1024 AS buffer_pool_consumption_gb 
FROM `INNODB_BUFFER_PAGE` bp 
GROUP BY bp.POOL_ID, 
	 db_name 
ORDER BY buffer_pool_consumption_gb DESC;

# Various innodb internal structures
SELECT * 
FROM `INNODB_BUFFER_PAGE` bp 
WHERE bp.TABLE_NAME IS NULL;

# Buffer pool consumption by database/table & page type
SELECT bp.POOL_ID, 
	NULLIF(SUBSTRING(bp.TABLE_NAME, 1, LOCATE(".", bp.TABLE_NAME) - 1), '') AS db_name, 
	bp.PAGE_TYPE, 
	bp.TABLE_NAME, 
	(COUNT(*) * 16) / 1024 / 1024 AS buffer_pool_consumption_gb 
FROM `INNODB_BUFFER_PAGE` bp 
GROUP BY bp.POOL_ID, 
	 db_name, 
	 bp.PAGE_TYPE, 
	 bp.TABLE_NAME 
ORDER BY bp.POOL_ID, 
	 db_name, 
	 bp.PAGE_TYPE, 
	 bp.TABLE_NAME, 
	 buffer_pool_consumption_gb DESC;

# Buffer pool consumption by pool/database/table
SELECT bp.POOL_ID, 
	NULLIF(SUBSTRING(bp.TABLE_NAME, 1, LOCATE(".", bp.TABLE_NAME) - 1), '') AS db_name, 
	bp.TABLE_NAME, 
	(COUNT(*) * 16) / 1024 / 1024 AS buffer_pool_consumption_gb 
FROM `INNODB_BUFFER_PAGE` bp 
GROUP BY bp.POOL_ID, 
	 db_name, 
	 bp.TABLE_NAME 
ORDER BY bp.POOL_ID, 
	 db_name, 
	 bp.TABLE_NAME, 
	 buffer_pool_consumption_gb DESC;

# Buffer pool consumption by database/table
SELECT NULLIF(SUBSTRING(bp.TABLE_NAME, 1, LOCATE(".", bp.TABLE_NAME) - 1), '') AS db_name, 
	bp.TABLE_NAME, 
	(COUNT(*) * 16) / 1024 / 1024 AS buffer_pool_consumption_gb,
	SUM(bp.NUMBER_RECORDS) AS total_number_records # Probably need to distinguish between data & index pages??
FROM `INNODB_BUFFER_PAGE` bp 
GROUP BY db_name, 
	 bp.TABLE_NAME 
ORDER BY buffer_pool_consumption_gb DESC;

# Buffer pool consumption by index
SELECT bp.POOL_ID, 
	NULLIF(SUBSTRING(bp.TABLE_NAME, 1, LOCATE(".", bp.TABLE_NAME) - 1), '') AS db_name, 
	bp.TABLE_NAME, 
	bp.INDEX_NAME, (COUNT(*) * 16) / 1024 / 1024 AS buffer_pool_consumption_gb 
FROM `INNODB_BUFFER_PAGE` bp 
GROUP BY bp.POOL_ID, 
	 db_name, 
	 bp.TABLE_NAME, 
	 bp.INDEX_NAME 
ORDER BY bp.POOL_ID, 
	 db_name, 
	 bp.PAGE_TYPE, 
	 buffer_pool_consumption_gb DESC;

