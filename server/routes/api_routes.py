from fastapi import APIRouter
from models import AccessRequest, AccessResponse
from connection_manager import manager

router = APIRouter()

# Example hardcoded access rules
authorized_pairs = {
    ("abc123", "door1"),
    ("client456", "door2")
}

@router.post("/verify-access", response_model=AccessResponse)
async def verify_access(request: AccessRequest):
    access = "granted" if (request.client_id, request.device_id) in authorized_pairs else "denied"
    message = "Access granted" if access == "granted" else "Access denied"

    # Push response back to client if connected
    if manager.is_connected(request.client_id):
        await manager.send_to(request.client_id, access)

    return AccessResponse(access=access, message=message)