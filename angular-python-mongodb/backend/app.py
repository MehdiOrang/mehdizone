from flask import Flask
from pymongo import MongoClient

app = Flask(__name__)

client = MongoClient("mongodb://mongo:27017/")
db = client["mydatabase"]

@app.route("/")
def hello():
    return "Hello from Python Flask backend"

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5001)
