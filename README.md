# Design Document: A More Accessible and Secure Access Control System

## 1. Overview
Physical badges for building access present security and accessibility challenges. This project proposes a Bluetooth-based digital badge system that improves security, enhances accessibility, and enables smoother interaction with door systems through a smartphone application.

## 2. Goals
- Replace physical badges with Bluetooth-enabled digital badges  
- Enable secure credential-based authentication  
- Enhance accessibility (no swiping, tapping, or holding cards)  
- Demonstrate feasibility with a working prototype using Arduino, mobile app and web server (credential verification server)

## 3. User Flow
- Employee opens the app on their smartphone  
- Face ID / password is required to continue  
- The app scans for nearby authorized receivers (BLE)  
- Available doors are displayed in the app  
- Employee selects a door to unlock  
- Credentials are sent via BLE to the Arduino receiver  
- Arduino forwards request to a web service  
- Web service authenticates and sends back Access Granted or Denied  
- Arduino updates status, which is reflected on a live webpage for demo

## 4. System Components

| Component        | Description                                                |
|------------------|------------------------------------------------------------|
| Smartphone App   | BLE-enabled app for identity authentication and door control |
| Arduino (ESP32)  | BLE receiver and credential forwarder                      |
| Web Server       | Validates user credentials and door permissions            |
| Web Dashboard    | Displays access status ("Access Granted" / "Access Denied")|

## 5. Security Considerations
- User authentication on the phone (Face ID / Password)  
- BLE communication uses encrypted pairing  
- App signs requests with a digital signature or token  
- Server verifies signature/token before granting access

## 6. Architecture Diagram (Description)
The architecture includes a smartphone app communicating via BLE with an ESP32. The ESP32 sends HTTP requests to a web server, which validates the user and updates a web dashboard accordingly.

## 7. Component Design

**Smartphone App**  
- Platform: Swift 
- Features: Authentication, BLE scan, user-friendly UI, send credentials  

**Arduino (ESP32)**  
- Acts as BLE GATT server, receives and forwards credentials, shows debug status  

**Web Server**  
- Stack: Fast API 
- Verifies tokens and access rights
- Notifies user of status. 


## 8. Data Flow Diagram (Description)
The user app sends BLE credentials to ESP32, which makes an HTTP request to the server. The server checks validity and updates a web dashboard.

## 9. Prototyping Setup
Components include BLE phone app, ESP32 dev board, local FASTApi server, and a localhost dashboard.

## 10. Stretch Features
- Geo-fencing via GPS or beacon triangulation  
- NFC fallback  
- Push notifications to staff on failed attempts  
- In-app camera preview before access

## 11. Future Considerations

| Feature                    | Notes                                 |
|----------------------------|---------------------------------------|
| Offline access             | Use signed time-limited tokens        |
| Integration with MS Entra ID | Real-world enterprise integration    |
| Door hardware integration  | Trigger relays or smart locks         |
| Analytics                  | Access logs, usage heatmaps           |

## 12. Risks & Mitigations

| Risk                          | Mitigation                                                  |
|-------------------------------|-------------------------------------------------------------|
| BLE interference / inaccuracy | Use RSSI thresholds with margin, test under different conditions |
| Replay attacks                | Use time-limited signed tokens                             |
| Phone theft                   | Require Face ID before every unlock attempt                |

