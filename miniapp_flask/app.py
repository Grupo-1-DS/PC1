import os
from flask import Flask, request, jsonify
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)

# Simula una base de datos en memoria
items = [
    {"id": 1, "nombre": "item1"},
    {"id": 2, "nombre": "item2"}
]

# GET: obtener todos los items


def find_item(item_id):
    return next((item for item in items if item["id"] == item_id), None)


@app.route('/')
def home():
    return jsonify(os.environ.get('MESSAGE'))


@app.route('/items', methods=['GET'])
def get_items():
    return jsonify(items)

# PUT: actualizar un item existente


@app.route('/items/<int:item_id>', methods=['PUT'])
def update_item(item_id):
    item = find_item(item_id)
    if not item:
        return jsonify({"error": "Item no encontrado"}), 404
    data = request.get_json()
    item["nombre"] = data.get("nombre", item["nombre"])
    return jsonify(item)

# DELETE: eliminar un item


@app.route('/items/<int:item_id>', methods=['DELETE'])
def delete_item(item_id):
    item = find_item(item_id)
    if not item:
        return jsonify({"error": "Item no encontrado"}), 404
    items.remove(item)
    return jsonify({"mensaje": "Item eliminado"})


if __name__ == '__main__':
    print("IP:", os.environ.get('IP'))
    print("PORT:", os.environ.get('PORT'))

    cert_dir = os.path.join(os.path.dirname(__file__), 'certs')
    cert_file = os.path.join(cert_dir, 'server.crt')
    key_file = os.path.join(cert_dir, 'server.key')
    host = os.environ.get('IP', '127.0.0.1')
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host=host, port=port,
            ssl_context=(cert_file, key_file))
