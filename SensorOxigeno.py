import obd
import time
import firebase_admin
from firebase_admin import credentials, db
import subprocess
import sys

# Inicializar conexión con Firebase
cred = credentials.Certificate("./automotrizapp-firebase-adminsdk-fbsvc-ddabfa472d.json")
firebase_admin.initialize_app(cred, {
    "databaseURL": "https://automotrizapp-default-rtdb.firebaseio.com"
})

# Referencias en Firebase Realtime Database
firebase_ref = db.reference("SensoresOxigeno")
controlador_ref = db.reference("Controlador/Clave")  # Ruta para condicionar la ejecución
protocolo_ref = db.reference("Controlador/protocolo")  # Nueva referencia para el protocolo
com_ref = db.reference("Controlador/COM")  # Nueva referencia para el puerto COM

# Función para obtener el protocolo y el puerto COM desde Firebase
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

# Comandos de sensores relacionados con oxígeno y temperatura del catalizador
oxygen_commands = {
    "Sensor oxigeno-B1S1": obd.commands.O2_B1S1,
    "Sensor oxigeno-B1S2": obd.commands.O2_B1S2,
    "Sensor oxigeno-B1S3":obd.commands.O2_B1S3,
    "Sensor oxigeno-B1S4":obd.commands.O2_B1S4,
    "Sensor oxigeno-B2S1": obd.commands.O2_B2S1,
    "Sensor oxigeno-B2S2": obd.commands.O2_B2S2,
    "Sensor oxigeno-B2S3":obd.commands.O2_B2S3,  # Voltaje del sensor de oxígeno, Banco 2, Sensor 3
    "Sensor oxigeno-B2S4":obd.commands.O2_B2S4, 
    "Temp catalizador-B1S1": obd.commands.CATALYST_TEMP_B1S1,
    "Temp catalizador-B1S2": obd.commands.CATALYST_TEMP_B1S2,
    "Temp catalizador-B2S1": obd.commands.CATALYST_TEMP_B2S1,
    "Temp catalizador-B2S2": obd.commands.CATALYST_TEMP_B2S2,    
}

# Lista para almacenar los comandos no soportados
unsupported_oxygen_commands = set()

# Función para procesar respuestas complejas
def process_complex_response(response):
    if isinstance(response.value, tuple):  # Verifica si es una tupla
        return [str(item) for item in response.value if item]  # Extrae valores no nulos
    return response.value.magnitude if not response.is_null() else None

# Función para leer datos de los sensores de oxígeno
def read_oxygen_sensors(connection):
    sensor_data = {}
    if not connection.is_connected():
        print("Reconectando al dispositivo OBD-II...")
        com, protocolo = obtener_configuracion()
        if com is None or protocolo is None:
            print("No se pudo obtener la configuración desde Firebase.")
            return None
        connection = obd.OBD(com, protocol=protocolo)  # Reconexión con el protocolo especificado

    for sensor_name, command in oxygen_commands.items():
        value = None
        
        # Evitar repetir mensajes de error para comandos no soportados
        if command in unsupported_oxygen_commands:
            sensor_data[sensor_name] = "No soportado"
            continue
        
        for _ in range(2):  # Intentar 3 veces
            response = connection.query(command)
            if not response.is_null():
                # Procesar respuesta compleja si es necesario
                if sensor_name == "DTC O2: Bank 1 - Sensor 1 Voltage":
                    value = process_complex_response(response)
                else:
                    value = response.value.magnitude
                break
            time.sleep(0.200)  # Esperar un poco entre intentos
        
        if value is None:  # Si después de 3 intentos no hay respuesta válida
            print(f"[OBD-II] '{command}' no es soportado por este vehículo.")
            unsupported_oxygen_commands.add(command)
            sensor_data[sensor_name] = "No soportado"
        else:
            sensor_data[sensor_name] = value
    return sensor_data

# Función para enviar datos a Firebase
def send_to_firebase(data):
    try:
        if data:  # Solo enviar si hay datos válidos
            firebase_ref.update(data)  # Usamos update() para no borrar los datos previos
            print(f"Datos actualizados en Firebase: {data}")
    except Exception as e:
        print(f"Error al enviar datos a Firebase: {e}")

# Función para verificar el valor de Controlador/Clave
def verificar_controlador():
    valor = controlador_ref.get()
    return valor

# Función principal
def main():
    print("Iniciando lectura de sensores de oxígeno...")
    try:
        # Obtener configuración inicial desde Firebase
        com, protocolo = obtener_configuracion()
        if com is None or protocolo is None:
            print("No se pudo obtener la configuración inicial. Saliendo...")
            return

        # Conexión inicial al dispositivo OBD-II con el protocolo especificado
        connection = obd.OBD(com, protocol=protocolo)

        if not connection.is_connected():
            print("No se pudo conectar al vehículo. Verifica el puerto y la llave de encendido.")
            return

        while True:
            # Verificar el valor de Controlador/Clave
            valor_controlador = verificar_controlador()

            if valor_controlador == "Mox":
                # Leer sensores y enviar datos a Firebase
                oxygen_sensor_data = read_oxygen_sensors(connection)
                if oxygen_sensor_data is not None:
                    send_to_firebase(oxygen_sensor_data)
                time.sleep(0.5)  # Intervalo de 0.5 segundos entre lecturas
            else:
                # Cerrar la conexión OBD-II y volver a main.py
                print("El valor de Controlador/Clave no es 'Mtt'. Cerrando conexión OBD-II...")
                if connection.is_connected():
                    connection.close()
                    print("Conexión OBD-II cerrada.")
                # Volver a main.py
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