import pandas as pd
from sqlalchemy import create_engine
import matplotlib.pyplot as plt

## Creamos la conexion
engine = create_engine(
    "postgresql+psycopg2://ibd_postgres:ibd_secretpassword@localhost:5433/pagila"
)

## datos media movil
datos_media_movil = pd.read_sql("""
WITH ventas_por_dia AS (SELECT DATE(payment_date) fecha, SUM(amount) monto 
FROM payment p INNER JOIN staff s ON p.staff_id = s.staff_id AND s.store_id=2 GROUP BY DATE(payment_date) ORDER BY DATE(payment_date))
SELECT fecha, ROUND(AVG(monto) OVER (ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) media_movil
FROM ventas_por_dia ORDER BY fecha;""", engine)

datos= pd.read_sql("""SELECT DATE(payment_date) fecha, SUM(amount) monto 
                   FROM payment p INNER JOIN staff s ON p.staff_id = s.staff_id AND s.store_id=2 GROUP BY DATE(payment_date) ORDER BY DATE(payment_date)""", engine)

plt.figure(figsize=(12,6))

plt.plot(
    datos['fecha'],
    datos['monto'],
    color='lightgray',
    label='Monto'
)

plt.plot(
    datos_media_movil['fecha'],
    datos_media_movil['media_movil'],
    label='Media móvil'
)

plt.grid(True, alpha=0.3)

titleFont={
    'color': '#666666',
    'size': 16
}

labelFont={
    'color': '#666666',
    'size': 12
}

ax = plt.gca()

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_color('gray')
ax.spines['left'].set_color('gray')
ax.tick_params(axis='x', colors='gray')
ax.tick_params(axis='y', colors='gray')

plt.title("Promedio de ventas diario para la tienda 2",loc="left",fontdict=titleFont)
plt.ylabel("Acumulado diario ventas",loc="top",fontdict=labelFont)
plt.xlabel("Fecha",loc="left",fontdict=labelFont)
legend = plt.legend(
    frameon=False  # sin caja alrededor
)

for text in legend.get_texts():
    text.set_color('#666666')


plt.show()



#datos intervalos entre ventas

datos= pd.read_sql("""SELECT c.customer_id, EXTRACT(DAY FROM rental_date-lag(rental_date) OVER(PARTITION BY c.customer_id ORDER BY rental_date)) intervalo
FROM rental r INNER JOIN customer c ON c.customer_id=r.customer_id AND c.active=true;""", engine)


plt.hist(datos['intervalo'],bins=20)

media=datos['intervalo'].mean()
mediana= datos['intervalo'].median()

plt.axvline(
    media,
    color='gray',
    linestyle='--',
    linewidth=2,
    label=f'Media: {media:.2f}'
)

plt.axvline(
    mediana,
    color='gray',
    linestyle=':',
    linewidth=2,
    label=f'Mediana: {mediana:.2f}'
)

ax = plt.gca()

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_color('gray')
ax.spines['left'].set_color('gray')
ax.tick_params(axis='x', colors='gray')
ax.tick_params(axis='y', colors='gray')

plt.ylabel("Frecuencia",loc="top",fontdict=labelFont)
plt.xlabel("Cantidad de días entre ventas",loc="left",fontdict=labelFont)
plt.title("Distribución de intervalo entre ventas",loc='left',fontdict=titleFont)

legend = plt.legend(
    frameon=False  # sin caja alrededor
)

for text in legend.get_texts():
    text.set_color('#666666')

plt.show()
## 
print('graficos listos')