import pytest
from unittest.mock import patch
from httpx import AsyncClient, ASGITransport


@pytest.fixture(autouse=True)
def mock_firebase():
    """Testlerde Firebase baslatmayi atla."""
    with patch("app.core.firebase.initialize_firebase"):
        with patch("app.core.firebase.get_firestore"):
            yield


@pytest.mark.asyncio
async def test_health_check():
    from main import app
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["success"] is True
    assert body["data"]["status"] == "ok"