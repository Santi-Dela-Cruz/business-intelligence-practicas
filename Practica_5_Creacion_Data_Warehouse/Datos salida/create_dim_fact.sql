-- Tabla RAW (staging)
CREATE TABLE raw_desnutricion (
  child_id VARCHAR(10),
  gender CHAR(1),
  age_months INT,
  weight_kg NUMERIC(10,2),
  height_cm NUMERIC(10,2),
  nutritional_status VARCHAR(50),
  region VARCHAR(50),
  institution VARCHAR(100),
  date_measured DATE
);

-- Tabla de Dimensión Paciente
CREATE TABLE dim_paciente (
  paciente_key SERIAL PRIMARY KEY,
  child_id VARCHAR(10),
  gender CHAR(1),
  age_months INT
);

-- Tabla de Dimensión Lugar
CREATE TABLE dim_lugar (
  lugar_key SERIAL PRIMARY KEY,
  region VARCHAR(50),
  institution VARCHAR(100)
);

-- Tabla de Dimensión Diagnóstico
CREATE TABLE dim_diagnostico (
  diagnostico_key SERIAL PRIMARY KEY,
  nutritional_status VARCHAR(50)
);

-- Tabla de Dimensión Tiempo
CREATE TABLE dim_tiempo (
  date_key DATE PRIMARY KEY,
  year INT,
  month INT,
  day INT,
  quarter VARCHAR(5)
);

-- Tabla de Hechos
CREATE TABLE fact_desnutricion (
  fact_key SERIAL PRIMARY KEY,
  paciente_key INT,
  lugar_key INT,
  diagnostico_key INT,
  date_key DATE,
  weight_kg NUMERIC(10,2),
  height_cm NUMERIC(10,2),
  casos INT DEFAULT 1
);