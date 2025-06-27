from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import asyncio
from connection_manager import manager

router = APIRouter()

@router.websocket("/ws/client/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str):
    await manager.connect(client_id, websocket)
    try:
        while True:
            # Ping every 20 seconds to keep socket alive
            await websocket.send_text("ping")
            await asyncio.sleep(20)
    except WebSocketDisconnect:
        manager.disconnect(client_id)