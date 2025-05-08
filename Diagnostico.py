import obd
import firebase_admin
from firebase_admin import credentials, firestore, db
import serial.tools.list_ports
def detectar_puertos():
    puertos_disponibles = [port.device for port in serial.tools.list_ports.comports()]
    return puertos_disponibles
cred = credentials.Certificate("./automotrizapp-firebase-adminsdk-fbsvc-ddabfa472d.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://automotrizapp-default-rtdb.firebaseio.com/' 
})
def obtener_protocolo():
    ref = db.reference('Controlador/protocolo')
    protocolo = ref.get()
    return protocolo
puertos_disponibles = detectar_puertos()
if not puertos_disponibles:
    print("No se encontraron puertos disponibles.")
    exit()
puerto_seleccionado = puertos_disponibles[0]
print(f"Conectando al puerto: {puerto_seleccionado}")
protocolo = obtener_protocolo()
if not protocolo:
    print("No se pudo obtener el protocolo desde Firebase Realtime Database.")
    exit()
print(f"Protocolo obtenido desde Firebase Realtime Database: {protocolo}")
connection = obd.OBD(puerto_seleccionado, protocol=protocolo)
if connection.is_connected():
    print("Conexión exitosa con el vehículo.")
    comandos = [
        obd.commands.DTC_LONG_FUEL_TRIM_1,
        obd.commands.DTC_O2_B1S1,
        obd.commands.DTC_O2_SENSORS,
        obd.commands.DTC_OBD_COMPLIANCE,
        obd.commands.DTC_PIDS_B,
        obd.commands.DTC_RPM,
        obd.commands.DTC_SHORT_FUEL_TRIM_1,
        obd.commands.DTC_STATUS,
        obd.commands.DTC_THROTTLE_POS,
        obd.commands.DTC_TIMING_ADVANCE,
        obd.commands.ELM_VERSION,
        obd.commands.GET_CURRENT_DTC,
        obd.commands.GET_DTC,
        obd.commands.O2_SENSORS,
        obd.commands.DISTANCE_SINCE_DTC_CLEAR,
        obd.commands.ELM_VERSION,
        obd.commands.PIDS_A,  
        obd.commands.PIDS_B,  
        obd.commands.PIDS_C,  
        obd.commands.PIDS_9A,
    ]
    diagnosticos = {}
    for cmd in comandos:
        print(f"\nConsultando {cmd.desc}...")
        respuesta = connection.query(cmd)
        if respuesta.is_null():
            diagnosticos[cmd.name] = "No soportado por el auto"
            print(f"No se obtuvo una respuesta válida para {cmd.desc}.")
        else:
            diagnosticos[cmd.name] = str(respuesta.value)
            print(f"{cmd.desc}: {respuesta.value}")
    try:
        # Conecta con Firestore
        firestore_db = firestore.client()
        doc_ref = firestore_db.collection('DTC').document('diagnosticos')
        doc_ref.set(diagnosticos)
        print("Diagnósticos enviados a Firestore.")
    except Exception as e:
        print(f"Error al guardar en Firestore: {e}")
else:
    print("No se pudo conectar al vehículo. Verifica la conexión al puerto OBD.")
connection.close()