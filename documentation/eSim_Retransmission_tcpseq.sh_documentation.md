The script `eSim_Retransmission_tcpseq.sh` has the following special characteristics:

* Line 64-67: There must be at least 3 retransmissions to calculate the epsilon similarity scores. Otherwise, an error because of division by 0 would occur in the remainder of the calculation. Therefore, if a flow has both enough packets (see head -n for window length) and less than 3 retransmissions within the window, the script will not calculate epsilon similarity scores but instead it prints out the information "no or not enough (<=2) retransmissions existent".
* Line 77-84: If a distance delta equals 0, the corresponding lambda value is also set to 0. This serves to avoid a division by 0, since delta is in the denominator of the quotient when calculating lambdas.

