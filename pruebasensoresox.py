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
root_ref = db.reference('/SensoresOxigeno')

def random_val(exclude_no_soportado=False):
    if exclude_no_soportado:
        return round(random.uniform(0, 100), 2)
    return random.choice([4, round(random.uniform(0, 100), 2)])

def enviar_datos():
    root_ref.update({
        "voltajeOxi1": random_val(),
        "voltajeOxi2": random_val(),
        "voltajeOxi3": random_val(),
        "voltajeOxi4": random_val(),
        "AFROxi1": random_val(),
        "AFROxi2": random_val(),
        "AFROxi3": random_val(),
        "AFROxi4": random_val(),
    })
    print("Datos enviados.")

# Enviar datos cada 2 segundos (simulación)
while True:
    enviar_datos()
    time.sleep(2)
