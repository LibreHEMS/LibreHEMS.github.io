---
title: Tesla
parent: Inverters and Batteries
layout: default
---

# Tesla

<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

## User Guide: Integrating Tesla Solar and Powerwall with EMHASS for Home Assistant

This guide explains how to connect your Tesla solar panels and Powerwall battery system to Home Assistant, and how to use the EMHASS add-on for advanced energy management. Separate sections cover solar PV and battery integration, including sensor setup and best practices.

---

### **1. Tesla Solar and Powerwall Integration with Home Assistant**

#### **A. Powerwall Integration**

- Home Assistant natively supports Tesla Powerwall via the `powerwall` integration[^1].
- The integration can often be auto-discovered. If not, add it manually:

1. Go to **Settings > Devices \& Services**.
2. Click **Add Integration** and search for "Tesla Powerwall".
3. Follow the on-screen instructions to connect to your Powerwall Gateway[^1].
- The integration provides a wide range of sensors, including:
    - Solar production (`sensor.powerwall_solar_now`)
    - Battery state of charge (`sensor.powerwall_charge`)
    - Battery power (`sensor.powerwall_battery_now`)
    - Site/grid power, load, and more[^1].


#### **B. Tesla Solar-Only Integration**

- If you have Tesla solar panels without a Powerwall, direct integration is more limited.
- The official Tesla integration supports vehicles, not solar panels[^4].
- For some setups, the [Tesla Custom Integration by alandtse](https://github.com/alandtse/tesla) (via HACS) can expose a `sensor.tesla_solar_panel` for solar production[^5].
- This sensor typically reports instantaneous power in Watts. To use it for energy dashboards or EMHASS, convert it to kWh using Home Assistant’s integration platform (see below)[^5].

---

## **2. Solar PV Integration with EMHASS**

**A. Identify Your Solar PV Sensor**

- For Powerwall users: Use `sensor.powerwall_solar_now` (power in kW)[^1].
- For Tesla Custom Integration users: Use `sensor.tesla_solar_panel` (power in W)[^5].
- Convert Watts to kWh using the Riemann sum integration:

```yaml
- platform: integration
  source: sensor.tesla_solar_panel
  name: tesla_solar_production
  unit_prefix: k
  round: 2
```

- Use the resulting `sensor.tesla_solar_production` for energy values in EMHASS[^5].

**B. Configure EMHASS for Solar PV**

- In the EMHASS configuration, set:

```json
{
  "sensor_power_photovoltaics": "sensor.powerwall_solar_now"
}
```

or, for solar-only:

```json
{
  "sensor_power_photovoltaics": "sensor.tesla_solar_production"
}
```

- Also set your main household load sensor, e.g.:

```json
{
  "sensor_power_load_no_var_loads": "sensor.house_load"
}
```


---

## **3. Battery Integration with EMHASS**

**A. Identify Battery Sensors**

- The Powerwall integration provides:
    - Battery state of charge: `sensor.powerwall_charge` (percent)[^1]
    - Battery power: `sensor.powerwall_battery_now` (kW, negative for charging)[^1]
    - Battery capacity: `sensor.powerwall_battery_capacity` (kWh)[^1]

**B. Configure EMHASS for Battery**

- In the EMHASS configuration, add:

```json
{
  "sensor_battery_power": "sensor.powerwall_battery_now",
  "sensor_battery_soc": "sensor.powerwall_charge",
  "battery_capacity_kwh": 13.5  // Replace with your actual Powerwall size
}
```

- Adjust charge/discharge limits and reserve settings as needed.

**C. Enable Battery Optimization**

- EMHASS will now optimize Powerwall charging and discharging, considering your solar production, consumption, and tariffs.

---

## **4. Tips and Troubleshooting**

- **Powerwall 3 Note:** Integration with Powerwall 3 may require the Gateway’s IP address. Some users report issues connecting directly to the Powerwall 3 device; ensure you are using the correct credentials and network address[^2].
- **Solar-Only Systems:** If you do not have a Powerwall, your options for direct solar integration are limited. Consider using the Tesla Custom Integration or CT clamp sensors for solar monitoring[^3][^5].
- **Data Conversion:** Always ensure your solar production sensor reports energy (kWh) for EMHASS compatibility. Use Home Assistant’s integration platform if needed[^5].
- **Automations:** Use EMHASS outputs in your automations to control loads, schedule battery charging, and more.

---

## **Summary Table: Key Configuration Entities**

| Function | Home Assistant Entity Example | EMHASS Config Parameter |
| :-- | :-- | :-- |
| Solar PV Power | `sensor.powerwall_solar_now` | `sensor_power_photovoltaics` |
| Main Load | `sensor.powerwall_load_now` | `sensor_power_load_no_var_loads` |
| Battery Power | `sensor.powerwall_battery_now` | `sensor_battery_power` |
| Battery SOC | `sensor.powerwall_charge` | `sensor_battery_soc` |


---

By following these steps, you can connect your Tesla solar and Powerwall system to Home Assistant and use EMHASS to optimize your energy usage, maximize self-consumption, and automate your home’s energy management[^1][^3][^5].

<div style="text-align: center">⁂</div>

[^1]: https://www.home-assistant.io/integrations/powerwall/

[^2]: https://www.reddit.com/r/Powerwall/comments/1h5pl7n/home_assistant_with_powerwall_3_and_gateway_2/

[^3]: https://www.home-assistant.io/docs/energy/battery/

[^4]: https://community.home-assistant.io/t/tesla-solar-without-powerwall-supported/306812

[^5]: https://robpickering.com/home-assistant-energy-monitoring-of-tesla-solar-panels/

[^6]: https://www.reddit.com/r/TeslaSolar/comments/vcyhm9/tesla_solar_and_home_assistant/

[^7]: https://community.home-assistant.io/t/custom-tesla-integration-and-energy-dashboard/676295

[^8]: https://community.home-assistant.io/t/converting-tesla-solar-watts-sensor-to-kwh-correctly/528780

[^9]: https://www.solarquotes.com.au/blog/best-ev-chargers-2025/

[^10]: https://community.home-assistant.io/t/tesla-solar-charging-script-automation/607903

