from pydantic import BaseModel

class RutaCreate(BaseModel):
    conductor: str
    origen: str
    destino: str
    lugares_disponibles: int

class RutaResponse(RutaCreate):
    id: int

    class Config:
        from_attributes = True