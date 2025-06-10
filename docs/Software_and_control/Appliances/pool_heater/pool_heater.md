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
    - Wire the pool heater's power control to a smart relay (e.g., Shelly 1).
    - Integrate the relay with Home Assistant (e.g., via Shelly's official integration or MQTT).
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

In EMHASS's `config.json` or web UI:

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


#### **B. EMHASS Sensor Generation**

Once configured, EMHASS will generate optimization sensors for your deferrable loads[^3][^4]:

- `sensor.p_deferrable0` - Power allocation for first deferrable load
- `sensor.p_deferrable1` - Power allocation for second deferrable load (pool heater)
- Values represent power in watts allocated to each load at the current time step

---

### **4. Pool Heat Pump Automation**

This automation controls your pool heat pump based on EMHASS optimization results. It uses the `sensor.p_deferrable1` entity to determine when the heat pump should operate.

#### **A. Complete Automation Code**

```yaml
alias: p_deferrable1 automation (Pool Heat Pump)
description: Pool Heat Pump
triggers:
  - entity_id:
      - sensor.p_deferrable1
    below: 100
    for:
      hours: 0
      minutes: 0
      seconds: 0
    trigger: numeric_state
  - entity_id:
      - sensor.p_deferrable1
    for:
      hours: 0
      minutes: 5
      seconds: 0
    above: 100
    id: above
    trigger: numeric_state
    enabled: true
conditions: []
actions:
  - choose:
      - conditions:
          - condition: trigger
            id:
              - above
        sequence:
          - type: turn_on
            device_id: 03a766ec3275e2c80020c5f5a3d8e603
            entity_id: b7f0627d5ad30682167f4f358843c8d3
            domain: switch
    default:
      - type: turn_off
        device_id: b3b025341171b91f30d49135315dad53
        entity_id: 90ee5ad67de0cda2edac93b903064b13
        domain: switch
mode: single
```


#### **B. Automation Step-by-Step Breakdown**

**Triggers:**

1. **Low Power Trigger**: Activates immediately when `sensor.p_deferrable1` drops below 100 watts
2. **High Power Trigger**: Activates when `sensor.p_deferrable1` stays above 100 watts for 5 minutes (prevents short cycling)

**Actions:**

1. **Conditional Choice**: Uses the `choose` action to determine which device to control
2. **Heat Pump ON**: If triggered by the "above" condition, turns on the Pool Heater Pump
3. **Socket OFF**: If triggered by any other condition (below 100W), turns off Socket 1 as the default action

**Key Features:**

- **Hysteresis**: 5-minute delay prevents rapid on/off cycling when power allocation fluctuates around 100W
- **Single Mode**: Prevents multiple instances running simultaneously
- **Immediate Response**: Turns off devices immediately when power drops below threshold


#### **C. Customizing for Your Setup**

Replace the device and entity IDs with your actual devices:

```yaml
# Replace these with your actual entity IDs
entity_id: switch.pool_heat_pump    # Your heat pump switch
entity_id: switch.pool_auxiliary    # Your auxiliary device (if any)
```


#### **D. Setting the Power Threshold**

The 100-watt threshold can be adjusted based on your setup:

- **Higher threshold (200-500W)**: More conservative, ensures adequate power before turning on
- **Lower threshold (50-100W)**: More aggressive, utilizes smaller power allocations
- **Consider your heat pump's minimum power requirements**

---

### **5. Advanced Configuration Options**

#### **A. Multiple Device Control**

For complex pool systems with multiple components:

```yaml
actions:
  - choose:
      - conditions:
          - condition: trigger
            id: above
          - condition: numeric_state
            entity_id: sensor.p_deferrable1
            above: 500  # Additional power check
        sequence:
          - service: switch.turn_on
            target:
              entity_id: 
                - switch.pool_heat_pump
                - switch.pool_circulation_pump
      - conditions:
          - condition: trigger
            id: above
          - condition: numeric_state
            entity_id: sensor.p_deferrable1
            above: 100
            below: 500
        sequence:
          - service: switch.turn_on
            target:
              entity_id: switch.pool_heat_pump
    default:
      - service: switch.turn_off
        target:
          entity_id:
            - switch.pool_heat_pump
            - switch.pool_circulation_pump
```


#### **B. Temperature-Based Override**

Add temperature conditions to prevent unnecessary heating:

```yaml
conditions:
  - condition: numeric_state
    entity_id: sensor.pool_temperature
    below: 26  # Don't heat if already at target temperature
```


#### **C. Time-Based Restrictions**

Limit operation to specific hours:

```yaml
conditions:
  - condition: time
    after: "06:00:00"
    before: "22:00:00"
```


---

### **6. Monitoring and Troubleshooting**

#### **A. Key Entities to Monitor**

- `sensor.p_deferrable1` - Current power allocation from EMHASS
- `switch.pool_heat_pump` - Heat pump status
- `sensor.pool_heat_pump_power` - Actual power consumption
- `automation.p_deferrable1_automation` - Automation status


#### **B. Common Issues**

**Heat Pump Not Turning On:**

- Check if `sensor.p_deferrable1` is above 100 for the required duration
- Verify EMHASS optimization is running and updating the sensor
- Ensure device IDs and entity IDs are correct

**Frequent On/Off Cycling:**

- Increase the 5-minute delay in the trigger
- Adjust the power threshold to create more hysteresis
- Check EMHASS time step configuration (should be 30+ minutes)[^3]

**EMHASS Sensor Not Updating:**

- Verify EMHASS add-on is running and configured correctly
- Check that the deferrable load is properly defined in EMHASS config
- Ensure optimization is being published to Home Assistant sensors


#### **C. Performance Monitoring**

Track automation performance with template sensors:

```yaml
template:
  - sensor:
      - name: "Pool Heat Pump Daily Runtime"
        state: >
          {% set start = now().replace(hour=0, minute=0, second=0, microsecond=0) %}
          {{ ((as_timestamp(now()) - as_timestamp(start)) / 3600) | round(1) if is_state('switch.pool_heat_pump', 'on') else 0 }}
        unit_of_measurement: "hours"
```


---

### **7. Integration with Other Systems**

#### **A. Weather-Based Adjustments**

Modify power thresholds based on weather conditions:

```yaml
# In automation conditions
- condition: template
  value_template: >
    {% if states('weather.home') == 'sunny' %}
      {{ states('sensor.p_deferrable1') | float > 50 }}
    {% else %}
      {{ states('sensor.p_deferrable1') | float > 150 }}
    {% endif %}
```


#### **B. Pool Pump Dependency**

Ensure the heat pump only runs when the circulation pump is active[^2][^6]:

```yaml
conditions:
  - condition: state
    entity_id: switch.pool_circulation_pump
    state: 'on'
```


---

### **8. Resources**

- [EMHASS Documentation](https://emhass.readthedocs.io)
- [EMHASS GitHub Repository](https://github.com/davidusb-geek/emhass)
- [Home Assistant Automation Documentation](https://www.home-assistant.io/docs/automation/)
- [Pool Automation Community Examples](https://community.home-assistant.io/t/using-excess-solar-power-to-heat-swimming-pool/471158)

By implementing this EMHASS-based automation, your pool heat pump will automatically operate during optimal times based on energy costs, solar production, and grid conditions, maximizing efficiency while minimizing operating costs.

<div style="text-align: center">⁂</div>

<div style="text-align: center">⁂</div>

[^1]: image.jpg

[^2]: https://community.home-assistant.io/t/using-excess-solar-power-to-heat-swimming-pool/471158

[^3]: https://github.com/davidusb-geek/emhass

[^4]: https://emhass.readthedocs.io/en/stable/intro.html

[^5]: https://www.reddit.com/r/pools/comments/ukkdd9/pool_automation_with_home_assistant/

[^6]: https://community.home-assistant.io/t/running-devices-when-energy-is-cheaper-and-greener/380011?page=2

[^7]: https://community.home-assistant.io/t/poolsync-pool-heat-pump-integration/682888

[^8]: https://www.youtube.com/watch?v=D1jqYmTeVRg

[^9]: https://github.com/haufes/home-assistant-pool

[^10]: https://www.youtube.com/watch?v=fRtfh1v-T6M

[^11]: https://community.home-assistant.io/t/fully-automated-pump-management-for-water-pool/729960

