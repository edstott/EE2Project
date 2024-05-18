# Smart Grid

## Requirements

1. The system shall provide energy to load LEDs to satisfy the demands given by a third-party web server.
2. The system shall extract energy from a bench power supply (PSU) set up to emulate the voltage-current characteristic of a PV array.
    1. The configuration of the PSU shall be determined by characterising a supplied PV array
    2. The current and/or voltage of the PSU shall be manually modulated to emulate the effect of the day/night cycle
    3. The system shall use a switch-mode power supply (SMPS) with variable duty cycle to maximise the energy extracted from the emulated PV array
3. The system shall store excess energy in a provided flywheel for use at a later time
    1. No batteries shall be used
4. A mismatch between supply and demand of power shall be accommodated by importing from or exporting to an external grid, which is emulated by a PSU with an energy sink.
    1. The energy imported or exported shall be metered and converted to a monetary value using variable prices specified by the third-party web server
5. The system shall minimise the overall cost of importing energy with an algorithm to decide when to store/release and import/export energy. It shall also choose when to satisfy demands that can be deferred
    1. The algorithm should perform better than a naive algorithm that always acts to minimise the amount of power imported or exported at a given moment, and delivers demands as soon as they are requested.
6. There shall be a user interface that displays current and historic information about energy flows and stores in the system.

## Resources Provided

### Hardware Kit

Your starter kit contains:

| Qty. | Item |
| ---- | ---- |
| 3    | Bidirectional Buck/Boost SMPS Module |
| 3    | Buck SMPS Module - Configured as LED Driver |
| 3    | Power LED Module |
| 1    | PV Array with 4 cells and connection block |
| 2    | Clamp Multimeter |
| 2    | Busbar |
| 1    | Load Resistor Module |
| 2    | 0.25F Supercapacitor |

### Software

Starter code for the Bidirectional SMPS modules is based on the Power Electronics and Power Systems lab. A skeleton code for the LED driver SMPSs will be provided.

### Lab Benches

Eight lab benches are dedicated to the energy project and they are available for booking.
Four of the lab benches have flywheels.
Do not attempt to relocated any lab equipment for this project

### The Web Server

An external webserver provides information about demands and externalities that you need to meet the project requirements. In particular, you can look up:

1. The instantaneous demand that you need to satisfy. This represents the sum of all applications that are required immediately by the user, such as boiling a kettle
2. A list of deferrable demands, which can be satisfied at any time in a specified time period. These represent time-flexible applications such as charging an electric vehicle
3. The import (sell) and export (buy) cost for energy. The export price is paid to users for energy that they export
4. The sun irradiance, represented as a fraction of the maximum current setting to be used for the PSU that emulates the PV input
5. A history of the irradiance, demand and price from the previous cycle.

The values returned by the webserver change every 5 seconds. They are computed by summing a periodic component, which follows a repeating 5-minute cycle, with a randomised component. Each cycle approximates the characteristics of a day in real life. Data is returned in JSON format and the code used to generate the webserver output is provided for reference.

### Project Budget

A budget is available for you to purchase additional items, but it should be possible to complete the project with the equipment provided.

## Getting Started

Try the following steps to get started with the project:

1. Gather some initial data from the PV array and Flywheel by connecting them to a load or bench power supply via an SMPS module. Use the SMPS module to vary the energy flow and log the resulting currents and voltages
2. Set up the information network with a basic UI that displays some measurements from a database. Set up an SMPS module to log data to the database via WiFi. Set up a mechanism for adjusting the output voltage of an SMPS via the UI.
3. Gather samples of the randomised daily cycle by downloading data from the external server. Research techniques that could be used to optimise energy cost, considering both heuristic approaches (based on specific rules) and more general approaches based on modelling.
4. Consider potential layouts for the energy grid, in particular how the SMPS modules could be configured to balance the energy flows and maintain a constant bus voltage.

## Technical Guide

This section contains advice on the following sections:

