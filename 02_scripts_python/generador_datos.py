import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta

# Configuración
NUM_ROWS = 5000
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2024, 12, 31)

print("📊 Iniciando simulación de transacciones financieras...")

# Datos Maestros
clientes = ["TechSolutions Inc", "Global Corp", "SoftWare House", "DataSystems", "CloudNet"]
productos = [
    ("Licencia Enterprise", "Software", 5000),
    ("Soporte Premium", "Servicios", 1200),
    ("Consultoría Hora", "Servicios", 150),
    ("Servidor Dedicado", "Hardware", 3500),
    ("Pack Seguridad", "Software", 800)
]
sucursales = ["Norte", "Sur", "Este", "Oeste", "Central"]

data = []

# Generación de Filas
for i in range(1, NUM_ROWS + 1):
    # Fecha aleatoria dentro del rango (para tener series de tiempo)
    days_diff = (END_DATE - START_DATE).days
    random_days = random.randint(0, days_diff)
    fecha = START_DATE + timedelta(days=random_days)
    
    # Selección aleatoria
    prod = random.choice(productos)
    cliente = random.choice(clientes)
    
    # Introducir "Suciedad" para el CTE de limpieza
    # A veces el cliente está en mayúsculas, a veces en minúsculas
    if random.random() < 0.3:
        cliente = cliente.upper()
    elif random.random() < 0.3:
        cliente = cliente.lower()
        
    row = {
        "ID_Transaccion": i,
        "Fecha_Venta": fecha.strftime("%Y-%m-%d"),
        "Cliente": cliente,
        "Producto": prod[0],
        "Categoria": prod[1],
        "Sucursal": random.choice(sucursales),
        "Cantidad": random.randint(1, 10),
        "Precio_Unitario": prod[2],
        "Descuento": round(random.uniform(0, 0.1), 2) # Descuento entre 0% y 10%
    }
    data.append(row)

# Crear DataFrame
df = pd.DataFrame(data)

# Exportar a CSV
import os
output_dir = os.path.join(os.path.dirname(__file__), "..", "01_data")
os.makedirs(output_dir, exist_ok=True)
output_path = os.path.join(output_dir, "raw_sales_dump.csv")
df.to_csv(output_path, index=False)

print(f"✅ Archivo generado exitosamente: {output_path}")
print(f"   - Total Filas: {len(df)}")
print(f"   - Rango Fechas: {START_DATE.date()} a {END_DATE.date()}")
print("   - Nota: Se han incluido inconsistencias en los nombres de clientes para el ejercicio de limpieza.")
