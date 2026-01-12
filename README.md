# Smart-Greenhouse-Monitoring-Control-System
The AgroGuard system is an open-source, ESP32 based solution designed for precision agriculture  and automated greenhouse management. It  integrates multiple environmental sensors with a  dual-channel relay board, allowing for real-time  monitoring and automated control of irrigation  and ventilation systems. this is product design product.


## 📖 Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Hardware Components](#hardware-components)
- [Monitored Parameters](#monitored-parameters)
- [Operating Modes](#operating-modes)
- [Mobile Application](#mobile-application)
- [Safety & Maintenance](#safety--maintenance)


---

## 🚀 Overview
AgroGuard allows users to monitor critical environmental data and control greenhouse equipment remotely via a mobile application. It ensures optimal growing conditions by automatically managing water pumps, fans, and grow lights based on sensor feedback.

## ✨ Key Features
* **Wireless Connectivity:** Integrated Wi-Fi module for seamless cloud integration and remote access.
* **Real-Time Monitoring:** Continuous tracking of temperature, humidity, soil moisture, light, gas levels, and water tank levels.
* **Dual Control Modes:** Supports both **Auto** (Sensor-based) and **Manual** (App-based) control.
* **Smart Alerts:** Instant notifications via Mobile App and Buzzer for critical events (e.g., Low water, Gas leak).
* **Power Control:** Onboard 5V relays to switch AC/DC loads like pumps and fans.
* **Mobile app** controll all equipments.

---

## 🛠 Hardware Components
The system is built using the following components:

* **Main Controller:** ESP32 Development Board
* **Sensors:**
    * Temperature & Humidity Sensor (e.g., DHT11/DHT22)
    * Soil Moisture Sensor
    * Light Intensity Sensor (LDR/BH1750)
    * Gas Sensor (e.g., MQ Series)
    * Water Level Monitoring Circuit
* **Actuators:**
    * 2-Channel 5V Relay Module
    * Buzzer (for local alarms)
* **Power Supply:** Recommended DC source for ESP32 and Relays.

---

## 📊 Monitored Parameters
All data is visualized in real-time on the AgroGuard mobile app:

| Parameter | Unit | Description |
| :--- | :---: | :--- |
| **Temperature** | °C | Ambient air temperature |
| **Humidity** | % | Relative air humidity |
| **Soil Moisture** | % | Moisture content in the soil |
| **Light Intensity** | - | Current light levels |
| **Gas Concentration** | - | Detection of harmful gases/smoke |
| **Water Tank Level** | % | Water availability in the reservoir |

---

## ⚙️ Operating Modes

### 1. Auto Mode 🤖
In this mode, AgroGuard automatically makes decisions based on preset thresholds:
* **Irrigation:** If `Soil Moisture < Threshold` → **Pump ON** 💧
* **Ventilation:** If `Temperature > Threshold` → **Fan ON** ❄️
* **Lighting:** If `Light Intensity < Threshold` → **Grow Light ON** 💡

### 2. Manual Mode 📱
Users can override automation and manually toggle devices (Pumps, Fans, Lights) using the Android/iOS mobile application.

---

## 🚨 Alerts & Notifications
The system ensures safety by generating alerts for:
* ⚠️ **Low Water Tank Level**
* ⚠️ **High Gas Concentration**
* ⚠️ **Abnormal Temperature or Humidity**

*Alerts are delivered via **Mobile Push Notifications** and a local **Buzzer**.*

---

## 🛡 Safety & Maintenance

### Safety Instructions
* ❌ **Do not** expose the main controller PCB to water.
* 🔌 Always disconnect power before performing maintenance.
* ⚡ Use only recommended power supplies.
* 🔒 Ensure all sensor connections are secure.

### Maintenance
* Clean sensors periodically to ensure accuracy.
* Inspect wiring connections regularly.
* Ensure stable Wi-Fi connectivity for remote monitoring.

---

## 📝 License
This project is open-source. Feel free to contribute or modify it for your needs.

---
*Created for the AgroGuard Project (Version 1.0)*
