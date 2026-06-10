-- ================= --
-- STEP 1: STRUCTURE --
-- ================= --

SELECT
  column_name,
  data_type
FROM `mon-projet-bigquery-481616.bellabeat_project_1.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'sleep_time'

-- Observation:
  -- contain 6 columns:
    -- Id(STRING)
    -- Date(DATE)
    -- asleep(INT64)
    -- restless(INT64)
    -- awake(INT64)
    -- total_minutes_sleep(INT64)

-- Decision:
  -- Data is valid for analysis, proceeding to next step


-- ======================== --
-- STEP 2: GENERAL OVERVIEW --
-- ======================== --

SELECT *
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time_cleaning`
LIMIT 10

-- Observation:
  -- sleep information for each day

-- Decision:
  -- Data is valid for analysis, proceeding to next step



-- ============== --
-- STEP 3: VOLUME --
-- ============== --

SELECT COUNT(*) AS nb_rows
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time`


-- Observation:
  -- rows = 916



-- ======================== --
-- STEP 4: DUPLICATE SEARCH --
-- ======================== --

SELECT
  Id,
  Date,
  COUNT(*)AS nb_duplicates
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time`
GROUP BY Id, Date
HAVING COUNT(*) > 1

-- Observation:
  -- several duplicated rows, 2nd scan to check for duplicates

WITH doublons AS (
SELECT
  Id,
  Date,
  COUNT(*)AS nb_duplicates
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time`
GROUP BY Id, Date
HAVING COUNT(*) > 1
)

SELECT
  s.*
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time` s
INNER JOIN doublons d
ON s.Id = d.Id
AND s.Date = d.Date

-- Observation:
  -- The duplicate data differs, which could be explained by tracker problems or by two periods of sleep during the day (night and nap)
  
-- Decision:
  -- After analyzing duplicates, the option to keep the highest value data will be used
  -- Aggregating the data would have yielded values ​​well above the maximum values ​​recommended by the NSF (720 minutes = 12 hours)



-- =========================== --
-- STEP 5: VALUES NULLs SEARCH --
-- =========================== --

SELECT
  COUNTIF(asleep IS NULL) AS asleep,
  COUNTIF(restless IS NULL) AS restless,
  COUNTIF(awake IS NULL) AS awake,
  COUNTIF(total_minutes_sleep IS NULL) AS total_minutes_sleep
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time`

-- Observation:
  -- No NULLs values

-- Decision:
  -- Data is valid for analysis, proceeding to next step



-- ====================== --
-- STEP 6: NUMERICS STATS --
-- ====================== --

SELECT
  MAX(asleep) AS max_asleep,
  MIN(asleep) AS min_asleep,
  AVG(asleep) AS avg_asleep,
  MAX(restless) AS max_restless,
  MIN(restless) AS min_restless,
  AVG(restless) AS avg_restless,
  MAX(awake) AS max_awake,
  MIN(awake) AS min_awake,
  AVG(awake) AS avg_awake,
  MAX(total_minutes_sleep) AS max_total_minutes_sleep,
  MIN(total_minutes_sleep) AS min_total_minutes_sleep,
  AVG(total_minutes_sleep) AS avg_total_minutes_sleep
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time`

-- Observation:
  -- Data defined to at least 0, potential recording problem
  -- 2nd scan to verify data at 0

SELECT
  *
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time`
WHERE total_minutes_sleep >= 30

-- Observation:
  -- According to research, a valid Fitbit recording for collecting sleep data (awake, restless, and asleep) is a minimum of 30 minutes

-- Decision:
  -- All data less than 30 minutes old will be deleted in cleaning phase


-- ============= --
-- STEP 7: DATES --
-- ============= --

SELECT 
  MIN(Date) AS min_date,
  MAX(Date) AS max_date
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time`

-- Observation:
  -- MIN date = 03/11/2016
  -- MAX date = 05/12/2016
  -- File containing dates from 3/12/2016 to 5/12/2016

SELECT 
  *
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time`
WHERE Date = '2016-03-11'

-- Observation:
  -- The recording data from 11/03/2026 does not represent a night's sleep for each user
  -- The maximum being 161 minutes

-- Decision:
  -- Delete data from 11/03/2016



-- ============================== --
-- STEP 8: VERIFICATION OF VALUES --
-- ============================== --

SELECT
  asleep,
  restless,
  awake,
  total_minutes_sleep
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time`
WHERE asleep < 0
OR restless < 0
OR awake < 0
OR total_minutes_sleep < 0

-- Observation:
  -- No negatives values

-- Decision:
  -- Data is valid for analysis, proceeding to next step
