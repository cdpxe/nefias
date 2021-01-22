# NeFiAS Scripts

This directory contains the following scripts:

| *Filename*        | *Description*  | *Author*      | *Comment/Reference* |
| ----------------- | -------------- |:-------------:|--------------------:|
| `kappa_framelen.sh` | Calculate compressibility score (K) using a static window size (1.000) on the basis of the frame length (per flow); i.e. this script helps to detect network covert channels that modulate sizes of succeeding packets (such covert channels implement the so-called [Size Modulation](http://ih-patterns.blogspot.com/p/p1-size-modulation-pattern.html) hiding pattern) | Steffen Wendzel | see documentation; essentially the same as explained in (Wendzel et al., 2019) |
| `kappa_framelen_- multiple_winsize.sh` | Same as `kappa_framelen.sh`, but with multiple window sizes | Steffen Wendzel | same as `kappa_framelen.sh` |
| `kappa_IAT.sh` | Calculate compressibility score (K) using a static window size (1.000) on the basis of inter-packet gaps (per flow); this script helps to detect network covert channels that modulate the timings between succeeding network packets (such covert channels implement the so-called [Inter-packet Times](http://ih-patterns.blogspot.com/p/blog-page_40.html) hiding pattern) | Steffen Wendzel | see documentation; essentially the same as explained in (Keidel et al., 2018) |
| `kappa_IAT_- multiple_winsize.sh` | Same as `kappa_IAT.sh`, but with multiple window sizes | Steffen Wendzel | same as `kappa_IAT.sh` |
| `kappa_MQTT_topics_- multiple_winsize.sh` | Calculates compressibility score (K) using the appearance of MQTT topics with different window sizes. Output format: `<flow (CSV)>, window-size, kappa, number-of-topic-changes-within-winsize` | Steffen Wendzel | code was used for (Mileva et al., 2020) |
| `kappa_TCP_- seqmod_message_- ordering_pattern.sh` | Calculates compressibility score (K) using different window sizes to detect the [Message Ordering](http://ih-patterns.blogspot.com/p/p10-pdu-order-pattern.html) pattern in TCP, i.e. those covert channels that modulate the order of TCP segments | Steffen Wendzel | Implements exactly the coding and compression as used by (Wendzel, 2019). Also, see [*] |
| `MQTT_Artifi- cialRecon_multi- ple_winsize.sh` | Calculates compressibility score (K) using the appearance of MQTT client_ids with different window sizes. Output format: `<flow (CSV)>, window-size, kappa, number-of-client_id-changes-within-winsize` | Steffen Wendzel | code was used for (Mileva et al., 2020) |
| `eSim_IAT_frametimerelative.sh` | Calculates epsilon similarity scores using a static window size (2,001) on the basis of inter-packet gaps (per flow); this script helps to detect network covert channels that modulate the timings between succeeding network packets (such covert channels implement the so-called [Inter-packet Times](http://ih-patterns.blogspot.com/p/blog-page_40.html) hiding pattern) | Kevin Albrechts, in cooperation with Steffen Wendzel | see [documentation](https://github.com/cdpxe/nefias/blob/master/documentation/eSim_IAT_frametimerelative.sh_documentation.md); implementation of epsilon similarity for inter-packet times pattern described by (Cabuk et al., 2004 and 2009) |
| `eSim_Retransmission_tcpseq.sh` | Calculates epsilon similarity scores using a static window size (2,000) on the basis of tcp retransmissions (per flow); this script helps to detect network covert channels that use artificial (tcp) retransmissions of network packets (such covert channels implement the so-called [Retransmission](http://ih-patterns.blogspot.com/p/p11-re-transmission-pattern.html) hiding pattern) | Kevin Albrechts, in cooperation with Steffen Wendzel | see [documentation](https://github.com/cdpxe/nefias/blob/master/documentation/eSim_Retransmission_tcpseq.sh_documentation.md); implementation of epsilon similarity for retransmission pattern described by (Zillien and Wendzel, 2018) |
| `eSim_Size_Modulation_framelen.sh` | Calculates epsilon similarity scores using a static window size (2,000) on the basis of packet sizes (per flow); this script helps to detect network covert channels that modulate the packet sizes of succeeding network packets (such covert channels implement the so-called [Size Modulation](http://ih-patterns.blogspot.com/p/p1-size-modulation-pattern.html) hiding pattern) | Kevin Albrechts, in cooperation with Steffen Wendzel | see [documentation](https://github.com/cdpxe/nefias/blob/master/documentation/eSim_Size_Modulation_framelen.sh_documentation.md); implementation of epsilon similarity for size modulation pattern described by (Wendzel et al., 2019) |

The following scripts are NeFiAS-internal scripts and are not usable directly:

* `nefias_lib.sh` (this file must be included by all other scripts and provides basic NeFiAS functionality to these scripts).


# References

* (Zillien und Wendzel, 2018) S. Zillien, S. Wendzel: [Detection of covert channels in TCP retransmissions](https://link.springer.com/chapter/10.1007%2F978-3-030-03638-6_13), in Proc. 23rd Nordic Conference on Secure IT Systems (NordSec), LNCS Vol. 11252, pp. 203-218, Springer, 2018.
* (Keidel et al., 2018) R. Keidel, S. Wendzel, S. Zillien et al.: [WoDiCoF - A Testbed for the Evaluation of (Parallel) Covert Channel Detection Algorithms](http://dx.doi.org/10.3217/jucs-024-05-0556), Journal of Universal Computer Science (J.UCS), Vol. 24(5), 2018.
* (Wendzel et al., 2019) S. Wendzel, F. Link, D. Eller, W. Mazurczyk: [Detection of Size Modulation Covert Channels Using Countermeasure Variation](http://www.jucs.org/jucs_25_11/detection_of_size_modulation), Journal of Universal Computer Science (J.UCS), Vol. 25(11), pp. 1396-1416, 2019.
* (Wendzel, 2019) S. Wendzel: [Protocol-independent Detection of 'Messaging Ordering' Network Covert Channels](https://doi.org/10.1145/3339252.3341477), in Proc. ARES 2019 (Third International Workshop on Criminal Use of Information Hiding – CUING 2019), pp. 63:1-63:8, ACM, 2019.
* (Mileva et al., 2020) A. Mileva, A. Velinov, L. Hartmann, S. Wendzel, W. Mazurczyk: [Comprehensive Analysis of MQTT 5.0 Susceptibility to Network Covert Channels](https://doi.org/10.1016/j.cose.2021.102207), Computers & Security, Elsevier, 2021.
* (Cabuk et al., 2004) S. Cabuk, C. E. Brodley, C. Shields: *IP covert timing channels: design and detection*, Proc. 11th ACM conference on Computerand Communications Security (CCS’04), 178–187, ACM, 2004.
* (Cabuk et al., 2009) S. Cabuk, C. E. Brodley, C. Shields: *IP covert channel detection*, ACM Trans. Inf. Syst. Secur. 12(4), 22:1–22:29, ACM, 2009.


### Notes
[*] The original paper used a window size (i.e. amount of segments considered for calculation) of 200. However, the NeFiAS script supports multiple window sizes by default. Moreover, the original paper implemented four different variants to encode the string `S` but only the best performing string coding is implemented in the NeFiAS script. For details, see (Wendzel, 2019).
