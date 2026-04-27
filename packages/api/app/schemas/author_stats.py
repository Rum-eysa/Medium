from pydantic import BaseModel, ConfigDict


class AuthorStatsRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    author_id: str
    total_articles: int
    total_views: int
    total_claps: int
    total_followers: int
    average_reading_time: float