	INSERT INTO transaction.transaction
	(
	  id 
	, status_code
	, approval_datetime
	, change_user 
	)
	SELECT
	  'LandOnlineNZ'
	, 'approved'
	, CURRENT_TIMESTAMP
	, 'jvb'
	WHERE NOT EXISTS (SELECT id FROM  transaction.transaction WHERE id = 'LandOnlineNZ'); 