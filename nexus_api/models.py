
# pyrefly: ignore [missing-import]
from sqlalchemy import Column, Integer, String, Float
from database import Base

class Ruta(Base):
    __tablename__ = "rutas"

    id = Column(Integer, primary_key=True, index=True)
    conductor = Column(String, index=True)
    origen = Column(String)
    destino = Column(String)
    lugares_disponibles = Column(Integer)

class Perfil(Base):
    __tablename__ = "perfiles"

    id = Column(Integer, primary_key=True, index=True)
    tipo_usuario = Column(String) # 'alumno' o 'socio_nexus'
    nombre_completo = Column(String)
    correo = Column(String, unique=True, index=True)
    password = Column(String)
    modelo_carro = Column(String, nullable=True)
    placas = Column(String, nullable=True)
    foto_perfil = Column(String)
    foto_carro = Column(String, nullable=True)
    calificacion = Column(Float, default=5.0)