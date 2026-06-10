-- Removing duplicates
-- Keep only the days with exactly 24 hours of recording
-- Days with >= 15 hours at 0 steps



CREATE OR REPLACE TABLE `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps_cleaning` AS
WITH duplicates AS (
SELECT DISTINCT
  id,
  activity_date,
  steps_total
  FROM `mon-projet-bigquery-481616.bellabeat_project_1.hourly_steps`
),

valid_days AS (
  SELECT
    id,
    DATE(activity_date) AS activity_day
  FROM duplicates
  GROUP BY id, DATE(activity_date)
  HAVING COUNT(*) = 24
),

inactivity_date AS (
  SELECT
    id,
    DATE(activity_date) AS activity_day
  FROM duplicates
  GROUP BY id, DATE(activity_date)
  HAVING COUNTIF(steps_total = 0) >= 15
)

SELECT
  d.*
FROM duplicates d
INNER JOIN valid_days v
  ON v.id = d.id
  AND v.activity_day = DATE(d.activity_date)
WHERE NOT EXISTS(
  SELECT 1
  FROM inactivity_date i
  WHERE i.id = d.id
  AND i.activity_day = DATE(d.activity_date)
)
