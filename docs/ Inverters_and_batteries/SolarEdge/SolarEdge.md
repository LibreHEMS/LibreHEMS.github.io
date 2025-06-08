---
title: Solar Edge
parent: Inverters and Batteries
layout: minimal
---

# SolarEdge

## User Guide: Integrating SolarEdge with EMHASS for Home Assistant

This guide explains how to integrate your SolarEdge solar PV and battery system with Home Assistant and optimize it using the EMHASS add-on. It covers both solar PV and battery integration, ensuring you can maximize self-consumption, reduce costs, and automate your energy usage.

---

### **1. SolarEdge Integration with Home Assistant**

**A. Obtain SolarEdge API Key and Site ID**

- Log in to your SolarEdge monitoring portal.
- Go to **Admin > API Access**.
- Generate and save your API key and note your Site ID[2][8].

**B. Add SolarEdge Integration in Home Assistant**

- Open Home Assistant and go to **Settings > Devices & Services**.
- Click **+ Add Integration** and search for "SolarEdge".
- Select the SolarEdge integration and enter your Site ID and API key.
- Complete the setup as prompted. Home Assistant will now fetch data from your SolarEdge system every 15 minutes due to API rate limits[2][8].

---

## **2. Solar PV Integration with EMHASS**

**A. Configure Solar PV Sensor in EMHASS**

- In the EMHASS configuration (via the add-on web interface or `config.json`), set the parameter for your PV production sensor.
- Typically, this is the entity created by the SolarEdge integration, such as `sensor.solaredge_power` or similar.

  Example configuration:
  ```json
  {
    "sensor_power_photovoltaics": "sensor.solaredge_power"
  }
  ```

- Also, define your main household load sensor, excluding deferrable loads:
  ```json
  {
    "sensor_power_load_no_var_loads": "sensor.power_load_no_var_loads"
  }
  ```

- If needed, create a template sensor in Home Assistant to calculate `sensor.power_load_no_var_loads` by subtracting the power of deferrable loads from your total load sensor[3][4].

**B. Launch and Test Optimization**

- Start the EMHASS optimization from the web UI or via the API.
- Review the suggested schedules and outputs for your loads and PV usage.

---

## **3. Battery Integration with EMHASS**

**A. Ensure Battery Data is Available**

- The SolarEdge integration exposes battery-related sensors (e.g., battery state-of-charge, power, etc.) if your system includes a compatible SolarEdge battery[7][8].
- Identify the relevant battery sensors in Home Assistant (e.g., `sensor.solaredge_battery_soc`, `sensor.solaredge_battery_power`).

**B. Configure Battery Parameters in EMHASS**

- In the EMHASS configuration, add the battery sensor entities:
  ```json
  {
    "sensor_battery_power": "sensor.solaredge_battery_power",
    "sensor_battery_soc": "sensor.solaredge_battery_soc"
  }
  ```
- Set battery capacity and other relevant parameters according to your system specs.

**C. Enable Battery Optimization**

- EMHASS will now consider your battery’s charge/discharge capabilities in its optimization, allowing it to schedule when to store excess PV or use stored energy to minimize grid usage[1][3][4][6].

---

## **4. Automating and Monitoring**

- Link EMHASS’s optimized schedules to real Home Assistant automations for devices like water heaters, EV chargers, or pool pumps.
- Example: Use the output from EMHASS to turn devices on/off based on the optimal schedule[1][3][4].

---

## **Summary Table: Key Configuration Entities**

| Function         | Home Assistant Entity Example           | EMHASS Config Parameter             |
|------------------|----------------------------------------|-------------------------------------|
| Solar PV Power   | `sensor.solaredge_power`               | `sensor_power_photovoltaics`        |
| Main Load        | `sensor.power_load_no_var_loads`        | `sensor_power_load_no_var_loads`    |
| Battery Power    | `sensor.solaredge_battery_power`       | `sensor_battery_power`              |
| Battery SOC      | `sensor.solaredge_battery_soc`         | `sensor_battery_soc`                |

---

## **Best Practices**

- Always verify the correct mapping of your SolarEdge sensors in Home Assistant before configuring EMHASS.
- Test the optimization results before automating device control.
- Regularly update both Home Assistant and EMHASS for new features and compatibility improvements.

---

By following these steps, you can fully leverage your SolarEdge system’s data within Home Assistant and optimize your solar and battery usage with EMHASS for maximum savings and efficiency[1][3][4][8].

- [1] https://emhass.readthedocs.io/en/stable/intro.html
- [2] https://www.home-assistant.io/integrations/solaredge/
- [3] https://emhass.readthedocs.io/en/latest/intro.html
- [4] https://github.com/siku2/hass-emhass
- [5] https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126?page=3
- [6] https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126
- [7] https://www.solarbatteriesonline.com.au/solaredge-battery/
- [8] https://markus-haack.com/our-own-electricity-3/
- [9] https://sites.google.com/site/davidusb/projects/emhass
- [10] https://knowledge-center.solaredge.com/sites/kc/files/solaredge-monitoring-portal-user-guide.pdf
- [11] https://community.home-assistant.io/t/solaredge-modbus-configuration-for-single-inverter-and-battery/464084?page=26
- [12] https://www.solarquotes.com.au/blog/solaredge-home-assistant-hack/
- [13] https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126?page=143
- [14] https://knowledge-center.solaredge.com/sites/kc/files/se-solaredge-one-for-residential-third-party-integrations-guide-application-note-eu.pdf
- [15] https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126/61
- [16] https://github.com/davidusb-geek/emhass/discussions/389
- [17] https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126?page=4
- [18] https://emhass.readthedocs.io
- [19] https://github.com/davidusb-geek/emhass/discussions/277
- [20] https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126/136
- [21] https://github.com/amberelectric/public-api/discussions/123
- [22] https://www.aph.gov.au/DocumentStore.ashx?id=a161b5af-7ae6-4f69-9ee9-a90347401a01&subId=748526
- [23] https://pypi.org/project/emhass/0.3.6/
