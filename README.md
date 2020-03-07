# NeFiAS – Network Forensics and Anomaly Detection System

NeFiAS is a tool that I use to conduct my own research, especially in the domain of network covert channels (network steganography).

# Features

- Very tiny framework, less than 1.000 LOC
- Super portable (core system entirely written in `bash` and `awk` (see the *story* below)
- Provides a good performance due to beowulf cluster, i.e. can be easily spread among many nodes
- Requires only standard Linux, no special libraries or tools required (see *requirements* below)

# The story behind this tool

A few years ago, my colleagues and me developed WoDiCoF, the *Worms Distributed Covert Channel Detection Framework*. As its name implies, WoDiCoF was a system for network covert channel detection. However, WoDiCoF was based on Apache Hadoop and I wanted a very, very lightweight network anomaly detection system (of course, also tailored for covert channel detection). And I wanted it without dependencies on things like Hadoop, Tomcat, Java (at all!), Python 2.x (we wrote some WoDiCoF code using Python 2, it was required to modify the code for Python 3), etc. Also, I wanted this system to be trivial to deploy on nodes and run on standard Linux. For this reason, I decided to implement one tiny network anomaly detection system (mostly for myself) in `bash`, using `awk` and similar tools. It might not be the fastest, and bash scripting is not the best solution to several problems, but if I can easily distribute workload on many nodes, it might still provide a good performance. Moreover, I wanted a system that can easily be extended and can be used in the scientific community to analyze detection algorithms and to perform replication studies.

# Requirements

NeFiAS requires only standard Linux tools:

- `bc` (console calculator)
- `dialog` (optional)
- `bash`
- `ssh`/`scp`
- `awk`, `sed`, `tr`, `split` etc.
- `gzip`
- `tshark` (optionally, but pretty useful)

