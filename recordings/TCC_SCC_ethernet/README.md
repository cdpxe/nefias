# Traffic Recordings over Ethernet (Timing *and* Storage Channel)

Cabuk tests for *storage* simple covert channel (SCC)  with e.g. τ=0.04 sec., i.e. they measure, whether a packet is present within the 0.04 sec time slot, or not
(indicating a 0 or 1 bit, respectively). In a *timing* SCC, this works different: we have two (or more) values τ1 and τ2 to signal hidden
information (s. p. 7 of the paper).
In other words, a storage SCC uses one constant τ while a timing SCC uses a set containing at least two values (τ1, τ2, ...τn).
On p. 11, the authors state, that *given a storage IP SCC with timing interval τ, we can construct a timing IP SCC with τ1 = τ and τ2 = 2τ.*

However, *being able to construct* is not *equal* here. In other words, we should not compare the storage SCC compressibility results
of Cabuk et al. for some τ with a timing SCC that uses τ and 2τ. Instead, we should only compare the values of Cabuk et al. with our
own storage SCC values. Additionally, we provide our results on the timing SCC detectability using the compressibility and
show all the findings (e.g. how the digits used for string construction influence Kappa).

*Illustration* of the difference between a storage SCC using τ and a timing SCC that uses (τ,2τ): X denotes a packet being sent.
```
           1.τ        2.τ          3.τ
         --------|-------------|----------> t
          send 0 | send 0      | send 1  |
storage:  ...... | ............|    X    |

          send 0               | send 1  |
timing:   ...... | ......X(2τ) |    X    |
         --------|-------------|----------> t
```

Please note that the following table uses the abbreviations SCC (storage covert channel) and TCC (timing covert channel), i.e. **SCC does not mean Simple Covert Channel** here:

| *Type*        | *Parameters*  | *Input*       | *Filename* | *Comment* |
| ------------- | ------------- |:-------------:| -----:| ---------:|
| **Storage:**|
| STORAGE        | τ=0.04       | ABABAB        | SCC_ABABAB_40.pcap | OK |
| STORAGE        | τ=0.06       | ABABAB        | SCC_ABABAB_60.pcap | OK |
| STORAGE        | τ=0.08       | ABABAB        | SCC_ABABAB_80.pcap | OK |
| STORAGE        | τ=0.04       | Faust         | SCC_Faust_40.pcap | OK |
| STORAGE        | τ=0.06       | Faust         | SCC_Faust_60.pcap | OK |
| STORAGE        | τ=0.08       | Faust         | SCC_Faust_80.pcap | OK |
| STORAGE        | τ=0.04       | Faust BZ2     | SCC_Faust_BZ2_40.pcap | OK |
| STORAGE        | τ=0.06       | Faust BZ2     | SCC_Faust_BZ2_60.pcap | OK |
| STORAGE        | τ=0.08       | Faust BZ2     | SCC_Faust_BZ2_80.pcap | OK |
| STORAGE        | τ=0.04       | Faust GZ      | SCC_Faust_GZ_40.pcap | OK |
| STORAGE        | τ=0.06       | Faust GZ      | SCC_Faust_GZ_60.pcap | OK |
| STORAGE        | τ=0.08       | Faust GZ      | SCC_Faust_GZ_80.pcap | OK |
| STORAGE        | τ=0.04       | Faust ZIP     | SCC_Faust_ZIP_40.pcap | OK |
| STORAGE        | τ=0.06       | Faust ZIP     | SCC_Faust_ZIP_60.pcap | OK |
| STORAGE        | τ=0.08       | Faust ZIP     | SCC_Faust_ZIP_80.pcap | OK |
| STORAGE        | τ=0.04       | RedBrownFox   | SCC_RedBrownFox_40.pcap | OK |
| STORAGE        | τ=0.06       | RedBrownFox   | SCC_RedBrownFox_60.pcap | OK |
| STORAGE        | τ=0.08       | RedBrownFox   | SCC_RedBrownFox_80.pcap | OK |
| **Timing:** |
| TIMING        | τ=0.04 and 2τ | ABABAB        | TCC_ABABAB_40_80.pcap | OK |
| TIMING        | τ=0.06 and 2τ | ABABAB        | TCC_ABABAB_60_120.pcap | OK |
| TIMING        | τ=0.08 and 2τ | ABABAB        | TCC_ABABAB_80_160.pcap | OK |
| TIMING        | τ=0.04 and 2τ | Faust         | TCC_Faust_40_80.pcap | OK |
| TIMING        | τ=0.06 and 2τ | Faust         | TCC_Faust_60_120.pcap | OK |
| TIMING        | τ=0.08 and 2τ | Faust         | TCC_Faust_80_160.pcap | OK |
| TIMING        | τ=0.04 and 2τ | Faust BZ2     | TCC_Faust_BZ2_40_80.pcap | OK |
| TIMING        | τ=0.06 and 2τ | Faust BZ2     | TCC_Faust_BZ2_60_120.pcap | OK |
| TIMING        | τ=0.08 and 2τ | Faust BZ2     | TCC_Faust_BZ2_80_160.pcap | OK |
| TIMING        | τ=0.04 and 2τ | Faust GZ      | TCC_Faust_GZ_40_80.pcap | OK |
| TIMING        | τ=0.06 and 2τ | Faust GZ      | TCC_Faust_GZ_60_120.pcap | OK |
| TIMING        | τ=0.08 and 2τ | Faust GZ      | TCC_Faust_GZ_80_160.pcap | OK |
| TIMING        | τ=0.04 and 2τ | Faust ZIP     | TCC_Faust_ZIP_40_80.pcap | OK |
| TIMING        | τ=0.06 and 2τ | Faust ZIP     | TCC_Faust_ZIP_60_120.pcap | OK |
| TIMING        | τ=0.08 and 2τ | Faust ZIP     | TCC_Faust_ZIP_80_160.pcap | OK |
| TIMING        | τ=0.04 and 2τ | RedBrownFox   | TCC_RedBrownFox_40_80.pcap | OK |
| TIMING        | τ=0.06 and 2τ | RedBrownFox   | TCC_RedBrownFox_60_120.pcap | OK |
| TIMING        | τ=0.08 and 2τ | RedBrownFox   | TCC_RedBrownFox_80_160.pcap | OK |

## Setup

Traffic is sent from PC04 to PC05.

```
[=========================]                   [=================================]
[Netsec-pc04              ] ----------------> [Netsec-pc05                      ]
[.........................]                   [.................................]
[(CCEAP client)           ]                   [(CCEAP server + tcpdump recorder)]
[=========================]                   [=================================]
```

The following commands were used on the machines:

#### PC04 (Sender)

Generate SCC/TCC traffic:
```
# cd ~/CCEAP
# ./client -P 9999 -D 143.93.191.118 -t `./iat_encode [file] [T] [2T(=TCC) or 0 (=SCC)]`
```

#### PC05 (Receiver)

Generate SCC/TCC traffic:
```
$ cd CCEAP
$ ./run_server_loop.sh
```

Create traffic recordings (must be called before PC04 client is started so that all packets are catched):

```
# cd CCEAP_Recordings
# tcpdump -i eth0 tcp port 9999 -w [filename]
```

