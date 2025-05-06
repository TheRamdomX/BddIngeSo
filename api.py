from fastapi import FastAPI, HTTPException
import psycopg2
from psycopg2 import sql
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "asistencia_db")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")
DB_PORT = os.getenv("DB_PORT", "5432")

def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        port=DB_PORT
    )


@app.post("/partition")
async def create_partitions():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute("SELECT ID FROM Secciones")
        secciones = cursor.fetchall()
        
        for sec_id in secciones:
            sec_id = sec_id[0]
            
            tabla_asistencia = f"asistencia_id_{sec_id}"
            cursor.execute(sql.SQL("""
                CREATE TABLE IF NOT EXISTS {} PARTITION OF Asistencia
                FOR VALUES FROM (%s) TO (%s)
            """).format(sql.Identifier(tabla_asistencia)), (sec_id, sec_id + 1))
            
            cursor.execute(sql.SQL("""
                CREATE INDEX IF NOT EXISTS {} ON {}(AlumnoID)
            """).format(
                sql.Identifier(f"idx_{tabla_asistencia}_alumno"),
                sql.Identifier(tabla_asistencia)
            ))
            
            cursor.execute(sql.SQL("""
                CREATE INDEX IF NOT EXISTS {} ON {}(ModuloID)
            """).format(
                sql.Identifier(f"idx_{tabla_asistencia}_modulo"),
                sql.Identifier(tabla_asistencia)
            ))
            
            tabla_reporte = f"reporteasistencia_id_{sec_id}"
            cursor.execute(sql.SQL("""
                CREATE TABLE IF NOT EXISTS {} PARTITION OF ReporteAsistencia
                FOR VALUES FROM (%s) TO (%s)
            """).format(sql.Identifier(tabla_reporte)), (sec_id, sec_id + 1))
            
            cursor.execute(sql.SQL("""
                CREATE INDEX IF NOT EXISTS {} ON {}(AlumnoID)
            """).format(
                sql.Identifier(f"idx_{tabla_reporte}_alumno"),
                sql.Identifier(tabla_reporte)
            ))
            
            cursor.execute(sql.SQL("""
                CREATE INDEX IF NOT EXISTS {} ON {}(ModuloID)
            """).format(
                sql.Identifier(f"idx_{tabla_reporte}_modulo"),
                sql.Identifier(tabla_reporte)
            ))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return {"message": "Particiones creadas exitosamente"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/AddCache/{seccion_id}")
async def add_cache(seccion_id: int):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        tabla_asistencia = f"asistencia_id_{seccion_id}"
        tabla_reporte = f"reporteasistencia_id_{seccion_id}"
        
        cursor.execute(sql.SQL("SELECT pg_prewarm(%s, 'buffer')").format(sql.Literal(tabla_asistencia)))
        cursor.execute(sql.SQL("SELECT pg_prewarm(%s, 'buffer')").format(sql.Literal(tabla_reporte)))
        
        conn.commit()
        
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            conn.close()
    
    return {"status": "completed"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)