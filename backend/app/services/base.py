from abc import ABC, abstractmethod
from typing import TypeVar, Optional, List

ModelT  = TypeVar("ModelT")
CreateT = TypeVar("CreateT")
UpdateT = TypeVar("UpdateT")


class BaseService(ABC):
    """
    Tum servisler bu kontrati uygular.
    Firestore client __init__ ile injection edilir.
    """
    pass


class BaseCRUDService(BaseService, ABC):
    @abstractmethod
    async def get_by_id(self, id: str) -> Optional[ModelT]: ...

    @abstractmethod
    async def get_all(self, limit: int = 20) -> List[ModelT]: ...

    @abstractmethod
    async def create(self, schema: CreateT) -> ModelT: ...

    @abstractmethod
    async def update(self, id: str, schema: UpdateT) -> Optional[ModelT]: ...

    @abstractmethod
    async def delete(self, id: str) -> bool: ...