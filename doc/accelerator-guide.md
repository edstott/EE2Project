# Mathematics Accelerator

## Requirements

1. The system shall display a visualisation of a mathematical function that is computed in real time
    1. The function shall be computationally intensive, such that it is not trivial to generate the visualisation at the required resolution and frame rate
    2. The computation should be 'embarrassingly parallel', which means that multiple solutions of the problem, pixels in this case, can be computed independently with no data dependence between them
2. The visualisation shall be generated with the supplied PYNQ-1000 SoC FPGA platform with an accelerator for the soft logic of the FPGA that computes the inner loops of the calculation
   1. The accelerator shall be described using Verilog or SystemVerilog
   2. The accelerator shall provide an interface with the integrated CPU for the adjustment of parameters
   3. The number formats and word lengths used in the accelerator should be selected to optimise the trade-off between visualisation accuracy and computational throughput
   4. The computational throughput of the accelerated implementation shall exceed that of a CPU-only alternative programmed with C, C++ or Cython
3. The system shall provide a user interface to enhance the function of the visualisation as an educational tool.
    1. The user interface may be implemented using separate hardware to the visualisation computer
    2. The user interface shall allow a user to adjust parameters of the visualisation in an intuitive or interesting way
    3. The user interface should provide information about the visualisation as an overlay on the image or via a separate medium

## Resources Provided

### Hardware

Pynq kits can be borrowed from EEE Stores. They contain:

- A Pynq FPGA board
- HDMI cable and HDMI-USB adapter
- Ethernet cable and Ethernet-USB adapter
- USB Cable
- WiFi adapter

### Software

Tutorials and code examples for the Pynq can be found on the official GitHub repository.

An example project shows generation of a video pattern using the Zynq CPU core and FPGA logic.

### Project budget

The project requirements specify that the Pynq board is used to generate the visualisation. However, you may wish to purchase additional components to implement the user interface and a budget is available for this.

### Getting started

These are suggested tasks for making a start on the project:

