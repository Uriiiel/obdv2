import time
import firebase_admin
from firebase_admin import credentials, firestore, db  # Importar db para Realtime Database
import serial.tools.list_ports

# Inicializar Firebase (asegúrate de tener el archivo de credenciales JSON)
cred = credentials.Certificate("./automotrizapp-firebase-adminsdk-fbsvc-ddabfa472d.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://automotrizapp-default-rtdb.firebaseio.com'  # URL de tu Realtime Database
})

# Inicializar Firestore
db_firestore = firestore.client()

def hex_a_ascii(hex_value):
    try:
        # Convertir el hexadecimal a bytes y luego a ASCII
        ascii_value = bytes.fromhex(hex_value).decode('ascii', errors='ignore')
        return ascii_value.strip()  # Eliminar espacios en blanco al inicio y final
    except Exception as e:
        print(f"Error al convertir el hexadecimal a ASCII: {e}")
        return None

def extraer_vin(ascii_value):
    try:
        # Dividir el texto en líneas
        lineas = ascii_value.splitlines()
        
        # Filtrar las líneas que contienen los datos del VIN
        datos_vin = []
        for linea in lineas:
            if "49 02" in linea or ":" in linea:  # Buscar líneas con datos del VIN
                # Eliminar prefijos como "49 02" o "0:"
                partes = linea.split()
                if "49" in partes and "02" in partes:
                    # Si la línea contiene "49 02", tomar los valores después de "02"
                    datos_vin.extend(partes[partes.index("02") + 1:])
                elif ":" in linea:
                    # Si la línea contiene ":", tomar los valores después de ":"
                    indice_dos_puntos = linea.index(":")
                    partes = linea[indice_dos_puntos + 1:].split()
                    datos_vin.extend(partes)
        
        # Filtrar solo caracteres válidos para un VIN (números y letras mayúsculas)
        vin_hex = "".join([c for c in "".join(datos_vin) if c.isalnum() and c.isascii()])
        
        # Convertir el resultado final a ASCII para obtener el VIN
        vin = bytes.fromhex(vin_hex).decode('ascii', errors='ignore')
        
        # Filtrar solo caracteres válidos para un VIN (números y letras mayúsculas)
        vin_final = "".join([c for c in vin if c.isalnum() and c.isascii()])
        
        return vin_final
    except Exception as e:
        print(f"Error al extraer el VIN: {e}")
        return None

def detectar_puertos():
    puertos_disponibles = [port.device for port in serial.tools.list_ports.comports()]
    return puertos_disponibles

def obtener_vin():
    puertos = detectar_puertos()
    if not puertos:
        print("No se encontraron puertos disponibles.")
        return None, None
    
    puerto = puertos[0]  # Tomar el primer puerto disponible
    velocidad = 115200
    timeout = 4  # Aumentar el timeout

    try:
        ser = serial.Serial(puerto, velocidad, timeout=timeout)
        print(f"Conectado al puerto {puerto}")

        # Enviar el comando para solicitar el VIN
        comando = '0902\r\n'
        ser.write(comando.encode())
        time.sleep(1)  # Esperar un poco más para la respuesta

        respuesta = b""
        start_time = time.time()
        while time.time() - start_time < timeout:  # Leer durante el tiempo de timeout
            if ser.in_waiting > 0:
                respuesta += ser.read(ser.in_waiting)
            time.sleep(0.1)  # Pequeña pausa para no saturar la CPU

        ser.close()

        if not respuesta:
            print("No se recibió respuesta del OBD-II.")
            return None, None

        print("Respuesta cruda en hexadecimal:")
        hex_response = respuesta.hex()
        print(hex_response)

        vin = extraer_vin(hex_a_ascii(hex_response))
        if vin:
            print(f"VIN extraído: {vin}")
        else:
            print("No se pudo extraer un VIN válido.")
        return hex_response, vin

    except serial.SerialException as e:
        print(f"Error de conexión: {e}")
        return None, None

def enviar_a_firestore(hex_response, vin):
    if hex_response and vin:
        doc_ref = db_firestore.collection("DTC").document("VIN")
        doc_ref.set({"hexadecimal": hex_response, "VIN": vin})
        print("Datos enviados a Firestore correctamente.")
    else:
        doc_ref = db_firestore.collection("DTC").document("VIN")
        doc_ref.set({"hexadecimal": hex_response if hex_response else "N/A", "VIN": "No se pudo obtener"})
        print("Datos enviados a Firestore con VIN no obtenido.")

def enviar_a_realtime_db(decvn):
    try:
        # Referencia a la ruta Controlador/Clave en Realtime Database
        ref = db.reference('Controlador/Clave')
        ref.set(decvn)  # Enviar el valor Decvn
        print(f"Valor '{decvn}' enviado a Firebase Realtime Database correctamente.")
    except Exception as e:
        print(f"Error al enviar a Firebase Realtime Database: {e}")

def main():
    print("Descifrando")
    print("-----------------------------------------")
    
    # Obtener el VIN y el hexadecimal del puerto serial
    hex_response, vin = obtener_vin()
    
    if hex_response and vin:
        # Enviar el VIN y el hexadecimal a Firestore
        enviar_a_firestore(hex_response, vin)
        
        # Enviar el valor Decvn a Realtime Database
        enviar_a_realtime_db("Decvn")
    else:
        # Enviar "No se pudo obtener" a Firestore
        enviar_a_firestore(hex_response, None)
        
        # Enviar "NnN" a Realtime Database
        enviar_a_realtime_db("NnN")

if __name__ == "__main__":
    main()