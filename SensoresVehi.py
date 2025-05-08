import obd
import time
import firebase_admin
from firebase_admin import credentials, db
import subprocess
import sys
import serial.tools.list_ports
cred = credentials.Certificate("./automotrizapp-firebase-adminsdk-fbsvc-ddabfa472d.json")
firebase_admin.initialize_app(cred, {
    "databaseURL": "https://automotrizapp-default-rtdb.firebaseio.com/"
})
firebase_ref = db.reference("SensoresVehiculo")
controlador_ref = db.reference("Controlador/Clave")  # Ruta para condicionar la ejecución
protocolo_ref = db.reference("Controlador/protocolo")  # Nueva referencia para el protocolo
com_ref = db.reference("Controlador/COM")  
def obtener_configuracion():
    try:
        protocolo = str(protocolo_ref.get())  # Convertir a string
        com = str(com_ref.get())  # Convertir a string
        if protocolo is None or com is None:
            raise ValueError("No se encontró el protocolo o el puerto COM en Firebase.")
        return com, protocolo
    except Exception as e:
        print(f"Error al obtener la configuración desde Firebase: {e}")
        return None, None
commands = {    
    "Voltaje": obd.commands.ELM_VOLTAGE,
    "Velocidad":obd.commands.SPEED,    
    "Presión combustible": obd.commands.FUEL_PRESSURE,
    "Tmp Funcionamiento": obd.commands.RUN_TIME,    
    "Presion barometrica":obd.commands.BAROMETRIC_PRESSURE,
}
unsupported_commands = set()
def kpa_to_psi(kpa):
    return kpa * 0.1450377377
def read_engine_sensors(connection):
    sensor_data = {}
    if not connection.is_connected():
        print("Reconectando al dispositivo OBD-II...")
        com, protocolo = obtener_configuracion()
        if com is None or protocolo is None:
            print("No se pudo obtener la configuración desde Firebase.")
            return None
        connection = obd.OBD(com, protocol=protocolo) 
    for sensor_name, command in commands.items():
        value = None
        if command in unsupported_commands:
            sensor_data[sensor_name] = "No soportado"
            continue
        for _ in range(3):  # Intentar 3 veces
            response = connection.query(command)
            if not response.is_null():
                value = response.value.magnitude
                if sensor_name == "Presión colector admisión":
                    value = kpa_to_psi(value)
                break
            time.sleep(0.200)  
        if value is None:  # Si después de 3 intentos no hay respuesta válida
            print(f"[OBD-II] '{command}' no es soportado por este vehículo.")
            unsupported_commands.add(command)
            value = "No soportado"
        sensor_data[sensor_name] = value
    return sensor_data
def send_to_firebase(data):
    try:
        firebase_ref.update(data)
        print(f"Datos enviados a Firebase: {data}")
    except Exception as e:
        print(f"Error al enviar datos a Firebase: {e}")
def verificar_controlador():
    valor = controlador_ref.get()
    return valor
def main():
    print("Iniciando lectura de sensores...")
    try:
        com, protocolo = obtener_configuracion()
        if com is None or protocolo is None:
            print("No se pudo obtener la configuración inicial. Saliendo...")
            return
        connection = obd.OBD(com, protocol=protocolo)
        if not connection.is_connected():
            print("No se pudo conectar al vehículo. Verifica el puerto y la llave de encendido.")
            return
        while True:
            valor_controlador = verificar_controlador()
            if valor_controlador == "Mvh":
                sensor_data = read_engine_sensors(connection)
                if sensor_data is not None:
                    send_to_firebase(sensor_data)
                time.sleep(0.5)  
            else:
                print(" Cerrando conexión OBD-II...")
                if connection.is_connected():
                    connection.close()
                    print("Conexión OBD-II cerrada.")
                print("Volviendo a main.py...")
                subprocess.run([sys.executable, "main.py"])
                sys.exit()  # Salir del script actual
                break  # Salir del bucle
    except Exception as e:
        print(f"Error durante la conexión o ejecución: {e}")
    finally:
        if 'connection' in locals() and connection.is_connected():
            connection.close()
            print("Conexión OBD-II cerrada.")
if __name__ == "__main__":
    main()