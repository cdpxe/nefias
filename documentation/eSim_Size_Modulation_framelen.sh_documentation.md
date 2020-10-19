# Documentation of Script [`eSim_Size_Modulation_framelen.sh`](https://github.com/cdpxe/nefias/blob/master/scripts/eSim_Size_Modulation_framelen.sh)

Contents:

* Short description
* Author
* Comment/reference
* Functionality
* Testing and evaluation of the script
* Customize script for own research
* Further notes
* References


### Short Description

Calculates epsilon similarity scores using a static window size (2,000) on the basis of packet sizes (per flow); this script helps to detect network covert channels that modulate the packet sizes of succeeding network packets (such covert channels implement the so-called [Size Modulation](http://ih-patterns.blogspot.com/p/p1-size-modulation-pattern.html) hiding pattern)

### Author

Kevin Albrechts, in cooperation with Steffen Wendzel

### Comment/Reference

Implementation of epsilon similarity for size modulation pattern described by (Wendzel et al., 2019).

### Functionality

##### Input

* Chunk of the traffic recording (`--traffic-source=`) to be analysed
* Jobname

##### Output

* A file that contains one line per flow, where the flow is part of the input chunk and has at least the amount of packets defined by `head -n`. Here, a flow is referred to as one direction of an IP-conncection. A flow, therefore, is characterized by a sender and a receiver IP address, port numbers are not taken into account. (To distinguish flows additionally by port numbers, choose `tcp+udp` or anything like this. See [`nefias_lib.sh`](https://github.com/cdpxe/nefias/blob/master/scripts/nefias_lib.sh) and the general [documentation](https://github.com/cdpxe/nefias/blob/master/documentation/README.md) for more information on this.)
* A line consists of the flow information, such as source and destination IP addresses, followed by the calculated epsilon similarity scores (in %).
* The epsilon similarity scores of the following epsilon values are calculated: 0.0001, 0.1, 10 and >= 0.1 .

##### Computation Steps

The script starts with including the functionality of the NeFiAS library script [`nefias_lib.sh`](https://github.com/cdpxe/nefias/blob/master/scripts/nefias_lib.sh).

Afterwards, the flows are initialized by calling `NEFIAS_INIT_PER_FLOW`. The third parameter within this statement is `"ip"`. This is chosen because only packet sizes of network packets are relevant to the [Size Modulation](http://ih-patterns.blogspot.com/p/p1-size-modulation-pattern.html) hiding pattern regardless of whether it contains a tcp segment or udp datagram.

The script mainly consists of a for loop over all flows of the input chunk. Within this loop, the following computation steps are carried out:

1. "Grab" (`grep`) the first 2,000 packets of a flow. (Each packet correponds to a line in the input chunk file.)
2. Process these packets with `gawk` (whereas the program-file is specified directly):
   - BEGIN: Epsilon values are declared and initialized.
   - Action statements: The packet size of each network packet is saved based on `frame_len` (corresponds to `frame.len`).
   - END:
     - We make sure the window is filled with enough packets (defined by head -n, i.e., 2,000 packets here). There must be at least 2 packets, otherwise an error would occur because of division by 0. If one of these conditions is false, END does not do anything further, i.e. go to step 3.
     - Sort the packet sizes.
     - Calculate the pairwise relative differences lambda. Please note: If a packet size equals 0, the corresponding lambda value is also set to 0. This serves to avoid a division by 0, since packet size is in the denominator of the quotient when calculating lambdas.
     - Count the number of lambdas which are below the respective epsilon values.
     - Calculate the epsilon similarity scores.
     - Concatenate the epsilon similarity scores to a single string. (in %, rounded to two decimal places)
     - Print out the string of the epsilon similarity scores.
3. Redirect the output of step 2 (either a line of epsilon similarity scores or empty): Overwrite the temporary working file `${TMPWORKFILE}` with this output.
4. Paste the output of step 2 (contained in `${TMPWORKFILE}`) into the temporary results file `${TMPRESULTSFILE}`: If `${TMPWORKFILE}` is empty, `${TMPRESULTSFILE}` will be empty as well. Otherwise, the flow information and the epsilon similarity scores are concatenated and written to `${TMPRESULTSFILE}`.
5. Delete the temporary working file `${TMPWORKFILE}`.


Lastly, the script calls `NEFIAS_FINISH` to finalize the processing of the chunk.

### Testing and Evaluation of the Script


##### Traffic Recordings

* Legitimate Traffic: Part of NZIX-II data of [WAND Network Research Group](https://wand.net.nz/wits/nzix/2/). The [file](https://wand.net.nz/wits/nzix/2/20000705-152900.php) containing traffic from Wed Jul 5 15:29:00 2000 to Wed Jul 5 17:59:59 2000 was split into 6 almost equally sized files by libtrace for better processing. From the first 4 files, those IP (one-directional) connections were extracted which contain at least 2,001 packets, and from the last 2 files, those with at least 5,000 packets were extracted. Each extracted connection was saved to one file each. To sum up, 542 files were used for testing.
* Covert Channels: Serveral covert channels were implemented and recorded that use one of the following pairs of packet sizes to encode 0- and 1-bits: (50,60), (100,101), (100,200), (100,1000) and (1000,1001). Each covert channel transmits the covert message "TheQuickBrownFoxJumpedOverTheLazyDog" in constant repetition using UTF-8. More information on this channel, its impelementation and recordings can be found [here](https://github.com/cdpxe/nefias/tree/master/recordings/covert_channel_size_modulation_pattern). Please note that the recordings of these covert channels were imperfect but this flaw is very small. Check the previous link for more information on this.



##### Plots

###### Legitimate Traffic

In addition to the data sets for testing, a legitimate flow from reading newspaper online was recorded (not part of testing) using `tshark`. The newspaper [NWZ Online](https://www.nwzonline.de/) was opened on Sept. 9th 2020 at 22:33. Several articles and local sites were openend and read to simulate legitimate traffic and "normal" behavior on the internet. Recording stopped at 22:55 after 5,000 packets (of both flows/directions). The file can be found [here](https://github.com/cdpxe/nefias/tree/master/recordings/Legitimate_flow_of_reading_newspaper). For the first 2,001 packets of the flow from the newspaper's server to the local (and recordring) host, the following plots show the unsorted packet sizes, the sorted packet sizes and the lambdas.

<p align="center">
  <img src="https://github.com/cdpxe/nefias/blob/master/documentation/images/epsilon-similarity_size_modulation/Veusz_Size_Modulation_NWZ_Zeitung_unsorted_packet_sizes.png" width="600" title="Unsorted packet sizes">
</p>

<p align="center">
  <img src="https://github.com/cdpxe/nefias/blob/master/documentation/images/epsilon-similarity_size_modulation/Veusz_Size_Modulation_NWZ_Zeitung_sorted_packet_sizes.png" width="600" title="Sorted packet sizes">
</p>

<p align="center">
  <img src="https://github.com/cdpxe/nefias/blob/master/documentation/images/epsilon-similarity_size_modulation/Veusz_Size_Modulation_NWZ_Zeitung_lambdas.png" width="600" title="Lambdas">
</p>



###### Covert Channel

The following plots visualize the unsorted packet sizes, the sorted packet sizes and the lambdas of the first 2,000 packets of the flow from `192.168.0.46` to `192.168.0.206` of the recordings contained in the file "Size_Mod_1000_1001_300ms_0925_1800.pcap.csv" (can be found [here](https://github.com/cdpxe/nefias/blob/master/recordings/covert_channel_size_modulation_pattern/covert_channel_size_mod_implementation/Size_Mod_1000_1001_300ms_0925_1800.pcap.csv), this file was not part of testing but is just for illustrations) of a covert channel with Size Modulation hiding pattern. The channel uses payload sizes of 1,000 and 1,001 bytes. The packets of the TCP handshake are vaguely perciptle on the left edge of the first plot.


<p align="center">
  <img src="https://github.com/cdpxe/nefias/blob/master/documentation/images/epsilon-similarity_size_modulation/Veusz_Size_Modulation_covert3_unsorted_packet_sizes.png" width="600" title="Unsorted packet sizes">
</p>

<p align="center">
  <img src="https://github.com/cdpxe/nefias/blob/master/documentation/images/epsilon-similarity_size_modulation/Veusz_Size_Modulation_covert3_sorted_packet_sizes.png" width="600" title="Sorted packet sizes">
</p>

<p align="center">
  <img src="https://github.com/cdpxe/nefias/blob/master/documentation/images/epsilon-similarity_size_modulation/Veusz_Size_Modulation_covert3_lambdas.png" width="600" title="Lambdas">
</p>




##### Results


If the script is run with the legitimate traffic described above, it produces results in the following form, whereas this is only an extract of all results:

```
$ cat results/*
10.0.147.228,10.4.90.240,,,, eSim(0.1)=99.70%, eSim(>=0.1)=0.30%, eSim(0.0001)=99.15%, eSim(10)=100.00%
10.0.0.42,10.3.65.0,,,, eSim(0.1)=99.85%, eSim(>=0.1)=0.15%, eSim(0.0001)=99.80%, eSim(10)=100.00%
10.0.0.29,10.2.27.34,,,, eSim(0.1)=99.65%, eSim(>=0.1)=0.35%, eSim(0.0001)=94.30%, eSim(10)=100.00%
10.0.0.29,10.2.27.34,,,, eSim(0.1)=99.80%, eSim(>=0.1)=0.20%, eSim(0.0001)=92.45%, eSim(10)=100.00%
10.0.0.29,10.2.27.34,,,, eSim(0.1)=99.65%, eSim(>=0.1)=0.35%, eSim(0.0001)=94.05%, eSim(10)=100.00%
10.0.0.29,10.2.27.34,,,, eSim(0.1)=99.95%, eSim(>=0.1)=0.05%, eSim(0.0001)=95.20%, eSim(10)=100.00%
10.0.0.29,10.2.27.34,,,, eSim(0.1)=99.85%, eSim(>=0.1)=0.15%, eSim(0.0001)=95.20%, eSim(10)=100.00%
10.0.0.29,10.2.27.34,,,, eSim(0.1)=99.80%, eSim(>=0.1)=0.20%, eSim(0.0001)=91.85%, eSim(10)=100.00%
10.0.0.29,10.2.27.34,,,, eSim(0.1)=99.85%, eSim(>=0.1)=0.15%, eSim(0.0001)=91.70%, eSim(10)=100.00%
10.0.33.168,10.0.219.217,,,, eSim(0.1)=100.00%, eSim(>=0.1)=0.00%, eSim(0.0001)=100.00%, eSim(10)=100.00%
10.0.33.168,10.0.219.217,,,, eSim(0.1)=100.00%, eSim(>=0.1)=0.00%, eSim(0.0001)=100.00%, eSim(10)=100.00%
10.0.4.118,10.0.14.251,,,, eSim(0.1)=99.40%, eSim(>=0.1)=0.60%, eSim(0.0001)=98.55%, eSim(10)=100.00%
10.0.41.57,10.2.202.63,,,, eSim(0.1)=100.00%, eSim(>=0.1)=0.00%, eSim(0.0001)=86.14%, eSim(10)=100.00%
10.0.41.57,10.2.202.63,,,, eSim(0.1)=100.00%, eSim(>=0.1)=0.00%, eSim(0.0001)=88.59%, eSim(10)=100.00%
```

The results can be found [here](https://github.com/cdpxe/nefias/tree/master/documentation/results/epsilon-similarity_size_modulation). The following table shows the arithmetic averages and standard deviations of the epsilon similarity scores for several epsilon values:

<p align="center">
  <img src="https://github.com/cdpxe/nefias/blob/master/documentation/results/epsilon-similarity_size_modulation/test_results_eSim_Size_Modulation.png" width="800" title="Test results for eSim of Size Modulation pattern">
</p>


The following decision heuristic is proposed: A flow is classified as covert if the epsilon similarity score for epsilon = 0.0001 lies within the interval (99,45\%;99,95\%); otherwise, it is classified as legitimate traffic. Applying this decision heuristic to the flows from above, the following detection results are obtained:

<p align="center">
  <img src="https://github.com/cdpxe/nefias/blob/master/documentation/results/epsilon-similarity_size_modulation/detection_results_eSim_Size_Modulation.png" width="600" title="Detection results for eSim of Size Modulation pattern">
</p>


The following plot shows accuracy, precision and recall of the detection results:

<p align="center">
  <img src="https://github.com/cdpxe/nefias/blob/master/documentation/results/epsilon-similarity_size_modulation/Precision_Accuracy_Recall-Size_Modulation-detection_results.png" width="600" title="Accuracy, precision and recall of the detection results for eSim of Size Modulation pattern">
</p>



### Customize Script for Own Research

##### Window size

If you want to change the window size, you need to make modifications to the following parts of the script:

* At the beginning of the for loop: `head -n`
* At the beginning of the END block within the gawk program-file: The first part of the if condition `if (counter == 2000 && counter >= 2)`

##### Epsilon values

If you want to change the epsilon values, you need to make modifications to the following parts of the script (not necessarily all of them):

* In the BEGIN block within the gawk program-file: e.g. `epsilon_1=<your value>` or if you want to add an additional epsilon value, append `epsilon_5=<your value>; epsilon_5_counter=0`
* In the END block within the gawk program-file where the number of lambdas, which are below the respective epsilon values, is counted: e.g. `if (arr_lambda[i] < epsilon_1) epsilon_1_counter++`
* In the END block within the gawk program-file where the epsilon similarity scores are explicitly calculated: e.g. `eSim_1 = epsilon_1_counter / length(arr_lambda)`
* In the END block within the gawk program-file where the epsilon similarity scores are concatenated to a single string


### Further Notes

* The script requires `gawk` due to built-in functions asort() und length().


### References

* (Wendzel et al., 2019) S. Wendzel, F. Link, D. Eller, W. Mazurczyk: [Detection of Size Modulation Covert Channels Using Countermeasure Variation](http://www.jucs.org/jucs_25_11/detection_of_size_modulation), Journal of Universal Computer Science (J.UCS), Vol. 25(11), pp. 1396-1416, 2019.


