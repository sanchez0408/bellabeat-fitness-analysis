CREATE OR REPLACE TABLE `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity_cleaning` AS
SELECT
  Id,
  ActivityDate,
  MAX(TotalSteps)AS TotalSteps,
  MAX(TotalDistance) AS TotalDistance,
  MAX(TrackerDistance) AS TrackerDistance,
  MAX(LoggedActivitiesDistance)AS LoggedActivitiesDistance,
  MAX(VeryActiveDistance)AS VeryActiveDistance,
  MAX(ModeratelyActiveDistance)AS ModeratelyActiveDistance,
  MAX(LightActiveDistance)AS LightActiveDistance,
  MAX(SedentaryActiveDistance)AS SedentaryActiveDistance,
  MAX(VeryActiveMinutes)AS VeryActiveMinutes,
  MAX(FairlyActiveMinutes)AS FairlyActiveMinutes,
  MAX(LightlyActiveMinutes)AS LightlyActiveMinutes,
  MAX(SedentaryMinutes)AS SedentaryMinutes,
  MAX(Calories) AS Calories
FROM `mon-projet-bigquery-481616.bellabeat_project_1.daily_activity`
GROUP BY Id, ActivityDate
