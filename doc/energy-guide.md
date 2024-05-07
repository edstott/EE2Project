# Smart Grid

## Requirements

1. The system shall provide energy to load LEDs to satisfy the demands given by a third-party web server.
2. The system shall extract energy from a bench power supply (PSU) set up to emulate the voltage-current characteristic of a PV array.
    1. The voltage, current limit and series resistance of the PSU shall be determined by characterising a supplied PV array
    2. The current limit of the PSU shall be manually modulated to emulate the effect of weather and the day/night cycle
    3. The system shall use a switch-mode power supply (SMPS) with variable duty cycle to maximise the energy extracted from the emulated PV array
3. The system shall store excess energy in a provided flywheel for use at a later time
    1. The maximum speed of the flywheel shall not exceed 650 rpm.
    2. No other form of energy storage shall be used, excluding the capacitance incorporated into the SMPS modules
4. A mismatch between supply and demand of power shall be accommodated by importing from or exporting to an external grid, which is emulated by a PSU with an energy sink.
    1. The energy imported or exported shall be metered and converted to a monetary value using variable prices specified by a third-party web server
5. The system shall minimise the overall cost of importing energy with an algorithm to decide when to store/release and import/export energy. It shall also choose when to satisfy demands that can be deferred
    1. The algorithm should perform better than a naive algorithm that always acts to minimise the amount of power imported or exported at a given moment, and never defers any demand requirements.
6. There shall be a user interface that displays current and historic information about energy flows and stores in the system.

## Resources Provided

### Hardware Kit

Your starter kit contains:

| Qty. | Item |
| ---- | ---- |
| 3    | Bidirectional Buck/Boost SMPS Module |
| 4    | Buck SMPS Module |
| 4    | Power LED Module |
| 1    | PV Array |
| 2    | Clamp Multimeter |
| 2    | Busbar |
| 1    | Load Resistor Module |

### Software

Starter code for buck/boost module is based on the Power Electronics and Power Systems lab. 

### Lab Benches

Two kinds of lab benches are dedicated to the Smart Grid project: and flywheel benches.

### The Web Server

An external webserver provides information about demands and externalities that you need to meet the project requirements. In particular, you can look up:

1. The current instantaneous demand that you need to satisfy. This represents the sum of all applications that are required immediately by the user, such as boiling a kettle
2. A list of deferrable demands, which can be satisfied at any time before a specified deadline. These represent time-flexible applications such as charging an electric vehicle
3. The current import and export cost for energy. The export price is negative, meaning that the user is paid for energy that they export
4. The current sun irradiance, represented as a fraction of the maximum current setting to be used for the PSU that emulates the PV input

The values returned by the webserver vary over time. They are computed by summing a periodic component, which follows a repeating 10-minute cycle, with a randomised component. The code used to generate the webserver output is provided for reference.

### Project Budget

A budget is available for you to purchase additional items