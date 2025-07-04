from flask import Flask, request, jsonify
from collections import Counter

app = Flask(__name__)

@app.route('/')
def home():
    return 'GBGM Predictor API is running!'

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    history = data.get('history', [])

    if not history or len(history) < 5:
        return jsonify({'error': 'Invalid input'}), 400

    freq = Counter(history)
    missing_gap = {i: len(history) for i in range(10)}
    for i in range(len(history)-1, -1, -1):
        n = history[i]
        if missing_gap[n] == len(history):
            missing_gap[n] = len(history) - i

    score = {i: freq[i] + 1 / (missing_gap[i] + 1) for i in range(10)}
    best_number = max(score, key=score.get)
    confidence = score[best_number] / sum(score.values()) * 100

    return jsonify({'prediction': best_number, 'confidence': round(confidence, 2)})
