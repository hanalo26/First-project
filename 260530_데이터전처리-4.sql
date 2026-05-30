-- 건물명, 권리구분 컬럼의 NULL값 처리
UPDATE prop_copy3
SET
    -- 건물명 NULL → UNKNOWN
    BLDG_NM = COALESCE(BLDG_NM, 'UNKNOWN'),
    -- 권리구분 NULL → '-'
    RGHT_SE = COALESCE(RGHT_SE, '-');

-- # 사용한 SQL 문법
-- UPDATE 테이블명 -> 이 테이블에서
-- SET 컬럼 = 새값 -> 이 컬럼을 이 값으로 바꿈
-- WHERE 조건;    -> 이 조건에 해당하는 행만 바꿈 (이 쿼리가 없으면 전체 행)