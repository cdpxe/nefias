## NeFiAS – Network Forensics and Anomaly Detection System

<img src="https://github.com/cdpxe/nefias/raw/master/documentation/logo/nefias_logo.png" title="NeFiAS logo" />

NeFiAS is a simple and portable tool for network anomaly detection/network forensics, mostly tailored for the domain of network covert channels (network steganography). It was (initially) written by [Steffen Wendzel](https://www.wendzel.de). With NeFiAS we aim to provide the scientific community with the most accessible, easy-to-use testbed feasible. NeFiAS is a tool that you can use to test your own covert channel detection algorithms. Also, feel invited to publish your own detection algorithms in this repository to allow experimental replications of your own research work (just contact Steffen for this purpose).

## Design Goals

- Portability
- Code-base as tiny as possible
- Low barrier to work with the tool; enable students to easily extend the tool when they write a thesis
- Support good performance, *but* prioritize performance if the system can be made more accessible for students and other researchers
- Enable replication studies
- Modularity for detection modules; make it possible to write detection modules with as few lines of code as feasible

## Features

- Very tiny framework: core system contains less than 1,000 lines of code
- Super portable (core system entirely written in `bash` and `awk` (see the *story* below)
- Provides rather a good performance (if used with a Beowulf cluster), i.e. can be easily spread among many nodes
- Requires only standard Linux, no special libraries or tools required (see *requirements* below)

### Read the [Documentation](https://github.com/cdpxe/nefias/blob/master/documentation/README.md)

### Check the available NeFiAS [Detection Scripts](https://github.com/cdpxe/nefias/blob/master/scripts/README.md)

## Requirements

NeFiAS requires only standard Linux tools:

- `bc` (console calculator)
- `dialog` (optional)
- `bash`
- `ssh`/`scp`
- `gawk`, `sed`, `tr`, `split` etc.
- `gzip`
- `tshark` (optional, but pretty useful)
