# Traffic Recordings over Internet to a Remote Host (Timing *and* Storage Channel)

Please note that the remote host used here is approx. 8 hops appart from my laptop at HS Worms. Please also note that my laptop (client system in this case, while the remote host was the recipient) was also performing other types of connections over the same network interface, e.g. browsing and e-mail. I hope it will not have influenced the covert channel significantly. No downloads/updates were performed. This traffic should provide the necessary quality to compare it with the *ethernet* covert channels (to see whether there are differences visible). I already spotted smaller differences for IAT rounding precision=3 in a first observation (even without any e-mail/browsing traffic).

In order to cut down the measurements to as few files as possible, I measured the "extremes": (i) ABABAB and (ii) Goethe's Faust with compression (in this case GZip), each with the values τ=0.04 to 0.08 seconds. I conducted both experiment types for all τ using both techniques, storage and timing channels.


## Required Traffic Recordings

| *Type*        | *Parameters*  | *Input*       | *Filename* | *Comment* |
| ------------- | ------------- |:-------------:| -----:| ---------:|
| **Storage:**|
| STORAGE        | τ=0.04       | ABABAB   | remotehost_SCC_ABABAB_40.pcap | OK |
| STORAGE        | τ=0.06       | ABABAB   | remotehost_SCC_ABABAB_60.pcap | OK |
| STORAGE        | τ=0.08       | ABABAB   | remotehost_SCC_ABABAB_80.pcap | OK |
| STORAGE        | τ=0.04       | Faust GZ | remotehost_SCC_faust_GZ_40.pcap | OK |
| STORAGE        | τ=0.06       | Faust GZ | remotehost_SCC_faust_GZ_60.pcap | OK |
| STORAGE        | τ=0.08       | Faust GZ | remotehost_SCC_faust_GZ_80.pcap | OK |
| **Timing:** |
| TIMING        | τ=0.04 and 2τ | ABABAB   | remotehost_TCC_ABABAB_40_80.pcap | OK |
| TIMING        | τ=0.06 and 2τ | ABABAB   | remotehost_TCC_ABABAB_60_120.pcap | OK |
| TIMING        | τ=0.08 and 2τ | ABABAB   | remotehost_TCC_ABABAB_80_160.pcap | OK | 
| TIMING        | τ=0.04 and 2τ | Faust GZ | remotehost_TCC_faust_GZ_40.pcap | OK |
| TIMING        | τ=0.06 and 2τ | Faust GZ | remotehost_TCC_faust_GZ_60.pcap | OK |
| TIMING        | τ=0.08 and 2τ | Faust GZ | remotehost_TCC_faust_GZ_80.pcap | OK |


## Additional Traffic Recordings


| *Type*        | *Parameters*  | *Input*       | *Filename* | *Comment* |
| ------------- | ------------- |:-------------:| -----:| ---------:|
| **Timing:** |
| TIMING        | τ=0.02 and 2τ | Faust GZ | remotehost_TCC_faust_GZ_20_40.pcap | OK, *not required, just additional data* |


