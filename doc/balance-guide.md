# Balance Robot

## Requirements

1. The robot shall demonstrate a form of autonomous behaviour based inputs from a camera and/or other sensors
2. The robot shall balance on two wheels, with a centre of gravity above the axis of rotation of the wheels
3. There shall be remote control interface that allows a user to enable or control the autonomous behaviour, and to move the robot manually in two dimensions around a flat surface
    1. The user interface shall display useful information about the power status of the robot, such as power consumption and remaining battery energy
    2. The user interface shall provide inputs and display information that are pertinent to the demonstrator application.
4. The robot should augment the provided chassis with a head unit that suits the chosen demonstrator application

## Resources Provided

### Hardware Kit

Your starter kit contains:

| Qty. | Item |
| ---- | ---- |
| 2    | Robot Chassis with Motors and Power PCB |
| 4    | Temporary Robot Stabilisers |
| 4    | 7.2V 2000mAh NiMH battery |
| 2    | Raspberry Pi 3 Model B with keyboard |
| 2    | ESP32 Microcontroller Module |
| 2    | Breadboard |
| 2    | Accelerometer/Gyroscope Module (MPU)|
| 3    | Wiring Loom |
| 2    | Battery Bypass Cable |
| 4    | USB Cable |

### Software

Starter code is provided for the ESP32 MCU to demonstrate stepper motor control and the interface with the MPU

## Suggestions

### Robot Function

This project option is open-ended because the high-level function of the robot is not defined.
Think carefully about what your robot should do and look for functionality that can be developed incrementally so that your final demonstration can be a success even if some of your ideas don't work as planned.
The Raspberry Pi supports a camera and you will find libraries and tutorials online that allow you to implement some basic computer vision tasks.
You may wish your robot to avoid obstacles and it may be easiest to do this with dedicated sensors based on optical or ultrasonic proximity, or even mechanical touch.
Detecting obstacles with a camera is a complex task because significant signal processing is needed to convert a 2D camera stream into a 3D representation of the environment, but you may find libraries that help.

You can choose whether your robot should operate in a real world environment or a special arena that is designed to demonstrate a specific task.
An arena is available for your use, and you can configure it with markings and/or objects to suit your purpose.
A typical arena task might be to follow a line, navigate a maze or map the positions of objects.
You can use lighting to help, in the form of flexible LED strips, glowing beacons and overhead lamps.

![An artificial environment for robot problem solving]()

A robot operating in real-world environments will need to cope with greater uncertainty, and it may encounter moving objects, uneven surfaces and challenging lighting conditions.
Typical tasks for robots in this environment could be meet-and-greet/personal assistance, search and rescue and domestic help.
Think about how you can constrain the problem so you can develop functionality incrementally.
A robot in a real-world environemnt may be reliant on third-party vision libraries, so make sure you understand the capabilities and limits of any candidate libraries before you commit yourself to achieving a particular goal.

![A meet and greet robot]()

Make use of consultation sessions with staff to refine and develop your ideas.

### Balancing

ONe of the project requirements is that the robot can balance on two wheels, but it's important to decouple this requirement from the other tasks that you face in your project planning.
In other words, ensure that you can work on balancing independently from developing robot functionality, otherwise some team members might find their progress blocked while others work on balancing.
To help with this, each group is provided with two robot chassis and a set of stabilisers that can be fitted to the robot to keep it upright without the need for a balancing algorithm.

### Control 

Balancing can be achieved with a PID controller, where the input is the current angle of tilt of the robot, the setpoint is the desired angle of tilt (usually upright) and the output is the motor acceleration.
Motor acceleration is used because accelerating the wheels provides a turning force at the base of the robot that corrects any error in the tilt angle.
Modelling the balancing algorithm is encouraged, but often the best way to tune the algorithm is to adjust the PID parameters manually with trial-and-error.
In general, if the robot runs away and falls over, then more proportional gain is needed to provide a greater restoring force.
If the robot oscillates before falling over, then proportional gain should be decreased or differential gain increased to introduce damping and remove overshoot.

![Force diagram of robot]()

