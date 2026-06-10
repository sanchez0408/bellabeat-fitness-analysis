                        -- BELLABEAT PROJECT --
                        -- TABLE: DAILY ACTIVITY --               
                        -- DATE : 08/04/2026 --



                        -- ================= --
                        -- DATA EXPLORATION  --
                        -- ================= --



-- ================= --
-- STEP 1: STRUCTURE --
-- ================= --

SELECT
  column_name,
  data_type
FROM `mon-projet-bigquery-481616.bellabeat_project_1.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'daily_activity'

-- Observation:
  -- There are 15 columns:
    -- Id(INT64), ActivityDate(DATE), TotalSteps(INT64), TotalDistance(FLOAT), TrackerDistance(FLOAT), LoggedActivitiesDistance(FLOAT), VeryActiveDistance(FLOAT), ModeratelyActiveDistance(FLOAT), LightActiveDistance(FLOAT), SedentaryActiveDistance(FLOAT), VeryActiveMinutes(INT64), FairlyActiveMinutes(INT64), LightlyActiveMinutes(INT64), SedentaryMinutes(INT64), Calories(INT64)

-- Decision:
  -- Data is valid for analysis, proceeding to next step


-- ======================== --
-- STEP 2: GENERAL OVERVIEW --
-- ======================== --

SELECT *
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
LIMIT 10

-- Observation:
  -- Too many decimal places in floats, not readable enough
  -- Use `round` to round to two decimal places in analysis phase

-- Decision:
  -- Data is valid for analysis, proceeding to next step



-- ============== --
-- STEP 3: VOLUME --
-- ============== --

SELECT COUNT(*) AS nb_rows
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`

-- Observation:
  -- Number rows = 1397



-- ======================== --
-- STEP 4: DUPLICATE SEARCH --
-- ======================== --

SELECT
  Id,
  ActivityDate,
  COUNT(*) AS nb_duplicate
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
GROUP BY Id, ActivityDate
HAVING COUNT(*) > 1

-- Observation :
  -- 24 duplicate records detected for same Id and ActivityDate

-- Duplicate rows identified, 2nd scan to inspect the actual records

WITH doublons AS (
SELECT
  Id,
  ActivityDate,
  COUNT(*) AS nb_duplicates
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
GROUP BY Id, ActivityDate
HAVING COUNT(*) > 1
)

SELECT
  s.*
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity` s
INNER JOIN doublons d
ON s.Id = d.Id
AND s.ActivityDate = d.ActivityDate
ORDER BY Id

-- Observation:
  -- It would appear that these duplicates are at the junction between the two tables in the dates

-- Decision :
  -- Duplicates were resolved using MAX() aggregation on all numeric columns, keeping the highest value recorded per user and per day



-- =========================== --
-- STEP 5: VALUES NULLs SEARCH --
-- =========================== --

SELECT
  COUNTIF(Id IS NULL) AS Id,
  COUNTIF(ActivityDate IS NULL) AS ActivityDate,
  COUNTIF(TotalSteps IS NULL) AS TotalSteps,
  COUNTIF(TotalDistance IS NULL) AS TotalDistance,
  COUNTIF(TrackerDistance IS NULL) AS TrackerDistance,
  COUNTIF(LoggedActivitiesDistance IS NULL) AS LoggedActivitiesDistance,
  COUNTIF(VeryActiveDistance IS NULL) AS VeryActiveDistance,
  COUNTIF(ModeratelyActiveDistance IS NULL) AS ModeratelyActiveDistance,
  COUNTIF(LightActiveDistance IS NULL) AS LightActiveDistance,
  COUNTIF(SedentaryActiveDistance IS NULL) AS SedentaryActiveDistance,
  COUNTIF(VeryActiveMinutes IS NULL) AS VeryActiveMinutes,
  COUNTIF(FairlyActiveMinutes IS NULL) AS FairlyActiveMinutes,
  COUNTIF(LightlyActiveMinutes IS NULL) AS LightlyActiveMinutes,
  COUNTIF(SedentaryMinutes IS NULL) AS SedentaryMinutes,
  COUNTIF(Calories IS NULL) AS Calories
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`

-- Observation: 
  -- No NULL values found in key columns

-- Decision:
  -- Data is valid for analysis, proceeding to next step



-- ====================== --
-- STEP 6: NUMERICS STATS --
-- ====================== --


