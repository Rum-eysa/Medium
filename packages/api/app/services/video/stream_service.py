from app.services.video.base_video import BaseVideoService

class StreamService(BaseVideoService):
    async def process_frame(self, frame_bytes: bytes) -> dict:
        return {"objects_detected": [], "fps": 0}
    async def start_stream(self, session_id: str) -> None:
        pass
    async def stop_stream(self, session_id: str) -> None:
        pass