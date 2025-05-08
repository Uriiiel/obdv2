import obd
import time
import firebase_admin
from firebase_admin import credentials, db
import subprocess
import sys
cred = credentials.Certificate("./automotrizapp-firebase-adminsdk-fbsvc-ddabfa472d.json")
firebase_admin.initialize_app(cred, {
    "databaseURL": "https://automotrizapp-default-rtdb.firebaseio.com/"
})
firebase_ref = db.reference("SensoresCombustible")
controlador_ref = db.reference("Controlador/Clave") 
protocolo_ref = db.reference("Controlador/protocolo")  
com_ref = db.reference("Controlador/COM")  
def obtener_configuracion():
    try:
        protocolo = str(protocolo_ref.get())  
        com = str(com_ref.get()) 
        if protocolo is None or com is None:
            raise ValueError("No se encontró el protocolo o el puerto COM en Firebase.")
        return com, protocolo
    except Exception as e:
        print(f"Error al obtener la configuración desde Firebase: {e}")
        return None, None
commands = {
    "Nivel de combustible": obd.commands.FUEL_LEVEL,
    "Presión de la bomba de combustible": obd.commands.FUEL_PRESSURE,
    "Estado del sistema de combustible": obd.commands.FUEL_STATUS,
    "Consumo instantáneo de combustible": obd.commands.FUEL_RATE,
    "Presion Riel combustible relativa":obd.commands.FUEL_RAIL_PRESSURE_VAC, 
    "Presion Riel combustible directa":obd.commands.FUEL_RAIL_PRESSURE_DIRECT,  
    "Tipo combustible":obd.commands.FUEL_TYPE, 
    "Porcentaje etanol en combustible":obd.commands.ETHANOL_PERCENT,  
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
        for _ in range(3):  
            response = connection.query(command)
            if not response.is_null():
                # Verificar el tipo de respuesta
                if hasattr(response.value, 'magnitude'):
                    # Si tiene el atributo magnitude, usarlo
                    value = response.value.magnitude
                elif isinstance(response.value, tuple):
                    # Si es una tupla, tomar el primer valor (si tiene magnitude)
                    if hasattr(response.value[0], 'magnitude'):
                        value = response.value[0].magnitude
                    else:
                        value = response.value[0]  # Tomar el valor directamente
                elif isinstance(response.value, (int, float)):
                    # Si es un número, usarlo directamente
                    value = response.value
                elif isinstance(response.value, str):
                    # Si es una cadena, manejarla adecuadamente
                    value = response.value  # O convertirla a un número si es posible
                else:
                    # Si no se reconoce el tipo, marcar como no soportado
                    value = "No soportado"
                    print(f"[OBD-II] Respuesta no reconocida para '{command}': {response.value}")
                
                # Convertir unidades si es necesario
                if sensor_name == "Presión de la bomba de combustible" and isinstance(value, (int, float)):
                    value = kpa_to_psi(value)
                break
            time.sleep(0.200) 
        if value is None:  # Si después de 3 intentos no hay respuesta válida
            print(f"[OBD-II] '{command}' no es soportado por este vehículo.")
            unsupported_commands.add(command)
            value = "No soportado"
        sensor_data[sensor_name] = value
    return sensor_data
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
        for _ in range(3):  
            response = connection.query(command)
            if not response.is_null():
                value = response.value.magnitude
                if sensor_name == "Presión de la bomba de combustible":
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
        if data:  # Solo enviar si hay datos válidos
            firebase_ref.update(data)  # Usamos update() para no borrar los datos previos
            print(f"Datos actualizados en Firebase: {data}")
    except Exception as e:
        print(f"Error al enviar datos a Firebase: {e}")
def verificar_controlador():
    valor = controlador_ref.get()
    return valor
def main():
    print("Iniciando lectura de sensores de combustible...")
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
            if valor_controlador == "Mcm":
                sensor_data = read_engine_sensors(connection)
                if sensor_data is not None:
                    send_to_firebase(sensor_data)
                time.sleep(0.5)  # Intervalo de 0.5 segundos entre lecturas
            else:
                print("El valor de Controlador/Clave no es 'Mtt'. Cerrando conexión OBD-II...")
                if connection.is_connected():
                    connection.close()
                    print("Conexión OBD-II cerrada.")
                print("Volviendo a main.py...")
                subprocess.run([sys.executable, "main.py"])
                sys.exit()  # Salir del script actual
                break  
    except Exception as e:
        print(f"Error durante la conexión o ejecución: {e}")
    finally:
        if 'connection' in locals() and connection.is_connected():
            connection.close()
            print("Conexión OBD-II cerrada.")
if __name__ == "__main__":
    main()