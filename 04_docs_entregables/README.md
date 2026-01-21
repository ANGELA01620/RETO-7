
# 🚀 Reto 7: Financial Analyst Protocol

Este script implementa el análisis de métricas financieras avanzadas utilizando **Common Table Expressions (CTE)** y **Window Functions** para el cálculo de crecimiento mensual y acumulado anual.

## Codigo en sql que resuelve el reto
```sql
/*
    RETO 7: FINANCIAL ANALYST PROTOCOL
    Autor: Angela Tatiana Orjuela Guevara
    Fecha: 21/01/2026
    
    Objetivo: Reporte MoM (Month over Month) y YTD (Year to Date)
*/

USE RetoSQL;
GO

/*
    BLOQUE: CÁLCULO DE MÉTRICAS FINANCIERAS (MoM Y YTD)
    Se utiliza CleanSales para normalizar datos y MonthlyMetrics para 
    agregar las ventas antes de aplicar funciones de ventana.
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
    -- Cálculo de ventas del mes anterior usando LAG
    LAG(Total_Ventas) OVER (PARTITION BY Anio ORDER BY Mes) AS Ventas_Mes_Anterior,
    -- % Crecimiento MoM (Month over Month)
    CASE 
        WHEN LAG(Total_Ventas) OVER (PARTITION BY Anio ORDER BY Mes) IS NULL THEN NULL
        ELSE (Total_Ventas - LAG(Total_Ventas) OVER (PARTITION BY Anio ORDER BY Mes))
             / LAG(Total_Ventas) OVER (PARTITION BY Anio ORDER BY Mes) * 100
    END AS Porc_Crecimiento_MoM,
    -- Acumulado YTD (Year to Date) usando SUM acumulativo
    SUM(Total_Ventas) OVER (PARTITION BY Anio ORDER BY Mes) AS Acumulado_YTD
FROM MonthlyMetrics
ORDER BY Anio, Mes;
```

## resultados

![Resultados del Reporte Financiero](https://raw.githubusercontent.com/ANGELA01620/RETO-7/main/04_docs_entregables/sql%20resultados.png)

