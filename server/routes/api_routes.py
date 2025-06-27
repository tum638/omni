from fastapi import APIRouter, HTTPException, status 
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
    if (request.client_id, request.device_id) in authorized_pairs:
        message = "Access granted"
        if manager.is_connected(request.client_id):
            await manager.send_to(request.client_id, "granted")
        return AccessResponse(access="granted", message=message)

    # Access denied
    if manager.is_connected(request.client_id):
        await manager.send_to(request.client_id, "denied")

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Access denied"
    )