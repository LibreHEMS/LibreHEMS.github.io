---
title: Sungrow
parent: Inverters and Batteries
layout: minimal
---

# Sungrow

## User Guide: Integrating Sungrow Solar PV and Battery with EMHASS for Home Assistant

This guide explains how to connect your Sungrow inverter and battery system to Home Assistant, and how to set up the EMHASS add-on for advanced energy management. It covers both solar PV and battery integration, using the most reliable community-supported methods.

---

### **1. Sungrow Integration with Home Assistant**

Sungrow does not have an official Home Assistant integration, but several community solutions exist. The most common approaches use Modbus, MQTT, or the iSolarCloud API, depending on your inverter model and network setup.

**Recommended Integrations:**

- **Modbus TCP:** For many Sungrow inverters (e.g., SHx series).
- **Winet-S Dongle (Websocket API):** For newer inverters with a Winet-S dongle.
- **iSolarCloud API:** For cloud-based access.

**Popular Community Projects:**

- [Sungrow-SHx-Inverter-Modbus-Home-Assistant (MK Kaiser)](https://github.com/mkaiser/Sungrow-SHx-Inverter-Modbus-Home-Assistant) – For SHx series via Modbus[^1][^2][^6].
- [ModbusTCP2MQTT](https://github.com/MatterVN/ModbusTCP2MQTT) – Converts Modbus data to MQTT for Home Assistant[^1][^6].
- [GoSungrow](https://github.com/MickMake/GoSungrow) – iSolarCloud API access[^1][^6].
- [Winet-S Integration](https://community.home-assistant.io/t/sungrow-winet-s-addon-for-newer-inverters/732565) – For inverters with a Winet-S dongle, sends metrics via MQTT[^5].

**Setup Steps:**

1. **Choose the integration that matches your inverter and network setup.**
2. **Follow the instructions in the selected project’s README to install and configure.**
3. **Verify that Home Assistant receives the following sensor entities:**
    - Solar PV power (e.g., `sensor.sungrow_pv_power`)
    - Battery power (e.g., `sensor.sungrow_battery_power`)
    - Battery state of charge (SOC) (e.g., `sensor.sungrow_battery_soc`)
    - Grid import/export power (optional)

---

## **2. Solar PV Integration with EMHASS**

**A. Identify Your Solar PV Sensor**

- After integration, locate the Home Assistant entity showing your Sungrow inverter’s PV output (e.g., `sensor.sungrow_pv_power`).

**B. Configure EMHASS for Solar PV**

- In the EMHASS configuration (via the add-on web interface or `config.json`), set the solar PV sensor parameter:

```json
{
  "sensor_power_photovoltaics": "sensor.sungrow_pv_power"
}
```

- Also set your main household load sensor (excluding deferrable loads):

```json
{
  "sensor_power_load_no_var_loads": "sensor.house_load"
}
```


**C. Test and Monitor**

- Use the EMHASS web interface to run a day-ahead optimization.
- Check that PV forecasts and actuals are displayed and used in the optimization.

---

## **3. Battery Integration with EMHASS**

**A. Identify Battery Sensors**

- Ensure your Sungrow integration provides battery power and SOC entities (e.g., `sensor.sungrow_battery_power`, `sensor.sungrow_battery_soc`)[^2][^4].
- If not, check your integration’s documentation or consider switching to a different method (e.g., ModbusTCP2MQTT or Winet-S).

**B. Configure EMHASS for Battery**

- In the EMHASS configuration, add the battery parameters:

```json
{
  "sensor_battery_power": "sensor.sungrow_battery_power",
  "sensor_battery_soc": "sensor.sungrow_battery_soc",
  "battery_capacity_kwh": 9.6  // Replace with your actual battery size
}
```

- Set battery operational parameters (charge/discharge limits, reserves) as needed[^4].

**C. Enable Battery Optimization**

- EMHASS will now optimize when to charge/discharge your battery based on forecasts, tariffs, and your usage patterns.
- You can set backup reserves and schedules to ensure power is available during peak periods[^4].

---

## **4. Tips and Troubleshooting**

- **Data Update Frequency:** Some integrations (like Winet-S) update every 10 seconds[^5]. For Modbus, update rates may be slower.
- **Cloud vs. Local:** Local integrations (Modbus, Winet-S) are more reliable and responsive than cloud-based (iSolarCloud).
- **Automation:** Use EMHASS outputs in Home Assistant automations to control loads, battery, and more.
- **Dashboards:** Consider using Grafana or Home Assistant dashboards to visualize PV, battery, and grid data[^4].

---

## **Summary Table: Key Configuration Entities**

| Function | Home Assistant Entity Example | EMHASS Config Parameter |
| :-- | :-- | :-- |
| Solar PV Power | `sensor.sungrow_pv_power` | `sensor_power_photovoltaics` |
| Main Load | `sensor.house_load` | `sensor_power_load_no_var_loads` |
| Battery Power | `sensor.sungrow_battery_power` | `sensor_battery_power` |
| Battery SOC | `sensor.sungrow_battery_soc` | `sensor_battery_soc` |


---

By following this guide, you can connect your Sungrow solar and battery system to Home Assistant and use EMHASS to optimize your energy usage, maximize self-consumption, and automate your home’s energy management[^1][^2][^4][^5][^6].

<div style="text-align: center">⁂</div>

[^1]: https://www.reddit.com/r/homeassistant/comments/1c3r72b/sungrow_solar_setup/

[^2]: https://community.home-assistant.io/t/support-for-modbus-sungrow-with-notficication-battery-level/720833

[^3]: https://github.com/amberelectric/public-api/discussions/207

[^4]: https://github.com/saltpool/localvolts-sungrow-homeassistant

[^5]: https://community.home-assistant.io/t/sungrow-winet-s-addon-for-newer-inverters/732565

[^6]: https://community.home-assistant.io/t/home-assistant-community-add-on-isolarcloud-sungrow/411602?page=2

[^7]: https://community.home-assistant.io/t/home-assistant-community-add-on-isolarcloud-sungrow/411602

[^8]: https://github.com/mkaiser/Sungrow-SHx-Inverter-Modbus-Home-Assistant

[^9]: https://www.smartmotion.life/product/solar-and-battery-controller/

[^10]: https://sungather.net

