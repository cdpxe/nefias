# Documentation of Script [`eSim_IAT_frametimerelative.sh`](https://github.com/cdpxe/nefias/blob/master/scripts/eSim_IAT_frametimerelative.sh)

### Short Description

Calculates epsilon similarity scores using a static window size (2,001) on the basis of inter-packet gaps (per flow); this script helps to detect network covert channels that modulate the timings between succeeding network packets (such covert channels implement the so-called [Inter-packet Times](http://ih-patterns.blogspot.com/p/blog-page_40.html) hiding pattern)

### Author

Kevin Albrechts, in cooperation with Steffen Wendzel

### Comment/Reference

Implementation of epsilon similarity for inter-packet times pattern described by (Cabuk et al., 2004 and 2009).

### Funcitonality

##### Input

* Chunk of the traffic recording to be analysed and
* Jobname

##### Output

* A file that contains one line per flow, where the flow is part of the input chunk and has at least the amount of packets defined by `head -n`. Here, a flow is referred to as one direction of an IP-conncection. A flow, therefore, is characterized by a sender and a receiver IP address, port numbers are not taken into account.
* A line consists of the information of the flow, such as source and destination IP addresses, followed by the calculated epsilon similarity scores (in %).
* The epsilon similarity scores of the following epsilon values are calculated: 0.005, 0.008, 0.01, 0.02, 0.03, 0.1 and >= 0.1 .

##### Computation Steps

The script starts with including the functionality of the NeFiAS library script `nefias_lib.sh`.

Afterwards, the flows are initialized by calling `NEFIAS_INIT_PER_FLOW`. The third parameter within this statement is `"ip"`. This is chosen because only inter-packet times (gaps) between network packets are relevant to the [Inter-packet Times](http://ih-patterns.blogspot.com/p/blog-page_40.html) hiding pattern regardless of whether it contains a tcp segment or udp datagram.

The script mainly consists of a for loop over all flows of the input chunk. Within this loop, the following computation steps are carried out:

1. "Grab" (`grep`) the first 2.001 packets of a flow.
2. ...



Lastly, the script calls `NEFIAS_FINISH` to finalize the processing of the chunk.


### Plots

### Results



### Customize the script for own research

##### Window size

...Wo anpassen

##### Epsilon values

---Wo anpassen (begin, end)


### Special ...

The script `eSim_IAT_frametimerelative.sh` has the following special characteristics:

* It requires `gawk` due to built-in functions asort() und length().
* Line 58-65: If an inter-packet time equals 0, the corresponding lambda value is also set to 0. This serves to avoid a division by 0, since inter-packet time is in the denominator of the quotient when calculating lambdas.

