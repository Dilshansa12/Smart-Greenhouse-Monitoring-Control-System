#include <WiFi.h>
#include <Firebase_ESP_Client.h>


// -------------------- Firebase Configuration --------------------
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

#define API_KEY "pnPjJvGH2wTO0agSX3MMt7W3CSpfl32A6ge0va0j"
#define DATABASE_URL "https://sensor-hub-91866-default-rtdb.firebaseio.com/"


#define WIFI_SSID "Dialog 4G 287"
#define WIFI_PASSWORD "dilshanpdn281220"


#define WATER_PIN 34


void setup() {
  Serial.begin(115200);
  pinMode(WATER_PIN, INPUT);
  // Wi-Fi Connection
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi Connected");

  // Firebase Configuration
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  config.signer.tokens.legacy_token = "pnPjJvGH2wTO0agSX3MMt7W3CSpfl32A6ge0va0j";

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);  
}


// -------------------- Main Loop --------------------
void loop() {

  int waterVal = digitalRead(WATER_PIN);
  Serial.print("Water Level: ");
  Serial.println(waterVal);

  if (Firebase.RTDB.setInt(&fbdo, "/sensors/waterLevel", waterVal)) {
      Serial.println("Firebase Updated");
  } 
  else {
    Serial.println("Upload Error");
  }
  


  delay(2000);
}
