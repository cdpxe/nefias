# NeFiAS Scripts

This directory contains the following scripts:

| *Filename*        | *Description*  | *Author*      | *Comment/Reference* |
| ----------------- | -------------- |:-------------:|--------------------:|
| `kappa_framelen.sh` | Calculate compressibility score (K) using a static window size (1.000) on the basis of the frame length (per flow); i.e. this script helps to detect network covert channels that modulate sizes of succeeding packets (such covert channels implement the so-called [Size Modulation](http://ih-patterns.blogspot.com/p/p1-size-modulation-pattern.html) hiding pattern) | Steffen Wendzel | see documentation; essentially the same as explained in (Wendzel et al., 2019) |
| `kappa_framelen_multiple_winsize.sh` | Same as `kappa_framelen.sh`, but with multiple window sizes | Steffen Wendzel | same as `kappa_framelen.sh` |
| `kappa_IAT.sh` | Calculate compressibility score (K) using a static window size (1.000) on the basis of inter-packet gaps (per flow); this script helps to detect network covert channels that modulate the timings between succeeding network packets (such covert channels implement the so-called [Inter-packet Times](http://ih-patterns.blogspot.com/p/blog-page_40.html) hiding pattern) | Steffen Wendzel | see documentation; essentially the same as explained in (Keidel et al., 2018) |
| `kappa_IAT_multiple_winsize.sh` | Same as `kappa_IAT.sh`, but with multiple window sizes | Steffen Wendzel | same as `kappa_IAT.sh` |

The following scripts are NeFiAS-internal scripts and are not usable directly:

* `nefias_lib.sh` (this file must be included by all other scripts and provides basic NeFiAS functionality to these scripts).


# References

* (Keidel et al., 2018) R. Keidel, S. Wendzel, S. Zillien et al.: [WoDiCoF - A Testbed for the Evaluation of (Parallel) Covert Channel Detection Algorithms](http://dx.doi.org/10.3217/jucs-024-05-0556), Journal of Universal Computer Science (J.UCS), Vol. 24(5), 2018.
* (Wendzel et al., 2019) S. Wendzel, F. Link, D. Eller, W. Mazurczyk: [Detection of Size Modulation Covert Channels Using Countermeasure Variation](http://www.jucs.org/jucs_25_11/detection_of_size_modulation), Journal of Universal Computer Science (J.UCS), Vol. 25(11), pp. 1396-1416, 2019.

