The script `eSim_Size_Modulation_framelen.sh` has the following special characteristics:

* It requires `gawk` due to built-in functions asort() und length().
* Line 52-59: If a packet size equals 0, the corresponding lambda value is also set to 0. This serves to avoid a division by 0, since packet size is in the denominator of the quotient when calculating lambdas.

