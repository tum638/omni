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
    client_id = request.client_id
    device_id = request.device_id

    if (client_id, device_id) in authorized_pairs:
        message = "Access granted"
        # Send to iOS via WebSocket if connected
        if manager.is_connected(client_id):
            await manager.send_to(client_id, "access_granted")

        return AccessResponse(access="granted", message=message)

    # Not authorized
    if manager.is_connected(client_id):
        await manager.send_to(client_id, "access_denied")

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Access denied"
    )


