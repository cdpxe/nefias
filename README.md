# NeFiAS – Network Forensics and Anomaly Detection System

NeFiAS is a simple and portable tool for network anomaly detection/network forensics, mostly tailored for the domain of network covert channels (network steganography). It was (initially) written by [Steffen Wendzel](http://www.wendzel.de).

# Features

- Very tiny framework: core system contains less than 1.000 lines of code
- Super portable (core system entirely written in `bash` and `awk` (see the *story* below)
- Provides a good performance due to beowulf cluster, i.e. can be easily spread among many nodes
- Requires only standard Linux, no special libraries or tools required (see *requirements* below)

## Read the [Documentation](https://github.com/cdpxe/nefias/blob/master/documentation/README.md)

## Check the available NeFiAS [Detection Scripts](https://github.com/cdpxe/nefias/blob/master/scripts/README.md)

# Requirements

NeFiAS requires only standard Linux tools:

- `bc` (console calculator)
- `dialog` (optional)
- `bash`
- `ssh`/`scp`
- `gawk`, `sed`, `tr`, `split` etc.
- `gzip`
- `tshark` (optional, but pretty useful)

