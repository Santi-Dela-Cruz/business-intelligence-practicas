-- =============================================================================
-- TRABAJO EN GRUPO - MODELO ESTRELLA DE VENTAS
-- SCRIPT DDL: Creación de tablas de Staging, Dimensiones y Hechos
-- =============================================================================

-- 1. Tabla de Staging para los datos desnormalizados de ventas
DROP TABLE IF EXISTS stg_ventas CASCADE;

CREATE TABLE stg_ventas (
    product_key         INT,
    product_code        VARCHAR(20),
    product_name        VARCHAR(100),
    list_price          NUMERIC(10,2),
    color               VARCHAR(30),
    size                VARCHAR(30),
    category            VARCHAR(50),
    subcategory         VARCHAR(50),
    customer_key        INT,
    birth_date          DATE,
    marital_status      VARCHAR(20),
    gender              VARCHAR(10),
    income              NUMERIC(12,2),
    children            INT,
    home_owner          VARCHAR(5),
    cars                INT,
    order_date_key      INT,
    order_date          DATE,
    ship_date_key       INT,
    ship_date           DATE,
    order_number        VARCHAR(20),
    order_line_number   INT,
    quantity            INT,
    unit_price          NUMERIC(10,2),
    product_cost        NUMERIC(10,2),
    sales_amount        NUMERIC(10,2)
);

-- 2. Creación de Dimensiones del Esquema Estrella

-- 2.1 Dimensión Producto
DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_ventas_product CASCADE;

CREATE TABLE dim_ventas_product (
    product_key     INT PRIMARY KEY,
    product_code    VARCHAR(20) NOT NULL,
    product_name    VARCHAR(100) NOT NULL,
    list_price      NUMERIC(10,2) NOT NULL,
    color           VARCHAR(30) NOT NULL,
    size            VARCHAR(30) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    subcategory     VARCHAR(50) NOT NULL
);

-- 2.2 Dimensión Cliente
DROP TABLE IF EXISTS dim_ventas_customer CASCADE;

CREATE TABLE dim_ventas_customer (
    customer_key    INT PRIMARY KEY,
    birth_date      DATE NOT NULL,
    marital_status  VARCHAR(20) NOT NULL,
    gender          VARCHAR(10) NOT NULL,
    income          NUMERIC(12,2) NOT NULL,
    children        INT NOT NULL,
    home_owner      VARCHAR(5) NOT NULL,
    cars            INT NOT NULL
);

-- 2.3 Dimensión Fecha (para OrderDate y ShipDate)
DROP TABLE IF EXISTS dim_ventas_date CASCADE;

CREATE TABLE dim_ventas_date (
    date_key        INT PRIMARY KEY,
    full_date       DATE NOT NULL,
    year            INT NOT NULL,
    month           INT NOT NULL,
    month_name      VARCHAR(20) NOT NULL,
    day             INT NOT NULL,
    quarter         INT NOT NULL,
    year_month      VARCHAR(7) NOT NULL
);

-- 3. Creación de la Tabla de Hechos (Fact Table)
CREATE TABLE fact_sales (
    sales_key           BIGSERIAL PRIMARY KEY,
    order_number        VARCHAR(20) NOT NULL,
    order_line_number   INT NOT NULL,
    product_key         INT NOT NULL REFERENCES dim_ventas_product(product_key),
    customer_key        INT NOT NULL REFERENCES dim_ventas_customer(customer_key),
    order_date_key      INT NOT NULL REFERENCES dim_ventas_date(date_key),
    ship_date_key       INT NOT NULL REFERENCES dim_ventas_date(date_key),
    quantity            INT NOT NULL,
    unit_price          NUMERIC(10,2) NOT NULL,
    product_cost        NUMERIC(10,2) NOT NULL,
    sales_amount        NUMERIC(10,2) NOT NULL,
    CONSTRAINT uq_order_line UNIQUE (order_number, order_line_number)
);

-- Índices sobre claves foráneas para optimizar consultas OLAP
CREATE INDEX idx_fact_sales_product ON fact_sales(product_key);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_key);
CREATE INDEX idx_fact_sales_order_date ON fact_sales(order_date_key);
CREATE INDEX idx_fact_sales_ship_date ON fact_sales(ship_date_key);
