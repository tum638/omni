#include <WiFiS3.h>
#include <ArduinoBLE.h>

#define SVC_UUID  "19B10000-E8F2-537E-4F6C-D104768A1214"
#define CHR_UUID  "19B10001-E8F2-537E-4F6C-D104768A1214"

BLEService provService(SVC_UUID);
BLEStringCharacteristic credChar(CHR_UUID, BLEWrite, 96);

// Fallback Wi-Fi credentials if BLE hasn't sent anything yet
String wifiSSID = "4466784";
String wifiPASS = "tanatswa";

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

        int u1 = json.indexOf("\"u\":\"");
        int p1 = json.indexOf("\"p\":\"");
        if (u1 >= 0 && p1 >= 0) {
          wifiSSID = json.substring(u1 + 5, json.indexOf('"', u1 + 5));
          wifiPASS = json.substring(p1 + 5, json.indexOf('"', p1 + 5));
          Serial.print("→ Parsed SSID: "); Serial.println(wifiSSID);
          Serial.print("→ Parsed PASS: "); Serial.println(wifiPASS);
          connectToWiFi();  // reconnect with new creds
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
