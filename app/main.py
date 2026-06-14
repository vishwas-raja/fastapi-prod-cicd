import os
import psycopg2
from fastapi import FastAPI

app = FastAPI()

DB_HOST = os.getenv("DB_HOST", "postgres")
DB_NAME = os.getenv("DB_NAME", "appdb")
DB_USER = os.getenv("DB_USER", "appuser")
DB_PASSWORD = os.getenv("DB_PASSWORD", "apppassword")


def get_conn():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )


@app.on_event("startup")
def init_db():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS visits (
            id SERIAL PRIMARY KEY,
            message TEXT NOT NULL
        );
    """)
    conn.commit()
    cur.close()
    conn.close()


@app.get("/")
def home():
    return {"message": "FastAPI app running behind Nginx with PostgreSQL"}


@app.post("/visit")
def create_visit():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO visits (message) VALUES (%s) RETURNING id;",
        ("CI/CD production-like deployment working",),
    )
    visit_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()

    return {"visit_id": visit_id}


@app.get("/visits")
def get_visits():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT id, message FROM visits ORDER BY id DESC;")
    rows = cur.fetchall()
    cur.close()
    conn.close()

    return [{"id": r[0], "message": r[1]} for r in rows]


@app.get("/health")
def health():
    return {"status": "ok"}
