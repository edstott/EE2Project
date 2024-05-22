from machine import Pin, I2C, ADC, PWM
from PID import PID

vret_pin = ADC(Pin(26))
vout_pin = ADC(Pin(28))
vin_pin = ADC(Pin(27))
pwm = PWM(Pin(0))
pwm.freq(100000)
pwm_en = Pin(1, Pin.OUT)

pid = PID(0.2, 10, 0, setpoint=0.3, scale='ms')

count = 0
pwm_out = 0
pwm_ref = 0
setpoint = 0.0
delta = 0.05

def saturate(duty):
    if duty > 62500:
        duty = 62500
    if duty < 100:
        duty = 100
    return duty

while True:
    
    pwm_en.value(1)

    vin = 1.026*(12490/2490)*3.3*(vin_pin.read_u16()/65536) # calibration factor * potential divider ratio * ref voltage * digital reading
    vout = 1.026*(12490/2490)*3.3*(vout_pin.read_u16()/65536) # calibration factor * potential divider ratio * ref voltage * digital reading
    vret = 1*3.3*((vret_pin.read_u16()-350)/65536) # calibration factor * potential divider ratio * ref voltage * digital reading
    count = count + 1
    
    pwm_ref = pid(vret)
    pwm_ref = int(pwm_ref*65536)
    pwm_out = saturate(pwm_ref)
    pwm.duty_u16(pwm_out)
    
    if count > 2000:
        print("Vin = {:.3f}".format(vin))
        print("Vout = {:.3f}".format(vout))
        print("Vret = {:.3f}".format(vret))
        print("Duty = {:.0f}".format(pwm_out))
        count = 0
        setpoint = setpoint + delta
                
        if setpoint > 0.4:
            setpoint = 0.4
            delta = - delta
        
        if setpoint < 0.05:
            setpoint = 0.05
            delta = -delta
            
        pid.setpoint = setpoint
