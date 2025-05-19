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
        "Nivel de combustible": random_val(),
        "Presion combustible": random_val(),
        "Presion riel": random_val(),
        "Tasa combustible": random_val(),
        "Banco 1 corto": random_val(),
        "Banco 1 largo": random_val(),
        "Banco 2 corto": random_val(),
        "Banco 2 largo": random_val(),
    })
    print("Datos enviados.")

# Enviar datos cada 2 segundos (simulación)
while True:
    enviar_datos()
    time.sleep(2)
