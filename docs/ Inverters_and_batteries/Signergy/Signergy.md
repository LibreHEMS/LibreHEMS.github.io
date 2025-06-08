---
title: Signergy
parent: Inverters and Batteries
layout: minimal
---

# Signergy 

<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

## User Guide: Integrating Sigenergy Solar, Battery, and EV Chargers with EMHASS for Home Assistant

This updated guide uses the comprehensive [Sigenergy-Local-Modbus integration](https://github.com/TypQxQ/Sigenergy-Local-Modbus) for Home Assistant, enabling local monitoring and control of Sigenergy systems. Below are setup instructions for solar PV, battery storage, DC/AC EV chargers, and EMHASS optimization.

---

### **1. Integration Setup via Sigenergy-Local-Modbus**

#### **A. Installation (HACS)**

1. **Add the Integration Repository**
    - In Home Assistant, go to **HACS > Integrations**.
    - Click **⋮ > Custom Repositories** and add:

```
https://github.com/TypQxQ/Sigenergy-Local-Modbus
```

    - Install the **Sigenergy ESS Integration**.
2. **Configure Modbus-TCP**
    - Ensure your Sigenergy inverter has Modbus-TCP enabled (ask your installer).
    - Assign a **static IP** to the Sigenergy device on your network.
3. **Auto-Discovery**
    - Restart Home Assistant. The integration should auto-discover your Sigenergy system under **Settings > Devices \& Services > Discovered**.
    - If not found, add it manually:
        - Go to **Add Integration > Sigenergy**.
        - Enter the device IP, port (default: `502`), and first Device ID (usually `1`).

---

### **2. Solar PV Integration**

**A. Key Sensors**
The integration auto-creates these entities:

- PV Power: `sensor.plant_pv_power`
- PV Strings: `sensor.inverter_pv_string_1_power`, etc.

**B. EMHASS Configuration**

- In EMHASS’s `config.json` or web UI:

```json
{
  "sensor_power_photovoltaics": "sensor.plant_pv_power",
  "sensor_power_load_no_var_loads": "sensor.plant_load_power"
}
```


---

### **3. Battery Integration**

**A. Key Sensors**

- Battery Power: `sensor.inverter_battery_power` (negative when charging)
- Battery SOC: `sensor.inverter_battery_soc`

**B. EMHASS Configuration**

- Enable battery optimization:

```json
{
  "sensor_battery_power": "sensor.inverter_battery_power",
  "sensor_battery_soc": "sensor.inverter_battery_soc",
  "battery_capacity_kwh": 48  // Adjust for your system
}
```


---

### **4. DC EV Bidirectional Charger (25kW V2X)**

**A. Home Assistant Setup**

- The integration exposes:
    - Charger Power: `sensor.dc_charger_power`
    - Charger Status: `sensor.dc_charger_status`

**B. EMHASS Configuration**

- Treat the charger as a secondary battery:

```json
{
  "sensor_ev_battery_power": "sensor.dc_charger_power",
  "sensor_ev_soc": "sensor.ev_soc"  // Requires EV SOC sensor
}
```


---

### **5. AC EV Charger (7-22kW)**

**A. Home Assistant Setup**

- Key entities:
    - Charger Power: `sensor.ac_charger_power`
    - Charger Mode: `select.ac_charger_work_mode`

**B. EMHASS Configuration**

- Add as a deferrable load:

```json
{
  "deferrable_loads": {
    "ev_charger": {
      "entity_id": "switch.ac_charger_control",
      "max_power": 22000  // 22kW
    }
  }
}
```


---

### **6. Automation Example**

**Optimize Charging Based on Solar Forecast**

```yaml
alias: "EV Charging Schedule"
trigger:
  - platform: time
    at: "04:00:00"  # Run after EMHASS optimization
action:
  - service: input_number.set_value
    target:
      entity_id: input_number.evac_charge_limit
    data:
      value: "{{ state_attr('sensor.emhass_optim', 'ev_charge_power') }}"
```


---

## **Troubleshooting**

- **Modbus Not Detected:**
Confirm Modbus-TCP is enabled on the Sigenergy device and the IP is static.
- **Entity Mismatches:**
Verify sensor names in **Developer Tools > States**.
- **Control Limitations:**
Enable write access in the integration’s configuration options.

---

## **Summary Table: Key Entities**

| Component | Home Assistant Entity | EMHASS Parameter |
| :-- | :-- | :-- |
| Solar PV | `sensor.plant_pv_power` | `sensor_power_photovoltaics` |
| Battery | `sensor.inverter_battery_power` | `sensor_battery_power` |
| DC EV Charger | `sensor.dc_charger_power` | `sensor_ev_battery_power` |
| AC EV Charger | `switch.ac_charger_control` | `deferrable_loads.ev_charger` |


---

For advanced configurations, refer to the [Sigenergy-Local-Modbus documentation](https://github.com/TypQxQ/Sigenergy-Local-Modbus). This integration provides the most reliable local control for optimizing Sigenergy systems with EMHASS.

<div style="text-align: center">⁂</div>

[^1]: Sigenergy-Local-Modbus

[^2]: https://github.com/seud0nym/sigenergy2mqtt

[^3]: https://gist.github.com/fbradyirl/08fef90bd11d7bdddf588a56e668d879

[^4]: https://community.home-assistant.io/t/sig-energy-system-integration/760448

[^5]: https://community.home-assistant.io/t/sigenergy-hybrid-inverter-integration/770528

[^6]: https://github.com/typqxq

[^7]: https://forums.whirlpool.net.au/thread/374p81k1?p=95

[^8]: https://github.com/evcc-io/evcc/discussions/16246

[^9]: https://github.com/topics/modbus?o=desc\&s=updated

