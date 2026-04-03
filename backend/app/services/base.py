from abc import ABC, abstractmethod
from typing import Generic, TypeVar, Optional, List
from sqlalchemy.ext.asyncio import AsyncSession

ModelT  = TypeVar("ModelT")
CreateT = TypeVar("CreateT")
UpdateT = TypeVar("UpdateT")


class BaseService(ABC, Generic[ModelT, CreateT, UpdateT]):
    def __init__(self, db: AsyncSession):
        self.db = db

    @abstractmethod
    async def get_by_id(self, id: str) -> Optional[ModelT]: ...

    @abstractmethod
    async def get_all(self, skip: int = 0, limit: int = 20) -> List[ModelT]: ...

    @abstractmethod
    async def create(self, schema: CreateT) -> ModelT: ...

    @abstractmethod
    async def update(self, id: str, schema: UpdateT) -> Optional[ModelT]: ...

    @abstractmethod
    async def delete(self, id: str) -> bool: ...