The setpoint tilt angle might not be exactly zero due to an offset of the centre of mass of the robot from the central axis use to measure tilt.
There can also be misalignment between the tilt sensor and the axis.
You can find out this offset by turning the motors off and finding the tilt angle measured when the robot naturally balances as you gently hold it upright.
Finding the right setpoint for a static condition can avoid needing to use an integral term in the controller because there is no steady-state error when the robot is perfectly balanced.

![Diagram of a generic PID]()

Once the robot can balance in a static position, the next task is to make it move around.
One way to do this is to use a cascaded controller, which means that the setpoint for the inner loop (desired tilit angle in this case) is itself set by a PID controller.
If the robot is tilted off balance and that tilt angle is constant, then the motors must accelerate continuously at a constant rate to provide a force that counteracts the toppling force.
Therefore, if you want to move the robot to another location, your control algorithm should change the tilt angle for a short time to accelerate the robot, then tilt it in the opposite direction to slow it down before it reaches its target position.
A PID controller can do this, but note that the acceleration required to maintain a tilt angle will quickly speed the wheels to their maximum speed, at which point the robot will fall over.
A good first step is to make the outer control loop a speed controller.
That way, you can ensure that the robot will bring the tilt angle back to the balanced condition before the wheels reach their speed limit.

![General diagram of a cascaded controller]()

### Measuring Tilt

Tilt measurement is achieved with a combined accelerometer and gyroscope sensor.
The sensor and a measurement library are provided.
The accelerometer detects the direction of gravity and therefore the tilt angle of the robot with respect to gravity.
However, without additional information, it is impossible to distinguish between a gravitational force and a force due to acceleration.
That means if the robot accelerates in the back/forward direction, either to move the robot or just to counteract a tilitng force, an error will be introduced in the tilt angle measurement.

This error can be reduced by using the gyroscope measurement.
Silicon gyroscopes of this type measure the differential of tilt angle, i.e. the rate of change of angle.
This differential can be used directly to calculate the D term of a PID controller, but an absolute measure of tilt is needed for the P term.
Integrating the output of the sensor will work, but only for a short time because any error in the measurement (there is always error) will also be intergated until the result becomes completley useless.

These problems can be resolved by using a _Complementary Filter_.
Notice that the integral of the gyroscope is useful over short time periods, before the error grows too large.
Meanwhile, the tilt angle calculation from the accelerometer will have short-lived error transients due to longitudanal movements, but over a long period of time these will average to zero because the robot cannot accelerate continuously.
Therefore, a complementary filter works by applying a low-pass filter to the tile measured by acceleration and summing it with a high-pass-filtered tilt measured by the gyroscope.

The form of the complementary filter is: $\Theta_{n} = (1-C) \Theta_a + C \(\frac{d\Theta_g}{dt} \Delta t + \Theta_{n-1}\)$

Here, $\Theta_{n}$ is the calculated tilt at iteration $n$, while $\Theta_{n-1}$ is the calculation from the previous iteration.
$\Theta_g$ is the tilt angle measured by accelerometer and $\frac{d\Theta_g}{dt}$ is the differential tilt angle measured with the gyroscope.
$\Delta t$ is the time period between iterations and $C$ is a factor between 0 and 1 that sets the time constant - typically it is close to 1.

With $C$ close to 1, you can see that $\Theta_{n}$ at any given iteration is mostly derived by integrating the gyroscope measurement (multipling by $\Delta T$) and adding it to the previous tilt angle.
This means any rapid changes in tilt, which are measured accurately by the gyroscope without interference from longitudnal acceleration, are included in $\Theta_{n}$.
Because $C<1$, any error in $\frac{d\Theta_g}{dt}$ will not accumulate forever and eventually it will converge to a constant error in $\Theta_{n}$, which is manageable.
Meanwhile, the small contribution from $\Theta_a$ will gradually accumulate so, in static conditions after a long period of time, $\Theta_{n} = \Theta_{a} + e_g$, where $e_g$ is the converged accumulated error from the gyroscope.
With an appropriate value of $C$, $e_g$ will be small and constant, so it will not affect the stability of the PID controller.
