#############################################################################
# Author: Rhys Campbell                                                     #
# Created: 2016-06-09                                                       #
# Description: Summarises data in the events_statements_summary_by_digest   #
# table. This is an attempt to identify the "bad" queries needing attention #
# work in progress.                                                         #
#############################################################################
DROP TABLE IF EXISTS  tmp_exclude_query;
CREATE TABLE tmp_exclude_query
(
	query_text VARCHAR(100) PRIMARY KEY
) ENGINE=MEMORY;
INSERT INTO tmp_exclude_query VALUES ('SHOW GLOBAL STATUS');

SET @schema_name = 'passeport';

SELECT all_digests.DIGEST,
       all_digests.COUNT_STAR,
       count_star.count_star_rank,
       sum_timer_wait.sum_timer_wait_rank,
       sum_lock_time.sum_lock_time_rank,
       sum_no_index_used.sum_no_index_used_rank,
       sum_created_tmp_tables.sum_created_tmp_tables_rank,
       sum_select_scan.sum_select_scan_rank,
       max_timer_wait.max_timer_wait_rank,
       avg_timer_wait.avg_timer_wait_rank,
       min_timer_wait.min_timer_wait_rank,
       min_max_timer_diff.min_max_timer_diff_rank,
       sum_sort_scan.sum_sort_scan_rank,
       sum_sort_rows.sum_sort_rows_rank
FROM
(
	SELECT DIGEST,
	       COUNT_STAR
	FROM `events_statements_summary_by_digest`
) AS all_digests
LEFT JOIN
(
	SELECT DIGEST,
	       @COUNT_STAR := @COUNT_STAR + 1 AS count_star_rank
	FROM `events_statements_summary_by_digest`,
		(SELECT @COUNT_STAR := 0) AS r
	WHERE COUNT_STAR > 0
	AND SCHEMA_NAME = @schema_name
	AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)
	ORDER BY COUNT_STAR DESC
	LIMIT 20
) AS count_star
	ON all_digests.DIGEST = count_star.DIGEST
LEFT JOIN (
		SELECT DIGEST,
		       @SUM_TIMER_WAIT := @SUM_TIMER_WAIT + 1 AS sum_timer_wait_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @SUM_TIMER_WAIT := 0) AS r
		WHERE SUM_TIMER_WAIT > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)
		ORDER BY SUM_TIMER_WAIT DESC
		LIMIT 20
		) AS sum_timer_wait
	ON all_digests.DIGEST = sum_timer_wait.DIGEST
LEFT JOIN (
		SELECT DIGEST,
			@SUM_LOCK_TIME := @SUM_LOCK_TIME + 1 AS sum_lock_time_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @SUM_LOCK_TIME := 0) AS r
		WHERE SUM_LOCK_TIME > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)		
		ORDER BY SUM_LOCK_TIME DESC
		LIMIT 20
		) AS sum_lock_time
	ON all_digests.DIGEST = sum_lock_time.DIGEST
LEFT JOIN (
		SELECT DIGEST,
			@SUM_NO_INDEX_USED := @SUM_NO_INDEX_USED + 1 AS sum_no_index_used_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @SUM_NO_INDEX_USED := 0) AS r
		WHERE SUM_NO_INDEX_USED > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)		
		ORDER BY SUM_NO_INDEX_USED DESC
		LIMIT 20
		) AS sum_no_index_used
	ON all_digests.DIGEST = sum_no_index_used.DIGEST
LEFT JOIN (
		SELECT DIGEST,
			@SUM_CREATED_TMP_TABLES := @SUM_CREATED_TMP_TABLES + 1 AS sum_created_tmp_tables_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @SUM_CREATED_TMP_TABLES := 0) AS r
		WHERE SUM_CREATED_TMP_TABLES > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)		
		ORDER BY SUM_CREATED_TMP_TABLES DESC
		LIMIT 20
		) AS sum_created_tmp_tables
	ON all_digests.DIGEST = sum_created_tmp_tables.DIGEST
