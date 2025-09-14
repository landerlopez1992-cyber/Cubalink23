#!/usr/bin/env python3
"""
Script para probar un endpoint simple
"""

from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/api/test')
def test_endpoint():
    return jsonify({
        "message": "Test endpoint funcionando",
        "status": "success"
    })

@app.route('/api/payments/test')
def test_payments():
    return jsonify({
        "message": "Payments test endpoint funcionando",
        "status": "success"
    })

if __name__ == '__main__':
    app.run(debug=True, port=5000)

