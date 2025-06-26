from pydantic import BaseModel

class AccessRequest(BaseModel):
    client_id: str
    device_id: str

class AccessResponse(BaseModel):
    access: str  # "granted" or "denied"
    message: str