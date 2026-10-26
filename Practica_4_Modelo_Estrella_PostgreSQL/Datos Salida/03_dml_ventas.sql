-- =============================================================================
-- TRABAJO EN GRUPO - MODELO ESTRELLA DE VENTAS
-- SCRIPT DML: Carga de Staging, Limpieza y Poblado del Esquema Estrella
-- =============================================================================

-- 1. Cargar archivo CSV desnormalizado en Staging
-- Delimitador es punto y coma (;) y formato CSV con encabezado UTF-8
\copy stg_ventas FROM 'Tabla_Desnormalizada_Ventas.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');

-- 2. Validación de la carga en Staging
SELECT COUNT(*) AS total_registros_staging FROM stg_ventas;

-- 3. Limpieza y estandarización básica en Staging
UPDATE stg_ventas
SET product_name = regexp_replace(btrim(product_name), '\s+', ' ', 'g'),
    category = btrim(category),
    subcategory = btrim(subcategory),
    color = btrim(color),
    size = btrim(size),
    marital_status = btrim(marital_status),
    gender = btrim(gender),
    home_owner = btrim(home_owner);

-- 4. Poblado de la Dimensión Fecha (dim_ventas_date)
-- Consolida tanto las fechas de orden como de envío
INSERT INTO dim_ventas_date (date_key, full_date, year, month, month_name, day, quarter, year_month)
SELECT DISTINCT
    d.date_key,
    d.full_date,
    EXTRACT(YEAR FROM d.full_date)::INT AS year,
    EXTRACT(MONTH FROM d.full_date)::INT AS month,
    TO_CHAR(d.full_date, 'TMMonth') AS month_name,
    EXTRACT(DAY FROM d.full_date)::INT AS day,
    EXTRACT(QUARTER FROM d.full_date)::INT AS quarter,
    TO_CHAR(d.full_date, 'YYYY-MM') AS year_month
FROM (
    SELECT order_date_key AS date_key, order_date AS full_date FROM stg_ventas
    UNION
    SELECT ship_date_key AS date_key, ship_date AS full_date FROM stg_ventas
) d
ORDER BY d.date_key;

-- 5. Poblado de la Dimensión Producto (dim_ventas_product)
INSERT INTO dim_ventas_product (product_key, product_code, product_name, list_price, color, size, category, subcategory)
SELECT DISTINCT
    product_key,
    product_code,
    product_name,
    list_price,
    color,
    size,
    category,
    subcategory
FROM stg_ventas
ORDER BY product_key;

-- 6. Poblado de la Dimensión Cliente (dim_ventas_customer)
INSERT INTO dim_ventas_customer (customer_key, birth_date, marital_status, gender, income, children, home_owner, cars)
SELECT DISTINCT
    customer_key,
    birth_date,
    marital_status,
    gender,
    income,
    children,
    home_owner,
    cars
FROM stg_ventas
ORDER BY customer_key;

-- 7. Poblado de la Tabla de Hechos (fact_sales)
INSERT INTO fact_sales (
    order_number,
    order_line_number,
    product_key,
    customer_key,
    order_date_key,
    ship_date_key,
    quantity,
    unit_price,
    product_cost,
    sales_amount
)
SELECT
    order_number,
    order_line_number,
    product_key,
    customer_key,
    order_date_key,
    ship_date_key,
    quantity,
    unit_price,
    product_cost,
    sales_amount
FROM stg_ventas
ORDER BY order_number, order_line_number;

-- 8. Validaciones finales de consistencia
SELECT COUNT(*) AS total_fechas FROM dim_ventas_date;
SELECT COUNT(*) AS total_productos FROM dim_ventas_product;
SELECT COUNT(*) AS total_clientes FROM dim_ventas_customer;
SELECT COUNT(*) AS total_hechos_ventas FROM fact_sales;
