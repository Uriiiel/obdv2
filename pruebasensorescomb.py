import firebase_admin
from firebase_admin import credentials, db
import random
import time

# Ruta a tu archivo de claves
cred = cred = credentials.Certificate("./automotrizapp-firebase-adminsdk-fbsvc-ddabfa472d.json")

# Inicializa la app con la URL de tu base de datos
firebase_admin.initialize_app(cred, {
    "databaseURL": "https://automotrizapp-default-rtdb.firebaseio.com/" # cambia esto por tu URL real
})

# Referencia al nodo SensoresMotor
root_ref = db.reference('/SensoresCombustible')

def random_val(exclude_no_soportado=False):
    if exclude_no_soportado:
        return round(random.uniform(0, 100), 2)
    return random.choice([4, round(random.uniform(0, 100), 2)])

def enviar_datos():
    root_ref.update({
        "Consumo instantáneo de combustible": random_val(),
        "Estado del sistema de combustible": random_val(),
        "Nivel de combustible": random_val(),
        "Porcentaje etanol en combustible": random_val(),
        "Presion Riel combustible directa": random_val(),
        "Presion Riel combustible relativa": random_val(),
        "Presión de la bomba de combustible": random_val(),
        "Tipo combustible": random_val(),
    })
    print("Datos enviados.")

# Enviar datos cada 2 segundos (simulación)
while True:
    enviar_datos()
    time.sleep(2)
