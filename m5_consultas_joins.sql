
/*Creo la base de datos*/
CREATE DATABASE Ventas_Tech_DB;
GO


/*Me posiciono en la base de datos*/
USE Ventas_Tech_DB;
GO

/* DROP TABLES */

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;
GO

/* CREATE TABLES */

CREATE TABLE categorias (
	id_categoria INT PRIMARY KEY,
	nombre_categoria VARCHAR(50) NOT NULL,
	descripcion VARCHAR(200)
);
GO

CREATE TABLE clientes (
	id_cliente INT PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	email VARCHAR(100) UNIQUE,
	ciudad VARCHAR(50),
	fecha_registro DATE NOT NULL
);
GO

CREATE TABLE productos (
	id_producto INT PRIMARY KEY,
	nombre_producto VARCHAR(100) NOT NULL,
	id_categoria INT,
	precio DECIMAL(10,2) NOT NULL,
	stock INT DEFAULT 0,
	activo TINYINT DEFAULT 1,
	CONSTRAINT FK_productos_categorias FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);
GO

CREATE TABLE ventas (
	id_venta INT PRIMARY KEY,
	id_cliente INT,
	id_producto INT,
	cantidad INT NOT NULL,
	precio_unitario DECIMAL(10,2) NOT NULL,
	fecha_venta DATE NOT NULL,
	CONSTRAINT FK_ventas_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
	CONSTRAINT FK_ventas_productos FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);
GO

/*INSERT DATA*/

-- categorias 
INSERT INTO categorias VALUES (1, 'Computación', 'Laptops, PCs y monitores');
INSERT INTO categorias VALUES (2, 'Accesorios', 'Periféricos y complementos');
INSERT INTO categorias VALUES (3, 'Audio', 'Auriculares y parlantes');
INSERT INTO categorias VALUES (4, 'Almacenamiento', 'Discos y memorias');
GO

-- clientes 
INSERT INTO clientes VALUES (1, 'María López',   'maria@mail.com',   'Buenos Aires', '2024-01-05');
INSERT INTO clientes VALUES (2, 'Carlos Ruiz',   'carlos@mail.com',  'Córdoba',      '2024-01-10');
INSERT INTO clientes VALUES (3, 'Ana Gómez',     'ana@mail.com',     'Rosario',      '2024-02-01');
INSERT INTO clientes VALUES (4, 'Pedro Sanz',    'pedro@mail.com',   'Mendoza',      '2024-02-15');
INSERT INTO clientes VALUES (5, 'Laura Torres',  'laura@mail.com',   'Tucumán',      '2024-03-01');
GO

-- productos
INSERT INTO productos VALUES (1, 'Laptop Pro 15',       1, 1200.00, 15, 1);
INSERT INTO productos VALUES (2, 'Mouse Inalámbrico',   2,   28.00, 80, 1);
INSERT INTO productos VALUES (3, 'Monitor 4K 27"',      1,  450.00, 12, 1);
INSERT INTO productos VALUES (4, 'Auriculares BT Pro',  3,  120.00, 35, 1);
INSERT INTO productos VALUES (5, 'SSD Externo 1TB',     4,  130.00, 18, 1);
INSERT INTO productos VALUES (6, 'Teclado Mecánico',    2,   95.00, 40, 1);
GO

-- ventas 
INSERT INTO ventas VALUES (1,  1, 1, 2, 1200.00, '2024-03-05');
INSERT INTO ventas VALUES (2,  2, 2, 5,   28.00, '2024-03-06');
INSERT INTO ventas VALUES (3,  3, 3, 1,  450.00, '2024-03-07');
INSERT INTO ventas VALUES (4,  1, 4, 2,  120.00, '2024-03-08');
INSERT INTO ventas VALUES (5,  4, 5, 3,  130.00, '2024-03-10');
INSERT INTO ventas VALUES (6,  2, 6, 4,   95.00, '2024-03-11');
INSERT INTO ventas VALUES (7,  5, 1, 1, 1200.00, '2024-03-12');
INSERT INTO ventas VALUES (8,  3, 2, 8,   28.00, '2024-03-13');
INSERT INTO ventas VALUES (9,  4, 4, 1,  120.00, '2024-03-14');
INSERT INTO ventas VALUES (10, 5, 3, 2,  450.00, '2024-03-15');
GO

/* Verificar integridad */
SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;
 
/* Pre entrega 4 */

/* ============================================================
   Consultas SQL de negocio
   Base de datos: Ventas_Tech_DB
   Trabajamos sobre la tabla ventas (id_cliente, id_producto,
   cantidad, precio_unitario, fecha_venta)
   ============================================================ */

USE Ventas_Tech_DB;
GO

/* ------------------------------------------------------------
   Consulta 1 - Resumen ejecutivo mensual
   Total facturado, cantidad de pedidos y ticket promedio,
   agrupado por mes.
   ------------------------------------------------------------ */
