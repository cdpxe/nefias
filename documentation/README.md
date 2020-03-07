# NeFiAS Documentation

(C) 2020 Prof. Dr. Steffen Wendzel (Cyber Security Research Group (CSRG)/Zentrum für Technologie & Transfer, Worms University of Applied Sciences, Germany)

NeFiAS (*Network Forensics and Anomaly Detection System*) is a shell-based tool for performing network anomaly detection, especially in the domain of network covert channels (network steganography). NeFiAS was (initially) written by [Steffen Wendzel](http://www.wendzel.de) (see below for a list of contributors).

NeFiAS is a a tiny framework (very few lines of code), super portable (standard Linux + SSH + TShark), can be run on every hardware (even very old ones) as a beowulf cluster, and can be installed in a few minutes.

# The story behind this tool

In 2017, my colleagues and me developed WoDiCoF, the *Worms Distributed Covert Channel Detection Framework* (see (Keidel et al, 2018)). As its name implies, WoDiCoF was a system for network covert channel detection. However, WoDiCoF was based on Apache Hadoop and I wanted a very(!) lightweight network anomaly detection system (of course, also tailored for covert channel detection). And I wanted it without dependencies on things like Hadoop, Tomcat, Java (at all!), Python 2.x (we wrote some WoDiCoF code using Python 2, it was required to modify the code for Python 3), etc. Also, I wanted this system to be trivial to deploy on nodes and run on standard Linux. For this reason, I decided to implement one tiny network anomaly detection system (mostly for myself) in `bash`, using `awk` and similar tools. It might not be the fastest, and bash scripting is not the best solution to several problems, but if I can easily distribute workload on many nodes, it might still provide a good performance. Moreover, I wanted a system that can easily be extended and can be used in the scientific community to analyze detection algorithms and to perform replication studies.

Note: NeFiAS contains some WoDiCoF code, for instance, `pcapng2csv` was originally written for the WoDiCoF project.


# Architecture

## Node Types and Job Concepts
NeFiAS requires two types of nodes: a master node and at least one slave node. Theoretically, master node and slave node can be installed on the same computer, so a one-node NeFiAS installation is possible. However, the more slave nodes you have, the more performance you will get. NeFiAS processes so-called **jobs**, i.e. computing tasks.

The **master node** is responsible of executing such a NeFiAS job. Therefore, the master node reads the input traffic (CSV format, can also be PCAP/PCAPNG, see below), extracts the relevant traffic meta-data (e.g. source IP address, destination IP address, packet length or other attributes), and splits the data into chunks (of configurable size). The master node then uploads the chunks to the **slave nodes**; the master node also uploads computation scripts and the NeFiAS library script(s) to the slave nodes. The master node monitors the progress of the slave nodes and fetches computation results, once they are completed. Once a node becomes idle, it receives new chunks. When all chunks are completed, the master node ends the job.

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

# Running Jobs with NeFiAS

Alright, let's try and see if everything works! On your master node, run the following command, which will use the slaves mentioned in *slaves.cfg*. It will then split the traffic file *mypcap.csv* in a couple of chunks and run the script `scripts/kappaIAT.sh` (some anomaly detection score for inter-arrival times) for these chunks on the slave nodes.

```
$ cd ~/nefias
$ ./nefias_master.sh --slave-hostconfig=slaves.cfg --slave-script=scripts/kappaIAT.sh --traffic-source=mypcap.csv

```

If everything worked fine, you should find the results of all slave nodes in your local results directory:

```
$ ls results/
nefias_11726.chunk_00.results  nefias_11726.chunk_01.results
```
The output of these jobs entirely depends on the scripts you execute on your slave nodes, for instance, above-mentioned script `kappaIAT.sh` calculates a compressibility score (*kappa value*) for all IP flows. Let's have a look:

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

Feel free to add additional values to the list of exported fields, such as HTTP parameters, or parameters of any other protocol supported by `tshark`. You can do this by modifying the variable `HEADER_FIELDS` in `pcapng2csv.sh`.

However, `nefias_master` needs to know that these header fields must be used, so you need to provide them using the parameter `--values=frame.number,...`. The default setting for the `--values` parameter is `--values="frame.number,frame.time_relative,frame.len,ip.src,ip.dst,ipv6.src,ipv6.dst,tcp.srcport,tcp.dstport,udp.srcport,udp.dstport"`

Note: These parameters

# Writing own NeFiAS scripts

TODO

Note: TShark can generate CSV (textual) output based on the content of PCAP files. What you NEED to export are the following fields; they MUST appear in the following order:

`frame.number,frame.time_relative,frame.len,ip.src,ip.dst,ipv6.src,ipv6.dst,tcp.srcport,tcp.dstport,udp.srcport,udp.dstport`




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

- N.N.

# Contributors

The following people contributed substantially to NeFiAS:

- N.N.

# References

* (Keidel et al., 2018) R. Keidel, S. Wendzel, S. Zillien et al.: [WoDiCoF - A Testbed for the Evaluation of (Parallel) Covert Channel Detection Algorithms](http://dx.doi.org/10.3217/jucs-024-05-0556), Journal of Universal Computer Science (J.UCS), Vol. 24(5), 2018.


