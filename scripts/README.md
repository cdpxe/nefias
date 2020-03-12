# NeFiAS Scripts

This directory contains the following scripts:

| *Filename*        | *Description*  | *Author*      | *Comment/Reference* |
| ----------------- | -------------- |:-------------:|--------------------:|
| `kappa_framelen.sh` | Calculate compressibility score (K) using a static window size (1.000) on the basis of the frame length (per flow); i.e. this script helps to detect network covert channels that modulate sizes of succeeding packets (such covert channels implement the so-called [Size Modulation](http://ih-patterns.blogspot.com/p/p1-size-modulation-pattern.html) hiding pattern) | Steffen Wendzel | see documentation; essentially the same as explained in (Wendzel et al., 2019) |
| `kappa_framelen_- multiple_winsize.sh` | Same as `kappa_framelen.sh`, but with multiple window sizes | Steffen Wendzel | same as `kappa_framelen.sh` |
| `kappa_IAT.sh` | Calculate compressibility score (K) using a static window size (1.000) on the basis of inter-packet gaps (per flow); this script helps to detect network covert channels that modulate the timings between succeeding network packets (such covert channels implement the so-called [Inter-packet Times](http://ih-patterns.blogspot.com/p/blog-page_40.html) hiding pattern) | Steffen Wendzel | see documentation; essentially the same as explained in (Keidel et al., 2018) |
| `kappa_IAT_- multiple_winsize.sh` | Same as `kappa_IAT.sh`, but with multiple window sizes | Steffen Wendzel | same as `kappa_IAT.sh` |
| `kappa_TCP_- seqmod_message_- ordering_pattern.sh` | Calculates compressibility score (K) using different window sizes to detect the [Message Ordering](http://ih-patterns.blogspot.com/p/p10-pdu-order-pattern.html) pattern in TCP, i.e. those covert channels that modulate the order of TCP segments | Steffen Wendzel | Implements exactly the coding and compression as used by (Wendzel, 2019). Also, see [*] |

The following scripts are NeFiAS-internal scripts and are not usable directly:

* `nefias_lib.sh` (this file must be included by all other scripts and provides basic NeFiAS functionality to these scripts).


# References

* (Keidel et al., 2018) R. Keidel, S. Wendzel, S. Zillien et al.: [WoDiCoF - A Testbed for the Evaluation of (Parallel) Covert Channel Detection Algorithms](http://dx.doi.org/10.3217/jucs-024-05-0556), Journal of Universal Computer Science (J.UCS), Vol. 24(5), 2018.
* (Wendzel et al., 2019) S. Wendzel, F. Link, D. Eller, W. Mazurczyk: [Detection of Size Modulation Covert Channels Using Countermeasure Variation](http://www.jucs.org/jucs_25_11/detection_of_size_modulation), Journal of Universal Computer Science (J.UCS), Vol. 25(11), pp. 1396-1416, 2019.
* (Wendzel, 2019) S. Wendzel: [Protocol-independent Detection of 'Messaging Ordering' Network Covert Channels](https://doi.org/10.1145/3339252.3341477), in Proc. ARES 2019 (Third International Workshop on Criminal Use of Information Hiding – CUING 2019), pp. 63:1-63:8, ACM, 2019.


### Notes
[*] The original paper used a window size (i.e. amount of segments considered for calculation) of 200. However, the NeFiAS script supports multiple window sizes by default. Moreover, the original paper implemented four different variants to encode the string `S` but only the best performing string coding is implemented in the NeFiAS script. For details, see (Wendzel, 2019).