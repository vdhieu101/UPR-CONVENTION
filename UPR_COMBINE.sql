DECLARE @UPR_FLAG INT = 202003 ;
DECLARE @LIMIT_DATA_CORE INT = 201901 ;

DROP TABLE IF EXISTS #TMP_POL ;
WITH
    CTE AS (
    SELECT --
        __.Contract_No,
        __.Contract_IssueDate,
        __.Contract_ExpireDate,
        ROW_NUMBER() OVER (PARTITION BY __.Contract_No ORDER BY __.Contract_No) AS row_num
    FROM
        dbo.IBMS_Contract AS __
    WHERE
        1 = 1
)
SELECT --
    __.*
INTO
    #TMP_POL
FROM
    CTE AS __
WHERE
    1              = 1
    AND __.row_num = 1 ;

WITH
    IS_UPR AS (
    SELECT --
        __.*,
        CASE
        WHEN 1 = 1
             AND __.year_booking * 100 + __.month_booking <= @UPR_FLAG
             AND CONVERT( INT, __.period_allocate_adj ) > @UPR_FLAG
             THEN 1
        ELSE 0
        END AS IS_UPR,
        CASE
        WHEN __.year_booking * 100 + __.month_booking <= @UPR_FLAG
             THEN 1
        ELSE 0
        END AS IS_GWP
    FROM
        dbo.A_PA_ULTI_SPLIT2_CREDIT_PREMIUM AS __
    WHERE
        1 = 1
),
    GROUP_AMT AS (
    SELECT --
        __.p_code,
        __.year_booking,
        SUM( CASE WHEN __.IS_UPR = 1 THEN __.std_p_premium_written ELSE 0 END ) AS UPR_AMT,
        SUM( __.std_p_premium_written )                                         AS GWP_AMT
    FROM
        IS_UPR AS __
    WHERE
        1 = 1
    GROUP BY
        __.p_code,
        __.year_booking
),
    RATE AS (
    SELECT --
        __.p_code                                       AS p_code,
        __.year_booking                                 AS year_booking,
        __.UPR_AMT                                      AS UPR_AMT,
        __.GWP_AMT                                      AS GWP_AMT,
        ISNULL( __.UPR_AMT / NULLIF(__.GWP_AMT, 0), 0 ) AS UPR_RATE
    FROM
        GROUP_AMT AS __
    WHERE
        1 = 1
),
    COMBINE AS (
    SELECT --
        __.F_YEAR * 100 + __.F_MONTH                                             AS period_booking,
        __.P_CODE                                                                AS P_CODE,
        __.P_PRODUCT                                                             AS P_PRODUCT,
        __.P_LOB                                                                 AS P_LOB,
        NULL																	 AS P_LOB_ACC,
        __.P_DEPARTMENT                                                          AS P_DEPARTMENT,
        __.P_BRANCH                                                              AS P_BRANCH,
        __.SALEUNIT_CODE                                                         AS SALEUNIT_CODE,
        CASE WHEN __.SALEUNIT_TYPE <> 'Core' THEN 'BA' ELSE __.SALEUNIT_TYPE END AS SALEUNIT_TYPE,
        __.SALEUNIT_NAME                                                         AS SALEUNIT_NAME,
        'IBMS'                                                                   AS P_TYPE,
        CASE __.BOM_CODE
        WHEN '04'
             THEN 'CEDED'
        WHEN 'CM1'
             THEN 'PREMIUM_COM'
        WHEN '22'
             THEN 'CEDED_COM'
        ELSE NULL
        END                                                                      AS BOM_TYPE,
        __.P_DATE_ISSUE                                                          AS P_DATE_EFFECTIVE,
        __.P_DATE_EXPIRY                                                         AS P_DATE_EXPIRY,
        'NULL'                                                                   AS DETAIL_STD,
        __.P_DATE_EXPIRY                                                         AS P_DATE_EXPIRY_REV,
        0                                                                        AS IS_ADJ,
        -__.AMOUNT                                                               AS AMOUNT,
        @UPR_FLAG                                                                AS PERIOD_UPR,
        -__.AMOUNT * PRT.UPR_RATE                                                AS UNEARNED_BAL
    FROM
        dbo.A3_fn_GLDE_COMBINE( 201501, @UPR_FLAG, 0 ) AS __
    LEFT JOIN
        RATE                                           AS PRT ON 1                     = 1
                                                                 AND  PRT.p_code       = __.P_CODE
                                                                 AND  PRT.year_booking = __.F_YEAR
    WHERE
        1                    = 1
        AND __.SALEUNIT_TYPE <> 'Core'
        AND __.BOM_CODE IN ( '04', 'CM1', '22' )

    UNION ALL

    SELECT --
        __.year_booking * 100 + __.month_booking AS period_booking,
        __.p_code                                AS P_CODE,
        __.product                               AS P_PRODUCT,
        IIT.AccountingGroupCode                  AS P_LOB,
        ALA.P_LOB_ACC                            AS P_LOB_ACC,
        __.department                            AS P_DEPARTMENT,
        __.branch                                AS P_BRANCH,
        CASE
        WHEN __.cooperation_name = 'Doctor Dong'
             THEN 'DD'
        WHEN __.cooperation_name = 'EZCredit'
             THEN 'EVNFC'
        WHEN __.cooperation_name = 'Home Credit'
             THEN 'HC'
        WHEN __.cooperation_name = 'JACCS'
             THEN 'JACCS'
        WHEN __.cooperation_name = 'MaritimeBank'
             AND __.product = 'CK'
             THEN 'MB-CK'
        WHEN __.cooperation_name = 'MaritimeBank'
             AND __.product = 'CM'
             THEN 'MB-CM'
        WHEN __.cooperation_name = 'Mcredit'
             THEN 'MC-CM'
        WHEN __.cooperation_name = 'OCB'
             THEN 'OCB'
        WHEN __.cooperation_name = 'TPBank'
             THEN 'TPB'
        WHEN __.cooperation_name = 'VPBank'
             THEN 'VPB'
        ELSE NULL
        END                                      AS SALEUNIT_CODE,
        'BA'                                     AS SALEUNIT_TYPE,
        __.cooperation_name                      AS SALEUNIT_NAME,
        'IBMS'                                   AS P_TYPE,
        'PREMIUM'                                AS BOM_TYPE,
        IBC.Contract_IssueDate                   AS P_DATE_EFFECTIVE,
        IBC.Contract_ExpireDate                  AS P_DATE_EXPIRY,
        'NULL'                                   AS DETAIL_STD,
        IBC.Contract_ExpireDate                  AS P_DATE_EXPIRY_REV,
        0                                        AS IS_ADJ,
        __.std_p_premium_written * __.IS_GWP     AS AMOUNT,
        @UPR_FLAG                                AS PERIOD_UPR,
        __.std_p_premium_written * __.IS_UPR     AS UNEARNED_BAL
    FROM
        IS_UPR                 AS __
    LEFT JOIN
        #TMP_POL               AS IBC ON 1                          = 1
                                         AND  IBC.Contract_No       = __.p_code
    LEFT JOIN
        dbo.IBMS_InsuranceType AS IIT ON 1                          = 1
                                         AND IIT.InsuranceType_Code = __.product
    LEFT JOIN
        dbo.A3_STD_LOB_ACC     AS ALA ON 1                          = 1
                                         AND ALA.P_PRODUCT          = __.product
    WHERE
        1 = 1

    UNION ALL

    SELECT --
        __.period_booking,
        __.P_CODE,
        __.P_PRODUCT,
        __.P_LOB,
        NULL					AS P_LOB_ACC,
        __.P_DEPARTMENT,
        __.P_BRANCH,
        __.SALEUNIT_CODE,
        __.SALEUNIT_TYPE,
        __.SALEUNIT_NAME,
        __.P_TYPE,
        __.BOM_TYPE,
        __.P_DATE_EFFECTIVE,
        __.P_DATE_EXPIRY,
        NULL					AS DETAIL_STD,
        NULL					AS P_DATE_EXPIRY_REV,
        NULL					AS IS_ADJ,
        __.AMOUNT,
        __.PERIOD_UPR,
        __.UNEARNED_BAL
    FROM
        dbo.A3_fn_tbl_UPR_CORE( @UPR_FLAG, @UPR_FLAG, @UPR_FLAG ) AS __
    WHERE
        1                     = 1
        AND __.period_booking >= @LIMIT_DATA_CORE
)
SELECT --
    __.*
FROM
    COMBINE AS __
WHERE
    1                     = 1
    AND __.period_booking <= @UPR_FLAG ;