-- Remove duplicates while keeping the highest value
-- Keep track of 30 minutes or more of sleep recording
-- Remove date of 11/03/2016

CREATE OR REPLACE TABLE `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time_cleaning` AS
WITH duplicates AS (
SELECT
  Id,
  Date,
  MAX(asleep) AS asleep,
  MAX(restless) AS restless,
  MAX(awake) AS awake,
  MAX(total_minutes_sleep) AS total_minutes_sleep
FROM `mon-projet-bigquery-481616.bellabeat_project_1.sleep_time_cleaning`
GROUP BY Id, Date
),

time_usage_valable AS (
  SELECT *
  FROM duplicates
  WHERE total_minutes_sleep >= 30
),

days_of_analysis AS (
  SELECT 
    *
  FROM time_usage_valable
  WHERE Date != '2016-03-11'
)

SELECT *
FROM days_of_analysis

