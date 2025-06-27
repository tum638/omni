#include <WiFiS3.h>
#include <ArduinoBLE.h>
#include <ArduinoHttpClient.h>

#define SVC_UUID  "19B10000-E8F2-537E-4F6C-D104768A1214"
#define CHR_UUID  "19B10001-E8F2-537E-4F6C-D104768A1214"

BLEService provService(SVC_UUID);
BLEStringCharacteristic credChar(CHR_UUID, BLEWrite, 96);

String clientId = "";
String deviceId = "";

// Fallback Wi-Fi credentials if BLE hasn't sent anything yet
String wifiSSID = "4466784";
String wifiPASS = "tanatswa";

char serverAddress[] = "172.20.10.3";
int serverPort = 8000;

WiFiClient wifiClient;
HttpClient httpClient(wifiClient, serverAddress, serverPort);


unsigned long lastStatus = 0;

void setup() {
  Serial.println("BLE advertising...");
  Serial.begin(115200);
  unsigned long start = millis();
  while (!Serial && millis() - start < 3000) { }

  pinMode(LED_BUILTIN, OUTPUT);

  // Start BLE
  if (!BLE.begin()) {
    Serial.println("BLE init failed — check firmware!");
    while (1);
  }
  Serial.println("✅ BLE started");
  // BLE.setSecurityLevel(BLE_LOCK_ENCRYPT);
  provService.addCharacteristic(credChar);
  BLE.setLocalName("DoorLock-R4");
  BLE.setAdvertisedService(provService);
  BLE.addService(provService);
  BLE.advertise();

  Serial.println("BLE advertising...");

  // Start Wi-Fi
  if (WiFi.status() == WL_NO_MODULE) {
    Serial.println("WiFi module not responding");
    while (1);
  }

  connectToWiFi();
}

void loop() {
  BLEDevice central = BLE.central();
  if (central) {
    Serial.print("🔗 BLE connected to "); Serial.println(central.address());

    while (central.connected()) {
      if (credChar.written()) {
        String json = credChar.value();
        Serial.print("Got JSON: "); Serial.println(json);

        int c1 = json.indexOf("\"client_id\":\"");
        int d1 = json.indexOf("\"device_id\":\"");
        if (c1 >= 0 && d1 >= 0) {
          clientId = json.substring(c1 + 13, json.indexOf('"', c1 + 13));
          deviceId = json.substring(d1 + 13, json.indexOf('"', d1 + 13));

          Serial.println("→ Parsed Client ID: " + clientId);
          Serial.println("→ Parsed Device ID: " + deviceId);

          connectToWiFi();
          sendToServer();
        }
      }
    }

    Serial.println("❌ BLE disconnected");
  }

  if (millis() - lastStatus > 10000) {
    lastStatus = millis();
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("WiFi lost, reconnecting...");
      connectToWiFi();
    } else {
      Serial.print("RSSI: "); Serial.println(WiFi.RSSI());
    }
  }
}

void connectToWiFi() {
  Serial.print("Connecting to "); Serial.println(wifiSSID);
  int attempts = 0;
  while (WiFi.begin(wifiSSID.c_str(), wifiPASS.c_str()) != WL_CONNECTED) {
    Serial.print("  Attempt "); Serial.print(++attempts);
    Serial.print(" - Status: "); Serial.println(WiFi.status());
    delay(1000);
    if (attempts > 10) break;  // prevent infinite loop
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("✅ WiFi Connected!");
    Serial.print("IP: "); Serial.println(WiFi.localIP());
  } else {
    Serial.println("❌ WiFi Failed");
  }
}

void sendToServer() {
  Serial.println("📡 Sending device identity to server...");

  String payload = "{";
  payload += "\"client_id\":\"" + clientId + "\",";
  payload += "\"device_id\":\"" + deviceId + "\"}";
  
  httpClient.beginRequest();
  httpClient.post("/verify-access");  // adjust path if needed
  httpClient.sendHeader("Content-Type", "application/json");
  httpClient.sendHeader("Content-Length", payload.length());
  httpClient.beginBody();
  httpClient.print(payload);
  httpClient.endRequest();

  int statusCode = httpClient.responseStatusCode();
  String response = httpClient.responseBody();

  Serial.print("✅ Server status: "); Serial.println(statusCode);
  Serial.print("📨 Server response: "); Serial.println(response);
}