LEFT JOIN (
		SELECT DIGEST,
			@SUM_SELECT_SCAN := @SUM_SELECT_SCAN + 1 AS sum_select_scan_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @SUM_SELECT_SCAN := 0) AS r
		WHERE SUM_SELECT_SCAN > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)		
		ORDER BY SUM_SELECT_SCAN DESC
		LIMIT 20
		) AS sum_select_scan
	ON all_digests.DIGEST = sum_select_scan.DIGEST	
LEFT JOIN (
		SELECT DIGEST,
			@MAX_TIMER_WAIT := @MAX_TIMER_WAIT + 1 AS max_timer_wait_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @MAX_TIMER_WAIT := 0) AS r
		WHERE MAX_TIMER_WAIT > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)		
		ORDER BY MAX_TIMER_WAIT DESC
		LIMIT 20
		) AS max_timer_wait
	ON all_digests.DIGEST = max_timer_wait.DIGEST
LEFT JOIN (
		SELECT DIGEST,
			@AVG_TIMER_WAIT := @AVG_TIMER_WAIT + 1 AS avg_timer_wait_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @MAX_TIMER_WAIT := 0) AS r
		WHERE AVG_TIMER_WAIT > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)		
		ORDER BY AVG_TIMER_WAIT DESC
		LIMIT 20
		) AS avg_timer_wait
	ON all_digests.DIGEST = avg_timer_wait.DIGEST
LEFT JOIN (
		SELECT DIGEST,
			@MIN_TIMER_WAIT := @MIN_TIMER_WAIT + 1 AS min_timer_wait_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @MIN_TIMER_WAIT := 0) AS r
		WHERE MIN_TIMER_WAIT > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)		
		ORDER BY MIN_TIMER_WAIT DESC
		LIMIT 20
		) AS min_timer_wait
	ON all_digests.DIGEST = min_timer_wait.DIGEST
LEFT JOIN (
		SELECT DIGEST,
			@MIN_MAX_TIMER_DIFF := @MIN_MAX_TIMER_DIFF + 1 AS min_max_timer_diff_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @MIN_MAX_TIMER_DIFF := 0) AS r
		WHERE MIN_TIMER_WAIT > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)		
		ORDER BY MAX_TIMER_WAIT - MIN_TIMER_WAIT DESC
		LIMIT 20
		) AS min_max_timer_diff
	ON all_digests.DIGEST = min_max_timer_diff.DIGEST
LEFT JOIN (
		SELECT DIGEST,
			@SUM_SORT_SCAN := @SUM_SORT_SCAN + 1 AS sum_sort_scan_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @SUM_SORT_SCAN := 0) AS r
		WHERE SUM_SORT_SCAN > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)		
		ORDER BY SUM_SORT_SCAN DESC
		LIMIT 20
		) AS sum_sort_scan
	ON all_digests.DIGEST = sum_sort_scan.DIGEST
LEFT JOIN (
		SELECT DIGEST,
			@SUM_SORT_ROWS := @SUM_SORT_ROWS + 1 AS sum_sort_rows_rank
		FROM `events_statements_summary_by_digest`,
			(SELECT @SUM_SORT_ROWS := 0) AS r
		WHERE SUM_SORT_ROWS > 0
		AND SCHEMA_NAME = @schema_name
		AND DIGEST_TEXT NOT IN (SELECT query_text FROM tmp_exclude_query)		
		ORDER BY SUM_SORT_ROWS DESC
		LIMIT 20
		) AS sum_sort_rows
	ON all_digests.DIGEST = sum_sort_rows.DIGEST	
HAVING count_star.count_star_rank > 0
OR sum_timer_wait.sum_timer_wait_rank > 0
OR sum_lock_time.sum_lock_time_rank > 0
OR sum_no_index_used.sum_no_index_used_rank > 0
OR sum_created_tmp_tables.sum_created_tmp_tables_rank > 0
OR sum_select_scan.sum_select_scan_rank > 0
OR max_timer_wait.max_timer_wait_rank > 0
OR avg_timer_wait.avg_timer_wait_rank > 0
OR min_timer_wait.min_timer_wait_rank > 0
OR min_max_timer_diff.min_max_timer_diff_rank > 0
OR sum_sort_scan.sum_sort_scan_rank > 0
OR sum_sort_rows.sum_sort_rows_rank > 0;

-- Clean up
DROP TABLE IF EXISTS tmp_exclude_query;
