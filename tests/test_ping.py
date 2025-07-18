import requests

def test_ping():
    resp = requests.get("http://localhost:8000/api/ping")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"
