import json
import firebase_admin
from firebase_admin import credentials, firestore, db  # Importar db para Realtime Database
import re

# Inicializar Firebase
cred = credentials.Certificate("./automotrizapp-firebase-adminsdk-fbsvc-ddabfa472d.json")
firebase_admin.initialize_app(cred, {
    "databaseURL": "https://automotrizapp-default-rtdb.firebaseio.com/"
})
db_firestore = firestore.client()

def load_manufacturers(json_file):
    """Carga el archivo JSON de fabricantes."""
    try:
        with open(json_file, 'r', encoding='utf-8') as file:
            return json.load(file)
    except FileNotFoundError:
        return "Archivo JSON de fabricantes no encontrado."
    except json.JSONDecodeError:
        return "Error al decodificar el archivo JSON."

def decode_vin(vin):
    """Decodifica el VIN y devuelve los datos decodificados."""
    vin = vin.strip()  # Eliminar espacios en blanco
    if len(vin) != 17:
        return "El VIN debe tener exactamente 17 caracteres."

    manufacturers = load_manufacturers("manufacturers.json")
    if isinstance(manufacturers, str):
        return manufacturers

    wmi = vin[:3]  # World Manufacturer Identifier (WMI)
    manufacturer = manufacturers.get(wmi, "Fabricante desconocido")

    year_codes = {
        "A": 1980, "B": 1981, "C": 1982, "D": 1983, "E": 1984,
        "F": 1985, "G": 1986, "H": 1987, "J": 1988, "K": 1989,
        "L": 1990, "M": 1991, "N": 1992, "P": 1993, "R": 1994,
        "S": 1995, "T": 1996, "V": 1997, "W": 1998, "X": 1999,
        "Y": 2000, "1": 2001, "2": 2002, "3": 2003, "4": 2004,
        "5": 2005, "6": 2006, "7": 2007, "8": 2008, "9": 2009,
        "A": 2010, "B": 2011, "C": 2012, "D": 2013, "E": 2014,
        "F": 2015, "G": 2016, "H": 2017, "J": 2018, "K": 2019,
        "L": 2020, "M": 2021, "N": 2022, "P": 2023, "R": 2024
    }
    year_char = vin[9]  # Código del año
    year = year_codes.get(year_char, "Año desconocido")

    plant_code = vin[10]  # Código de la planta de ensamblaje
    serial_number = vin[11:]  # Número de serie

    decoded_data = {
        "Fabricante": manufacturer,
        "Año del modelo": year,
        "Planta de ensamblaje (código)": plant_code,
        "Número de serie": serial_number
    }

    # Enviar datos decodificados a Firestore
    doc_ref = db_firestore.collection("DTC").document("Descifrado")
    doc_ref.set(decoded_data)
    print("Enviado satisfactoriamente a Firebase Firestore.")

    return decoded_data

def get_vin_from_firestore():
    """Obtiene el VIN desde Firestore."""
    doc_ref = db_firestore.collection("DTC").document("VIN")
    doc = doc_ref.get()
    if doc.exists:
        vin = doc.to_dict().get("VIN", "")
        vin = re.sub(r"[\x00-\x1F]", "", vin).strip()  # Eliminar caracteres no imprimibles
        if vin:
            print(f"VIN recuperado: {vin}")
            return vin
        else:
            print("No se encontró un VIN válido en Firestore.")
    else:
        print("El documento VIN no existe en Firestore.")
    return None

def enviar_a_realtime_db(valor):
    """Envía un valor a Firebase Realtime Database."""
    try:
        ref = db.reference('Controlador/Clave')
        ref.set(valor)
        print(f"Valor '{valor}' enviado a Firebase Realtime Database correctamente.")
    except Exception as e:
        print(f"Error al enviar a Firebase Realtime Database: {e}")

def enviar_a_firestore_descifrado_error():
    """Envía un mensaje de error al documento Descifrado en Firestore."""
    try:
        doc_ref = db_firestore.collection("DTC").document("Descifrado")
        doc_ref.set({
            "Fabricante": "Desconecte y vuelva a conectar el USB",
            "Año del modelo": "---",
            "Planta de ensamblaje (código)": "---",
            "Número de serie": "---"
        })
        print("Mensaje de error enviado a Firebase Firestore correctamente.")
    except Exception as e:
        print(f"Error al enviar a Firebase Firestore: {e}")

def main():
    """Función principal para decodificar el VIN."""
    vin = get_vin_from_firestore()
    if not vin:
        print("No se pudo obtener un VIN válido.")
        return

    result = decode_vin(vin)
    if isinstance(result, dict):  # Si el VIN se decodificó correctamente
        for key, value in result.items():
            print(f"{key}: {value}")
        enviar_a_realtime_db("Prot")  
    else:  # Si no se pudo decodificar el VIN
        print(result)  # Mostrar el mensaje de error
        print("Desconecte y vuelva a conectar el USB.")
        input("Presione Enter para continuar...")  # Esperar a que se presione Enter
        enviar_a_realtime_db("VINd")
        # Enviar mensaje de error a Firestore en el documento Descifrado
        enviar_a_firestore_descifrado_error()

if __name__ == "__main__":
    main()