CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.client_mv AS
SELECT DISTINCT
  cm.county_id,
  cm.county_name,
  pm.product_id AS product_type_id,
  pm.product_type AS product_type,
  c.eic_count,
  c.installed_capacity,
  cast(c.is_business as boolean) AS is_business,
  TO_DATE(date, 'yyyy-MM-dd') AS observ_date,
  c.data_block_id
FROM cscie103_catalog_final.bronze.client c INNER JOIN cscie103_catalog_final.silver.county_mapping cm 
ON c.county = cm.county_id INNER JOIN cscie103_catalog_final.silver.product_mapping pm
ON c.product_type = pm.product_id
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.weather_mapping_mv AS
SELECT DISTINCT
  UPPER(wm.county_name) AS county_name,
  ROUND(wm.longitude,12) AS longitude,
  ROUND(wm.latitude,12) AS latitude,
  wm.county as county_id
FROM cscie103_catalog_final.bronze.weather_mapping wm 
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.weather_hist_mv AS
SELECT DISTINCT
ROUND(wh.latitude, 12) as latitude,
ROUND(wh.longitude, 12) as longitude,
wh.datetime,
wh.temperature,
wh.dewpoint,
wh.rain,
wh.snowfall,
wh.surface_pressure,
wh.cloudcover_total,
wh.cloudcover_low,
wh.cloudcover_mid,
wh.cloudcover_high,
wh.windspeed_10m,
wh.winddirection_10m,
wh.shortwave_radiation,
wh.direct_solar_radiation,
wh.diffuse_radiation,
wh.data_block_id,
wm.county as county_id,
wm.county_name
FROM cscie103_catalog_final.bronze.weather_hist wh INNER JOIN cscie103_catalog_final.bronze.weather_mapping wm
ON ROUND(wh.latitude,12)=ROUND(wm.latitude, 12) and ROUND(wh.longitude, 12)=ROUND(wm.longitude,12)
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.weather_forecast_mv AS
SELECT DISTINCT
ROUND(wf.latitude, 12) as latitude,
ROUND(wf.longitude, 12) as longitude,
wf.origin_datetime,
wf.hours_ahead,
wf.temperature,
wf.dewpoint,
wf.cloudcover_high,
wf.cloudcover_low,
wf.cloudcover_mid,
wf.cloudcover_total,
wf.10_metre_u_wind_component,
wf.10_metre_v_wind_component,
wf.data_block_id,
wf.forecast_datetime,
wf.direct_solar_radiation,
wf.surface_solar_radiation_downwards,
wf.snowfall,
wf.total_precipitation,
wm.county as county_id,
wm.county_name
FROM cscie103_catalog_final.bronze.weather_forecast wf INNER JOIN cscie103_catalog_final.bronze.weather_mapping wm
ON ROUND(wf.latitude,12)=ROUND(wm.latitude, 12) and ROUND(wf.longitude, 12)=ROUND(wm.longitude,12)
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.train_mv AS
SELECT DISTINCT
cm.county_id,
cm.county_name,
pm.product_id AS product_type_id,
pm.product_type AS product_type,
CAST(is_business AS BOOLEAN) AS is_business,
target,
CAST(is_consumption AS BOOLEAN) AS is_consumption,
datetime,
data_block_id,
row_id,
prediction_unit_id
FROM cscie103_catalog_final.bronze.train t INNER JOIN cscie103_catalog_final.silver.county_mapping cm 
ON t.county = cm.county_id INNER JOIN cscie103_catalog_final.silver.product_mapping pm
ON t.product_type = pm.product_id 
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.gas_prices_mv AS
SELECT DISTINCT
forecast_date,
lowest_price_per_mwh,
highest_price_per_mwh,
origin_date,
data_block_id
FROM cscie103_catalog_final.bronze.gas_prices gp
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.silver.electricity_prices_mv AS
SELECT DISTINCT
forecast_date,
euros_per_mwh,
origin_date,
data_block_id
FROM cscie103_catalog_final.bronze.electricity_prices ep
;