-- 계약일 YYYY-MM 형태로 변환 + 불필요 컬럼 제거
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
    DATE_FORMAT(STR_TO_DATE(CTRT_DAY, '%Y%m%d'), '%Y-%m') AS CTRT_MONTH,
    THING_AMT,
    ARCH_AREA,
    LAND_AREA,
    FLR,
    RGHT_SE,
    ARCH_YR,
    BLDG_USG
FROM prop_copy2;