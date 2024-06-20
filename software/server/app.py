from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/api', methods=['POST'])
def api():
    data = request.get_json()
    response = {'message': 'Data received', 'data': data}
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)