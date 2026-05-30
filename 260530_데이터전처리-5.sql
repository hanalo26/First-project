-- 파생변수 제작
-- DECIMAL(전체 자릿수(Precision), 소수 자릿수(Scale))
-- 	: Precision (전체 자릿수): 소수점을 포함하여 숫자가 가질 수 있는 총 자릿수 (기본값: 10)
--  : Scale (소수 자릿수): 소수점 오른쪽에 올 수 있는 최대 자릿수 (기본값: 0)

CREATE TABLE prop_copy4 AS
SELECT
    *,
    -- 파생변수 1 : 건물연식 = 접수연도 - 건축년도
    (RCPT_YR - ARCH_YR) AS BD_AGE,
    -- 파생변수 2 : 평수 = 건물면적(㎡) / 3.3
    ROUND(ARCH_AREA / 3.3, 1) AS K_SQ,
    -- 파생변수 3 : 평당가 = 물건금액 / 평수
    ROUND(THING_AMT / ROUND(ARCH_AREA / 3.3, 1), 1) AS PRICE_PER_KSQ
FROM prop_copy3;

-- ########################################
-- 파생변수 4 : 프리미엄 여부 (is_PM)
-- Python으로 구현 (MySQL에서 PERCENTILE_CONT 미지원으로 SQL 구현 불가)
-- ########################################