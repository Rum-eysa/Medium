from app.services.ai.base_nlp import BaseNLPService

class BertService(BaseNLPService):
    async def analyze_text(self, text: str) -> dict:
        return {"sentiment": "positive", "score": 0.95}
    async def embed(self, text: str) -> list[float]:
        return [0.0] * 768
    async def classify(self, text: str, labels: list[str]) -> dict:
        return {label: 0.0 for label in labels}