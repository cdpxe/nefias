This folder contains the implementation and recordings of covert channels which use the [Size Modulation](http://ih-patterns.blogspot.com/p/p1-size-modulation-pattern.html) hiding pattern. The covert channel mainly relies on `ncat` and was recorded using `tshark`. However, due to time pressure, the implementation and recording did not provide "perfect" results. That means, some packets were recorded with a packet size twice as big as well as some retransmissions or segments out of order. Nevertheless, these imperfections were very few compared to the total amount of packets. For more about this, take a look at the recording files. A short overview of the recordings is given by the following table:

| | |
| ------------- | ------------- |
| **Payload sizes** (0-bit_1-bit in byte)        | 50_60, 100_101, 100_200, 100_1000, 1000_1001        |
| **Covert message**        | "TheQuickBrownFoxJumpedOverTheLazyDog" in constant repetition       |
| **Number of files and contained packets**        | Per pair of payload sizes 10 files with 30,000 packets each. A total of 50 files with 30,000 packets each.       |
| **Transmission path**        | directly over stable Ethernet       |



### References

* (Wendzel et al., 2019) S. Wendzel, F. Link, D. Eller, W. Mazurczyk: [Detection of Size Modulation Covert Channels Using Countermeasure Variation](http://www.jucs.org/jucs_25_11/detection_of_size_modulation), Journal of Universal Computer Science (J.UCS), Vol. 25(11), pp. 1396-1416, 2019.

