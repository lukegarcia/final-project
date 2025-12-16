CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.client_mv AS
SELECT DISTINCT
  cm.county_id,
  cm.county_name,
  pm.product_id AS product_type_id,
  pm.product_type AS product_type,
  CAST(c.eic_count AS INT) AS eic_count,
  CAST(c.installed_capacity AS DOUBLE) AS installed_capacity,
  cast(c.is_business as boolean) AS is_business,
  TO_DATE(date, 'yyyy-MM-dd') AS observ_date,
  CAST(c.data_block_id AS INT) AS data_block_id
FROM cscie103_catalog_final.bronze.client_stream c INNER JOIN cscie103_catalog_final.silver.county_mapping cm 
ON c.county = cm.county_id INNER JOIN cscie103_catalog_final.silver.product_mapping pm
ON c.product_type = pm.product_id
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.weather_mapping_mv AS
SELECT DISTINCT
  UPPER(wm.county_name) AS county_name,
  ROUND(wm.longitude,12) AS longitude,
  ROUND(wm.latitude,12) AS latitude,
  wm.county as county_id
FROM cscie103_catalog_final.bronze.weather_mapping_stream wm 
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.weather_hist_mv AS
SELECT DISTINCT
ROUND(wh.latitude, 12) as latitude,
ROUND(wh.longitude, 12) as longitude,
TO_TIMESTAMP(wh.datetime) AS datetime,
CAST(wh.temperature as DOUBLE) AS temperature,
CAST(wh.dewpoint AS DOUBLE) AS dewpoint,
CAST(wh.rain AS DOUBLE) AS rain,
CAST(wh.snowfall AS DOUBLE) AS snowfall,
CAST(wh.surface_pressure AS DOUBLE) AS surface_pressure,
CAST(wh.cloudcover_total AS DOUBLE) AS cloudcover_total,
CAST(wh.cloudcover_low AS DOUBLE) AS cloudcover_low,
CAST(wh.cloudcover_mid AS DOUBLE) AS cloudcover_mid,
CAST(wh.cloudcover_high AS DOUBLE) AS cloudcover_high,
CAST(wh.windspeed_10m AS DOUBLE) AS windspeed_10m,
CAST(wh.winddirection_10m AS DOUBLE) AS winddirection_10m,
CAST(wh.shortwave_radiation AS DOUBLE) AS shortwave_radiation,
CAST(wh.direct_solar_radiation AS DOUBLE) AS direct_solar_radiation,
CAST(wh.diffuse_radiation AS DOUBLE) AS diffuse_radiation,
CAST(wh.data_block_id AS INT) AS data_block_id,
CAST(wm.county AS INT) AS county_id,
wm.county_name
FROM cscie103_catalog_final.bronze.weather_hist_stream wh INNER JOIN cscie103_catalog_final.bronze.weather_mapping_stream wm
ON ROUND(wh.latitude,12)=ROUND(wm.latitude, 12) and ROUND(wh.longitude, 12)=ROUND(wm.longitude,12)
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.weather_forecast_mv AS
SELECT DISTINCT
ROUND(wf.latitude, 12) AS latitude,
ROUND(wf.longitude, 12) AS longitude,
TO_TIMESTAMP(wf.origin_datetime) AS origin_datetime,
CAST(wf.hours_ahead AS INT) AS hours_ahead,
CAST(wf.temperature AS DOUBLE) AS temperature,
CAST(wf.dewpoint AS DOUBLE) AS dewpoint,
CAST(wf.cloudcover_high AS DOUBLE) AS cloudcover_high,
CAST(wf.cloudcover_low AS DOUBLE) AS cloudcover_low,
CAST(wf.cloudcover_mid AS DOUBLE) AS cloudcover_mid,
CAST(wf.cloudcover_total AS DOUBLE) AS cloudcover_total,
CAST(wf.10_metre_u_wind_component AS DOUBLE) AS 10_metre_u_wind_component,
CAST(wf.10_metre_v_wind_component AS DOUBLE) AS 10_metre_v_wind_component,
CAST(wf.data_block_id AS INT) AS data_block_id,
TO_TIMESTAMP(wf.forecast_datetime) AS forecast_datetime,
CAST(wf.direct_solar_radiation AS DOUBLE) AS direct_solar_radiation,
CAST(wf.surface_solar_radiation_downwards AS DOUBLE) AS surface_solar_radiation_downwards,
CAST(wf.snowfall AS DOUBLE) AS snowfall,
CAST(wf.total_precipitation AS DOUBLE) AS total_precipitation,
CAST(wm.county AS INT) AS county_id,
wm.county_name
FROM cscie103_catalog_final.bronze.weather_forecast_stream wf 
INNER JOIN cscie103_catalog_final.bronze.weather_mapping_stream wm
ON ROUND(wf.latitude,12)=ROUND(wm.latitude, 12) 
AND ROUND(wf.longitude, 12)=ROUND(wm.longitude,12)
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.train_mv AS
SELECT DISTINCT
cm.county_id,
cm.county_name,
pm.product_id AS product_type_id,
pm.product_type AS product_type,
CAST(is_business AS BOOLEAN) AS is_business,
CAST(target AS DOUBLE) AS target,
CAST(is_consumption AS BOOLEAN) AS is_consumption,
TO_TIMESTAMP(datetime) as datetime,
CAST(data_block_id AS INT) AS data_block_id,
CAST(row_id AS INT) AS row_id,
CAST(prediction_unit_id AS INT) AS prediction_unit_id
FROM cscie103_catalog_final.bronze.train_stream t INNER JOIN cscie103_catalog_final.silver.county_mapping cm 
ON t.county = cm.county_id INNER JOIN cscie103_catalog_final.silver.product_mapping pm
ON t.product_type = pm.product_id 
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.gas_prices_mv AS
SELECT DISTINCT
TO_DATE(forecast_date) AS forecast_date,
CAST(lowest_price_per_mwh AS DOUBLE) AS lowest_price_per_mwh,
CAST(highest_price_per_mwh AS DOUBLE) AS highest_price_per_mwh,
TO_DATE(origin_date) AS origin_date,
CAST(data_block_id AS INT) AS data_block_id
FROM cscie103_catalog_final.bronze.gas_prices_stream gp
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.electricity_prices_mv AS
SELECT DISTINCT
TO_TIMESTAMP(forecast_date) AS forecast_date,
CAST(euros_per_mwh AS DOUBLE) AS euros_per_mwh,
TO_TIMESTAMP(origin_date) AS origin_date,
CAST(data_block_id AS INT) AS data_block_id
FROM cscie103_catalog_final.bronze.electricity_prices_stream ep
;