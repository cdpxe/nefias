# Documentation of Script ### [`eSim_IAT_frametimerelative.sh`](https://github.com/cdpxe/nefias/blob/master/scripts/eSim_IAT_frametimerelative.sh)

### Short Description

Calculates epsilon similarity scores using a static window size (2,001) on the basis of inter-packet gaps (per flow); this script helps to detect network covert channels that modulate the timings between succeeding network packets (such covert channels implement the so-called [Inter-packet Times](http://ih-patterns.blogspot.com/p/blog-page_40.html) hiding pattern)

### Author

Kevin Albrechts, in cooperation with Steffen Wendzel

### Comment/Reference

Implementation of epsilon similarity for inter-packet times pattern described by (Cabuk et al., 2004 and 2009).

### (documentation to be continued)

...



The script `eSim_IAT_frametimerelative.sh` has the following special characteristics:

* It requires `gawk` due to built-in functions asort() und length().
* Line 58-65: If an inter-packet time equals 0, the corresponding lambda value is also set to 0. This serves to avoid a division by 0, since inter-packet time is in the denominator of the quotient when calculating lambdas.

