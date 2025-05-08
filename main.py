import firebase_admin
from firebase_admin import credentials, db
import time
import subprocess
import sys
import keyboard  # Para detectar la tecla ESC
import serial.tools.list_ports

# Configuración de Firebase
cred = credentials.Certificate("./automotrizapp-firebase-adminsdk-fbsvc-ddabfa472d.json")
firebase_admin.initialize_app(cred, {
    "databaseURL": "https://automotrizapp-default-rtdb.firebaseio.com"
})
ref = db.reference('Controlador/Clave')

def listener(event):
    global valor_actual
    print(f"El valor de Controlador/Clave ha cambiado a: {event.data}")
    valor_actual = event.data

ref.listen(listener)

def verificar_conexion_obd():
    while True:
        # Listar los puertos seriales disponibles
        puertos = serial.tools.list_ports.comports()
        obd_conectado = False

        for puerto in puertos:
            if "OBDLink SX" in puerto.description or "USB Serial Port" in puerto.description:
                obd_conectado = True
                print("OBDLink SX o puerto USB detectado.")
                break

        if not obd_conectado:
            print("No se detectó OBDLink SX o puerto USB. Esperando conexión...")
            time.sleep(2)  # Esperar 2 segundos antes de verificar nuevamente
        else:
            break

def componente_principal():
    global valor_actual
    valor_actual = ref.get()  # Obtener el valor inicial    
    print(f"Valor inicial de Controlador/Clave: {valor_actual}")

    try:
        while True:
            # Verificar si se presionó la tecla ESC
            if keyboard.is_pressed('esc'):
                print("Tecla ESC presionada. Cerrando el programa...")
                # Enviar "VINd" a Firebase antes de salir
                ref.set("VINd")
                print("Valor 'VINd' enviado a Firebase.")
                break

            if valor_actual == "Mtt":
                print("Ejecutando Sensor Motor...")
                subprocess.run([sys.executable, "SensorMotor.py"])
                break  # Salir del bucle y terminar main.py
            elif valor_actual == "Mox":
                print("Ejecutando Sensor Oxigeno...")
                subprocess.run([sys.executable, "SensorOxigeno.py"])
            elif valor_actual == "Mcm":
                print("Ejecutando Sensor Combustible...")
                subprocess.run([sys.executable, "SensorCombustible.py"])
            elif valor_actual == "Mvh":
                print("Ejecutando Sensores general...")
                subprocess.run([sys.executable, "SensoresVehi.py"])
            elif valor_actual == "VINd":
                print("Esperando 3 segundos antes de ejecutar VIN.py...")
                time.sleep(4) 
                print("Ejecutando VIN.py...")
                subprocess.run([sys.executable, "VIN.py"])
            elif valor_actual == "Decvn":
                print("Ejecutando Decodificador...")
                subprocess.run([sys.executable, "Decodificador.py"])
            elif valor_actual == "Prot":
                print("Ejecutando Protocolo...")
                subprocess.run([sys.executable, "DecodProt.py"])
            elif valor_actual == "GDTC":
                print("Obteniendo informacion y diagnostico...")
                subprocess.run([sys.executable, "Diagnostico.py"])
            elif valor_actual == "detener":
                print("Deteniendo el programa...")
                break
            else:
                print("Esperando instrucciones...")
                time.sleep(2)  # Espera antes de volver a verificar

    except KeyboardInterrupt:
        print("Programa interrumpido por el usuario. Enviando 'VINd' a Firebase...")
        ref.set("VINd")
        print("Valor 'VINd' enviado a Firebase.")

if __name__ == "__main__":
    verificar_conexion_obd()  # Verificar la conexión antes de entrar en el bucle principal
    componente_principal()