-- Step 0 : 연도별 데이터 병합
CREATE TABLE unions_v2 AS
SELECT * FROM `2018`
UNION ALL
SELECT * FROM `2019`
UNION ALL
SELECT * FROM `2020`
UNION ALL
SELECT * FROM `2021`
UNION ALL
SELECT * FROM `2022`
UNION ALL
SELECT * FROM `2023`
UNION ALL
SELECT * FROM `2024`;

-- Step 1 : 컬럼명 변경 + 불필요 컬럼 제거 (신고구분, 신고한 개업공인중개사 시군구명)
CREATE TABLE prop_copy AS
SELECT
    접수연도 AS RCPT_YR,
    자치구코드 AS CGG_CD,
    자치구명 AS CGG_NM,
    법정동코드 AS STDG_CD,
    법정동명 AS STDG_NM,
    지번구분 AS LOTNO_SE,
    지번구분명 AS LOTNO_SE_NM,
    본번 AS MNO,
    부번 AS SNO,
    건물명 AS BLDG_NM,
    계약일 AS CTRT_DAY,
    `물건금액(만원)` AS THING_AMT,
    `건물면적(㎡)` AS ARCH_AREA,
    `토지면적(㎡)` AS LAND_AREA,
    층 AS FLR,
    권리구분 AS RGHT_SE,
    취소일 AS RTRCN_DAY,
    건축년도 AS ARCH_YR,
    건물용도 AS BLDG_USG
FROM unions_v2;

-- Step 2 : 취소된 부동산 거래 제거
CREATE TABLE prop_copy2 AS
SELECT *
FROM prop_copy
WHERE RTRCN_DAY IS NULL;

-- Step 3 : 건물명, 권리구분 NULL 처리
UPDATE prop_copy2
SET
    BLDG_NM = COALESCE(BLDG_NM, 'UNKNOWN'),
    RGHT_SE = COALESCE(RGHT_SE, '-');

-- Step 4 : 취소일 컬럼 제거
ALTER TABLE prop_copy2 DROP COLUMN RTRCN_DAY;

-- Step 5 : 계약일 → CTRT_MONTH(YYYY-MM) + CTRT_QUARTER(연도Q분기) 변환 + CTRT_DAY 제거
CREATE TABLE prop_copy3 AS
SELECT
    RCPT_YR,
    CGG_CD,
    CGG_NM,
    STDG_CD,
    STDG_NM,
    LOTNO_SE,
    LOTNO_SE_NM,
    MNO,
    SNO,
    BLDG_NM,
    -- 계약일 YYYY-MM 형태로 변환
    DATE_FORMAT(STR_TO_DATE(CTRT_DAY, '%Y%m%d'), '%Y-%m') AS CTRT_MONTH,
    -- 연도+분기 컬럼 생성 (예: 2018Q1)
    CONCAT(YEAR(STR_TO_DATE(CTRT_DAY, '%Y%m%d')), 'Q',
           QUARTER(STR_TO_DATE(CTRT_DAY, '%Y%m%d'))) AS CTRT_QUARTER,
    THING_AMT,
    ARCH_AREA,
    LAND_AREA,
    FLR,
    RGHT_SE,
    ARCH_YR,
    BLDG_USG
FROM prop_copy2;

-- Step 6 : 파생변수 생성 (건물연식, 평수, 평당가)
CREATE TABLE prop_copy4 AS
SELECT
    *,
    -- 파생변수 1 : 건물연식 = 접수연도 - 건축년도
    (RCPT_YR - ARCH_YR) AS BD_AGE,
    -- 파생변수 2 : 평수 = 건물면적(㎡) / 3.3
    ROUND(ARCH_AREA / 3.3, 1) AS K_SQ,
    -- 파생변수 3 : 평당가 = 물건금액 / 평수
    THING_AMT / ROUND(ARCH_AREA / 3.3, 1) AS PRICE_PER_KSQ
FROM prop_copy3;

-- Step 7 : 프리미엄 여부 (is_PM) 추가
-- Python으로 구현 (MySQL에서 PERCENTILE_CONT 미지원으로 SQL 구현 불가)
-- 자치구명 + 건물용도 기준으로 그룹화 후, Q3 + IQR * 1.5 초과하는 매물을 프리미엄(True,1)으로 분류
-- 작업 파일: python/01_is_PM.py
-- 결과: prop_copy5 테이블로 import 예정

-- is_PM 컬럼 생성 후, 행 개수 : 804,690개
SELECT COUNT(*) FROM prop_copy5;