
# pyrefly: ignore [missing-import]
from sqlalchemy import Column, Integer, String
from database import Base

class Ruta(Base):
    __tablename__ = "rutas"

    id = Column(Integer, primary_key=True, index=True)
    conductor = Column(String, index=True)
    origen = Column(String)
    destino = Column(String)
    lugares_disponibles = Column(Integer)