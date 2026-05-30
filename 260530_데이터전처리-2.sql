-- 취소건 필터링 : 취소일(RTRCN_DAY)이 NULL인 데이터만 남김
CREATE TABLE prop_copy2 AS
SELECT *
FROM prop_copy
WHERE RTRCN_DAY IS NULL;

SELECT COUNT(*) FROM prop_copy2;