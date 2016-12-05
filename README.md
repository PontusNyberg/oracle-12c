# Instant Oracle datase server
A [Docker](https://www.docker.com/) [image](https://registry.hub.docker.com/u/wscherphof/oracle-12c/) with [Oracle Database 12c Enterprise Edition Release 12.1.0.2.0](http://www.oracle.com/technetwork/database/enterprise-edition/overview/index.html) running in [Oracle Linux 7](http://www.oracle.com/us/technologies/linux/overview/index.html)
- Default ORCL database on port 1521

## Build
1. [Install Docker-Toolbox](https://www.docker.com/products/docker-toolbox)
2. Start "Docker Quickstart Terminal" to create the default VirtualBox (docker-machine).
3. This image is rather large so we will need to enlarge the VirtualBox disc and then enlarge the partition for the busybox. Make sure your box is turned off.
  You can turn the box off by starting VirtualBox and choose turn off.<br/>
  3.1 Clone the .vmdk image to a .vdi.<br/>
      `$ vboxmanage clonehd "default.vmdk" "default.vdi" --format vdi`<br/>
  3.2 Resize the new .vdi image (50000 ~ 50 GB).<br/>
      `$ vboxmanage modifyhd "default.vdi" --resize 50000`<br/>
  3.3 Optional; switch back to a .vmdk.<br/>
      `$ VBoxManage clonehd "default.vdi" "resized.vmdk" --format vmdk`<br/>
  3.4 Start Virtualbox and choose your box and choose settings -> storage -> default.vmdk -> the icon next to hard-disk -> Choose virtual hard-disk file -> default.vdi or resized.vmdk.<br/>
  3.5 Download the gparted iso from http://gparted.sourceforge.net/download.php<br/>
  3.6 Go to the settings for the Virtualbox like above and choose storage -> boot2docker.iso and click the icon next to Optical Drive -> Choose Virtual Optical Disk Drive -> gparted.iso<br/>
  3.7 Start the default box in VirtualBox and it will boot on the gparted disc, choose GParted Live and then when it have loaded press enter 3 times so the program starts.<br/>
  3.8 Choose /dev/sda1 and click "Resize/Move" and drag the bar until it fills all the space and click "Resize/Move" then "Apply".<br/>
  3.9 In the VirtualBox window right click on the default box and choose close and "Power off the machine".<br/>
  3.10 Go back into settings and go to storage and change back to the boot2docker.iso, it is located in "C:\Program Files\Docker Toolbox\boot2docker.iso" or where you choose to install it.<br/>
4. Time to let the image build.<br/>
     `$ docker build -t oracle-12c --shm-size=4g .`<br/>
  	This will build everything you need. (Takes about 20m)<br/>
  	Below you can see some of the important steps, if these fails<br/>
  	try again and if multiple tries fail, send an email.<br/>

## Run
Create and run a container named orcl:
```
$ docker run --shm-size=4g -d -p 1521:1521 -p 8080:8080 -p 5500:5500 --name orcl oracle-12c
989f1b41b1f00c53576ab85e773b60f2458a75c108c12d4ac3d70be4e801b563
```

## Connect
The default password for the `sys` user is `change_on_install`, and for `system` it's `manager`
The `ORCL` database port `1521` is bound to the Docker host through `run -P`. To find the host's port:
```
$ docker port orcl 1521
0.0.0.0:1521
```
So from the host, you can connect with `system/manager@localhost:1521/orcl`
Though if using [Boot2Docker](https://github.com/boot2docker/boot2docker), you need the actual ip address instead of `localhost`:
```
$ boot2docker ip

The VM's Host only interface IP address is: 192.168.59.103

```
If you're looking for a databse client, consider [sqlplus](http://www.oracle.com/technetwork/database/features/instant-client/index-100365.html)
```
$ sqlplus system/manager@192.168.59.103:49189/orcl

SQL*Plus: Release 11.2.0.4.0 Production on Mon Sep 15 14:40:52 2014

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Partitioning, OLAP, Advanced Analytics and Real Application Testing options

SQL> |
```

## Monitor
The container runs a process that starts up the database, and then continues to check each minute if the database is still running, and start it if it's not. To see the output of that process:
```
$ docker logs orcl

LSNRCTL for Linux: Version 12.1.0.2.0 - Production on 16-SEP-2014 11:34:56

Copyright (c) 1991, 2014, Oracle.  All rights reserved.

Starting /u01/app/oracle/product/12.1.0/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 12.1.0.2.0 - Production
Log messages written to /u01/app/oracle/diag/tnslsnr/e90ad7cc75a1/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=e90ad7cc75a1)(PORT=1521)))

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 12.1.0.2.0 - Production
Start Date                16-SEP-2014 11:34:56
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Log File         /u01/app/oracle/diag/tnslsnr/e90ad7cc75a1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=e90ad7cc75a1)(PORT=1521)))
The listener supports no services
The command completed successfully

SQL*Plus: Release 12.1.0.2.0 Production on Tue Sep 16 11:34:56 2014

Copyright (c) 1982, 2014, Oracle.  All rights reserved.

Connected to an idle instance.
ORACLE instance started.

Total System Global Area 1073741824 bytes
Fixed Size		    2932632 bytes
Variable Size		  721420392 bytes
Database Buffers	  343932928 bytes
Redo Buffers		    5455872 bytes
Database mounted.
Database opened.
Disconnected from Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Partitioning, OLAP, Advanced Analytics and Real Application Testing options

LSNRCTL for Linux: Version 12.1.0.2.0 - Production on 16-SEP-2014 11:35:24

Copyright (c) 1991, 2014, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 12.1.0.2.0 - Production
Start Date                16-SEP-2014 11:34:56
Uptime                    0 days 0 hr. 0 min. 28 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Log File         /u01/app/oracle/diag/tnslsnr/e90ad7cc75a1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=e90ad7cc75a1)(PORT=1521)))
Services Summary...
Service "ORCL" has 1 instance(s).
  Instance "ORCL", status READY, has 1 handler(s) for this service...
The command completed successfully
```

## Enter
There's no ssh daemon or similar configured in the image. If you need a command prompt inside the container, consider [nsenter](https://github.com/jpetazzo/nsenter) (and mind the [Boot2Docker note](https://github.com/jpetazzo/nsenter#docker-enter-with-boot2docker) there)
or just go for 'docker exec -ti orcl bash', this will get you into terminal on the box.

## License
[GNU Lesser General Public License (LGPL)](http://www.gnu.org/licenses/lgpl-3.0.txt) for the contents of this GitHub repo; for Oracle's database software, see their [Licensing Information](http://docs.oracle.com/database/121/DBLIC/toc.htm)
