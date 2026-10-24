from flask import Flask, jsonify
import os
 
app = Flask(__name__)
 
@app.route("/")
def home():
    return jsonify({
        "message": "Welcome to CloudOps API",
        "status": "running"
    })
 
@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    })

@app.route("/version")
def version():
    return jsonify({
        "application": "cloudops-api",
        "version": os.getenv("APP_VERSION", "1.0.0")
    })
 
if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)

