# NeFiAS Documentation (early alpha)

<img align="right" src="https://github.com/cdpxe/nefias/raw/master/documentation/logo/nefias_logo.png" title="NeFiAS logo" />

(C) 2020 Prof. Dr. Steffen Wendzel (Cyber Security Research Group (CSRG)/Zentrum für Technologie & Transfer, Worms University of Applied Sciences, Germany)

NeFiAS (*Network Forensics and Anomaly Detection System*) is a shell-based tool for performing network anomaly detection, especially in the domain of network covert channels (network steganography, see (Wendzel et al., 2015) or [our project on network covert channel patterns](https://ih-patterns.blogspot.com)). NeFiAS was (initially) written by [Steffen Wendzel](http://www.wendzel.de) (see below for a list of contributors).

NeFiAS is a a tiny framework (very few lines of code), super portable (standard Linux + SSH + TShark), can be run on every hardware (even very old ones) as a beowulf cluster, and can be installed in a few minutes.

# The story behind this tool

In 2017, my colleagues and me developed WoDiCoF, the *Worms Distributed Covert Channel Detection Framework* (see (Keidel et al., 2018)). As its name implies, WoDiCoF was a system for network covert channel detection. However, WoDiCoF was based on Apache Hadoop and I wanted a very(!) lightweight network anomaly detection system (of course, also tailored for covert channel detection). And I wanted it without dependencies on things like Hadoop, Tomcat, Java (at all!), Python 2.x (we wrote some WoDiCoF code using Python 2, it was required to modify the code for Python 3), etc. Also, I wanted this system to be trivial to deploy on nodes and run on standard Linux. For this reason, I decided to implement one tiny network anomaly detection system (mostly for myself) in `bash`, using `awk` and similar tools. It might not be the fastest, and bash scripting is not the best solution to several problems, but if I can easily distribute workload on many nodes, it might still provide a good performance. Moreover, I wanted a system that can easily be extended and can be used in the scientific community to analyze detection algorithms and to perform replication studies.

Note: NeFiAS contains some WoDiCoF code, for instance, `pcapng2csv` was originally written for the WoDiCoF project.


# Architecture

## Node Types and Job Concepts
NeFiAS requires two types of nodes: a master node and at least one slave node. Theoretically, master node and slave node can be installed on the same computer, so a one-node NeFiAS installation is possible. However, the more slave nodes you have, the more performance you will get. NeFiAS processes so-called **jobs**, i.e. computing tasks.

The **master node** is responsible of executing such a NeFiAS job. Therefore, the master node reads the input traffic (CSV format, can also be PCAP/PCAPNG, see below), extracts the relevant traffic meta-data (e.g. source IP address, destination IP address, packet length or other attributes), and splits the data into chunks (of configurable size). The master node then uploads the chunks to the **slave nodes**; the master node also uploads computation scripts and the NeFiAS library script(s) to the slave nodes. The master node monitors the progress of the slave nodes and fetches computation results, once they are completed. Once a node becomes idle, it receives new chunks. When all chunks are completed, the master node ends the job.

Check the available NeFiAS [Detector Scripts](https://github.com/cdpxe/nefias/blob/master/scripts/README.md).

## Communication Architecture

NeFiAS is entirely based on `ssh` and `scp`, it also takes advantage of the OpenSSH-internal encryption and compression functionality. Using OpenSSH has the following reason: a) OpenSSH is reliable and secure, b) OpenSSH is widely known and often already installed by default (if not, a package/port is available), c) implementing an own communication architecture could not be much better than OpenSSH. There might be faster solutions feasible, but NeFiAS' design concept foresees that performance is *only* achieved through parallelization, not through efficient implementation.

# Setup

## Setting up the NeFiAS master

Install the following command line tools under your Linux host (probably, it will also work on *BSD or *Un*x): `bc` (console calculator), `dialog` (optional), `bash`, `ssh`/`scp`, `awk`, `sed`, `tr`, `split`, `gzip`, `tshark` (optionally, but pretty useful). So, on a common Ubuntu Linux, you simply run this command (most likely, the majority of these tools is already installed by default):

`$ sudo apt install bc dialog openssh-client gawk gzip tshark`

