#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <Adafruit_SSD1306.h>
#include <Adafruit_GFX.h>
#include <Wire.h>
#include "DHT.h"
#include <BH1750.h>

// -------------------- Firebase Configuration --------------------
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

#define API_KEY "pnPjJvGH2wTO0agSX3MMt7W3CSpfl32A6ge0va0j"
#define DATABASE_URL "https://sensor-hub-91866-default-rtdb.firebaseio.com/"

// -------------------- WiFi Configuration --------------------
#define WIFI_SSID "Dialog 4G 287"
#define WIFI_PASSWORD "dilshanpdn281220"

// -------------------- Sensors and Devices --------------------
#define DHTPIN 17
#define DHTTYPE DHT22
#define SOIL_PIN 36
#define GAS_PIN 39

#define RELAY_FAN 26
#define RELAY_BULB 27
#define BUZZER 25

DHT dht(DHTPIN, DHTTYPE);
BH1750 lightMeter;

// -------------------- OLED Display --------------------
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

// -------------------- Variables --------------------
float temp, hum, lightVal;
int soilVal, gasVal, waterVal;
bool autoMode = true;
bool fanOn = false;
bool bulbOn = false;
bool buzzerState = false;
int tempThreshold = 30;
int lightThreshold = 50;
int gasThreshold = 300;

// -------------------- Setup --------------------
void setup() {
  Serial.begin(115200);

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

  // Initialize sensors
  dht.begin();
 // SDA = 21, SCL = 22
Wire.begin(21, 22);  
// Continuous high resolution mode, address 0x23
lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE, 0x23);


  // Pin modes
  pinMode(RELAY_FAN, OUTPUT);
  pinMode(RELAY_BULB, OUTPUT);
  pinMode(BUZZER, OUTPUT);


  digitalWrite(RELAY_FAN, LOW);
  digitalWrite(RELAY_BULB, LOW);
  digitalWrite(BUZZER, LOW);

  // OLED Setup
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.println("🌿 Greenhouse Starting...");
  display.display();
  delay(2000);
}

// -------------------- Main Loop --------------------
void loop() {
  // ---- Read Sensors ----
  temp = dht.readTemperature();
  hum = dht.readHumidity();
  soilVal = analogRead(SOIL_PIN);
  gasVal = analogRead(GAS_PIN);
  lightVal = lightMeter.readLightLevel();


  // ---- Push Sensor Data to Firebase ----
  Firebase.RTDB.setFloat(&fbdo, "/sensors/temp", temp);
  if (Firebase.RTDB.setFloat(&fbdo, "/sensors/temp", temp)) {
  Serial.println("Temp updated");
} else {
  Serial.println("Error: " + fbdo.errorReason());
}

  Firebase.RTDB.setFloat(&fbdo, "/sensors/hum", hum);
  if (Firebase.RTDB.setFloat(&fbdo, "/sensors/temp", temp)) {
  Serial.println("Temp updated");
} else {
  Serial.println("Error: " + fbdo.errorReason());
}

  Firebase.RTDB.setInt(&fbdo, "/sensors/soil", soilVal);
  if (Firebase.RTDB.setFloat(&fbdo, "/sensors/temp", temp)) {
  Serial.println("Temp updated");
} else {
  Serial.println("Error: " + fbdo.errorReason());
}

  Firebase.RTDB.setInt(&fbdo, "/sensors/gas", gasVal);
  if (Firebase.RTDB.setFloat(&fbdo, "/sensors/temp", temp)) {
  Serial.println("Temp updated");
} else {
  Serial.println("Error: " + fbdo.errorReason());
}

  Firebase.RTDB.setFloat(&fbdo, "/sensors/light", lightVal);
  if (Firebase.RTDB.setFloat(&fbdo, "/sensors/temp", temp)) {
  Serial.println("Temp updated");
} else {
  Serial.println("Error: " + fbdo.errorReason());
}

// ---- Read Water Level from Board2 ----
if (Firebase.RTDB.getInt(&fbdo, "/sensors/waterLevel")) {
  waterVal = fbdo.intData();
} else {
  waterVal = -1; // Error reading
  Serial.println("Water read error: " + fbdo.errorReason());
}



  // ---- Read Control Settings from Firebase ----
  if (Firebase.RTDB.getBool(&fbdo, "/control/autoMode")) autoMode = fbdo.boolData();
  if (Firebase.RTDB.getBool(&fbdo, "/control/fanOn")) fanOn = fbdo.boolData();
  if (Firebase.RTDB.getBool(&fbdo, "/control/bulbOn")) bulbOn = fbdo.boolData();
  if (Firebase.RTDB.getInt(&fbdo, "/control/tempThreshold")) tempThreshold = fbdo.intData();
  if (Firebase.RTDB.getInt(&fbdo, "/control/lightThreshold")) lightThreshold = fbdo.intData();
  if (Firebase.RTDB.getInt(&fbdo, "/control/gasThreshold")) gasThreshold = fbdo.intData();

  // ---- Automatic Control Logic ----
  if (autoMode) {
    if (temp > tempThreshold)
      digitalWrite(RELAY_FAN, LOW);
    else
      digitalWrite(RELAY_FAN, HIGH);

    if (lightVal < lightThreshold)
      digitalWrite(RELAY_BULB, LOW);
    else
      digitalWrite(RELAY_BULB, HIGH);
  } else {
    digitalWrite(RELAY_FAN, fanOn ? LOW : HIGH);
    digitalWrite(RELAY_BULB, bulbOn ? LOW : HIGH);
    
  }

  // ---- Buzzer Alerts ----
  if (gasVal > gasThreshold || waterVal == 1) {
    digitalWrite(BUZZER, HIGH);
    Firebase.RTDB.setBool(&fbdo, "/alerts/buzzer", true);
  } else {
    digitalWrite(BUZZER, LOW);
    Firebase.RTDB.setBool(&fbdo, "/alerts/buzzer", false);
  }

  // ---- OLED Display Update ----
  display.clearDisplay();
  display.setCursor(0, 0);
  display.print("Temp: "); display.print(temp); display.println(" C");
  display.print("Hum : "); display.print(hum); display.println(" %");
  display.print("Soil: "); display.println(soilVal);
  display.print("Gas : "); display.println(gasVal);
  display.print("Light: "); display.print(lightVal); display.println(" lx");
  display.print("Water: ");
  if (waterVal == 1) {
    display.println("HIGH");
}
  else if (waterVal == 0) {   // <-- parentheses added
    display.println("LOW");
}
  else {
    display.println("ERR");
}

  display.display();
  delay(2000);
}
