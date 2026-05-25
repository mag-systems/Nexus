import os
import uuid
from typing import Optional

from fastapi import APIRouter, Depends, Form, UploadFile, File, Request
from sqlalchemy.orm import Session

from database import get_db
import models

router = APIRouter(
    prefix="/perfiles",
    tags=["Perfiles"]
)

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/")
async def crear_perfil(
    request: Request,
    tipo_usuario: str = Form(...),
    nombre_completo: str = Form(...),
    correo: str = Form(...),
    password: str = Form(...),
    modelo_carro: Optional[str] = Form(None),
    placas: Optional[str] = Form(None),
    foto_perfil: UploadFile = File(...),
    foto_carro: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    base_url = str(request.base_url)

    # Guardar foto de perfil
    ext_perfil = foto_perfil.filename.split('.')[-1] if foto_perfil.filename else "jpg"
    filename_perfil = f"{uuid.uuid4()}.{ext_perfil}"
    path_perfil = os.path.join(UPLOAD_DIR, filename_perfil)
    
    with open(path_perfil, "wb") as f:
        f.write(await foto_perfil.read())
        
    url_foto_perfil = f"{base_url}uploads/{filename_perfil}"

    # Guardar foto de carro si existe
    url_foto_carro = None
    if foto_carro:
        ext_carro = foto_carro.filename.split('.')[-1] if foto_carro.filename else "jpg"
        filename_carro = f"{uuid.uuid4()}.{ext_carro}"
        path_carro = os.path.join(UPLOAD_DIR, filename_carro)
        
        with open(path_carro, "wb") as f:
            f.write(await foto_carro.read())
            
        url_foto_carro = f"{base_url}uploads/{filename_carro}"

    # Crear registro en la BD
    nuevo_perfil = models.Perfil(
        tipo_usuario=tipo_usuario,
        nombre_completo=nombre_completo,
        correo=correo,
        password=password,
        modelo_carro=modelo_carro,
        placas=placas,
        foto_perfil=url_foto_perfil,
        foto_carro=url_foto_carro
    )
    
    db.add(nuevo_perfil)
    db.commit()
    db.refresh(nuevo_perfil)
    
    # Retornar diccionario para evitar problemas de serialización de SQLAlchemy si no hay response_model
    return {
        "id": nuevo_perfil.id,
        "tipo_usuario": nuevo_perfil.tipo_usuario,
        "nombre_completo": nuevo_perfil.nombre_completo,
        "correo": nuevo_perfil.correo,
        "modelo_carro": nuevo_perfil.modelo_carro,
        "placas": nuevo_perfil.placas,
        "foto_perfil": nuevo_perfil.foto_perfil,
        "foto_carro": nuevo_perfil.foto_carro,
        "calificacion": nuevo_perfil.calificacion
    }
