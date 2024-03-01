# EEE2/EIE2 Group Project

## Outline

## Project Groups

Project groups may be self-selected.
Your group must contain at least two students from the EEE programme and two from the EIE programme.
You may register a group of four, five or six members, but if you register fewer than six members it is likely that others will be added to your group.
It is also possible that groups of four will be broken up if there is no-one available to join the group.
There may be some groups of five due to division of the cohort.

Each project option can only support a limited number of groups, so you will need to rank your option preferences.
If an option is oversubscribed for first preferences, then groups will be randomly selected for allocation to their second or third choice.

If you do not have a self-selected group then you may also submit preferences as an individual, which will be considered when allocating you to a group.

## Common Project Aims

All three projects share some common aims. They all require the design and implementation of a system made up of modular elements and interfaces between them.
The project topics are designed to draw on different areas of the EEE and EIE curricula, so that a collaborative approach is needed, drawing on different discilines and skills.
Finally, every project will draw upon various non-technical skill areas, including project planning and management, communication and teamworking

## Project Options

The three project options are intended to build upon elements of both the EEE and EIE programmes.
Each of the project options contains elements that are suited to students from your stream.

### Balance Robot

![Balance robot starter kit](doc/balance-robot.jpg)

The aim of this project is to build a demonstrator robot that can balance on two wheels.
You should choose an application for the robot that will demonstrate interaction with human users or the environment.
A robot platform is provided, which contains wheels, motors, batteries, power electronics and mounting points for embedded computing platforms

#### Core technical challenges
- Use a control algorithm to achieve stability of the robot and allow it to move around the environment
- Add sensing and/or imaging components to the robot that allows it to detect obstacles, users or other objects that are appropriate to the demonstrator environment
- Construct a head unit for the robot that suits its purpose as a demonstrator
- Create a remote user interface that allows manual control of the robot's motion and shows a history of events, plus other information relevant to the demonstrator application

[Complete project brief](doc/robot-brief.md)

### Smart Grid

![Flywheel energy storage](doc/flywheel.jpg)

The aim of this project is to build an energy management system for connecting a home to a smart grid.
A photovoltaic array and mechanical flywheel are provided for energy generation and storage.
The system must balance energy supply and demand and use forecasting to minimise the cost of importing energy from the grid.
The system will face uncertain amounts of sunshine, costs of energy and demand requirements, so decisions (e.g. whether to store or sell excess energy) require modelling to deliver the best expected outcome - this is a similar problem to those faced by stock market traders.

#### Core technical challenges
- Develop connected power converters that can control loads and match the differeing I-V characteristics of the components in the system
- Characterise the PV array and flywheel to find the most efficient operating points
- Create a database with a user interface that shows the history and forecast of internal and external variables in the system
- Use mathematical modelling to make decisions about when to store and use energy
  
[Complete project brief](doc/smartgrid-brief.md)

### Mathematics Accelerator

![Visualisation of a fractal](doc/fractal.png)

The aim of this project is to create an educational tool that can visualise a mathematical function.
The function will computationally intensive, which means that a custom-logic FPGA accelerator is required to achieve the necessary responsiveness for human interaction.
The advantage of FPGA accelerator is that the logic is specific to the algorithm, which makes it more efficient than a CPU implementation.
But maximising the potential of the FPGA requires parallelisation of the algorithm and choosing the best number representations and word lengths.

#### Core technical challenges
- Develop an accelerator for the Pynq system-on-chip FPGA platform, written in Verilog or SystemVerilog, that can generate a video output visualising the chosen function
- Identify opportunities for parallelism to increase calculation throughput
- Use numerical analysis to determine the optimum number representations and bit-widths to achieve suitable accuracy
- Use human-computer interaction to allow a user to manipulate and understand the visualisation

[Complete project brief](doc/accelerator-brief.md)
