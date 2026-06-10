-- ================= --
-- STEP 1: STRUCTURE --
-- ================= --

SELECT
  column_name,
  data_type
FROM `project_id.dataset_name.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'table_name'

-- Observation:

-- Decision:



-- ======================== --
-- STEP 2: GENERAL OVERVIEW --
-- ======================== --

SELECT *
FROM `project_id.dataset_name.table_name`
LIMIT 10

-- Observation:

-- Decision:



-- ============== --
-- STEP 3: VOLUME --
-- ============== --

SELECT COUNT(*) AS nb_lines
FROM `project_id.dataset_name.table_name`

-- Observation:



-- ======================== --
-- STEP 4: DUPLICATE SEARCH --
-- ======================== --

-- Define duplicate column
SELECT
  column_1,
  column_2
  COUNT(*)AS nb_duplicates
FROM `project_id.dataset_name.table_name`
GROUP BY column_1, column_2
HAVING COUNT(*) > 1

-- Observation:

-- Decision:



-- =========================== --
-- STEP 5: VALUES NULLs SEARCH --
-- =========================== --

SELECT
  COUNTIF(column_1 IS NULL) AS column_1
  -- Other columns
FROM `project_id.dataset_name.table_name`

-- Observation:

-- Decision:



-- ====================== --
-- STEP 6: NUMERICS STATS --
-- ====================== --

SELECT
  MAX(numeric_column),
  MIN(numeric_column),
  AVG(numeric_column)
FROM `project_id.dataset_name.table_name`

-- Observation:

-- Decision:



-- ============= --
-- STEP 7: DATES --
-- ============= --

SELECT 
  MIN(date_column) AS min_date,
  MAX(date_column) AS max_date
FROM `project_id.dataset_name.table_name`

-- Observation:

-- Decision:



-- ============================== --
-- STEP 8: VERIFICATION OF VALUES --
-- ============================== --

SELECT
FROM `project_id.dataset_name.table_name`
WHERE numeric_column < 0

-- Observation:

-- Decision:
