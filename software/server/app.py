import time

import smbus
from flask import Flask, jsonify

# ADXL345のI2Cアドレス
DEVICE_ADDRESS = 0x53

# レジスタアドレス
POWER_CTL = 0x2D
DATA_FORMAT = 0x31
BW_RATE = 0x2C
DATAX0 = 0x32

# I2Cバスの設定
bus = smbus.SMBus(1)

def adxl345_setup():
    # デバイスの初期設定
    bus.write_byte_data(DEVICE_ADDRESS, POWER_CTL, 0x08)
    bus.write_byte_data(DEVICE_ADDRESS, DATA_FORMAT, 0x08)
    bus.write_byte_data(DEVICE_ADDRESS, BW_RATE, 0x0A)

def read_adxl345():
    # データを読み取る
    data0 = bus.read_byte_data(DEVICE_ADDRESS, DATAX0)
    data1 = bus.read_byte_data(DEVICE_ADDRESS, DATAX0 + 1)
    data2 = bus.read_byte_data(DEVICE_ADDRESS, DATAX0 + 2)
    data3 = bus.read_byte_data(DEVICE_ADDRESS, DATAX0 + 3)
    data4 = bus.read_byte_data(DEVICE_ADDRESS, DATAX0 + 4)
    data5 = bus.read_byte_data(DEVICE_ADDRESS, DATAX0 + 5)

    # 16ビットの値に変換
    x = data0 | (data1 << 8)
    if x & (1 << 16 - 1):
        x = x - (1 << 16)
    
    y = data2 | (data3 << 8)
    if y & (1 << 16 - 1):
        y = y - (1 << 16)
    
    z = data4 | (data5 << 8)
    if z & (1 << 16 - 1):
        z = z - (1 << 16)
    
    return x, y, z

# センサーの初期設定
adxl345_setup()

app = Flask(__name__)

@app.route('/sensor', methods=['GET'])
def get_sensor_data():
    x, y, z = read_adxl345()
    data = {'x': x, 'y': y, 'z': z}
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)