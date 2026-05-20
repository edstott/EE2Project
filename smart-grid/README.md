# Smart Grid

## Requirements

1. The system shall provide energy to domestic emulator LEDs to satisfy the demands given by a third-party web server.
2. The system shall extract energy from a pair of PV panels illuminated by solar emulator lamps.
    1. The light output will be modulated to represent the day/night cycle
    2. Each group has a single PV setup for development rather than two. A PSU can be used to emulate the dual PV array for testing.
    3. The system shall use a switch-mode power supply (SMPS) to maximise the energy extracted from the PV array across various conditions
3. The system shall store excess energy in a provided supercapacitor for use at a later time
    1. No batteries shall be used
4. A mismatch between supply and demand of power shall be accommodated by importing from or exporting to an external grid, which is emulated by a PSU with an energy sink.
    1. The energy imported or exported shall be metered and converted to a monetary value using variable prices specified by a third-party web server
5. The system shall minimise the overall cost of importing energy with an algorithm to decide when to store/release and import/export energy. It shall also choose when to satisfy demands that can be deferred
    1. The algorithm should perform better than a naive algorithm that always acts to minimise the amount of power imported or exported at a given moment, and delivers demands as soon as they are requested.
6. There shall be a user interface that displays current and historic information about energy flows and stores in the system.

## Resources Provided

### Hardware Kit

| ![Photo of your starter kit](doc/starter_kit.jpg) |
|:--:|
| _Photo of your starter kit_ | 

Your starter kit contains:

| Qty. | Item |
| ---- | ---- |
| 4    | Bidirectional Buck/Boost SMPS Module |
| 1    | Triple LED Assembly - 3 Buck SMPS connected to 3 1A LEDs as loads (due to be ready shortly after project start) |
| 1    | Single LED Assembly - 1 Buck SMPS connected to 1 0.3A LED as loads (temporary for development while we wait for the new setup) |
| 1    | PV Panel with solar emulation lamp |
| 2    | Clamp Multimeter |
| 1    | DC Grid Busbar |
| 1    | Supercapacitor module |
| 1    | Collection of USB leads |
| 1    | Collection of 4mm Banana Leads |


### Software

