# from flask import Flask, request, jsonify
# from flask_cors import CORS

# app = Flask(__name__)
# CORS(app)  # allows Flutter to access backend

# events = {}

# @app.route("/add_event", methods=["POST"])
# def add_event():
#     data = request.json
#     title = data.get("title")
#     time = data.get("time")
#     type_ = data.get("type")
#     date = data.get("date")

#     if not title or not time or not type_ or not date:
#         return jsonify({"error": "Missing fields"}), 400

#     if date not in events:
#         events[date] = []

#     event = {"title": title, "time": time, "type": type_}
#     events[date].append(event)
#     return jsonify({"message": "Event added", "event": event}), 200


# @app.route("/get_events", methods=["GET"])
# def get_events():
#     return jsonify(events), 200


# if __name__ == "__main__":
#     app.run(debug=True)

# backend/calendar.py
from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

# Store events in memory for now (you can replace this with a DB)
events = {}

def date_key(date_str):
    # Convert 'YYYY-MM-DD' string to a consistent key
    return datetime.strptime(date_str, "%Y-%m-%d").date()

@app.route("/get_events", methods=["GET"])
def get_events():
    date_str = request.args.get("date")
    key = date_key(date_str)
    day_events = events.get(key, [])
    return jsonify(day_events)

@app.route("/add_event", methods=["POST"])
def add_event():
    data = request.json
    date_str = data.get("date")  # expected 'YYYY-MM-DD'
    title = data.get("title")
    time = data.get("time")
    type_ = data.get("type")  # 'habit' or 'todo'

    key = date_key(date_str)
    if key not in events:
        events[key] = []

    events[key].append({
        "title": title,
        "time": time,
        "type": type_
    })

    return jsonify({"status": "success"}), 201

if __name__ == "__main__":
    app.run(debug=True)
