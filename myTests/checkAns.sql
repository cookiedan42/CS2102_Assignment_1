-- Compare zzsolution and zzanswer
WITH correct AS  ( 
	SELECT * FROM zzanswer 
	INTERSECT ALL 
	SELECT * FROM zzsolution
), 
extra AS (
	SELECT * FROM zzanswer 
	EXCEPT ALL 
	SELECT * FROM zzsolution
), 
missing AS (
	SELECT * FROM zzsolution 
	EXCEPT ALL 
	SELECT * FROM zzanswer
) 

INSERT INTO zzSummary
SELECT (SELECT 1+COUNT(*)from zzSummary), 
CASE 
	WHEN (SELECT COALESCE(COUNT(*),0) FROM extra) = 0 THEN
		CASE 
			WHEN (SELECT COALESCE(COUNT(*),0) FROM missing) = 0  THEN 'CORRECT'
			ELSE 'INCORRECT: MISSING = ' || (SELECT COUNT(*) FROM missing)
		END
	WHEN (SELECT COALESCE(COUNT(*),0) FROM missing) = 0  THEN 'INCORRECT: EXTRA = ' || (SELECT COUNT(*) FROM extra)
	ELSE 'INCORRECT: MISSING = ' || (SELECT COUNT(*) FROM missing) || ', EXTRA = ' || (SELECT COUNT(*) FROM extra)
END as status;

WITH correct AS  (
	SELECT * FROM zzsolution 
	INTERSECT ALL 
	SELECT * FROM zzanswer
), 
extra AS (
	SELECT * FROM zzanswer EXCEPT ALL SELECT * FROM zzsolution
), 
missing AS (
	SELECT * FROM zzsolution EXCEPT ALL select * FROM zzanswer
)
SELECT *, 'OK' AS "Test case Result"
FROM correct 
UNION ALL 
SELECT *, 'EXTRA' FROM extra 
UNION ALL 
SELECT *, 'MISSING' FROM missing;
--ORDER BY status;