SELECT
    MONTH(fecha_venta)                    AS mes,
    SUM(cantidad * precio_unitario)       AS total_facturado,
    COUNT(*)                              AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)       AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO

/* ------------------------------------------------------------
   Consulta 2 - Ranking de productos
   Top 5 de id_producto por total facturado, con unidades
   vendidas y total generado.
   ------------------------------------------------------------ */
SELECT TOP 5
    id_producto,
    SUM(cantidad)                         AS unidades_vendidas,
    SUM(cantidad * precio_unitario)       AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO

/* ------------------------------------------------------------
   Consulta 3 - Clientes recurrentes
   id_cliente con más de un pedido, cantidad de pedidos y
   total gastado.
   ------------------------------------------------------------ */
SELECT
    id_cliente,
    COUNT(*)                              AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)       AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO

/* ------------------------------------------------------------
   Consulta 4 - Meses por encima/por debajo del promedio
   Total facturado por mes, etiquetado según se ubique por
   encima o por debajo del promedio mensual general.
   ------------------------------------------------------------ */
WITH facturacion_mensual AS (
    SELECT
        MONTH(fecha_venta)              AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_mensual)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM facturacion_mensual
ORDER BY mes;
GO

/* ============================================================
   Hallazgos:
   ============================================================
   -- 1) Las 10 ventas cargadas caen todas en marzo 2024, por lo
   --    que la Consulta 1 y la Consulta 4 devuelven un único mes
   --    (aún no hay variación mensual para comparar).
   -- 2) El producto 1 (la Laptop Pro 15) concentra $3.600 de los
   --    $6.444 facturados en total (56%), muy por encima de
   --    cualquier otro producto del catálogo.
   -- 3) Los 5 clientes cargados son recurrentes: cada uno
   --    realizó exactamente 2 pedidos, así que la Consulta 3
   --    devuelve la base completa de clientes.
   ============================================================ */

   /* Pre entrega 5 */

   /* ============================================================
   Consultas con JOINs para el proyecto
   Base de datos: Ventas_Tech_DB
   Esquema: categorias, clientes, productos, ventas
   ============================================================ */

USE Ventas_Tech_DB;
GO

/* ------------------------------------------------------------
   Consulta 1 - Vista base del proyecto (INNER JOIN)
   Cruza ventas + clientes + productos + categorias.
   Columna 'ciudad' (de clientes) sirve como dimensión
   geográfica para agrupar/filtrar en Power BI, y
   'nombre_categoria' como dimensión de producto.
   ------------------------------------------------------------ */
SELECT
    v.fecha_venta,
    v.id_cliente,
    c.nombre                              AS nombre_cliente,
    c.ciudad                              AS ciudad_cliente,
    p.nombre_producto,
    cat.nombre_categoria                  AS categoria_producto,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario)      AS total_venta
FROM ventas v
INNER JOIN clientes c    ON v.id_cliente = c.id_cliente
INNER JOIN productos p   ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;
GO

/* ------------------------------------------------------------
   Consulta 2 - Clientes sin ventas (LEFT JOIN)
   Nota: con los 5 clientes cargados en M3, todos tienen al
   menos una venta registrada, así que esta consulta hoy
   devuelve 0 filas. Igualmente queda para detectar
   clientes nuevos que todavía no compraron.
   ------------------------------------------------------------ */
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL;
GO

/* ------------------------------------------------------------
   Consulta 3 - Productos sin ventas (LEFT JOIN)
   Nota: mismo caso que la Consulta 2 - los 6 productos
   cargados en M3 ya tienen ventas, así que hoy devuelve
   0 filas. Sirve para detectar productos sin movimiento
   a futuro (por ejemplo, si se agrega catálogo nuevo).
   ------------------------------------------------------------ */
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL;
GO

/* ------------------------------------------------------------
   Consulta 4 - Consolidado por canal (UNION ALL)
   El canal no existe en las tablas: se genera. Criterio elegido para separar el origen: fecha de
   venta anterior al 10/03/2024 = 'Online', desde esa fecha
   en adelante = 'Presencial' (simula dos períodos/orígenes
   distintos de venta).
   ------------------------------------------------------------ */
SELECT
    canal,
    COUNT(*)     AS cantidad_ventas,
    SUM(total)   AS total_facturado
FROM (
    SELECT
        fecha_venta,
        (cantidad * precio_unitario) AS total,
        'Online' AS canal
    FROM ventas
    WHERE fecha_venta < '2024-03-10'

    UNION ALL

    SELECT
        fecha_venta,
        (cantidad * precio_unitario) AS total,
        'Presencial' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-10'
) AS ventas_con_canal
GROUP BY canal
ORDER BY canal;
GO