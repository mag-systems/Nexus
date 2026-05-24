from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
import models, schemas

router = APIRouter(
    prefix="/rutas",
    tags=["Rutas de Viaje Compartido"]
)

@router.post("/", response_model=schemas.RutaResponse)
def crear_ruta(ruta: schemas.RutaCreate, db: Session = Depends(get_db)):
    # ruta.model_dump() reemplaza a ruta.dict() en Pydantic V2
    db_ruta = models.Ruta(**ruta.model_dump()) 
    db.add(db_ruta)
    db.commit()
    db.refresh(db_ruta)
    return db_ruta

@router.get("/", response_model=list[schemas.RutaResponse])
def obtener_rutas(db: Session = Depends(get_db)):
    return db.query(models.Ruta).all()