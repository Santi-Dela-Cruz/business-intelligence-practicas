-- =============================================================================
-- TRABAJO EN GRUPO - CONSULTAS ANALÍTICAS (ENTREGABLES)
-- Respuestas a las 5 preguntas del negocio sobre el Modelo Estrella
-- =============================================================================

-- -----------------------------------------------------------------------------
-- CONSULTA 1: ¿Cuántas ventas se realizaron por categoría de producto y mes?
-- (Se utiliza la fecha de la orden 'order_date_key')
-- -----------------------------------------------------------------------------
SELECT 
    p.category AS categoria_producto,
    d.year_month AS mes_orden,
    COUNT(*) AS total_transacciones,
    SUM(f.quantity) AS total_unidades,
    SUM(f.sales_amount) AS monto_total_ventas
FROM fact_sales f
JOIN dim_ventas_product p ON f.product_key = p.product_key
JOIN dim_ventas_date d ON f.order_date_key = d.date_key
GROUP BY p.category, d.year_month
ORDER BY p.category, d.year_month;


-- -----------------------------------------------------------------------------
-- CONSULTA 2: ¿Cuál es el ingreso total (ventas) por cliente y género?
-- -----------------------------------------------------------------------------
SELECT 
    c.customer_key AS id_cliente,
    c.gender AS genero,
    SUM(f.sales_amount) AS ingreso_total
FROM fact_sales f
JOIN dim_ventas_customer c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.gender
ORDER BY ingreso_total DESC;


-- -----------------------------------------------------------------------------
-- CONSULTA 3: ¿Cuál es la cantidad total vendida por producto?
-- -----------------------------------------------------------------------------
SELECT 
    p.product_key AS id_producto,
    p.product_name AS nombre_producto,
    p.category AS categoria,
    p.subcategory AS subcategoria,
    SUM(f.quantity) AS cantidad_total_vendida
FROM fact_sales f
JOIN dim_ventas_product p ON f.product_key = p.product_key
GROUP BY p.product_key, p.product_name, p.category, p.subcategory
ORDER BY cantidad_total_vendida DESC;


-- -----------------------------------------------------------------------------
-- CONSULTA 4: ¿Cuál fue la cantidad enviada por mes de envío?
-- (Se utiliza la fecha de envío 'ship_date_key')
-- -----------------------------------------------------------------------------
SELECT 
    d.year_month AS mes_envio,
    SUM(f.quantity) AS cantidad_total_enviada
FROM fact_sales f
JOIN dim_ventas_date d ON f.ship_date_key = d.date_key
GROUP BY d.year_month
ORDER BY mes_envio;


-- -----------------------------------------------------------------------------
-- CONSULTA 5: ¿Cuánto se vendió por tamaño de producto y por estado civil del cliente?
-- -----------------------------------------------------------------------------
SELECT 
    p.size AS tamano_producto,
    c.marital_status AS estado_civil_cliente,
    SUM(f.sales_amount) AS total_vendido,
    SUM(f.quantity) AS total_unidades_vendidas
FROM fact_sales f
JOIN dim_ventas_product p ON f.product_key = p.product_key
JOIN dim_ventas_customer c ON f.customer_key = c.customer_key
GROUP BY p.size, c.marital_status
ORDER BY p.size, c.marital_status;
