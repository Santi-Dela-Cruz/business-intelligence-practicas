-- HAPPYTECH | Caso constelacion | Clase 4
-- Ejecutar completo en PostgreSQL con Query Tool (pgAdmin) o psql.
-- Crea y recarga las tablas del esquema happytech_dw.
CREATE SCHEMA IF NOT EXISTS happytech_dw;
SET search_path TO happytech_dw;

DROP TABLE IF EXISTS fact_soporte, fact_pedidos, dim_motivo_soporte, dim_ciudad,
    dim_cliente, dim_producto, dim_fecha, stg_soporte, stg_pedidos CASCADE;

-- 1. STAGING: copia fiel de las dos hojas Excel (fechas originales tipo texto)
CREATE TABLE stg_pedidos (
  origen_fila integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fecha_texto text NOT NULL, producto text NOT NULL, categoria text NOT NULL,
  marca text NOT NULL, cliente text NOT NULL, ciudad text NOT NULL,
  region text NOT NULL, cantidad integer NOT NULL, total_pedido numeric(14,2) NOT NULL
);
CREATE TABLE stg_soporte (
  origen_fila integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fecha_texto text NOT NULL, producto text NOT NULL, categoria text NOT NULL,
  marca text NOT NULL, cliente text NOT NULL, ciudad text NOT NULL,
  region text NOT NULL, ticket_id integer NOT NULL, motivo text NOT NULL,
  tiempo_respuesta_horas numeric(12,2) NOT NULL
);

