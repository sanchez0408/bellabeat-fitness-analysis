-- ================= --
-- STEP 1: STRUCTURE --
-- ================= --

SELECT
  column_name,
  data_type
FROM `mon-projet-bigquery-481616.bellabeat_project_1.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'hourly_steps'

-- Observation:
  -- Dataset contains 3 columns:
    -- id (STRING): user identifier
    -- activity_date (DATETIME): timestamp of activity
    -- steps total (INT64): number of steps

-- Decision:
  -- Data is valid for analysis, proceeding to next step



-- ======================== --
-- STEP 2: GENERAL OVERVIEW --
-- ======================== --

SELECT *
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps`
LIMIT 10

-- Observation:
  -- Each row represents the number of steps (steps_total) a user (id) takes per hour (activity_date)
  -- Some row show steps_total = 0, which could indicate: periods of inactivity (night time...) or missing data
  -- The same id appears multiple times -> for each hour one data per id

-- Decision:
  -- Data structure is suitable for time based analysis
  -- steps_total = 0 values should be analyzed to determine if they represent real inactivity or data gaps

  
-- ======================== --
-- STEP 4: DUPLICATE SEARCH --
-- ======================== --

SELECT
  id,
  activity_date,
  COUNT(*) AS nb_duplicate
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps`
GROUP BY id, activity_date
HAVING COUNT(*) > 1

-- Observation:
  -- 175 duplicated rows
  -- Duplicate data found on multiple id per hour, all duplicates are dated 12/04/2016
  -- Possible duplicates on the junction of the 2 tables hourly steps

-- Decision:
  -- Further inspection is required to determine whether these represent true duplicates or multiple logged measurements

-- 2nd scan:

WITH doublons AS (
SELECT
  id,
  activity_date,
  COUNT(*) AS nb_duplicates
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps`
GROUP BY id, activity_date
HAVING COUNT(*) > 1
)

SELECT
  s.*
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps` s
INNER JOIN doublons d
ON s.id = d.id
AND s.activity_date = d.activity_date
ORDER BY id, activity_date

-- Observation:
  -- The duplicated data from 12/04/2016 is genuine duplicate data

-- Decision:
  -- Following cleaning, 175 records were retained out of 46,183 initial rows, representing a 0.38% reduction
  -- Duplicates removed after verification


-- ====================== --
-- STEP 6: NUMERICS STATS --
-- ====================== --

SELECT
  MIN(steps_total) AS min_step,
  MAX(steps_total) AS max_step,
  AVG(steps_total) AS avg_step
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps`

-- Observation:
  -- Value min = 0
  -- Value max = 10565
  -- Value avg = 302
  -- Verification of values min = 0 if inactivity or data gaps and max = 10565 if sport activity (running...)
  -- The difference between the max value and the avg value is very large
  -- Physical activity can produce this data, and the time at which it is performed is not sufficient to justify an anomaly
  -- And nigth time or no use tracking can justify values 0, if inactive time during the night
 
-- Decision:
  -- Zero-step hours will be investigated in steps 8.1 to 8.3 to distinguish natural inactivity from potential non-wear periods


-- ============================== --
-- STEP 8: VERIFICATION OF VALUES --
-- ============================== --

-- 8.1 Average steps per hour: --

--Objective: Identify the hours at 0 steps

SELECT
  COUNTIF(steps_total = 0) AS inactivity_hours,
  COUNT(*) AS total_hours,
  ROUND(COUNTIF(steps_total = 0) / COUNT(*) * 100, 1) AS pct_zero
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps`

-- Observation:
  -- 44.6% are hours with 0 steps, without any activity
  -- The fact that the steps are at 0 during nighttime hours does not represent an anomaly

-- Decision:
  -- Check the activity by hour to identify any potential problems


-- 8.2: Nighttime vs non-wearing: --

-- Objective: Identify zero-step patterns by hour of day to distinguish natural inactivity (night) from potential non-wear periods

SELECT
  EXTRACT(HOUR FROM activity_date) AS hour_of_day,
  COUNTIF(steps_total = 0) AS inactivity,
  COUNT(*) AS total,
  ROUND(COUNTIF(steps_total = 0) / COUNT(*) * 100, 1) AS pct_zero
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps`
GROUP BY hour_of_day
ORDER BY hour_of_day

-- Observation:
  -- The percentages appear to represent normal activity, with higher percentages of inactivity at night but activity during the day

-- Decision:
  -- In order to identify potential activity biases, such as not wearing the Fitbit, an hourly inactivity check will be performed for each user throughout the day


-- 8.3 hours of inactivity during the day: --

-- Objective: Flag days where an excessive number of hours show zero steps, suggesting the Fitbit was not worn for most of the day

SELECT
  id,
  DATE(activity_date) AS activity_day,
  COUNT(*) AS total_hours,
  COUNTIF(steps_total = 0) AS inactivity_hours
FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps`
GROUP BY id, activity_day
HAVING COUNTIF(steps_total = 0) >= 15 --> estimated 9 hours of inactivity for nighttime
ORDER BY inactivity_hours DESC

-- Observation:
  -- A threshold of 15 hours of inactivity was selected, excluding 8 hours of natural nocturnal inactivity
  -- 410 rows represent between 24 hours and 15 hours of inactivity for a full day
  -- 24 to 15 hours of total inactivity in a single day is not possible for a healthy person, even on a day off without work or external activity

-- Decision:
  -- This introduces bias into the analysis because it skews the user data; therefore, this data will be removed during the pre-analysis cleanup


-- 8.4 number of hours recorded in a day

SELECT
  recorded_hours,
  COUNT(*) AS nb_days,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 1) AS pct
FROM (
  SELECT
    id,
    DATE(activity_date) AS activity_day,
    COUNT(*) AS recorded_hours
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps`
  GROUP BY id, DATE(activity_date)
)
GROUP BY recorded_hours
ORDER BY recorded_hours ASC

-- Observation:
  -- 96.7% of days have exactly 24 hours of recorded data. Days with incomplete recordings (< 24h) represent only 3.3% of the dataset and will be excluded to ensure consistency in hourly analysis

-- Decision:
  -- keep only the 24-hour data for analysis


-- Following cleaning, 35,784 records were retained out of 46,183 initial rows, representing a 22.5% reduction. Exclusions include 175 duplicate rows, days with incomplete 24h recordings (3.3%), and days with 15 or more zero-step hours flagged as likely non-wear days
