This folder contains recordings of covert channels which use the [Retransmission](http://ih-patterns.blogspot.com/p/p11-re-transmission-pattern.html) hiding pattern. The original recordings contained downloads from Debian mirror servers located in different countries. The records have been cleaned up to remove the packets that were not part of the actual download flow, so that only packets of the file download are included, i.e. the sender of the flow is the mirror server. The covert channel was then embedded in the recordings. This encodes the message "TheQuickBrownFoxJumpedOverTheLazyDog" in constant repetition. The covert channels use different parameters, i.e. intervals between retransmissions (see (Zillien and Wendzel, 2018)). The parameters used are in the respective file name and follow the form O_D_I_J. A short overview of these recordings is given by the following table:

| ------------- | ------------- |:-------------:| -----:| ---------:|
| **Parameter** (O_D_I_J)        | 0_10_3_7, 0_50_10_20, 0_100_30_70, 0_500_100_200, 0_1000_300_700, 1000_10_3_7        |
| **Cover message**        | "TheQuickBrownFoxJumpedOverTheLazyDog" in constant repetition       |
| **Number of files and contained packets**        | 240 files, each containing between 11,000 and 17,000 packets       |
| **Location of sender**        | Armenia, Denmark, Germany, USA       |



### References

* (Zillien und Wendzel, 2018) S. Zillien, S. Wendzel: [Detection of covert channels in TCP retransmissions](https://link.springer.com/chapter/10.1007%2F978-3-030-03638-6_13), in Proc. 23rd Nordic Conference on Secure IT Systems (NordSec), LNCS Vol. 11252, pp. 203-218, Springer, 2018.

