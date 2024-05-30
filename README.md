#Training Task 4. Setting up a virtual network with shell scripts:

##Introduction:
The scripts contained in this repo are designed to set up a local network with a gateway, DHCP server and DNS server. There is also a script to install, configure and run the app found in the “trainee-challenge-node-app” repo.

To simplify the scripting and get the basic functionality sorted out I hardcoded a lot of variables like the network interface name, IP addresses and app environment variables. A more complex script could be written to find information like the NIC names with awk and then store these to be used later in the script but I thought this might be over-engineering the problem. Another idea I had was to write a single script that could set up all the servers by running commands on each of the different machines via ssh, this would need all of the VMs to be connected to the network already though which would mean half of the jobs would have already been done. I also modified most of the config files by simply overwriting the existing ones with minor changes, I could have probably have used something like awk to find and replace specific lines but this would’ve involved spending a long time learning regex expressions and I decided to focus on getting the task working first. I could have a go at making some of these improvements if I have nothing to do another day.

##Usage:
The intended way to run these scripts is by scp copying them over and running them on each of the VMs. VMs were created from the CentOS8Stream template and I tried to keep the manual configuration needed to a minimum.

###Gateway:
Set up a gateway VM and ssh copy all of the scripts over from the dev machine. The Gateway is connected to the EAS VM network so its external NIC is already configured and the IP can be obtained using:
 
$ nmcli
 
or your favourite network command.

We can ssh into the dev machine and run the script by running:

$ bash /data/NetworkScripts/Task4GatewayScript.sh

The path may be different depending on where you copied your scripts to.

The gateway is now fully configured. 

###DHCP:
We need to connect the DHCP server to the network so that we can copy our script over to it. We use an nmcli command to configure the network interface to use a static IP address and give it the IP address of our gateway:

$ nmcli con mod ens33 ipv4.method manual ip4 10.1.1.2/24 ipv4.gateway 10.1.1.1

We now need to restart the NetworkManager to make sure the changes take effect:

$ systemctl restart NetworkManager

Now we can copy over the Task4DHCPScript.sh script from the gateway to the DHCP server. And run it with bash. It will run until it pauses to prompt the user for the MAC address of the DNS server network card. This is so that it can configure a static IP address for the DNS server that it can send out to any new VMs created on the network. The MAC address of the DNS VM can be found by running nmcli on the DNS VM. This input is not validated so make sure to get it right first time, adding validation at this stage would be an important upgrade to the script.

Once the DNS MAC address is entered the script will finish running and when it completes the DHCP server will be fully configured.

###DNS
If we booted up the DNS server before the DHCP setup was finished we will need to restart NetworkManager before it will connect to the network.

We should then be able to scp the Task4DNSScript.sh script straight onto the DNS server, its IP address is hard coded as 10.1.1.3 in the script files. We can then bash the script as normal to configure the DNS server.

###APP
In the same way as with the DNS server we might need to restart the App VM NetworkManager before it can get its config from the DHCP server.

Copy Task4AppScript.sh to the App VM and bash it, it should run until the app starts, and waits for a request. We can send a request to the app from any other network VM by running the command:

$ curl http://10.1.1.50:8000

This should print a bunch of JSON data to the console of the connecting VM and print a complete message on the app VM, confirming that our scripts have done their job.
