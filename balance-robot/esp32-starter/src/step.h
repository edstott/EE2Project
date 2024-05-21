#include <Arduino.h>

class step {

public:

    const int MAX_SPEED = 10000;    //Maximum motor speed (steps/s)
    const int MAX_SPEED_INTERVAL_US = 1000; //Maximum interval between speed updates (μs)
    const int SPEED_SCALE = 2000;   //Integer speed units are in steps per SPEED_SCALE seconds
    const int MICROSTEPS = 16;      //Number of microsteps per physical step
    const int STEPS = 200;          //Number of physical steps per revolution
    const float STEP_ANGLE = (2.0 * PI)/(STEPS * MICROSTEPS);   //Angle per microstep (rad)
    int32_t accel = 0;          //current acceleration (steps/s)
    int32_t tSpeed = 0;         //current speed (steps/(SPEED_SCALE * s))

    //Initialise the stepper with interval and pin numbers
    step(int i, int8_t sp, int8_t dp) : interval(i), stepPin(sp), dirPin(dp) {
        pinMode(stepPin, OUTPUT);
        pinMode(dirPin, OUTPUT);
    }

    //Update the stepper motor, performing a step and updating the speed as necessary. Call every interval μs
    void runStepper(){
        //Note: ESP32 doesn't support floating point calculations in an ISR, so this function only uses integer operations
    
        //Increment speed calculation interval timer
        speedTimer += interval;

        //Check for stepping active
        if (step_period != 0) {

            //Increment step timer
            stepTimer += interval;

            //Check for step period elapsed
            if (stepTimer > step_period) {

                //Start pulse
                digitalWrite(stepPin, HIGH);

                //Roll back step timer by one period
                stepTimer -= step_period;

                //Recaculate step interval
                updateSpeed();

                //Set step direction for next step
                digitalWrite(dirPin, speed > 0);

                //Increment/decrement position counter
                position += (speed > 0) ? 1 : -1;

                //End pulse
                digitalWrite(stepPin, LOW);
            }

        } else {
            //Do nothing if stepping inactive
            stepTimer = 0;
        }

        //Recalculate step interval if the last update was longer ago than MAX_SPEED_INTERVAL_US
        if (speedTimer > MAX_SPEED_INTERVAL_US)
            updateSpeed();

    }

    //Set acceleration in rad/s/s. Do not call from ISR
    void setAccelerationRad(float accelRad){
        accel = static_cast<int>(accelRad / STEP_ANGLE);
    }

    //Set acceleration in microsteps/s/s
    void setAcceleration(int newAccel){
        accel = newAccel;
    }
    
    //Set target speed in rad/s. Do not call from ISR
    void setTargetSpeedRad(float speedRad){
        tSpeed = static_cast<int>(speedRad * SPEED_SCALE / STEP_ANGLE);
    }
    
    // Set target speed in microsteps/(SPEED_SCALE * s)
    void setTargetSpeed(int speed){
        tSpeed = speed;
    }
    
    // Get position in microsteps
    int getPosition() {
        return position;
    }
    
    //Get position in rads. Do not call from ISR
    float getPositionRad() {
        return static_cast<float>(position) * STEP_ANGLE;
    }
    
    //Get current speed in microsteps/(SPEED_SCALE * s)
    float getSpeed() {
        return speed;
    }
    
    //Get current speed in rad/s. Do not call from ISR
    float getSpeedRad() {
        return static_cast<float>(speed) * STEP_ANGLE / SPEED_SCALE;
    }

    private:

    int32_t stepTimer = 0;      //time since last step (μs)
    int32_t speedTimer = 0;     //time since last speed update (μs)
    int32_t step_period = 0;    //current time between steps (μs)
    int32_t position = 0;       //current accumulated steps (steps)
    int8_t stepPin;             //output pin number for step
    int8_t dirPin;              //output pin number for direction
    int32_t speed = 0;          //current steps per SPEED_SCALE seconds (steps)
    int32_t interval;           //interval between calls to runStepper (μs)

    //Update the motor speed and step interval
    void updateSpeed(){

        if (accel < 0) accel = -accel;

        //Calculate change to speed
        if (speed < tSpeed){
            speed += accel * speedTimer / (1000000/SPEED_SCALE);
            if (speed > tSpeed){
                speed = tSpeed;
            }
            if (speed > MAX_SPEED * SPEED_SCALE) {
                speed = MAX_SPEED * SPEED_SCALE;
            }
        }
        else {
            speed -= accel * speedTimer / (1000000/SPEED_SCALE);
            if (speed < tSpeed){
                speed = tSpeed;
            }
            if (speed < -MAX_SPEED * SPEED_SCALE) {
                speed = -MAX_SPEED * SPEED_SCALE;
            }
        }

        //Reset speed calculation timer
        speedTimer = 0;

        //Calculate step period
        if (speed == 0)
            step_period = 0;
        else if (speed > 0)
            step_period = 1000000 * SPEED_SCALE / speed;
        else
            step_period = -1000000 * SPEED_SCALE / speed;
    }

};