-- Distance metrics
SELECT
  MAX(TotalSteps) AS max_TotalSteps,
  MIN(TotalSteps) AS min_TotalSteps,
  AVG(TotalSteps) AS avg_TotalSteps,
  MAX(TotalDistance) AS max_Totaldist,
  MIN(TotalDistance) AS min_Totaldist,
  AVG(TotalDistance) AS avg_Totaldist,
  MAX(TrackerDistance) AS max_track_dist,
  MIN(TrackerDistance) AS min_track_dist,
  AVG(TrackerDistance) AS avg_track_dist,
  MAX(LoggedActivitiesDistance) AS max_log_dist,
  MIN(LoggedActivitiesDistance) AS min_log_dist,
  AVG(LoggedActivitiesDistance) AS avg_log_dist,
  MAX(VeryActiveDistance) AS max_VeryActive_dist,
  MIN(VeryActiveDistance) AS min_VeryActive_dist,
  AVG(VeryActiveDistance) AS avg_VeryActive_dist,
  MAX(ModeratelyActiveDistance) AS max_ModeratelyActive_dist,
  MIN(ModeratelyActiveDistance) AS min_ModeratelyActive_dist,
  AVG(ModeratelyActiveDistance) AS avg_ModeratelyActive_dist,
  MAX(LightActiveDistance) AS max_LightActive_dist,
  MIN(LightActiveDistance) AS min_LightActive_dist,
  AVG(LightActiveDistance) AS avg_LightActive_dist,
  MAX(SedentaryActiveDistance) AS max_SedentaryActive_dist,
  MIN(SedentaryActiveDistance) AS min_SedentaryActive_dist,
  AVG(SedentaryActiveDistance) AS avg_SedentaryActive_dist
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`

-- minutes metrics
SELECT
  MAX(VeryActiveMinutes) AS max_VeryActive_minute,
  MIN(VeryActiveMinutes) AS min_VeryActive_minute,
  AVG(VeryActiveMinutes) AS avg_VeryActive_minute,
  MAX(FairlyActiveMinutes) AS max_FairlyActive_minute,
  MIN(FairlyActiveMinutes) AS min_FairlyActive_minute,
  AVG(FairlyActiveMinutes) AS avg_FairlyActive_minute,
  MAX(LightlyActiveMinutes) AS max_LightlyActive_minute,
  MIN(LightlyActiveMinutes) AS min_LightlyActive_minute,
  AVG(LightlyActiveMinutes) AS avg_LightlyActive_minute,
  MAX(SedentaryMinutes) AS max_SedentaryMinutes_minute,
  MIN(SedentaryMinutes) AS min_SedentaryMinutes_minute,
  AVG(SedentaryMinutes) AS avg_SedentaryMinutes_minute
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`

-- Calories metrics
SELECT
  MAX(Calories) AS max_calories,
  MIN(Calories) AS min_calories,
  AVG(Calories) AS avg_calories
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`

-- Observation:
  -- Average total steps = 7,281
  -- Average sedentary minutes = 992
  -- Average calories = 2,266
  -- The high level of sedentary behavior suggests a predominantly inactive user base, which will be studied in more detail during the analysis phase

-- Decision:
  -- This pattern will be further explored in the analysis phase to better understand user behavior and activity trends



-- ============= --
-- STEP 7: DATES --
-- ============= --

SELECT 
  MIN(ActivityDate) AS min_date,
  MAX(ActivityDate) AS max_date
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`

-- Observation:
  -- min_date = 12/03/2016
  -- max_date = 12/05/2016
  -- Represent 62 days of data

-- Decision:
  -- Data is valid for analysis, proceeding to next step



-- ============================== --
-- STEP 8: VERIFICATION OF VALUES --
-- ============================== --

SELECT *
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
WHERE TotalSteps < 0 
  OR Calories < 0 
  OR TotalDistance < 0
  OR TrackerDistance < 0
  OR VeryActiveMinutes < 0
  OR FairlyActiveMinutes < 0
  OR LightlyActiveMinutes < 0
  OR SedentaryMinutes < 0

-- Observation: 
  -- No negative values detected across key numeric columns



-- 8.1 Check consistency between total steps and distances:

-- Objective: identify a possible inconsistency in the data between distance and steps

SELECT *
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
WHERE TotalDistance = 0 AND TotalSteps > 0
   OR TotalDistance > 0 AND TotalSteps = 0

