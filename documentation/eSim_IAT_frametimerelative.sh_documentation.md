# Documentation of Script [`eSim_IAT_frametimerelative.sh`](https://github.com/cdpxe/nefias/blob/master/scripts/eSim_IAT_frametimerelative.sh)

Contents:

* Short description
* Author
* Comment/reference
* Functionality
* Testing and evaluation of the script
* Customize script for own research
* Further notes


### Short Description

Calculates epsilon similarity scores using a static window size (2,001) on the basis of inter-packet gaps (per flow); this script helps to detect network covert channels that modulate the timings between succeeding network packets (such covert channels implement the so-called [Inter-packet Times](http://ih-patterns.blogspot.com/p/blog-page_40.html) hiding pattern)

### Author

Kevin Albrechts, in cooperation with Steffen Wendzel

### Comment/Reference

Implementation of epsilon similarity for inter-packet times pattern described by (Cabuk et al., 2004 and 2009).

### Functionality

##### Input

* Chunk of the traffic recording (`--traffic-source=`) to be analysed
* Jobname

##### Output

* A file that contains one line per flow, where the flow is part of the input chunk and has at least the amount of packets defined by `head -n`. Here, a flow is referred to as one direction of an IP-conncection. A flow, therefore, is characterized by a sender and a receiver IP address, port numbers are not taken into account. (To distinguish flows additionally by port numbers, choose `tcp+udp` or anything like this. See [`nefias_lib.sh`](https://github.com/cdpxe/nefias/blob/master/scripts/nefias_lib.sh) and the general [documentation](https://github.com/cdpxe/nefias/blob/master/documentation/README.md) for more information on this.)
* A line consists of the flow information, such as source and destination IP addresses, followed by the calculated epsilon similarity scores (in %).
* The epsilon similarity scores of the following epsilon values are calculated: 0.005, 0.008, 0.01, 0.02, 0.03, 0.1 and >= 0.1 .

##### Computation Steps

The script starts with including the functionality of the NeFiAS library script [`nefias_lib.sh`](https://github.com/cdpxe/nefias/blob/master/scripts/nefias_lib.sh).

Afterwards, the flows are initialized by calling `NEFIAS_INIT_PER_FLOW`. The third parameter within this statement is `"ip"`. This is chosen because only inter-packet times (gaps) between network packets are relevant to the [Inter-packet Times](http://ih-patterns.blogspot.com/p/blog-page_40.html) hiding pattern regardless of whether it contains a tcp segment or udp datagram.

The script mainly consists of a for loop over all flows of the input chunk. Within this loop, the following computation steps are carried out:

1. "Grab" (`grep`) the first 2.001 packets of a flow. (Each packet correponds to a line in the input chunk file.)
2. Process these packets with `gawk` (whereas the program-file is specified directly):
   - BEGIN: Epsilon values are declared and initialized.
   - Action statements: Starting from the second packet, the inter-packet times are calculated based on `frame_time_relative` (corresponds to `frame.time_relative`).
   - END:
     - We make sure the window is filled with enough packets (defined by head -n, i.e., 2.001 packets here). There must be at least 3 packets, otherwise an error would occur because of division by 0. If one of these conditions is false, END does not do anything further, i.e. go to step 3.
     - Sort the inter-packet times.
     - Calculate the pairwise relative differences lambda. Please note: If an inter-packet time equals 0, the corresponding lambda value is also set to 0. This serves to avoid a division by 0, since inter-packet time is in the denominator of the quotient when calculating lambdas.
     - Count the number of lambdas which are below the respective epsilon values.
     - Calculate the epsilon similarity scores.
     - Concatenate the epsilon similarity scores to a single string. (in %, rounded to two decimal places)
     - Print out the string of the epsilon similarity scores.
3. Redirect the output of step 2 (either a line of epsilon similarity scores or empty): Overwrite the temporary working file `${TMPWORKFILE}` with this output.
4. Paste the output of step 2 (contained in `${TMPWORKFILE}`) into the temporary results file `${TMPRESULTSFILE}`: If `${TMPWORKFILE}` is empty, `${TMPRESULTSFILE}` will be empty as well. Otherwise, the flow information and the epsilon similarity scores are concatenated and written to `${TMPRESULTSFILE}`.
5. Delete the temporary working file `${TMPWORKFILE}`.


Lastly, the script calls `NEFIAS_FINISH` to finalize the processing of the chunk.

### Testing and Evaluation of the Script

(to be continued) (German -> English)

##### Traffic Recordings

* Legitimate Traffic: Part of NZIX-II data of [WAND Network Research Group](https://wand.net.nz/wits/nzix/2/). The [file](https://wand.net.nz/wits/nzix/2/20000705-152900.php) containing traffic from Wed Jul 5 15:29:00 2000 to Wed Jul 5 17:59:59 2000 was split into 6 almost equally sized files by libtrace for better processing. From the first 4 files, those IP (one-directional) connections were extracted which contain at least 2,001 packets, and from the last 2 files, those with at least 5,000 packets were extracted. Each extracted connection was saved to one file each. To sum up, 542 files were used for testing.
* Covert Channels: The traffic recordings used for testing were provided by Steffen Wendzel and can be found here: [1](https://github.com/cdpxe/nefias/tree/master/recordings/TCC_SCC_ethernet), [2](https://github.com/cdpxe/nefias/tree/master/recordings/TCC_SCC_internet_remotehost), [3](https://github.com/cdpxe/nefias/tree/master/recordings/TCC_localhost).

##### Plots

###### Legitimate Traffic

In addition to the data sets for testing, a legitimate flow from reading newspaper online was recorded (not part of testing) using `tshark`. The newspaper [NWZ Online](https://www.nwzonline.de/) was opened on Sept. 9th 2020 at 22:33. Several articles and local sites were openend and read to simulate legitimate traffic and "normal" behavior on the internet. Recording stopped at 22:55 after 5,000 packets (of both flows/directions). The file can be found [here](https://github.com/cdpxe/nefias/tree/master/recordings/Legitimate_flow_of_reading_newspaper). For the first 2,001 packets of the flow from the newspaper's server to the local (and recordring) host, the following plots show the unsorted inter-packet times, the sorted inter-packet times and the lambdas.

![Unsorted Inter-packet Times](https://github.com/cdpxe/nefias/blob/master/documentation/images/epsilon-similarity_inter-packet_times/Veusz_IAT_NWZ_Zeitung_unsorted_inter-packet_times.png)
Format: ![Alt Text](url)


###### Covert Channel

... (to be continued)









##### Results

(to be continued)

* (example output/results file with several lines: IP addresses and eSim scores)
* (table with eSim scores)
* (decision heuristic)
* (detection results)
* (precision, accuracy, recall)


### Customize Script for Own Research

##### Window size

If you want to change the window size, you need to make modifications to the following parts of the script:

* At the beginning of the for loop: `head -n`
* At the beginning of the END block within the gawk program-file: The first part of the if condition `if (counter == 2001 && counter >= 3)`

##### Epsilon values

If you want to change the epsilon values, you need to make modifications to the following parts of the script (not necessarily all of them):

* In the BEGIN block within the gawk program-file: e.g. `epsilon_1=<your value>` or if you want to add an additional epsilon value, append `epsilon_8=<your value>; epsilon_8_counter=0`
* In the END block within the gawk program-file where the epsilon similarity scores are explicitly calculated: e.g. `eSim_1 = epsilon_1_counter / length(arr_lambda)`
* In the END block within the gawk program-file where the epsilon similarity scores are concatenated to a single string


### Further Notes

* The script requires `gawk` due to built-in functions asort() und length().

