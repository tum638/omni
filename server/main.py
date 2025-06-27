from fastapi import FastAPI
from routes.api_routes import router as api_router
from routes.websocket_routes import router as ws_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Optional: allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)
app.include_router(ws_router)

@app.get("/")
def read_root():
    return {"message": "Door access FastAPI server running"}