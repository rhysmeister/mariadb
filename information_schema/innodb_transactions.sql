# Blocking transactions... Needs checking with a fresh head
# Add information_schema.PROCESSLIST?
SELECT trx.TRX_ID,
	   trx.TRX_WEIGHT,
	   trx.TRX_STATE,
	   trx.TRX_REQUESTED_LOCK_ID,
	   trx.TRX_WAIT_STARTED,
	   trx.TRX_MYSQL_THREAD_ID,
	   trx.TRX_QUERY,
	   locks.*,
	   waits.*,
	   trx2.TRX_ID AS BLOCKING_TRX_ID,
	   trx2.TRX_WEIGHT BLOCKING_TRX_WEIGHT,
	   trx2.TRX_STATE BLOCKING_TRX_STATE,
	   trx2.TRX_REQUESTED_LOCK_ID BLOCKING_TRX_REQUESTED_LOCK_ID,
	   trx2.TRX_WAIT_STARTED BLOCKING_TRX_WAIT_STARTED,
	   trx2.TRX_MYSQL_THREAD_ID BLOCKING_TRX_MYSQL_THREAD_ID,
	   trx2.TRX_QUERY BLOCKING_TRX_QUERY,	   
FROM information_schema.INNODB_TRX trx
LEFT JOIN information_schema.INNODB_LOCKS locks
	ON locks.LOCK_TRX_ID = trx.TRX_ID
LEFT JOIN information_schema.INNODB_LOCK_WAITS waits
	ON waits.REQUESTING_TRX_ID = trx.TRX_ID
	AND waits.REQUESTED_LOCK_ID = locks.LOCK_ID
LEFT JOIN information_schema.INNODB_LOCKS locks2
	ON waits2.BLOCKING_TRX_ID = locks2.LOCK_TRX_ID
	AND waits2.BLOCKING_LOCK_ID = locks2.LOCK_ID
LEFT JOIN information_schema.INNODB_TRX trx2
	ON locks2.LOCK_TRX_ID = trx2.TRX_ID
WHERE trx.TRX_STATE = 'LOCK WAIT';