1. [Grid Configuration](#grid-configuration)
2. [Robot Function](#robot-function)
3. [PV Array](#pv-array)
4. [Energy Import and Export](#energy-import-and-export)
5. [Flywheel](#flywheel)

### Grid Configuration

Your system should use a central DC grid (or bus) with a constant voltage.
The load LEDs will draw from power from this bus as required, and your energy sources should supply power to maintain the bus voltage at the desired level.
The physical bus can be implemented simply by connecting modules to the provided busbar module with 4mm test leads.

SMPS modules are bidirectional, meaning that current and power can flow in either direction through the module.
However, energy transfer requires a higher voltage at Port A (left side) than Port B (right side).
The photovoltaic arrays output a variable voltage depending on the irradiance from sunlight and the flywheel outputs a variable voltage depending on its speed of rotation.
Therefore, choose a bus voltage to ensure that every SMPS module will always satisfy Va > Vb.

Each SMPS module can be used in different modes:

1. Attempt to set the voltage on Port A or Port B to a defined level (constant voltage mode)
2. Attempt to pass a certain amount of current input or output through Port B (constant current mode). This can also be used as a constant power mode by dividing the required power by the voltage on Port B.
3. Attempt to maximise the power flow through the module with maximum power point tracking (see [below](#pv-array))

You will need to choose how to configure your modules to meet the project requirements.

#### Data Connectivity

You will need to communicate with your SMPS modules to control them and monitor the system.
Each SMPS (bidirectional or buck) uses a Raspberry Pi Pico with WiFi capability, so you can connect them to an external server or database using the provided libraries.
You may need to use a mobile hotspot to provide a WiFi network because the College WiFi network is difficult to access for embedded devices.

### PV Array

The PV Array has 4 PV cells on an inclined stand.
The PV cells should be wired in parallel so that the total voltage doesn't exceed the limit of the SMPS modules.
The voltage of PV cells varies with the level of irradiance and inversely with the current flow.
Since power is the product of voltage and current, there exists a point where power output is maximum for a given irradiance.
You need to draw current from the array to extract power, but too much current will reduce the voltage to the point where power reduces.

The first step to optimal use of the PV array is to characterise its I-V (current-voltage) curve. This will need to be completed outside but can be achieved even in overcast conditions.
Place the PV array in a location with consistent irradiance and connect it to Port A of an SMPS module.
Connect Port B to a power resistor (supplied in your kit).
Then, sweep the duty cycle of the SMPS and log the input voltage and current.
Find the duty cycle which results in maximum power and you have found the most efficient operating point for the PV array.

| ![IV Characteristic of a PV Cell](PV-real.svg) |
|:--:|
| _Typical I-V characteristic of a PV cell. The cell has an open-circuit voltage $V_O$, a short-circuit current $I_S$, and a point ($V_M$, $I_M$) where power is maximal_

Unfortunately, this operating point varies with irradiance and temperature, so you cannot simply configure an SMPS to maintain a constant duty cycle to achieve an optimal output.
Instead, you need to implement _maximum power point tracking_ to alter voltage and current according to conditions.
Typically, the controller makes constant adjustments to duty cycle and measures the input power.
If an adjustment results in increased power, it is kept, otherwise it is reversed.

The PV array does not work well under artificial lighting, so you will need to set up a bench PSU in the lab to mimic the PV array under outdoor conditions.
The simplest approach is to set the voltage and current limits to the values you observed when the array produced maximal power.

| ![Simple PV Cell emulation with a bench power supply](PV-simple.svg) |
|:--:|
| _A bench power supply automatically switches between constant voltage mode and constant current mode such that the voltage limit and the current limit are not exceeded. This results in a rectangular I-V characteristic_ |

You can also add series and parallel resistances to make the I-V function more realistic.

![Simple PV Cell emulation with a bench power supply](PV-improved.svg)

Series and parallel resistances add slopes to the I-V characteristic, which can make more realistic test conditions for an MPPT algorithm.
Here, $I_M=I_S-(V_O/R_P)$ and $V_M=V_O-I_M R_S$.
If you implement this PV emulator, make sure you calculate the maximum power dissipation for each resistor and use resistors with an appropriate power rating.

### Energy Import and Export

The system includes a connection to an external power grid that can be used to supply energy if there is insufficient generation or storage.
It can also be used to sell surplus energy.

The external grid can be emulated with a bench power supply set at a constant voltage that can be converted up or down to your bus voltage with an SMPS.
If you attempt to drive current into a bench power supply the current will drop to zero and the terminal voltage will rise, so connect a resistor in parallel with the PSU to sink any reverse current. The resistor should be small enough that you can sink the maximum foreseeable export current through it without exceeding 15V.

The external grid connection is a reliable power source and sink, so it can be interfaced with your bus with a SMPS in constant voltage mode to regulate the bus voltage.
However, this technique could make it harder to precisely control the amount of energy import and export.
An alternative would be to use constant current mode to set the power import or export according to your forecasting algorithm, but you need to ensure that this does not cause the bus voltage to vary too much.

The SMPS module that you use to connect the external grid to your bus should be configured to measure current so that you can calculate the cost of imported energy and the income from exported energy.

### Flywheel

The flywheel stores energy in a spinning mass.
The mass is permanently coupled to a motor with a belt, so driving current into the motor will increase the speed and store energy.
Drawing current from the motor will take energy from the flywheel and it will slow down.
If no current flows through the motor, the flywheel will gradually slow down due to friction.
The voltage across the terminals of the motor varies with its speed, so you will need a SMPS module to convert energy between this variable potential and the fixed potential of your central bus.

The flywheel has a simple mechanical construction and does not have the design features for ultra-low friction that you would find in a commercial flywheel.
A helper motor with external power supply has been added to the flywheel to ensure that it maintains speed for a useful amount of time by applying slightly less torque (turning force) than the friction at a given speed.
The torque from the helper motor never exceeds the friction, so the kinetic energy in the flywheel is never greater than the energy you have supplied with the input/output motor.
The microcontroller in the flywheel also ensures that the flywheel doesn't exceed a safe speed.

The flywheel can be used to regulate the bus voltage in constant voltage mode, as long as there is sufficient energy stored.
However, power transfer between the flywheel might be more efficient at a certain I-V point, so MPPT is another option.
The power flow may be limited at lower rotational speeds due to the torque limit of the belt drive - it will be obvious if you apply too much torque because you will hear the belt skipping.

#### Tachometer

A tachometer output is available for you to detect the speed of the flywheel, and hence the amount of stored energy.
The output provides a short pulse once per revolution so you will need to measure the time between pulses to find the speed of rotation. You can connect the tachometer directly to the Raspberry Pi Pico on the SMPS module - some modules are modified with connectors to allow this.

The output is an open collector, which acts like a mechanical switch that is normally open, but closes during the pulse.
It has a signal and ground pin.
Normally, the ground pin is connected to ground so that the signal output is pulled down to 0V when the output is on.
Then, a a pull-up resistor is added that pulls the signal voltage up to logic high when the output is off (open circuit).
You can configure a microcontroller input, such as those on the Raspberry Pi Pico on the SMPS module, to use an internal pull-up resistor, so no external resistor is needed.

The tachometer is an asynchronous pulse input.
You can check the value of the input in the main loop of your code, but you will need to compare the value to the previous value to detect a change of the signal.
You also need to be certain that the execution time of the main loop is always less than the width of the pulse.
Alternatively, you can configure the microcontroller to trigger an interrupt when the input changes.
The interrupt works like an automatic function call so you can be sure to run the required code no matter when the pulse happens.

#### Flywheel Substitution

The flywheels are limited in number, so you may wish to explore alternatives to keep your project development progressing.

> [!WARNING]  
> Do not use batteries in this project. They are a safety hazard.

Your kit contains 2 supercapacitors rated at 0.25F and 18V each, which will store around 50J of energy in total when charged to the maximum SMPS voltage. The terminal voltage of a capacitor increases with the square root of the stored energy, which is a similar characteristic to the flywheel where $E \propto \omega^2$. So they are, to an extent, interchangeable.

It is also possible to emulate storage with a bench PSU and a bidirectional SMPS. Connect the PSU to port A and configure the SMPS to regulate the output port B at a defined voltage. Then, vary the output voltage in proportion to the integral of the current measured at port B, which is exactly the behaviour of a capacitor, and similar to a flywheel. For additional realism, you could emulate inefficient storage by adding resistors in series and/or parallel with the output port. The resistors could be real, or their effect could be modelled in the SMPS code.
