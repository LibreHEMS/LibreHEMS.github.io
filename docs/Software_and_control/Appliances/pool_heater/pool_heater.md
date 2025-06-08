---
title: Pool Heater
parent: Appliances
layout: minimal
---

# Pool Heater

<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

## User Guide: Integrating a Pool Heater with EMHASS for Home Assistant

This guide explains how to connect your pool heater to Home Assistant and optimize its energy usage using the EMHASS add-on. Learn to schedule heating during low-cost periods, align operation with solar surplus, and automate temperature control.

---

### **1. Prerequisites**

- **Pool Heater**:
    - Must support on/off control via a relay (e.g., via a smart switch like Shelly, Sonoff, or Tuya).
    - (Optional) Temperature sensor for pool water (e.g., Zigbee/Z-Wave sensor or DIY ESPHome device).
- **Home Assistant**:
    - EMHASS add-on installed ([setup guide](https://emhass.readthedocs.io)).
    - Integration for controlling the heater (e.g., [Shelly](https://www.home-assistant.io/integrations/shelly/), [localTuya](https://github.com/rospogrigio/localtuya)).

---

### **2. Home Assistant Integration**

#### **A. Connect the Pool Heater**

1. **Smart Switch Setup**:
    - Wire the pool heater’s power control to a smart relay (e.g., Shelly 1).
    - Integrate the relay with Home Assistant (e.g., via Shelly’s official integration or MQTT).
    - Entity example: `switch.pool_heater`.
2. **Temperature Monitoring**:
    - Add a temperature sensor (e.g., `sensor.pool_temperature`).
    - For DIY solutions, use an ESP32 with a waterproof DS18B20 probe and ESPHome.

#### **B. Verify Entities**

- Confirm these entities exist in Home Assistant:
    - Heater control: `switch.pool_heater`
    - Power consumption: `sensor.pool_heater_power` (via smart plug or energy monitor).
    - Pool temperature: `sensor.pool_temperature`

---

### **3. EMHASS Configuration**

#### **A. Define Pool Heater as a Deferrable Load**

In EMHASS’s `config.json` or web UI:

```json  
{  
  "deferrable_loads": {  
    "pool_heater": {  
      "entity_id": "switch.pool_heater",  
      "max_power": 4000,          // Heater power in Watts (e.g., 4kW)  
      "def_start_time": "06:00",  // Earliest allowed start time  
      "def_end_time": "22:00",    // Latest allowed end time  
      "def_hours": [3, 12]        // Min/max daily runtime in hours  
    }  
  }  
}  
```

- Adjust `def_hours` seasonally (e.g., `[^3][^9]` in summer, `[^6]` in winter).


#### **B. (Optional) Thermal Model for Temperature Control**

For precise temperature management, use EMHASS’s thermal model:

```json  
{  
  "def_load_config": {  
    "pool_heater": {  
      "thermal_config": {  
        "heating_rate": 2.0,      // Degrees per hour (adjust based on heater capacity)  
        "cooling_constant": 0.05, // Heat loss rate (adjust for pool insulation)  
        "start_temperature": 20,  // Initial pool temperature  
        "desired_temperatures": [22, 22, ..., 22]  // Target temps for each timestep  
      }  
    }  
  }  
}  
```

- Provide `outdoor_temperature_forecast` for accurate heat loss calculations.

---

### **4. Automation Examples**

#### **A. Solar-Powered Heating**

Run the heater only when solar production exceeds household load:

```yaml  
automation:  
  - alias: "Pool Heater on Solar Surplus"  
    trigger:  
      - platform: numeric_state  
        entity_id: sensor.pv_power  
        above: >  
          {{ states("sensor.house_load") | float + 4000 }}  // 4kW surplus  
    action:  
      - service: switch.turn_on  
        target:  
          entity_id: switch.pool_heater  
```


#### **B. Cost Optimization with EMHASS**

1. **Daily Schedule**:
    - EMHASS optimizes heater runtime based on tariffs and solar forecasts.
2. **Publish Schedule**:

```yaml  
rest_command:  
  emhass_optimize:  
    url: "http://localhost:5000/action/dayahead-optim"  
    method: POST  
automation:  
  - alias: "Update Pool Heater Schedule"  
    trigger:  
      - platform: time  
        at: "04:00:00"  
    action:  
      - service: rest_command.emhass_optimize  
```


---

### **5. Advanced: Thermal Model Integration**

- Use the `sensor.temp_predicted0` entity (created by EMHASS) to automate temperature setpoints:

```yaml  
climate:  
  - platform: generic_thermostat  
    name: "Pool Temperature"  
    heater: switch.pool_heater  
    target_sensor: sensor.pool_temperature  
    min_temp: 15  
    max_temp: 35  
    target_temp: "{{ states('sensor.temp_predicted0') | float }}"  
```


---

### **6. Troubleshooting**

- **Heater Not Turning On**:
    - Verify `def_start_time`/`def_end_time` in EMHASS.
    - Check smart relay wiring and entity permissions.
- **Inaccurate Thermal Model**:
    - Adjust `heating_rate` and `cooling_constant` using historical data.
- **High Energy Costs**:
    - Review tariff forecasts and ensure `def_hours` align with off-peak periods.

---

### **7. Resources**

- [EMHASS Documentation](https://emhass.readthedocs.io)
- [Shelly Integration Guide](https://www.home-assistant.io/integrations/shelly/)
- [ESPHome Pool Sensor Example](https://esphome.io/components/sensor/dallas.html)

By integrating your pool heater with EMHASS, you can reduce energy costs, extend swimming seasons, and maintain comfortable water temperatures using solar power and smart scheduling.

<div style="text-align: center">⁂</div>

[^1]: https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126/1020

[^2]: https://emhass.readthedocs.io/en/latest/thermal_model.html

[^3]: https://emhass.readthedocs.io/en/latest/study_case.html

[^4]: https://github.com/davidusb-geek/emhass

[^5]: https://www.reddit.com/r/homeassistant/comments/utczrn/pool_heater_automation_and_control/

[^6]: https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126

[^7]: https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126?page=2

[^8]: https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126/89

[^9]: https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126?page=40

[^10]: https://github.com/siku2/hass-emhass

