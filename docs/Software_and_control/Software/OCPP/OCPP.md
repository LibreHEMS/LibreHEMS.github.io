---
title: OCPP
parent: Software
layout: minimal
---

# OCPP

<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

## User Guide: Integrating OCPP EV Chargers with EMHASS for Home Assistant

This guide explains how to connect OCPP-compatible EV chargers to EMHASS for smart charging and vehicle-to-grid (V2G) optimization. Learn to automate charging schedules, align EV usage with solar production, and reduce energy costs using EMHASS’s predictive algorithms.

---

### **1. Prerequisites**

- **Hardware**:
    - OCPP 1.6J/2.0.1-compatible EV charger (e.g., Wallbox, Zappi, ABB Terra).
    - EV supporting bidirectional charging (V2G) if applicable (e.g., Nissan Leaf, Ford F-150 Lightning).
- **Software**:
    - Home Assistant (OS/Supervised recommended).
    - [OCPP Integration](https://github.com/lbbrhzn/ocpp) via HACS.
    - EMHASS add-on installed and configured for solar/battery optimization.

---

### **2. OCPP Integration Setup**

#### **A. Install and Configure OCPP**

1. **Install via HACS**:
    - Add `https://github.com/lbbrhzn/ocpp` to HACS repositories.
    - Install the **OCPP** integration and restart Home Assistant.
2. **Add Central System**:
    - Go to **Settings > Devices \& Services > Add Integration > OCPP**.
    - Set **Host** to `0.0.0.0` and **Port** to `9000`.
    - Note the WebSocket URL (e.g., `ws://192.168.1.100:9000`).
3. **Connect Your Charger**:
    - Configure the charger’s OCPP Central System URL to match the WebSocket URL.
    - Key entities will auto-populate:
        - Charger status: `sensor.charger_status`
        - Charging power: `sensor.charger_power`
        - Control switch: `switch.charger_charge_control`

---

### **3. EMHASS Configuration for OCPP Chargers**

#### **A. Define Charger as a Deferrable Load**

In EMHASS’s `config.json` or web UI:

```json  
{  
  "deferrable_loads": {  
    "ev_charger": {  
      "entity_id": "switch.charger_charge_control",  
      "max_power": 11000,  // Charger’s max power (Watts)  
      "soc_entity": "sensor.ev_battery_soc",  // Required for V2G  
      "soc_min": 20,       // Minimum battery % for discharge  
      "soc_max": 80        // Maximum battery % for charging  
    }  
  }  
}  
```


#### **B. For V2G (Bidirectional Charging)**

Add the EV as a battery asset in EMHASS:

```json  
{  
  "batteries": [  
    {  
      "name": "ev_battery",  
      "sensor_power": "sensor.charger_power",  // Negative = discharging  
      "sensor_soc": "sensor.ev_battery_soc",  
      "capacity_kwh": 40,  
      "max_discharge_rate": 5000  // 5kW max discharge  
    }  
  ]  
}  
```


---

### **4. Automating with EMHASS and OCPP**

#### **A. Daily Optimization Workflow**

1. **Run EMHASS Optimization**:
    - EMHASS calculates charging/discharging schedules using solar forecasts and tariffs.
2. **Apply Schedule via OCPP TxProfile**:

```yaml  
automation:  
  - alias: "Set Daily Charging Schedule"  
    trigger:  
      - platform: time  
        at: "04:00:00"  // Run before peak solar  
    action:  
      - service: rest_command.emhass_optimize  
      - delay: "00:05:00"  
      - service: ocpp.set_tx_profile  
        data:  
          charger_id: "EVSE1"  
          tx_profile:  
            schedule:  
              - start_period: "2025-06-10T10:00:00Z"  
                limit: 11000  // Charge at 11kW during solar surplus  
              - start_period: "2025-06-10T17:00:00Z"  
                limit: -5000  // Discharge 5kW during peak tariff  
```


#### **B. Solar-Powered Charging Automation**

```yaml  
automation:  
  - alias: "Charge Only on Solar Surplus"  
    trigger:  
      - platform: numeric_state  
        entity_id: sensor.pv_power  
        above: >  
          {{ states("sensor.house_load") | float + 1000 }}  // 1kW surplus  
    action:  
      - service: switch.turn_on  
        target:  
          entity_id: switch.charger_charge_control  
```


---

### **5. Key Entities and Services**

| **Function** | **Home Assistant Entity/Service** | **EMHASS Parameter** |
| :-- | :-- | :-- |
| Charger Control | `switch.charger_charge_control` | `deferrable_loads.ev_charger` |
| Charger Power | `sensor.charger_power` | Used in automations |
| EV Battery SOC | `sensor.ev_battery_soc` | `batteries.ev_battery.sensor_soc` |
| Set Schedule | `service: ocpp.set_tx_profile` | Linked to EMHASS outputs |


---

### **6. Troubleshooting**

- **Charger Not Responding**:
    - Check firewall rules for port `9000`.
    - Verify the charger’s OCPP URL matches the Home Assistant WebSocket address.
- **Incorrect Charging Power**:
    - Confirm `max_power` in EMHASS matches the charger’s rating.
    - Check `sensor.charger_power` unit (Watts vs. kilowatts).
- **V2G Not Working**:
    - Ensure the charger and EV support bidirectional charging.
    - Validate `sensor.charger_power` shows negative values during discharge.

---

### **7. Resources**

- **OCPP Integration Docs**: [home-assistant-ocpp.readthedocs.io](https://home-assistant-ocpp.readthedocs.io)
- **EMHASS Configuration**: [emhass.readthedocs.io](https://emhass.readthedocs.io)
- **OCPP 2.0.1 Specification**: [openchargealliance.org](https://www.openchargealliance.org)

By integrating OCPP with EMHASS, you unlock precise control over EV charging, turning your vehicle into a dynamic asset for solar optimization, grid cost reduction, and energy resilience.

