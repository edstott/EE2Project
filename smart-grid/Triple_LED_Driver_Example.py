from machine import Pin, I2C, ADC, PWM, Timer,SPI
from PID import PID ### !!!! Ensure PID.py is copied to the Pico for this to function.
import time

global timer_elapsed
timer_elapsed = 0
firstrun = 1

# This is the function executed by the loop timer, it simply sets a flag which is used to control the main loop
def tick(t): 
    global timer_elapsed
    timer_elapsed = 1


# Set up pins and PWMS
pwm_red_pin = Pin(11)
pwm_yel_pin = Pin(9)
pwm_grn_pin = Pin(7)

pwm_red_en = Pin(10, Pin.OUT)
pwm_yel_en = Pin(8, Pin.OUT)
pwm_grn_en = Pin(6, Pin.OUT)

pwm_red = PWM(pwm_red_pin)
pwm_yel = PWM(pwm_yel_pin)
pwm_grn = PWM(pwm_grn_pin)

pwm_red.freq(100000)
pwm_yel.freq(100000)
pwm_grn.freq(100000)

# Initial current setpoints
setpoint_red = 0.1
setpoint_yel = 0.5
setpoint_grn = 0.9

# Initial PI setup. Some rough gains to get you going but you may tune them as you need.
controller_red = PID(0.001, 1, 0, setpoint=setpoint_red, scale='ms')
controller_yel = PID(0.001, 1, 0, setpoint=setpoint_yel, scale='ms')
controller_grn = PID(0.001, 1, 0, setpoint=setpoint_grn, scale='ms')

# Counters and things.
count = 0
pwm_out = 0
pwm_ref = 0
delta = 0.3

# SPI setup for the ADC chip
spi = SPI(0, baudrate=400000)
adc_cs = Pin(17, mode=Pin.OUT, value=1)

def readadc(channel): # Function to read from a selected channel on the ADC
    txdata = bytearray([6 + (channel >> 2), (channel & 3) << 6, 0])
    rxdata = bytearray(len(txdata))
    try:
        adc_cs(0)                               # Select peripheral.
        time.sleep_us(10)
        spi.write_readinto(txdata, rxdata)  # Simultaneously write and read bytes.
    finally:
        adc_cs(1)                               # Deselect peripheral.
        
    return ((rxdata[1] & 15) << 8) + rxdata[2]

def saturate(duty): # Saturate a duty cycle so its not fully on or fully off
    if duty > 62500:
        duty = 62500
    if duty < 100:
        duty = 100
    return duty

while True:
    
    if firstrun:
        # This starts a 1kHz timer which we use to control the execution of the control loops and sampling
        loop_timer = Timer(mode=Timer.PERIODIC, freq=1000, callback=tick)
        firstrun = 0
        
        # It also turns off the PWM enables
        pwm_red_en.value(0)
        pwm_yel_en.value(0)
        pwm_grn_en.value(0)
    
    if timer_elapsed == 1: # This is executed at 1kHz
    
        #Enable the PWMs (or keep them enabled)
        pwm_red_en.value(1)
        pwm_yel_en.value(1)
        pwm_grn_en.value(1)

        count = count + 1
        
        #get the current measurements
        ired_pin = 2.497*(readadc(4)/4096) # 2.497 is the ADC reference, the readings are 12bit so this gives the ADC pin voltage.
        iyel_pin = 2.497*(readadc(2)/4096)
        igrn_pin = 2.497*(readadc(0)/4096)
        
        #get the voltage measurements
        vred_pin = 2.497*(readadc(5)/4096)
        vyel_pin = 2.497*(readadc(3)/4096)
        vgrn_pin = 2.497*(readadc(1)/4096)
        
        # The current sense is in the negative side of the current path, add the voltage across the current sense resistor to get the full voltage to ground of each LED
        vred = 2*vred_pin - ired_pin
        vyel = 2*vyel_pin - iyel_pin
        vgrn = 2*vgrn_pin - igrn_pin
        
        # The current sense resistor is 330mOhm so the current is 3x the voltage reading.
        ired = 3*ired_pin
        iyel = 3*iyel_pin
        igrn = 3*igrn_pin
        
        #feed the measures into the PIDs
        pwm_red_ref = controller_red(ired)
        pwm_yel_ref = controller_yel(iyel)
        pwm_grn_ref = controller_grn(igrn)
        
        #convert the PID outputs to ints and then saturate
        pwm_red_out = saturate(int(pwm_red_ref*65536))
        pwm_yel_out = saturate(int(pwm_yel_ref*65536))
        pwm_grn_out = saturate(int(pwm_grn_ref*65536))
        
        #send the PWMs out for the next cycle
        pwm_red.duty_u16(pwm_red_out)
        pwm_yel.duty_u16(pwm_yel_out)
        pwm_grn.duty_u16(pwm_grn_out)
        
        if count > 2000: #Printing too often slows the whole thing down
            #print("Vred = {:.3f}".format(vred))
            print("Ired = {:.3f}".format(ired))
            #print("Vyel = {:.3f}".format(vyel))
            print("Iyel = {:.3f}".format(iyel))
            #print("Vgrn = {:.3f}".format(vgrn))
            print("Igrn = {:.3f}".format(igrn))
            
            
            # This loops the setpoints between 0A and 1A to demonstrate function, you will want to determine the setpoints by your own means
            setpoint_red = setpoint_red + 0.1
            if setpoint_red > 1.05:
                setpoint_red = 0
                
            setpoint_yel = setpoint_yel + 0.1
            if setpoint_yel > 1.05:
                setpoint_yel = 0
                
            setpoint_grn = setpoint_grn + 0.1
            if setpoint_grn > 1.05:
                setpoint_grn = 0
            
            # Update the controllers
            controller_red.setpoint = setpoint_red
            controller_yel.setpoint = setpoint_yel
            controller_grn.setpoint = setpoint_grn
            
            # Reset the counter. We go again!
            count = 0
