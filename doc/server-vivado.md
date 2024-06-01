# Running Vivado on EEE Department server ee-mill1

  You can compile your FPGA project on the EEE department application server. The server is powerful and it can compile projects quicker than most laptops, but you might find the graphical interface to be laggy and hard to use.

## Log in

  You'll need to start a SSH session with X window forwarding to allow you to use the graphical interface.

### Windows

  1. Install [MobaXterm software](https://mobaxterm.mobatek.net/)
  2. ICT are in the process of changing how remote access works. If you are not connected to the College network you can try [Unified Access](https://www.imperial.ac.uk/admin-services/ict/self-service/connect-communicate/remote-access/unified-access/) or [VPN](https://www.imperial.ac.uk/admin-services/ict/self-service/connect-communicate/remote-access/virtual-private-network-vpn/).
  3. Run MobaXterm and start a new session
  4. Choose SSH, enter the hostname `ee-mill1.ee.ic.ac.uk` and your College username
  5. Click OK and enter your College password when prompted

### macOS

  1. Install [XQuartz](https://www.xquartz.org/)
  2. Start a terminal
  3. Start an SSH session with `ssh -X <username>@ee-mill1.ee.ic.ac.uk`

  Once you have logged in, test window forwarding by running `gedit &`. You should see a text editor window.

## Build the example project

 Clone the starter project to your home directory:

  ``` bash
  cd ~
  git clone git@github.com:edstott/EE2Project.git
  ```

  Set up the environment for Vivado by running

  ``` bash
  source /usr/local/Xilinx/Vivado/2023.2/settings64.sh
  ```

Start the Vivado GUI

  `vivado &`

You can also run the scripts to generate the project from the command line

  ``` bash
  vivado -mode batch -source build_ip.tcl
  vivado -mode batch -source base.tcl
  ```

Generate the block design and the bitstream using the GUI.

Once complete, you can copy the output files directly to the Pynq. Run the following commands on the terminal on the Pynq. The username should be your College username and you will be prompted for your College password.

``` bash
scp <username>@ee-mill1.ee.ic.ac.uk:~/EE2Project/maths-accelerator/overlay/base/base.runs/impl_1/base_wrapper.bit ./base.bit
scp <username>@ee-mill1.ee.ic.ac.uk:~/EE2Project/maths-accelerator/overlay/base/base.gen/sources_1/bd/base/hw_handoff/base.hwh ./base.hwh
```