INSERT INTO stg_pedidos (fecha_texto,producto,categoria,marca,cliente,ciudad,region,cantidad,total_pedido) VALUES
  ('2025-01-01', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 5930),
  ('2025-01-12', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Épsilon', 'Manta', 'Costa', 3, 3951),
  ('2025-01-08', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 1, 342),
  ('2025-01-20', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Beta', 'Guayaquil', 'Costa', 1, 1780),
  ('2025-01-02', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 1, 947),
  ('2025-01-20', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 2, 2738),
  ('2025-01-14', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 3, 831),
  ('2025-01-07', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 2, 3820),
  ('2025-01-25', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 2, 768),
  ('2025-01-25', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Alfa', 'Quito', 'Sierra', 1, 242),
  ('2025-01-11', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Delta', 'Ambato', 'Sierra', 2, 1060),
  ('2025-01-20', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Alfa', 'Quito', 'Sierra', 1, 481),
  ('2025-01-03', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 762),
  ('2025-01-07', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Épsilon', 'Manta', 'Costa', 2, 2836),
  ('2025-01-18', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Delta', 'Ambato', 'Sierra', 2, 5622),
  ('2025-01-25', 'Router AX10', 'Redes', 'NetGo', 'Empresa Delta', 'Ambato', 'Sierra', 2, 3756),
  ('2025-01-05', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 2242),
  ('2025-01-19', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Gama', 'Cuenca', 'Sierra', 1, 1324),
  ('2025-01-05', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Épsilon', 'Manta', 'Costa', 2, 4744),
  ('2025-01-26', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 5378),
  ('2025-01-14', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Alfa', 'Quito', 'Sierra', 1, 1203),
  ('2025-01-30', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Gama', 'Cuenca', 'Sierra', 3, 8331),
  ('2025-01-23', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 2, 3728),
  ('2025-01-29', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 2224),
  ('2025-01-03', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 3, 7470),
  ('2025-01-11', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Delta', 'Ambato', 'Sierra', 3, 2505),
  ('2025-01-30', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 2, 856),
  ('2025-01-25', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 2, 344),
  ('2025-01-17', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Épsilon', 'Manta', 'Costa', 1, 2098),
  ('2025-01-29', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Alfa', 'Quito', 'Sierra', 2, 3924),
  ('2025-01-29', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 1, 2723),
  ('2025-01-08', 'Router AX10', 'Redes', 'NetGo', 'Empresa Delta', 'Ambato', 'Sierra', 2, 4614),
  ('2025-01-29', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Delta', 'Ambato', 'Sierra', 3, 2586),
  ('2025-01-08', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Alfa', 'Quito', 'Sierra', 2, 4158),
  ('2025-01-19', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Alfa', 'Quito', 'Sierra', 3, 4404),
  ('2025-01-29', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Gama', 'Cuenca', 'Sierra', 3, 1026),
  ('2025-01-27', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Alfa', 'Quito', 'Sierra', 3, 5577),
  ('2025-01-23', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 1, 2912),
  ('2025-01-19', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 1, 2428),
  ('2025-01-12', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Gama', 'Cuenca', 'Sierra', 2, 4278),
  ('2025-01-11', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Delta', 'Ambato', 'Sierra', 2, 5828),
  ('2025-01-28', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Épsilon', 'Manta', 'Costa', 2, 3524),
  ('2025-01-03', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 3, 7602),
  ('2025-01-01', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Alfa', 'Quito', 'Sierra', 2, 4860),
  ('2025-01-21', 'Router AX10', 'Redes', 'NetGo', 'Empresa Alfa', 'Quito', 'Sierra', 1, 2203),
  ('2025-01-20', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 1, 1514),
  ('2025-01-24', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Delta', 'Ambato', 'Sierra', 3, 2964),
  ('2025-01-03', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 5558),
  ('2025-01-13', 'Router AX10', 'Redes', 'NetGo', 'Empresa Alfa', 'Quito', 'Sierra', 3, 3672),
  ('2025-01-27', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Beta', 'Guayaquil', 'Costa', 3, 3690);

INSERT INTO stg_soporte (fecha_texto,producto,categoria,marca,cliente,ciudad,region,ticket_id,motivo,tiempo_respuesta_horas) VALUES
  ('2025-01-08', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Delta', 'Ambato', 'Sierra', 4535, 'Actualización de software', 26),
  ('2025-01-26', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 2148, 'Consulta técnica', 48),
  ('2025-01-13', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Gama', 'Cuenca', 'Sierra', 1420, 'Configuración', 12),
  ('2025-01-15', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 9637, 'Consulta técnica', 5),
  ('2025-01-11', 'Router AX10', 'Redes', 'NetGo', 'Empresa Gama', 'Cuenca', 'Sierra', 7580, 'Actualización de software', 39),
  ('2025-01-11', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 7221, 'Actualización de software', 28),
  ('2025-01-02', 'Router AX10', 'Redes', 'NetGo', 'Empresa Delta', 'Ambato', 'Sierra', 6057, 'Actualización de software', 10),
  ('2025-01-04', 'Router AX10', 'Redes', 'NetGo', 'Empresa Gama', 'Cuenca', 'Sierra', 1417, 'Falla de hardware', 40),
  ('2025-01-17', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Gama', 'Cuenca', 'Sierra', 7863, 'Falla de hardware', 28),
  ('2025-01-20', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Beta', 'Guayaquil', 'Costa', 7769, 'Falla de hardware', 46),
  ('2025-01-24', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 9058, 'Actualización de software', 40),
  ('2025-01-02', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Épsilon', 'Manta', 'Costa', 1112, 'Consulta técnica', 20),
  ('2025-01-01', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 4325, 'Falla de hardware', 47),
  ('2025-01-08', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 5940, 'Consulta técnica', 27),
  ('2025-01-27', 'Router AX10', 'Redes', 'NetGo', 'Empresa Gama', 'Cuenca', 'Sierra', 5895, 'Falla de hardware', 14),
  ('2025-01-10', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Alfa', 'Quito', 'Sierra', 2510, 'Falla de hardware', 7),
  ('2025-01-04', 'Router AX10', 'Redes', 'NetGo', 'Empresa Gama', 'Cuenca', 'Sierra', 1422, 'Consulta técnica', 13),
  ('2025-01-18', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Épsilon', 'Manta', 'Costa', 3976, 'Configuración', 24),
  ('2025-01-17', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 3207, 'Consulta técnica', 27),
  ('2025-01-22', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Delta', 'Ambato', 'Sierra', 6484, 'Falla de hardware', 10),
  ('2025-01-26', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 1521, 'Falla de hardware', 7),
  ('2025-01-08', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 6533, 'Configuración', 20),
  ('2025-01-26', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Beta', 'Guayaquil', 'Costa', 5844, 'Falla de hardware', 11),
  ('2025-01-04', 'Router AX10', 'Redes', 'NetGo', 'Empresa Delta', 'Ambato', 'Sierra', 6467, 'Falla de hardware', 31),
  ('2025-01-27', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Beta', 'Guayaquil', 'Costa', 4523, 'Falla de hardware', 27),
  ('2025-01-07', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 4747, 'Actualización de software', 25),
  ('2025-01-27', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Gama', 'Cuenca', 'Sierra', 4641, 'Actualización de software', 33),
  ('2025-01-07', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Alfa', 'Quito', 'Sierra', 9307, 'Configuración', 36),
  ('2025-01-09', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 7727, 'Consulta técnica', 6),
  ('2025-01-05', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 6500, 'Falla de hardware', 12),
  ('2025-01-23', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Delta', 'Ambato', 'Sierra', 1830, 'Actualización de software', 3),
  ('2025-01-27', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 8978, 'Configuración', 35),
  ('2025-01-10', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Gama', 'Cuenca', 'Sierra', 2570, 'Consulta técnica', 38),
  ('2025-01-06', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Delta', 'Ambato', 'Sierra', 4487, 'Consulta técnica', 12),
  ('2025-01-18', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Épsilon', 'Manta', 'Costa', 7755, 'Consulta técnica', 45),
  ('2025-01-12', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Alfa', 'Quito', 'Sierra', 8249, 'Actualización de software', 7),
  ('2025-01-17', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Delta', 'Ambato', 'Sierra', 7022, 'Actualización de software', 15),
  ('2025-01-16', 'Router AX10', 'Redes', 'NetGo', 'Empresa Gama', 'Cuenca', 'Sierra', 5319, 'Configuración', 31),
  ('2025-01-24', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Beta', 'Guayaquil', 'Costa', 9035, 'Falla de hardware', 47),
  ('2025-01-23', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Gama', 'Cuenca', 'Sierra', 6058, 'Falla de hardware', 44),
  ('2025-01-12', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 4104, 'Consulta técnica', 19),
  ('2025-01-26', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Delta', 'Ambato', 'Sierra', 4312, 'Configuración', 33),
  ('2025-01-19', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Alfa', 'Quito', 'Sierra', 9796, 'Falla de hardware', 46),
  ('2025-01-06', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Alfa', 'Quito', 'Sierra', 4518, 'Configuración', 7),
  ('2025-01-02', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Gama', 'Cuenca', 'Sierra', 6387, 'Consulta técnica', 6),
  ('2025-01-07', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Épsilon', 'Manta', 'Costa', 6008, 'Falla de hardware', 42),
  ('2025-01-29', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 3828, 'Configuración', 22),
  ('2025-01-10', 'Router AX10', 'Redes', 'NetGo', 'Empresa Delta', 'Ambato', 'Sierra', 7221, 'Configuración', 19),
  ('2025-01-21', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 5495, 'Consulta técnica', 29),
  ('2025-01-15', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Épsilon', 'Manta', 'Costa', 8871, 'Configuración', 40);


-- 2. DIMENSIONES (dim_)
CREATE TABLE dim_fecha (
  fecha_key integer PRIMARY KEY, fecha date NOT NULL UNIQUE,
  dia integer NOT NULL, mes integer NOT NULL, trimestre integer NOT NULL,
  anio integer NOT NULL
);
CREATE TABLE dim_producto (
  producto_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  producto text NOT NULL UNIQUE, categoria text NOT NULL, marca text NOT NULL
);
CREATE TABLE dim_cliente (
  cliente_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cliente text NOT NULL UNIQUE
);
CREATE TABLE dim_ciudad (
  ciudad_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ciudad text NOT NULL UNIQUE, region text NOT NULL
);
CREATE TABLE dim_motivo_soporte (
  motivo_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  motivo text NOT NULL UNIQUE
);

INSERT INTO dim_fecha (fecha_key, fecha, dia, mes, trimestre, anio)
SELECT DISTINCT TO_CHAR(fecha_texto::date, 'YYYYMMDD')::integer, fecha_texto::date,
 EXTRACT(DAY FROM fecha_texto::date)::integer,
 EXTRACT(MONTH FROM fecha_texto::date)::integer,
 EXTRACT(QUARTER FROM fecha_texto::date)::integer,
 EXTRACT(YEAR FROM fecha_texto::date)::integer
FROM (SELECT fecha_texto FROM stg_pedidos UNION SELECT fecha_texto FROM stg_soporte) t
ORDER BY 1;

INSERT INTO dim_producto (producto, categoria, marca)
SELECT producto, MIN(categoria), MIN(marca)
FROM (SELECT producto,categoria,marca FROM stg_pedidos UNION ALL
 SELECT producto,categoria,marca FROM stg_soporte) x
GROUP BY producto ORDER BY producto;

INSERT INTO dim_cliente (cliente)
SELECT cliente FROM (SELECT cliente FROM stg_pedidos UNION SELECT cliente FROM stg_soporte) x
ORDER BY cliente;

INSERT INTO dim_ciudad (ciudad, region)
SELECT ciudad, MIN(region)
FROM (SELECT ciudad,region FROM stg_pedidos UNION ALL SELECT ciudad,region FROM stg_soporte) x
GROUP BY ciudad ORDER BY ciudad;

INSERT INTO dim_motivo_soporte(motivo)
SELECT DISTINCT motivo FROM stg_soporte ORDER BY motivo;

-- 3. TABLAS DE HECHOS (fact_): sin enlaces directos entre ellas
CREATE TABLE fact_pedidos (
 pedido_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 origen_fila integer NOT NULL UNIQUE,
 fecha_key integer NOT NULL REFERENCES dim_fecha(fecha_key),
 producto_key integer NOT NULL REFERENCES dim_producto(producto_key),
 cliente_key integer NOT NULL REFERENCES dim_cliente(cliente_key),
 ciudad_key integer NOT NULL REFERENCES dim_ciudad(ciudad_key),
 cantidad integer NOT NULL,
 total_pedido numeric(14,2) NOT NULL
);
CREATE TABLE fact_soporte (
 soporte_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 origen_fila integer NOT NULL UNIQUE,
 fecha_key integer NOT NULL REFERENCES dim_fecha(fecha_key),
 producto_key integer NOT NULL REFERENCES dim_producto(producto_key),
 cliente_key integer NOT NULL REFERENCES dim_cliente(cliente_key),
 ciudad_key integer NOT NULL REFERENCES dim_ciudad(ciudad_key),
 motivo_key integer NOT NULL REFERENCES dim_motivo_soporte(motivo_key),
 ticket_id integer NOT NULL,
 tiempo_respuesta_horas numeric(12,2) NOT NULL
);

INSERT INTO fact_pedidos (origen_fila, fecha_key, producto_key, cliente_key, ciudad_key,
 cantidad, total_pedido)
SELECT s.origen_fila, d.fecha_key, p.producto_key, c.cliente_key, u.ciudad_key,
 s.cantidad, s.total_pedido
FROM stg_pedidos s
JOIN dim_fecha d ON d.fecha=s.fecha_texto::date
JOIN dim_producto p ON p.producto=s.producto
JOIN dim_cliente c ON c.cliente=s.cliente
JOIN dim_ciudad u ON u.ciudad=s.ciudad;

INSERT INTO fact_soporte (origen_fila, fecha_key, producto_key, cliente_key, ciudad_key,
 motivo_key, ticket_id, tiempo_respuesta_horas)
SELECT s.origen_fila, d.fecha_key, p.producto_key, c.cliente_key, u.ciudad_key,
 m.motivo_key, s.ticket_id, s.tiempo_respuesta_horas
FROM stg_soporte s
JOIN dim_fecha d ON d.fecha=s.fecha_texto::date
JOIN dim_producto p ON p.producto=s.producto
JOIN dim_cliente c ON c.cliente=s.cliente
JOIN dim_ciudad u ON u.ciudad=s.ciudad
JOIN dim_motivo_soporte m ON m.motivo=s.motivo;

-- 4. VALIDACIONES: resultados esperados 50,100,158358.00,50,49,25.18
SELECT COUNT(*) AS registros_pedidos, SUM(cantidad) AS unidades_vendidas,
 SUM(total_pedido) AS total_pedidos FROM fact_pedidos;
SELECT COUNT(*) AS registros_soporte, COUNT(DISTINCT ticket_id) AS tickets_unicos,
 ROUND(AVG(tiempo_respuesta_horas),2) AS promedio_respuesta_horas FROM fact_soporte;
SELECT 'dim_fecha' AS tabla, COUNT(*) AS filas FROM dim_fecha
UNION ALL SELECT 'dim_producto', COUNT(*) FROM dim_producto
UNION ALL SELECT 'dim_cliente', COUNT(*) FROM dim_cliente
UNION ALL SELECT 'dim_ciudad', COUNT(*) FROM dim_ciudad
UNION ALL SELECT 'dim_motivo_soporte', COUNT(*) FROM dim_motivo_soporte;
-- Detectar identificadores duplicados sin alterar el archivo:
SELECT ticket_id, COUNT(*) AS apariciones FROM fact_soporte
GROUP BY ticket_id HAVING COUNT(*) > 1;

-- 5. CONSULTAS PARA LAS CUATRO PREGUNTAS DE NEGOCIO
-- 1a. Productos mas vendidos por ciudad
SELECT c.ciudad, p.producto, SUM(f.cantidad) AS unidades
FROM fact_pedidos f JOIN dim_ciudad c USING (ciudad_key)
JOIN dim_producto p USING (producto_key)
GROUP BY c.ciudad,p.producto ORDER BY c.ciudad, unidades DESC;
-- 1b. Categorias mas vendidas por ciudad
SELECT c.ciudad, p.categoria, SUM(f.cantidad) AS unidades
FROM fact_pedidos f JOIN dim_ciudad c USING (ciudad_key)
JOIN dim_producto p USING (producto_key)
GROUP BY c.ciudad,p.categoria ORDER BY c.ciudad, unidades DESC;
-- 2. Clientes que mas compran en cada ciudad
SELECT c.ciudad, cl.cliente, SUM(f.cantidad) AS unidades,
 SUM(f.total_pedido) AS importe
FROM fact_pedidos f JOIN dim_ciudad c USING (ciudad_key)
JOIN dim_cliente cl USING (cliente_key)
GROUP BY c.ciudad,cl.cliente ORDER BY c.ciudad,unidades DESC;
-- 3. Productos y categorias con mas registros de soporte
SELECT p.categoria, p.producto, COUNT(*) AS registros_soporte
FROM fact_soporte f JOIN dim_producto p USING (producto_key)
GROUP BY p.categoria,p.producto ORDER BY registros_soporte DESC;
-- 4. Clientes con mas registros de soporte
SELECT cl.cliente, COUNT(*) AS registros_soporte
FROM fact_soporte f JOIN dim_cliente cl USING (cliente_key)
GROUP BY cl.cliente ORDER BY registros_soporte DESC;