You should begin by following the [Pynq setup guide](https://pynq.readthedocs.io/en/latest/getting_started/pynq_z1_setup.html)

The example notebook for video uses a HDMI input, which might not be readily available to you, and it can be unstable. Instead, load the notebooks provided on the project repository

1. Research areas of mathematics that would make good visualisation and could be implemented with an algorithm that iterates over the image in a raster pattern.
2. Set up a hardware simulation flow with Verilator that can run a Verilog module that generates the colour for given pixel coordinates. Begin with a simple test pattern. Write a simulation wrapper that loops over the pixels in an image and visualises the result as an image file
3. Consider interesting methods for human interaction. Look for hardware suggestions or software libraries that might help
4. Familiarise yourself with the Pynq operating system and Python overlay interface using the demo notebook. Create a placeholder visualisation in software and set up an interface with a remote server or database that will pass in user parameters
5. Set up the Vivado tool flow that will allow you to generate your own Pynq overlay

### Technical information and suggestions

#### Powering the Zynq

The Pynq board can be powered by the USB interface (PROG UART) or an external power supply. Move the jumper JP5 to USB to use USB power and REG to use the power supply.

#### Connectivity

You will need network connectivity to interface with your board.

1. Ethernet (direct): you can plug the Zynq board into an ethernet port on your home router with the included cable. You will need to find the board's IP address to connect - you can do this by looking at DHCP leases on the configuration page for your router, or by typing `ip addr` into the USB command prompt. The board  won't work by connecting it to an ethernet port on the College network unless it happens to have been registered with ICT.
2. Ethernet (via host): the kit includes a USB ethernet adapter, which you can use to connect your Pynq board to the internet via your computer. Connect the Pynq to the ethernet socket and plug the adapter into a USB port on your computer. Then, you need to share your internet connection with the ethernet adapter you have plugged in:
   1. Windows: follow [these instructions](https://www.tomshardware.com/how-to/share-internet-connection-windows-ethernet-wi-fi).
   2. MacOS: follow [these instructions](https://support.apple.com/en-gb/guide/mac-help/mchlp1540/mac)
3. WiFi: the kit also includes a USB WiFi dongle. Plug it into the USB Host port on the Pynq and the operating system will automatically set it up as a networking device. You will need to access a terminal via Ethernet or USB cable to set up WiFi.

#### Development tools

The Pynq has a Jupyter notebook server installed, which allows you to edit and run Python code interactively via a web browser

The configuration for the FPGA logic in a Pynq system is called an overlay, and to edit it you will need [Vivado](https://www.xilinx.com/support/download.html) (version to be confirmed). Vivado can be run on Windows or Linux, so to run it on MacOS you'll need to install it in a Virtual Machine. The overlay is loaded onto the FPGA with a driver and Python API on the Pynq processor system, so you won't need USB drivers to download the overlay from your computer.

Minimise the installation size for Vivado by enabling support only for the Zynq-7000 SoC, which is the device family used on the Pynq-Z1 board.

#### Candidate Visualisations

The purpose of the project is to showcase hardware implementation of an algorithm. A visualisation of a mathematical algorithm is a good area to work with because:

1. A real-time, high-resolution visualisation requires the generation of millions pixels per second, so it's a good demonstration of the computational throughput of an FPGA
2. A mathematical function of the form $a=f(x,y)$, where $a$ is a pixel colour and $x, y$ are the pixel coordinates, is well suited for hardware video generation, which outputs pixels one by one in a raster pattern. A function of this type is also _embarrasingly parallel_, which means that multiple outputs can be computed simultaneously with no need to share any information between them
3. Many numerical algorithms have an interesting dependency on numerical precision. FPGAs can use custom word lengths and achieve significant optimisations compared to software implementations.

Visualising fractals is a common exercise in this domain, since they are visually interesting and a good test of computational throughput. An implementation for Pynq [already exists](), but this doesn't mean you can't implement your own.

Simulations are a popular option for visualisation demos, but they tend to be harder to parallelise because the simulation has a global state that must be shared between execution units. For example, in [N-body simulation](https://en.wikipedia.org/wiki/N-body_simulation), the behaviour of every particle in the system depends on the state of every other particle. Then, the particles must be rendered, which requires random access to a video frame buffer (since each particle could be anywhere on the screen), instead of much simpler sequential access. Therefore, these kinds of problems are not recommended unless you are feeling very confident about your digital design skills.

#### Working with Pynq Overlays

In Pynq, an overlay is a bitstream (programmable logic configuration) plus a Python library that interfaces with it. You will need to develop programmable logic but a Python library is optional because you can use the pre-existing base classes. A custom library for your overlay would make your code neater and more reusable.

The example design is based on the PYNQ base configuration with the addition of a block that generates a video test pattern.
That block is written in Verilog and connected to the rest of the system with the IP Integrator tool.
The block has two main interfaces:

1. An AXI Stream Output (Master - AMD still uses outdated master/slave terminology), which outputs the video data in raster order. A stream interface is just a bus (32-bits in this case) of data, with a valid signal to indicate each clock cycle when it has been updated. A ready signal acts as _backpressure_, which allows the receiver to pause transmission if it is not ready. A done signal indicates the end of a packet of data, which is a complete frame in the case of video data.
2. An AXI-Lite Slave port, which allows the control registers of the block to appear as a memory-mapped peripheral. If the user (via Python code on the processor system) wants to change a parameter of the visualisation, they would write the parameter to a specific address on the memory bus. The bus logic of the CPU and IP integrator system ensures that writes to this address are directed to this logic block. When the design is compiled, the address map for the entire system is written to a file, which is then used to find the address for a peripheral when it is accessed byt the user code. The AXI-Lite interface has slower data throughput than the streaming interface.

The stream output from the block is connected to a Video DMA (direct memory access) IP Block. This block can write to the main memory system independently from the CPU. When a video frame is generated, the DMA writes the image to an array in memory, where it can be accessed by the CPU or read by another DMA block for output to the video device. DMA blocks are configured by the CPU core by a separate AXI-Lite interface but after that they move data around the system without further involvement, which is much quicker than using the CPU core to access every pixel.

Since the example design is already working, you can implement your design just by adding your logic to the frame generator block. Make sure that it can still stream pixels out as required. The rest of the system will handle the rest. Modifying the design in the IP Intergator is not necessary, except in advanced cases.
