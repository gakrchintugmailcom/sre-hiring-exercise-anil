import pytest
from app import app as flask_app


@pytest.fixture()
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as client:
        yield client


def test_health_returns_200(client):
    response = client.get("/health")
    assert response.status_code == 200


def test_health_returns_ok_status(client):
    data = response = client.get("/health").get_json()
    assert data["status"] == "ok"


def test_health_includes_version(client):
    data = client.get("/health").get_json()
    assert "version" in data


def test_ready_returns_200(client):
    response = client.get("/ready")
    assert response.status_code == 200


def test_ready_returns_ready_status(client):
    data = client.get("/ready").get_json()
    assert data["status"] == "ready"