-- Observation:
  -- 3 records were identified showing a mismatch between steps and distance (steps > 0 while distance = 0)
  -- These cases may indicate either very low-intensity activity not converted into distance or potential tracking/synchronization limitations of the device

-- Decision:
  -- Given the very low number of affected records, they are considered negligible
  -- However, this still represents an analytical bias because it could be assumed that the watch was worn very little or that there was a synchronization problem -> delete the 3 rows



-- 8.2 check steps range:

-- Objective: Identify a step range in order to identify periods of inactivity and posible non-wearing of the Fitbit

SELECT
  CASE
    WHEN TotalSteps = 0 THEN '0' 
    WHEN TotalSteps < 500 THEN '1-499'
    WHEN TotalSteps < 1000 THEN '500-999'
    WHEN TotalSteps < 2000 THEN '1000-1999'
    ELSE '2000+'
  END AS steps_range,
  COUNT(*) AS nb_rows,
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
GROUP BY steps_range
ORDER BY steps_range

-- Observation:
  -- 138 rows with inactivity
  -- 40 rows with an activity from 1 to 499 steps
  -- Possible non-use of the Fitbit device

--Decision:
  -- Conduct a more thorough check of the data to find potential biases
  -- See steps 8.3, 8.4 and 8.5 below



-- 8.3 Check inactivity users per day:

-- Objective: Identify the number of days of inactivity among users

SELECT
  Id,
  COUNT(ActivityDate) AS inactive_day
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
WHERE TotalSteps <= 100
AND SedentaryMinutes >= 1400
GROUP BY Id

-- Observation:
  -- Days where TotalSteps ≤ 100 and SedentaryMinutes ≥ 1,400 were flagged as likely non-wear days, representing near-complete sedentary recording with minimal or no movement detected
  -- This represents 139 days without wearing the Fitbit

-- Decision:
  -- Check the days of inactivity for each user in order to identify a real problem for analysis



-- 8.4 View activity/inactivity by users:

-- Objective: Identify the percentage of inactivity for each user and decide on a minimum number of days of activity for the analysis


WITH inactive_days AS (
  SELECT
    Id,
    COUNT(ActivityDate) AS nb_inactive_days
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
  WHERE TotalSteps <= 100
    AND SedentaryMinutes >= 1400
  GROUP BY Id
),

user_days AS (
  SELECT
    Id,
    COUNT(ActivityDate) AS nb_total_days
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
  GROUP BY Id
)

SELECT
  u.Id,
  u.nb_total_days,
  COALESCE(i.nb_inactive_days, 0) AS nb_inactive_days,
  u.nb_total_days - COALESCE(i.nb_inactive_days, 0) AS nb_active_days,
  ROUND(COALESCE(i.nb_inactive_days, 0) / u.nb_total_days * 100, 1) AS pct_inactive,
  ROUND((u.nb_total_days - COALESCE(i.nb_inactive_days, 0)) / u.nb_total_days * 100, 1) AS pct_active
FROM user_days u
LEFT JOIN inactive_days i USING (Id)
ORDER BY pct_inactive DESC

-- Observation:
  -- Some users show near-total inactivity for more than 50% of their recorded days, strongly suggesting the Fitbit was not worn during those periods
  -- 2 users have data collected over less than 10 days

-- Decision:
  -- Given this data and the bias it could introduce into the analysis process, it is appropriate to remove data considered to represent a day without Fitbit and users with less than 10 days of data



-- 8.5 Segmenting Fitbit usage time:

-- Objective: Identify the number of minutes of activity per day to define a metric for analysis

SELECT
  CASE
    WHEN (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) < 480  THEN '<8h'
    WHEN (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) < 600  THEN '8h-10h'
    WHEN (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) < 720  THEN '10h-12h'
    ELSE '>= 12h'
  END AS time_slots,
  COUNT(*) AS nb_jours,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 1) AS pct
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
GROUP BY time_slots
ORDER BY
  CASE
    time_slots
    WHEN '<8h' THEN 1
    WHEN '8h-10h' THEN 2
    WHEN '10h-12h' THEN 3
    ELSE 4
  END

-- Observation:
  -- Since 96% of records exceed 720 minutes, this threshold was selected to define a valid full day of recording while preserving the vast majority of the dataset
  -- This data will be used to identify user behavior
  -- The other data will be reintegrated for frequency of use
  
  
-- The data was reviewed for potential non-wear days. Once cleaned, this dataset enables analysis of typical daily activity patterns, user activity segmentation, and average activity levels per user