Starter code for the SMPS modules and domestic load emulators is based on that used in Power Electronics and Power Systems lab. [Code can be found in the specifications section](#appendix---circuit-specifications).

### The Web Server

An external webserver provides information about demands and externalities that you need to meet the project requirements. In particular, you can look up:

1. The instantaneous demand that you need to satisfy. This represents the sum of all applications that are required immediately by the user, such as boiling a kettle
2. A list of deferrable demands, which can be satisfied at any time in a specified time period. These represent time-flexible applications such as charging an electric vehicle
3. The import (sell) and export (buy) cost for energy. The export price is paid to users for energy that they export
4. The sun irradiance, represented as a fraction of the maximum current setting to be used for the PSU that emulates the PV input or to control the solar emulator lamp
5. A history of the irradiance, demand and price from the previous cycle.

The values returned by the webserver change every 5 seconds (tick). They are computed by summing a periodic component, which follows a repeating 5-minute cycle, with a randomised component. Each cycle approximates the characteristics of a day in real life. Data is returned in JSON format and the code used to generate the webserver output is provided for reference.

The webserver is available at [https://icelec50015.azurewebsites.net/](https://icelec50015.azurewebsites.net/). There are various URIs that return JSON objects, all linked from the index page. The webserver code can be seen in its [GitHub repository](https://github.com/edstott/ICelec50015).

### Project Budget

A budget is available for you to purchase additional items, but it should be possible to complete the project with the equipment provided.

## Getting Started

Try the following steps to get started with the project:

1. Gather some initial data from the PV array by connecting it to a rheostat load. You may ask the lab technicians to borrow a rheostat to make measurements outdoors.
2. Set up the information network with a basic UI that displays some measurements from a database. Set up an SMPS module to log data to the database via WiFi. Set up a mechanism for adjusting the output voltage of an SMPS via the UI.
3. Gather samples of the randomised daily cycle by downloading data from the external server. Research techniques that could be used to optimise energy cost, considering both heuristic approaches (based on specific rules) and more general approaches based on modelling.
4. Consider potential layouts for the energy grid, in particular how the SMPS modules could be configured to balance the energy flows and maintain a constant bus voltage.

## Technical Guide

This section contains advice on the following sections:

1. [Grid Configuration](#grid-configuration)
2. [Data Connectivity](#data-connectivity)
3. [Energy Import and Export](#energy-import-and-export)
4. [PV Array](#pv-array)
5. [Supercapacitor](#supercapacitor)
6. [Domestic Load Simulator](#domestic-load-simulator)
7. [USB Connectivity of Lab Devices](#usb-connectivity-of-lab-devices)

### Grid Configuration
Your system should use a central DC bus with a constant voltage.
The domestic load emulator LEDs should draw from power from this bus as required by the server, and your energy/storage sources should supply power to maintain the bus voltage at the desired level.
The physical bus can be implemented simply by connecting modules to the provided busbar module with 4mm test leads.

SMPS modules are bidirectional, meaning that current and power can flow in either direction through the module.
However, energy transfer requires a higher voltage at Port A (left side) than Port B (right side).
The photovoltaic panel outputs a variable voltage depending on the irradiance from sunlight (or brightness of the lamp).
The voltage of the supercapacitor varies with the stored charge.
Therefore, choose a bus voltage to ensure that every SMPS module will always satisfy Va > Vb.

Each SMPS module can be used in one of many different modes, for example:

1. Control the voltage on Port A or Port B to a defined level (constant voltage mode)
2. Pass a certain amount of current input or output through Port B (constant current mode). This can also be used as a constant power mode by dividing the required power by the voltage on Port B.
3. Maximise the power flow through the module with maximum power point tracking (see [below](#pv-array))

You will need to choose how to configure your SMPSs to meet the project requirements.

### Data Connectivity

You will need to communicate with your SMPS modules to control them and monitor the system.
Each SMPS uses a Raspberry Pi Pico with WiFi capability, so you can connect them to an external server or database using the provided libraries.
You will need to use a mobile hotspot to provide a WiFi network because the College WiFi network is difficult to access for embedded devices.

### Energy Import and Export 

The system includes a connection to an external power grid that can be used to supply energy if there is insufficient generation or storage to meet the demand.
It can also be used to sell surplus energy.

The external grid can be emulated with a bench power supply set at a constant voltage that can be converted up or down to your bus voltage with an SMPS.
If you attempt to drive current into a bench power supply the current will drop to zero and the terminal voltage will rise, so connect a resistor in parallel with the PSU to sink any reverse current. The resistor should be small enough that you can sink the maximum foreseeable export current through it without exceeding 15V. The instructions for the bidirectional PSU in the EE2 Power Lab will help specify this.

The external grid connection is a reliable power source and sink, so it can be interfaced with your bus with a SMPS in a current controlled mode to regulate flow of energy to and from the grid.
However, this technique could make it harder to precisely control the bus voltage.
An alternative would be to use constant voltage mode to set DC bus voltage but you then are unable to directly control the import/export. This is one of many engineering decisions that you need to make where each side has pros and cons.

The SMPS module that you use to connect the external grid to your bus should be configured to measure current so that you can calculate the cost of imported energy and the income from exported energy.

### PV Array

The PV setup is an 8W nominal 6V panel with a plastic stand and 4mm banana lead connection. A solar emulator lamp is provided to allow you to test and characterise your PV panel under controlled conditions but you should also characterise it under natural light. The solar emulator is EXTREMELY bright and you should not look directly at it under any circumstances. Legs have been provided to allow you to use the emulator lamp face down with your panel. Beware that this setup will get hot over time so do not use it for extended periods or leave it on when not in use.
The voltage of PV panel varies with the level of irradiance and current flow.
Since power is the product of voltage and current, there exists a point where power output is maximum for a given irradiance.
You need to draw current from the array to extract power, but too much current will reduce the voltage to the point where power reduces.

The first step to optimal use of the PV array is to characterise its I-V (current-voltage) curve. This will need to be completed both inside and outside (but can be achieved even in overcast conditions) as each will be slightly different.
Place the PV array in a location with consistent irradiance and connect it to a load (such as the loadbank indoors or a rheostat outside).
Then, sweep the current to the load and log the input voltage and current by measuring them multimeters.
Find the duty cycle which results in maximum power and you have found the most efficient operating point for the PV array. The cell has an open-circuit voltage $V_O$, a short-circuit current $I_S$, and a point ($V_M$, $I_M$) where power is maximal.

| ![IV Characteristic of a PV Cell](doc/PV-real.svg) |
|:--:|
| _Typical I-V characteristic of a PV cell_ | 

Unfortunately, this operating point varies with irradiance and temperature, so you cannot simply configure an SMPS to maintain a constant voltage or current to achieve an optimal output.
Instead, you need to implement _maximum power point tracking_ to alter voltage and current according to conditions.
Typically, the controller makes constant adjustments to duty cycle and measures the input power.
If an adjustment results in increased power, it is kept, otherwise it is reversed.

You only have 1 PV setup per group, so you will need to set up a bench PSU in the lab (and possibly also an SMPS controlled by the server) to mimic the dual PV array that will be used in the demonstration.

### Supercapacitor

Your kit contains 2 supercapacitors rated at 0.25F and 18V each, which will store around 50J of energy in total when charged to the maximum SMPS voltage. Like a standard capacitor, they store energy as an electric charge according to the formula $E=CV^2$. That means, unlike a battery, you can accurately determine the amount of energy stored by measuring the terminal voltage, subject to the complications discussed below. Ensure that you do not exceed the voltage rating of the capacitor because it will break down and be destroyed.

The standard capacitors you've used in labs have close to ideal behaviour at low frequencies, but the supercapacitor has higher parasitic resistance. Furthermore, the resistance is distributed across the area of the capacitor plates and this means the localised charge stored in different parts of the capacitor can be temporarily imbalanced. This has a few consequences:

- If you apply a large charging current to the capacitor terminals the voltage will rise. But when you stop the current you will observe the voltage fall again as the charge stored near the terminals balances out across the capacitor plates
- If you short the capacitor terminals out or draw a large discharging current, the terminal voltage will drop to zero. But the capacitor might not be fully discharged as it takes time for the charge to move through the capacitor
- Passing charge through the internal resistance of the capacitor wastes energy, so you will not be able to recover all the energy you store in the capacitor

Take time to experiment with the capacitor and confirm that you take account of the internal resistance when you integrate it into your system.

### Domestic Load Simulator

Your kit contains a Domestic Load Simulator which is where you must dissipate the load energy as instructed by the web server.
The energy is to be dissipated in 3 LEDs that are connected a shared DC source. Each LED has an LED driver circuit, all three of these driver circuits are controlled, in turn, by a Raspberry Pi Pico.
An LED is approximately a fixed voltage device (like any diode) so controlling the power into them requires a current controlled source. The LED drivers you are provided with are a simple Buck SMPS (basically a cut down version of the EE2 lab SMPS) with current measurement on the inductor current, you will be provided with an example code which performs the basic functions but will need to be edited to integrate into your system. As with the solar emulator, these are very bright LEDs so you should be careful to not stare at them directly for extended periods of time.

### USB Connectivity of Lab Devices

Most of the lab equipment (certain PSUs, the load bank and the DMM) from the EE2 power lab have a USB port on the rear and can communicated over this using a relatively simple protocol. Using this feature may help automate some testing and development tasks in your experiment. Further details on how to achieve this with some example code will follow but in the meantime the manuals for these devices are available online ...

## Appendix - Circuit Specifications

### Lab SMPS

| ![Photo of supercapcitor bank](doc/lab_smpss.jpg) |
|:--:|
| _Photo of not one but FOUR SMPS boards_ | 

[Schematic of the Lab SMPS](doc/EE2_Power_Lab_SMPS_Schematic_2026.pdf)

[Example code for Lab SMPS](SMPS_2026_Bidirectional.py)  - Be aware that closed loop mode may not be stable, it was not tuned for your system

| Specification | Value | Unit |
| ------------- | ----- | ---- |
| Circuit Type | Buck or Boost | |
| Current Sensing | Bidirectional at Port B positive line | |
| Controller Type | Raspberry Pi Pico W | |
| Controller Power Source | USB, Port A* or Port B* | |
| PWM Frequency | 100 | kHz |
| Port A Voltage* | 0 - 17.5 | V |
| Port B Voltage* | 0 - 17.5 | V |
| Max Current | 5 | A |

*The Buck/Boost switch determines which port is used to power all the support circuitry on the board (Pico, Current Sensor, MOSFET drivers etc.), this port has a minimum voltage of 6-7V for this function. If the switch is set to Buck then Port A must meet the minimum voltage, if its set to Boost then Port B must meet the minimum voltage.

### Supercapacitor

| ![Photo of supercapcitor bank](doc/capn.jpg) |
|:--:|
| _Photo of your Supercapacitor bank_ | 

[Datasheet for Supercapacitor](https://www.mouser.co.uk/ProductDetail/Cornell-Dubilier-CDE/DSM254Q018W075PB?qs=rQFj71Wb1eXTUSitfenP%2Fw%3D%3D)

| Specification | Value | Unit |
| ------------- | ----- | ---- |
| Max Voltage | 18 | V |
| Capacitance | 0.25 | F |
| ESR | ~4 | Ohms |
| Current Limit (5s Peak) | 350 | mA | 

### PV Panels

| ![Photo of your PV panel](doc/pv_panel.jpg) |
|:--:|
| _Photo of 8W PV Panel_ | 

| ![Photo of your solar emulator](doc/notagrowlight.jpg) |
|:--:|
| _Photo of the Solar Emulator Light_ | 

| Specification | Value | Unit |
| ------------- | ----- | ---- |
| Rated Power | ~8 | W |
| V<sub>OC</sub> | ~8.5 | V |
| I<sub>SC</sub> | ~1000 | mA |

### Triple LED Driver SMPS

| ![Photo of domestic load emulator](doc/pingpongping.jpg) |
|:--:|
| _Photo of your Domestic Load Emulator_ | 

[Example code for LED Driver](Triple_LED_Driver_Example.py)  - This loops through brightnesses for all 3 LEDs, you will need to determine your own setpoints

[Schematic of the LED Driver](doc/LED_Driver_2026.pdf)

| Specification | Value | Unit |
| ------------- | ----- | ---- |
| Circuit Type | Buck | |
| Current Sensing | Unidirectional at output negative line | |
| Controller Type | Raspberry Pi Pico | |
| Controller Power Source | USB or Input Port | |
| Base Code | Triple_LED_Driver.py | |
| PWM Frequency | 100 | kHz |
| Input Voltage | 7 - 17.5 | V |
| Output Voltage | 0 - 17.5 | V |
| Max Current | ~1000 | mA |

### New LED Loads

| Specification | Value | Unit |
| ------------- | ----- | ---- |
| Power Rating | ~3 | W |
| Voltage Drop (varies with colour) | ~3 | V |
| Current Rating (also varies with colour) | ~1000 | mA |
