---
title: Deye Sunsynk
parent: Inverters and Batteries
layout: minimal
---

# Deye Sunsynk

<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

## User Guide: Integrating Deye Inverters with EMHASS for Home Assistant

This guide outlines how to integrate your Deye hybrid inverter (including solar PV, battery, and optional EV charger support) with Home Assistant using robust, local solutions. It then explains how to connect these sensors to the EMHASS add-on for advanced energy management and automation.

---

### **1. Integration Methods for Deye Inverters**

Deye inverters can be connected to Home Assistant using several local, privacy-friendly methods:

#### **A. Modbus TCP (Recommended for Most Users)**

- **Enable Modbus TCP on Your Inverter:**
    - Access your inverter’s web interface (find the IP via your router or a network scanner).
    - Log in (default: admin/admin).
    - Go to the advanced config page (`http://<inverter_ip>/config_hide.html`).
    - Set protocol to **TCP-Server**, port to **8899**, and enter your Home Assistant server’s IP. Save and reboot the inverter if needed[^7].
- **Configure Home Assistant:**
    - Use the [Imanol82/Modbus-TCP-for-Deye-Inverter](https://github.com/Imanol82/Modbus-TCP-for-Deye-Inverter) project for a ready-to-use configuration[^2].
        - Download the `modbus.yaml` and `template.yaml` files from the repository.
        - Place them in your Home Assistant config directory.
        - In `configuration.yaml`, add:

```yaml
modbus: !include modbus.yaml
template: !include template.yaml
```

        - Restart Home Assistant.
        - You should now see Deye inverter sensors (PV, battery, grid, etc.) in Developer Tools[^2].


#### **B. Modbus RTU (RS485)**

- For setups where TCP is unavailable, use an RS485-to-Ethernet or RS485-to-USB adapter[^4].
- Wire the RS485 lines from the inverter’s RJ45 port (see inverter manual for pinout) to the adapter.
- Configure the adapter’s parameters (baud rate usually 9600).
- Set up Home Assistant’s Modbus integration accordingly.


#### **C. ESPHome Integration**

- Use an ESP32 with a TTL-to-RS485 module and the [klatremis/esphome-for-deye](https://github.com/klatremis/esphome-for-deye) configuration for three-phase inverters[^6].
- This method provides real-time data and can be customized for your needs.


#### **D. Sunsynk/Deye Add-on**

- The [Sunsynk Add-on](https://github.com/kellerza/sunsynk) works for Deye-branded inverters via RS485 and MQTT, supporting extensive sensor coverage and control[^8][^9].

---

### **2. Solar PV Integration**

- **Key Sensor:**
    - `sensor.pv_power` or similar (actual name may vary by integration).
- **EMHASS Configuration:**

```json
{
  "sensor_power_photovoltaics": "sensor.pv_power"
}
```

- **Energy Dashboard:**
    - Add your PV sensor to Home Assistant’s Energy dashboard for visualization and tracking[^3].

---

### **3. Battery Integration**

- **Key Sensors:**
    - Battery Power: `sensor.battery_power`
    - State of Charge: `sensor.battery_soc`
- **EMHASS Configuration:**

```json
{
  "sensor_battery_power": "sensor.battery_power",
  "sensor_battery_soc": "sensor.battery_soc",
  "battery_capacity_kwh": 10  // Replace with your actual battery size
}
```

- **Energy Dashboard:**
    - Add battery charge/discharge sensors for full tracking[^3].

---

### **4. EV Charger Integration (If Available)**

- Some Deye inverters and third-party solutions allow EV charger integration via Modbus or MQTT.
- **Key Sensors:**
    - EV Charger Power: `sensor.ev_charger_power`
    - Charger Status: `sensor.ev_charger_status`
- **EMHASS Configuration Example:**

```json
{
  "deferrable_loads": {
    "ev_charger": {
      "entity_id": "switch.ev_charger",
      "max_power": 7000  // Example for 7kW charger
    }
  }
}
```


---

### **5. Troubleshooting and Tips**

- **Incorrect Values:**
    - If you see implausible sensor values (e.g., -100°C), check your Modbus register mapping and update to the latest YAML/templates[^1][^2].
- **Port Issues:**
    - For Modbus TCP, ensure port **8899** is open and correctly set on both inverter and Home Assistant[^7].
- **Cloud API:**
    - Deye is developing a cloud API, but local integration is faster and more reliable[^5].
- **Sensor Names:**
    - Sensor names may differ based on your integration method. Use Home Assistant’s Developer Tools to confirm actual entity IDs.

---

### **6. Summary Table: Key Entities**

| Function | Home Assistant Entity Example | EMHASS Config Parameter |
| :-- | :-- | :-- |
| Solar PV Power | `sensor.pv_power` | `sensor_power_photovoltaics` |
| Main Load | `sensor.load_power` | `sensor_power_load_no_var_loads` |
| Battery Power | `sensor.battery_power` | `sensor_battery_power` |
| Battery SOC | `sensor.battery_soc` | `sensor_battery_soc` |
| EV Charger | `switch.ev_charger` | `deferrable_loads.ev_charger` |


---

By following this guide, you can achieve reliable, local, and private integration of your Deye inverter with Home Assistant and EMHASS, enabling advanced automation and energy optimization for your solar, battery, and EV systems.

<div style="text-align: center">⁂</div>

[^1]: https://community.home-assistant.io/t/solarman-deye-inverter-integration/654848

[^2]: https://github.com/Imanol82/Modbus-TCP-for-Deye-Inverter

[^3]: https://kellerza.github.io/sunsynk/guide/energy-management

[^4]: https://www.enjoyelec.net/deye-inverter-setup-modbusrtu/

[^5]: https://community.home-assistant.io/t/deye-cloud-integration/813153

[^6]: https://github.com/klatremis/esphome-for-deye

[^7]: https://support.sourceful.energy/article/34-activate-modbus-tcp-deye

[^8]: https://github.com/kellerza/sunsynk

[^9]: https://www.youtube.com/watch?v=IktkBl3inTA

[^10]: https://community.home-assistant.io/t/deye-sunsynk-inverter-integration-add-on/544048

[^11]: https://github.com/StephanJoubert/home_assistant_solarman/issues/504

[^12]: https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126?page=124

[^13]: https://diysolarforum.com/threads/help-me-choose-ev-charger-that-can-work-with-my-deye-12kw-hybrid-solar-inverter.86582/

[^14]: https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126?page=33

[^15]: https://emhass.readthedocs.io/en/stable/intro.html

[^16]: https://www.youtube.com/watch?v=Cqktgvu0ob0

[^17]: https://powerforum.co.za/topic/31478-esp32-integration-from-deye-inverter-to-home-assistant/

[^18]: https://solarlinkaustralia.com.au/the-deye-off-grid-inverter-and-battery-storage-solution-a-smart-choice-for-energy-independence/

[^19]: https://v2charge.com/support/power-control/dynamic/photovoltaic/turbo-energy-deye-inverter/

