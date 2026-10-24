
from app.main import app


def test_health_endpoint():
    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    data = response.get_json()

    assert data["status"] == "healthy"
    
def test_home_endpoint():
    client = app.test_client()
 
    response = client.get("/")
 
    assert response.status_code == 200
 
    data = response.get_json()
 
    assert data["message"] == "Welcome to CloudOps API"
    assert data["status"] == "running"
 
 
def test_unknown_endpoint():
    client = app.test_client()
 
    response = client.get("/does-not-exist")
 
    assert response.status_code == 404