Then, perform the following commands, to have `nefias` installed in your `$HOME/nefias`:

```
$ cd ~
$ git clone https://github.com/cdpxe/nefias.git
```

## Setting up NeFiAS slave nodes

On each slave node, create a user `nefias`.

`$ adduser nefias`

Then, login as `nefias` (e.g. using `su -l nefias`) and create a nefias directory tree.

```
$ mkdir ~/nefias
$ mkdir ~/nefias/{finished,input,results,scripts,tmp}
```

Next, install some standard Linux tools and the OpenSSH service if in case you do not have them already:

`$ sudo apt install bc openssh-server gawk gzip`

Finally, deploy the SSH public key of the master node on each slave node. On the slave node (using the `nefias` user, create the *~/.ssh* directory, if not present so far:

`$ mkdir ~/.ssh; chmod 700 ~/.ssh`

We are almost done now. Now, copy the master node's SSH key to each slave node and mark it as *authorized* (otherwise, you would need to enter a password for each deployed nefias Job several times on each slave node, which would be painful):

On the master (for each slave): `$ scp ~/.ssh/id_rsa.pub nefias@your.slave.node:~/`

On each slave: `$ cat id_rsa.pub >> .ssh/authorized_keys; rm id_rsa.pub`

Finally, on your master node, add every slave node to your nefias configuration file *slaves.cfg* in the following form 'host:/directory/to/nefias':

```
# do not use a comma to separate elements
slaves=(
   '192.168.0.101:/home/nefias/nefias'
   '192.168.0.102:/home/nefias/nefias'
   'some-cloud-host.xyz:/home/nefias/nefias'
)
```

That's all!

## If you run into problems

Likely, you will receive an error message like `argument list too long` sooner or later. This is rooted in the limited stack space (usually 8192k).

**Solution 1:** Decrease the size of chunks (in lines). This will decrease the required stack space.


**Solution 2:** You can increase the stack size for the `nefias` user in each slave node's */etc/security/limits.conf*.

For instance, you could add the following line:

```
nefias	soft	stack 65000
nefias  hard	stack 65000
```

This provides a stack space of 65.000 kBytes for the `nefias` user.

# Running Jobs with NeFiAS

Alright, let's try and see if everything works! On your master node, run the following command,
which will use the slaves mentioned in *slaves.cfg*. It will then split the traffic file
*recordings/TCC_localhost/TCC_20-50_ABABAB.pcap.csv* in a couple of chunks and run the script `scripts/kappa_IAT.sh` (some anomaly detection score for inter-arrival times) for these chunks on the slave nodes.

```
$ cd ~/nefias
$ ./nefias_master.sh --slave-hostconfig=slaves.cfg --slave-script=scripts/kappa_IAT.sh --traffic-source=recordings/TCC_localhost/TCC_20-50_ABABAB.pcap.csv

```

If everything worked fine, you should find the results of all slave nodes in your local results directory:

```
$ ls results/
nefias_11726.chunk_00.results  nefias_11726.chunk_01.results
```
The output of these jobs entirely depends on the scripts you execute on your slave nodes, for
instance, above-mentioned script `kappa_IAT.sh` calculates a compressibility score (*kappa value*) for all IP flows. Let's have a look:

```
$ cat results/*
143.93.191.117,143.93.191.118,,,44074,9999,,, K=16.110344
143.93.191.118,143.93.191.117,,,9999,44074,,, K=15.855203
143.93.191.117,143.93.191.118,,,44074,9999,,, K=16.004566
143.93.191.118,143.93.191.117,,,9999,44074,,, K=15.895691
```
As you can see, there were only two flows (one connection with two directions). The first two columns are source and destination IP address, followed by source and destination IPv6 addresses (alternatively), followed by the TCP source and destination ports, and finally, the UDP source and destination ports (here empty). The resulting kappa value for each flow is listed at the end. Note that each flow appears twice as the flow was found in both chunks.

NeFiAS assigns every job a number by default, as you can see in the results' filenames, it was `11726` in our case. However, you can give every job your own additional name using `--jobname="Experiment123-Parameter-A-B-C"`.

Btw. have a look at `./nefias_master --help` -- this will print all the available parameters that you can use.

## Monitoring NeFiAS progress

To visually monitor the progress of NeFiAS on the master node, open a terminal, and run `./nefias_monitor.sh`.

## Using PCAP files or custom header fields as input for NeFiAS

### Using PCAP(ng) files

NeFiAS can be used with PCAP files, however, they must be processed by `tshark` first. 
For example, use the following command to export the data in the correct way:

`$ ./pcapng2csv.sh recording.pcapng recording.csv`

Finally, use the output data with the parameter `--traffic-source=recording.csv`.

Note: It is fine you only have IPv4 OR only IPv6 OR both. If is also fine if you have no TCP and/or no UDP flows, but e.g. just ICMP.


### Adding custom header fields to your CSV data

Feel free to add additional values to the list of exported fields, such as HTTP parameters, or parameters of any other protocol supported by `tshark`.

However, `nefias_master` needs to know that it should use these header fields, so you need to provide these fields using the parameter `--values=frame.number,...`. The default setting for the `--values` parameter is `--values="frame.number,frame.time_relative,frame.len,ip.src,ip.dst,ipv6.src,ipv6.dst,tcp.srcport,tcp.dstport,udp.srcport,udp.dstport"`

**Note:** TShark can generate CSV (textual) output based on the content of PCAP files. You can add custom header fields here as well. To this by modifying the variable `HEADER_FIELDS` in `pcapng2csv.sh`. However, what you NEED to export are the following fields; they MUST appear in the following order: `frame.number,frame.time_relative,frame.len,ip.src,ip.dst,ipv6.src,ipv6.dst,tcp.srcport,tcp.dstport,udp.srcport,udp.dstport`


# Local parallelization on slave nodes

An easy way to perform a parallel computation of scripts is to create multiple directory trees for NeFiAS on each slave node and then add each directory tree to the slave configuration file.

For instance, create the following directory structure on one of the slave nodes to run two NeFiAS scripts in parallel (e.g. useful when you have 2 CPU cores):

```
mkdir /home/nefias/nefias1/{finished,input,results,scripts,tmp}
mkdir /home/nefias/nefias2/{finished,input,results,scripts,tmp}
```

And in your slave configuration file (assuming the hostname is *myhost.xyz*):

```
slaves=(
   'myhost.xyz:/home/nefias/nefias1'
   'myhost.xyz:/home/nefias/nefias2'
)
```

# Writing own NeFiAS scripts

The real value of NeFiAS lies in the fact that you can run your own calculations within your own jobs. To this end, you need to implement own or modify **[existing NeFiAS scripts](https://github.com/cdpxe/nefias/blob/master/scripts/README.md)**, which you can find in the *scripts/* subdirectory of NeFiAS on your master node.

## Standard format for NeFiAS scripts

Every NeFiAS script basically looks as follows (this code is executed for every chunk of every job separately):

```
#!/bin/bash
source "`dirname $0`/nefias_lib.sh"
NEFIAS_INIT_PER_FLOW $1 $2 "tcp"

for flow in $FLOWS; do
	# magic happens here
done

NEFIAS_FINISH
```

The code above first includes the functionality of the NeFiAS library, then initiates the job with NEFIAS_INIT_PER_FLOW. The first two parameters (filename to process as well as jobname) are provided by NeFiAS itself and need to be passed. The third parameter (`"tcp"`) means that you want to focus on TCP flows (defined by source and destination IPv4/v6 address and TCP source/destination port). However, you can also pass the parameter (`"udp"`) for UDP flows, `"udp+tcp"` for all UDP and all TCP flows, or`"ip"` for IPv4/v6 flows (i.e. one flow may contain multiple TCP streams and UDP "connections").

Next, we see a loop to iterate trough all flows found in the data chunk that the node just received. Finally, NEFIAS_FINISH performs the necessary steps to finalize the work on the data chunk.

To exemplify, let us have a look on a typical content of above-mentioned `for` loop by analyzing the script `scripts/kappa_framelen.sh`'s loop, which is used to detect network covert channels that utilize packet sizes for hidden communications, see (Wendzel et al., 2015) and (Wendzel et al., 2019):

```
#!/bin/bash
# kappa_framelen.sh: calculate Kappa compressibility score based on frame length of a flows's packets
# This script receives the following parameters: ./script [chunk] [jobname]

source "`dirname $0`/nefias_lib.sh"
NEFIAS_INIT_PER_FLOW $1 $2 "ip" # || tcp || udp

for flow in $FLOWS; do
	# always get the first 1000 packets of that flow and calculate the kappa value based on the frame length.
	cat ${TMPPKTSFILE} | grep $flow | head -1000 | awk -F\, ${FLOWFIELDS} \
	'function abs(x) { return x<0 ? -x : x }
	BEGIN{ previous=0; output=""; counter=0 }
	{
		output = output sprintf(abs(previous-$frame_len)",") 
		previous=$frame_len;
		counter++;
	}
	END {
		# make sure the window is filled with enough pkts (max defined by head -n)
		if (counter >= 1000) print output;	
	}' > ${TMPWORKFILE}
	gzip -9 --no-name --keep ${TMPWORKFILE}
	S_len=`/bin/ls -l ${TMPWORKFILE} | awk '{print $5}'`
	if [ "$S_len" = "0" ]; then
		# too few elements (less than window size)
		touch ${TMPRESULTSFILE} # just let NEFIAS know that we did our job here (create the file, if not present)
	else
		C_len=`/bin/ls -l ${TMPWORKFILE}.gz | awk '{print $5}'`
		K=`echo "scale=6;($S_len/$C_len)" | bc`
		echo "${flow}, K=${K}" >> ${TMPRESULTSFILE} # Temporary storage for results until all entries were calculated
	fi
	rm -f ${TMPWORKFILE} ${TMPWORKFILE}.gz # clean-up our temporary files
done

NEFIAS_FINISH
```

The first statement in the `for` loop starts with a `cat $TMPPKTSFILE`. This allows us to filter all packets belonging to the currently processed `$flow` in the following way: All packets are contained in `${TMPPKTSFILE}`. From this file, we `grep` all packets that belong to the flow `$flow`, take the first 1.000 of these packets, and then let `awk` process each packet (*one packet = one line of input data*!). The `awk` code simply calculates the absolute differences between frame sizes and concatenates them; finally, the whole concatenated string is printed.

Header fields can be accessed using `awk` by providing the parameters `-F\, ${FLOWFIELDS}` using the format `$name_of_headerfield`, e.g. `ip_src`, `tcp_srcport` or `frame_time_relative`. Please note that field names used by tshark (e.g. `ip.src` are replaced with underscores: `ip_src`).

Every NeFiAS script can use `${TMPWORKFILE}` to store immediate results. This variable is provided by NeFiAS, just like `$FLOWFIELDS` and `$TMPPKTSFILE` (contains all packets of a data chunk) and `$TMPRESULTSFILE` (to store your textual computation results, which will then be transferred back to the master node).

After the `awk` code finished, we check the compressibility of our previously printed string in the following way (of course, you could do whatever else you want here!), however, **the key point is that you write your results in the file `${TMPRESULTSFILE}`**:

```
	# compress our original file
	gzip -9 --no-name --keep ${TMPWORKFILE}
	# get length of file
	S_len=`/bin/ls -l ${TMPWORKFILE} | awk '{print $5}'`
	if [ "$S_len" = "0" ]; then
		# too few packets
		touch ${TMPRESULTSFILE} # just let NEFIAS know that we did our job here (create the file, if not present)
	else
		# get length of compressed file
		C_len=`/bin/ls -l ${TMPWORKFILE}.gz | awk '{print $5}'`
		# calculate compressibility using bc
		K=`echo "scale=6;($S_len/$C_len)" | bc`
		# finally, write the computation's result into the results file
		echo "${flow}, K=${K}" >> ${TMPRESULTSFILE} # Temporary storage for results until all entries were calculated
	fi
	rm -f ${TMPWORKFILE} ${TMPWORKFILE}.gz # cleanup our intermediate files
```

Finally, `NEFIAS_FINISH` is called, which provides the results stored in `$TMPRESULTSFILE` to NeFiAS and allows the master node to fetch these results and to provide the slave node with the next chunk of data. 

**Hint:** Have a look into the scripts of the NeFiAS subdirectory *scripts/* on the master node to see further examples. Feel free to use them as a basis for your own scripts. *Publications of scripts through our GitHub repository are highly appreciated!*



# Additional comments (pre-alpha)

## Increasing the performance of slave nodes

Mount everything as *tmpfs* to speed-up all the stuff

*BEFORE* creating the directories on each node, do this:

```
$ sudo mount -t tmpfs swap /home/nefias/nefias/
$ sudo chown nefias:nefias /home/nefias/nefias/
$ sudo chmod 770 /home/nefias/nefias/
```


# Academic references to NeFiAS

NeFiAS was used for a few scientific experiments. Papers who used NeFiAS are cited below; if available, their codes are linked here as well.

- The script `kappa_TCP_seqmod_message_ordering_pattern.sh` does exactly, what was done in (Wendzel, 2019) for detecting the [Message Ordering](http://ih-patterns.blogspot.com/p/p10-pdu-order-pattern.html) pattern in TCP, i.e. those covert channels that modulate the order of TCP segments. The script basically calculates the compressibility score (K) using different window sizes. However, please note that the original work used a window size of 200 segments and only the best performing type of string coding (one out of four presented in the original paper) is implemented in the NeFiAS script. 
- Essentially the same functionality like provided by the script `scripts/kappa_frametime.sh` (minimal differences) was used in (Wendzel et al., 2019) to calculate the compressibility score for network covert channels that modulate sizes of succeeding packets (such covert channels implement the so-called [Size Modulation](http://ih-patterns.blogspot.com/p/p1-size-modulation-pattern.html) hiding pattern).
- Essentially the same functionality like provided by the script `scripts/kappa_IAT.sh` (but different coding, thus different Kappa values) was used in (Keidel et al., 2018) to calculate the compressibility score for network covert channels that modulate inter-arrival times between succeeding network packets (such covert channels implement the so-called [Inter-packet Times](http://ih-patterns.blogspot.com/p/blog-page_40.html) hiding pattern.
- Two scripts were used for the work on (Mileva et al., 2020) (see `scripts/README.md` directory), including a detection of the **Artificial Re-connections** pattern.

# Troubleshooting

- Running some of the scripts, I get the error message `awk: line x: illegal reference to array ...`.
	- Solution: You probably run another version of AWK as originally used by the developer. Install `gawk` instead.

# Contributors

The following people contributed substantially to NeFiAS:

- Kevin Albrechts, University of Hagen, Germany
- Sebastian Zillien, Worms University of Applied Sciences, Germany


# References

* (Wendzel et al., 2015) S. Wendzel, S. Zander, B. Fechner, C. Herdin: [Pattern-Based Survey and Categorization of Network Covert Channel Techniques](https://doi.org/10.1145/2684195), Computing Surveys (CSUR), Vol. 47(3), ACM, 2015.
* (Keidel et al., 2018) R. Keidel, S. Wendzel, S. Zillien et al.: [WoDiCoF - A Testbed for the Evaluation of (Parallel) Covert Channel Detection Algorithms](http://dx.doi.org/10.3217/jucs-024-05-0556), Journal of Universal Computer Science (J.UCS), Vol. 24(5), 2018.
* (Wendzel et al., 2019) S. Wendzel, F. Link, D. Eller, W. Mazurczyk: [Detection of Size Modulation Covert Channels Using Countermeasure Variation](http://www.jucs.org/jucs_25_11/detection_of_size_modulation), Journal of Universal Computer Science (J.UCS), Vol. 25(11), pp. 1396-1416, 2019.
* (Wendzel, 2019) S. Wendzel: [Protocol-independent Detection of 'Messaging Ordering' Network Covert Channels](https://doi.org/10.1145/3339252.3341477), in Proc. ARES 2019 (Third International Workshop on Criminal Use of Information Hiding – CUING 2019), pp. 63:1-63:8, ACM, 2019.
* (Mileva et al., 2020) A. Mileva, A. Velinov, L. Hartmann, S. Wendzel, W. Mazurczyk: Comprehensive Analysis of MQTT 5.0 Susceptibility to NetworkCovert Channels, under review.
