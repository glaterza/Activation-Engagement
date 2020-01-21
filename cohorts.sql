-- Temp Table cohort item (users)  -STEP 1
SELECT   date_trunc('week', u.date_created_nk)::date  AS cohort_week,
         user_sk                                      AS user_id
INTO TEMPORARY TABLE cohort_items
FROM panameraods.ods.dim_users u
WHERE date_created_nk > '2019-11-25'
ORDER BY 1, 2;

-- User activity_1   -STEP 2
SELECT
       a.user_sk                                       AS user_id,
       (Date_trunc('week', a.date_nk)::date)           AS week_number
INTO TEMPORARY TABLE user_activities_1
FROM  panameraods.ods.fact_user_hydra_browsing_activity a
WHERE date_nk > '2019-11-25'
GROUP BY  1, 2;

-- User activity_2  - STEP 3
SELECT
       a.user_id,
       TRUNC((a.week_number- c.cohort_week)/7 )         AS week_number
INTO TEMPORARY TABLE user_activities_2
FROM user_activities_1 a
LEFT JOIN cohort_items c
ON a.user_id = c.user_id;

DROP TABLE user_activities_1;

-- cohort sizing   -STEP 4
SELECT
        cohort_week,
        Count(1) AS num_users
INTO TEMPORARY TABLE cohort_size
FROM cohort_items
GROUP BY 1
ORDER BY 1;

-- count & grouping  - STEP 5
SELECT
       c.cohort_week,
       a.week_number,
       Count(1) AS num_users
INTO TEMPORARY TABLE grouping
FROM      user_activities_2 a
LEFT JOIN cohort_items c
ON        a.user_id = c.user_id
GROUP BY  1,2;

-- final table:(cohort_week, size, week_number, percentage)      -STEP 6
SELECT    g.cohort_week,
          s.num_users AS total_users,
          g.week_number,
          g.num_users::float * 100 / s.num_users AS percentage
FROM      grouping g
LEFT JOIN cohort_size s
ON        g.cohort_week = s.cohort_week
WHERE     g.cohort_week IS NOT NULL
ORDER BY  1,3;

--- cleaning
DROP TABLE cohort_items;
DROP TABLE user_activities_2;
DROP TABLE cohort_size;
DROP TABLE grouping;
