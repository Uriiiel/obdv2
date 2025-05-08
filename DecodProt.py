import obd
import serial.tools.list_ports
import firebase_admin
from firebase_admin import credentials, db

# Configuración de Firebase
cred = credentials.Certificate("./automotrizapp-firebase-adminsdk-fbsvc-ddabfa472d.json")
firebase_admin.initialize_app(cred, {
    "databaseURL": "https://automotrizapp-default-rtdb.firebaseio.com/"
})

def detectar_puertos():
    """Detecta los puertos COM disponibles."""
    puertos_disponibles = [port.device for port in serial.tools.list_ports.comports()]
    return puertos_disponibles

def intentar_conectar(puerto, protocolo):
    """Intenta conectar al puerto y protocolo especificados."""
    try:
        print(f"Intentando conectar en {puerto} con protocolo {protocolo}...")
        connection = obd.OBD(portstr=puerto, protocol=protocolo, fast=False)
        if connection.is_connected():
            print(f"¡Conexión exitosa en {puerto} con protocolo {protocolo}!")
            print("Protocolo detectado:", connection.protocol_name())
            print("Número de protocolo:", connection.protocol_id())
            respuesta_rpm = connection.query(obd.commands.RPM)
            if not respuesta_rpm.is_null():
                print(f"Valor de RPM: {respuesta_rpm.value}")
                print("El protocolo es correcto y soporta el comando RPM.")
                enviar_datos_a_firebase(connection.protocol_id(), puerto)
                return connection
            else:
                print("El protocolo no devolvió un valor válido para RPM. Probando otro protocolo...")
                return None
        else:
            print(f"No se pudo conectar en {puerto} con protocolo {protocolo}.")
            return None
    except Exception as e:
        print(f"Error al conectar en {puerto} con protocolo {protocolo}: {e}")
        return None

def enviar_datos_a_firebase(numero_protocolo, puerto):
    """Envía el número de protocolo y el puerto a Firebase."""
    try:
        ref_protocolo = db.reference("Controlador/protocolo")
        ref_protocolo.set(numero_protocolo)
        print(f"Número de protocolo {numero_protocolo} enviado a Firebase correctamente.")
        ref_puerto = db.reference("Controlador/COM")
        ref_puerto.set(puerto)
        print(f"Puerto {puerto} enviado a Firebase correctamente.")
    except Exception as e:
        print(f"Error al enviar datos a Firebase: {e}")

def enviar_valor_a_firebase(ruta, valor):
    """Envía un valor a una ruta específica en Firebase."""
    try:
        ref = db.reference(ruta)
        ref.set(valor)
        print(f"Valor '{valor}' enviado a Firebase en la ruta '{ruta}' correctamente.")
    except Exception as e:
        print(f"Error al enviar valor a Firebase: {e}")

# Lista de protocolos a probar
protocolos = [
    None,  # Auto-detección
    "1",   # SAE J1850 PWM
    "2",   # SAE J1850 VPW
    "3",   # ISO 9141-2
    "5",   # ISO 15765-4 (CAN)
    "6",   # SAE J1939
    "7",   # ISO 15765-4 (CAN) 29-bit
    "8",   # ISO 15765-4 (CAN) 11-bit (raw)
    "9",   # ISO 15765-4 (CAN) 29-bit (raw)
    "10",  # SAE J1939 (raw)
]

# Detectar puertos disponibles
puertos = detectar_puertos()
if not puertos:
    print("No se encontraron puertos disponibles.")
    exit()

# Intentar conectar a los puertos y protocolos
conexion_exitosa = None
try:
    for puerto in puertos:
        for protocolo in protocolos:
            conexion = intentar_conectar(puerto, protocolo)
            if conexion:
                conexion_exitosa = conexion
                break
        if conexion_exitosa:
            break

    if conexion_exitosa:
        print("Conexión establecida correctamente.")
    else:
        print("No se pudo establecer una conexión con ningún puerto o protocolo.")
finally:
    # Enviar "VINd" a Firebase antes de finalizar
    enviar_valor_a_firebase("Controlador/Clave", "NnN")