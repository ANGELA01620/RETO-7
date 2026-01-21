/*
    RETO 7: FINANCIAL ANALYST PROTOCOL
    Autor: [Angela Tatiana Orjuela Guevara]
    Fecha: [21/01/2025]
    
    Objetivo: Reporte MoM (Month over Month) y YTD (Year to Date)
*/
USE RetoSQL;
GO

/*
    BLOQUE 1: LIMPIEZA + MÉTRICAS MENSUALES
*/
WITH CleanSales AS (
    SELECT
        v.VentaID AS ID_Transaccion,
        UPPER(c.Nombre) AS Cliente,
        p.Nombre AS Producto,
        p.Categoria,
        s.Nombre AS Sucursal,
        v.Cantidad,
        p.Precio_Unitario,
        v.Descuento,
        (p.Precio_Unitario * v.Cantidad * (1 - v.Descuento)) AS Total_Linea,
        YEAR(v.Fecha) AS Anio,
        MONTH(v.Fecha) AS Mes
    FROM Venta AS v
    JOIN Cliente AS c ON v.ClienteID = c.ClienteID
    JOIN Producto AS p ON v.ProductoID = p.ProductoID
    JOIN Sucursal AS s ON v.SucursalID = s.SucursalID
),
MonthlyMetrics AS (
    SELECT
        Anio,
        Mes,
        SUM(Total_Linea) AS Total_Ventas
    FROM CleanSales
    GROUP BY Anio, Mes
)
SELECT * FROM MonthlyMetrics
ORDER BY Anio, Mes;



/*
    BLOQUE 2: CALCULO MO/M Y YTD
*/
WITH CleanSales AS (
    SELECT
        v.VentaID AS ID_Transaccion,
        UPPER(c.Nombre) AS Cliente,
        p.Nombre AS Producto,
        p.Categoria,
        s.Nombre AS Sucursal,
        v.Cantidad,
        p.Precio_Unitario,
        v.Descuento,
        (p.Precio_Unitario * v.Cantidad * (1 - v.Descuento)) AS Total_Linea,
        YEAR(v.Fecha) AS Anio,
        MONTH(v.Fecha) AS Mes
    FROM Venta AS v
    JOIN Cliente AS c ON v.ClienteID = c.ClienteID
    JOIN Producto AS p ON v.ProductoID = p.ProductoID
    JOIN Sucursal AS s ON v.SucursalID = s.SucursalID
),
MonthlyMetrics AS (
    SELECT
        Anio,
        Mes,
        SUM(Total_Linea) AS Total_Ventas
    FROM CleanSales
    GROUP BY Anio, Mes
)
SELECT
    Anio,
    Mes,
    Total_Ventas,
    -- Ventas del mes anterior
    LAG(Total_Ventas) OVER (PARTITION BY Anio ORDER BY Mes) AS Ventas_Mes_Anterior,
    -- % Crecimiento MoM
    CASE 
        WHEN LAG(Total_Ventas) OVER (PARTITION BY Anio ORDER BY Mes) IS NULL THEN NULL
        ELSE (Total_Ventas - LAG(Total_Ventas) OVER (PARTITION BY Anio ORDER BY Mes))
             / LAG(Total_Ventas) OVER (PARTITION BY Anio ORDER BY Mes) * 100
    END AS Porc_Crecimiento_MoM,
    -- Acumulado YTD
    SUM(Total_Ventas) OVER (PARTITION BY Anio ORDER BY Mes) AS Acumulado_YTD
FROM MonthlyMetrics
ORDER BY Anio, Mes;
