The script `eSim_IAT_frametimerelative.sh` has the following special characteristics:

* It needs gawk due to built-in functions asort() und length().
* Line 58-65: If an inter-packet time equals 0, the corresponding lambda value is also set to 0. This serves to avoid a division by 0, since inter-packet time is in the denominator of the quotient when calculating lambdas.

