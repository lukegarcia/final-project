-- Create bronze streaming table for client data selecting from a volume directory
CREATE OR REFRESH STREAMING TABLE cscie103_catalog_final.bronze.client_stream
COMMENT "Client streaming from volume using cloud_files autoloader"
AS
SELECT * FROM cloud_files(
  'dbfs:/Volumes/cscie103_catalog_final/bronze/landing/predict-energy-behavior-of-prosumers/client',
  'csv',
  map(    'header', 'true',
    'inferSchema', 'true',
    'includeExistingFiles', 'true')
);

-- Create bronze streaming table for weather station data selecting from a volume directory
CREATE OR REFRESH STREAMING TABLE cscie103_catalog_final.bronze.weather_mapping_stream
COMMENT "Weather Station streaming from volume using cloud_files autoloader"
AS
SELECT * FROM cloud_files(
  'dbfs:/Volumes/cscie103_catalog_final/bronze/landing/predict-energy-behavior-of-prosumers/weather_mapping',
  'csv',
  map(    'header', 'true',
    'inferSchema', 'true',
    'includeExistingFiles', 'true')
);
-- Create bronze streaming table for weather_forecast selecting from a volume directory
CREATE OR REFRESH STREAMING TABLE cscie103_catalog_final.bronze.weather_forecast_stream
COMMENT "Weather forecast streaming from volume using cloud_files autoloader"
AS
SELECT * FROM cloud_files(
  'dbfs:/Volumes/cscie103_catalog_final/bronze/landing/predict-energy-behavior-of-prosumers/forecast_weather',
  'csv',
  map(    'header', 'true',
    'inferSchema', 'true',
    'includeExistingFiles', 'true')
);
-- Create bronze streaming table for weather_hist data selecting from a volume directory
CREATE OR REFRESH STREAMING TABLE cscie103_catalog_final.bronze.weather_hist_stream
COMMENT "Weather History streaming from volume using cloud_files autoloader"
AS
SELECT * FROM cloud_files(
  'dbfs:/Volumes/cscie103_catalog_final/bronze/landing/predict-energy-behavior-of-prosumers/historical_weather',
  'csv',
  map(    'header', 'true',
    'inferSchema', 'true',
    'includeExistingFiles', 'true')
);
-- Create bronze streaming table for train data selecting from a volume directory
CREATE OR REFRESH STREAMING TABLE cscie103_catalog_final.bronze.train_stream
COMMENT "Train streaming from volume using cloud_files autoloader"
AS
SELECT * FROM cloud_files(
  'dbfs:/Volumes/cscie103_catalog_final/bronze/landing/predict-energy-behavior-of-prosumers/train',
  'csv',
  map(    'header', 'true',
    'inferSchema', 'true',
    'includeExistingFiles', 'true')
);
-- Create bronze streaming table for gas_prices data selecting from a volume directory
CREATE OR REFRESH STREAMING TABLE cscie103_catalog_final.bronze.gas_prices_stream
COMMENT "Gas prices streaming from volume using cloud_files autoloader"
AS
SELECT * FROM cloud_files(
  'dbfs:/Volumes/cscie103_catalog_final/bronze/landing/predict-energy-behavior-of-prosumers/gas_prices',
  'csv',
  map(    'header', 'true',
    'inferSchema', 'true',
    'includeExistingFiles', 'true')
);
-- Create bronze streaming table for electricity_prices data selecting from a volume directory
CREATE OR REFRESH STREAMING TABLE cscie103_catalog_final.bronze.electricity_prices_stream
COMMENT "Electricity prices streaming from volume using cloud_files autoloader"
AS
SELECT * FROM cloud_files(
  'dbfs:/Volumes/cscie103_catalog_final/bronze/landing/predict-energy-behavior-of-prosumers/electricity_prices',
  'csv',
  map(    'header', 'true',
    'inferSchema', 'true',
    'includeExistingFiles', 'true')
);
