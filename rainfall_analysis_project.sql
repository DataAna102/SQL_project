--database creation
CREATE DATABASE rainfall_db;

--table creation
CREATE TABLE district (
    dist_code INT PRIMARY KEY NOT NULL,
    district VARCHAR(50) NOT NULL,
    "actual rainfall (south_west)" FLOAT,
    "normal rainfall (south_west)" FLOAT,
    "actual rainfall (north_east)" FLOAT,
    "normal rainfall (north_east)" FLOAT,
    "actual rainfall (winter)" FLOAT,
    "normal rainfall (winter)" FLOAT,
    "actual rainfall (hot weather)" FLOAT,
    "normal rainfall (hot weather)" FLOAT,
    actual_total_rainfall FLOAT,
    normal_total_rainfall FLOAT
);

--ensure table creation
SELECT * FROM district;

--rename table
ALTER TABLE district RENAME TO rainfall_dataset;

--revisit the table
SELECT * FROM rainfall_dataset;

--rename column "actual rainfall (hot_weather)" and "normal rainfall (hot_weather)"
ALTER TABLE rainfall_dataset
RENAME COLUMN "actual rainfall (hot weather)" TO "actual rainfall (hot_weather)";

ALTER TABLE rainfall_dataset
RENAME COLUMN "normal rainfall (hot weather)" TO "normal rainfall (hot_weather)";

--ensure alteration in table
SELECT * FROM rainfall_dataset;

--import csv file
COPY rainfall_dataset
(dist_code, district, "actual rainfall (south_west)", "normal rainfall (south_west)", "actual rainfall (north_east)",
 "normal rainfall (north_east)", "actual rainfall (winter)", "normal rainfall (winter)", "actual rainfall (hot_weather)",
 "normal rainfall (hot_weather)", actual_total_rainfall, normal_total_rainfall)
FROM 'C:\Users\Lenovo\OneDrive\Documents\SQL\rainfall_dataset.csv'
DELIMITER ','
CSV HEADER;

--ensure imports 
SELECT * FROM rainfall_dataset;

--average rainfall of istrict across region
SELECT AVG("actual rainfall (south_west)") AS avg_south_west,
       AVG("actual rainfall (north_east)") AS avg_north_east,
       AVG("actual rainfall (winter)") AS avg_winter,
       AVG("actual rainfall (hot_weather)") AS avg_hot_weather
FROM rainfall_dataset
LIMIT 5;

--region received hightest rainfall
SELECT dist_code, district, actual_total_rainfall
FROM rainfall_dataset
WHERE actual_total_rainfall > (SELECT AVG(actual_total_rainfall) AS total_rain
								FROM rainfall_dataset)
GROUP BY dist_code
ORDER BY actual_total_rainfall desc;

--sum of actual and normal_total rainfall with avg
SELECT AVG("actual rainfall") AS "average_actual_rainfall",
       AVG("normal rainfall") AS "average_normal_rainfall"
FROM (
    SELECT SUM("actual_total_rainfall") AS "actual rainfall",
           SUM("normal_total_rainfall") AS "normal rainfall"
    FROM rainfall_dataset
) AS subquery;







