-- =============================================================================
-- PRÁCTICA 4: Implementación física de una dimensión para un modelo estrella
-- DIMENSIÓN: dim_product
-- =============================================================================

-- 1. Crear tabla de Staging
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS stg_products CASCADE;

CREATE TABLE stg_products (
    product_id      VARCHAR(5),
    product_name    VARCHAR(150),
    category        VARCHAR(80),
    subcategory     VARCHAR(80)
);

-- Cargar datos CSV a Staging
\copy stg_products FROM 'products.csv' WITH (FORMAT csv, HEADER true);

-- 2. Consultas de Validación Inicial
-- Número de registros (Esperado: 699)
SELECT COUNT(*) AS total_registros FROM stg_products;

-- IDs de producto únicos (Esperado: 699)
SELECT COUNT(DISTINCT product_id) AS productos_unicos FROM stg_products;

-- Categorías y subcategorías (Esperado: 10 categorías, 53 subcategorías)
SELECT COUNT(DISTINCT category) AS categorias,
       COUNT(DISTINCT subcategory) AS subcategorias
FROM stg_products;

-- 3. Limpieza de datos en Staging
UPDATE stg_products
SET product_name = regexp_replace(btrim(product_name), '\s+', ' ', 'g'),
    category = btrim(category),
    subcategory = btrim(subcategory);

-- Verificación de duplicados y nulos
SELECT product_id, COUNT(*)
FROM stg_products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT *
FROM stg_products
WHERE product_id IS NULL OR product_id = '';

-- 4. Crear Dimensión dim_product con Surrogate Key
CREATE TABLE dim_product (
    product_key  BIGSERIAL PRIMARY KEY,
    product_id   VARCHAR(5) NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category     VARCHAR(80) NOT NULL,
    subcategory  VARCHAR(80) NOT NULL
);

-- 5. Cargar datos a dim_product
INSERT INTO dim_product (product_id, product_name, category, subcategory)
SELECT DISTINCT
    product_id,
    product_name,
    category,
    subcategory
FROM stg_products
ORDER BY product_id;

-- Validar carga
SELECT COUNT(*) AS total_dim_product FROM dim_product;
SELECT * FROM dim_product ORDER BY product_key LIMIT 10;

-- 6. Consultas de Análisis
-- 6.1 Productos por categoría
SELECT category, COUNT(*) AS total_productos
FROM dim_product
GROUP BY category
ORDER BY total_productos DESC;

-- 6.2 Productos por subcategoría
SELECT subcategory, COUNT(*) AS total_productos
FROM dim_product
GROUP BY subcategory
ORDER BY total_productos DESC;

-- 6.3 Productos de la categoría 'Beauty & Hygiene'
SELECT product_id, product_name, subcategory
FROM dim_product
WHERE category = 'Beauty & Hygiene'
ORDER BY product_name
LIMIT 10;

-- 6.4 Productos de la subcategoría 'Biscuits & Cookies'
SELECT product_id, product_name, category
FROM dim_product
WHERE subcategory = 'Biscuits & Cookies'
ORDER BY product_name
LIMIT 10;

-- 6.5 Número de subcategorías por categoría
SELECT category, COUNT(DISTINCT subcategory) AS total_subcategorias
FROM dim_product
GROUP BY category
ORDER BY total_subcategorias DESC, category;
