import os

os.environ.setdefault("STUDYLOCK_APP_API_KEY", "test-app-key")
os.environ.setdefault("GOOGLE_API_KEY", "test-google-key")

from fastapi.testclient import TestClient

from main import app, rate_limit_events


client = TestClient(app)

def setup_function():
    rate_limit_events.clear()


def test_root_rejects_missing_app_key():
    response = client.get("/")

    assert response.status_code == 401


def test_root_rejects_invalid_app_key():
    response = client.get("/", headers={"X-StudyLock-App-Key": "wrong-key"})

    assert response.status_code == 401


def test_root_accepts_valid_app_key():
    response = client.get(
        "/",
        headers={"X-StudyLock-App-Key": "test-app-key"},
    )

    assert response.status_code == 200
    assert response.json() == {"status": 200}


def test_upload_route_requires_app_key_before_file_processing():
    response = client.post("/upload-file")

    assert response.status_code == 401


def test_rate_limit_returns_429():
    headers = {"X-StudyLock-App-Key": "test-app-key"}

    for _ in range(60):
        assert client.get("/", headers=headers).status_code == 200

    response = client.get("/", headers=headers)

    assert response.status_code == 429
    assert response.headers["retry-after"]
