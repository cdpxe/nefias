# NeFiAS sample traffic recordings

These traffic recordings were created with the tool [CCEAP](https://github.com/cdpxe/CCEAP). They contain both, a timing covert channel (TCC) and a "storage" covert channel (SCC) as described in work by Cabuk et al. Both covert channels essentially signal hidden information by modulating the inter-packet gaps (inter-arrival times or "IAT") between transmitted packets (such covert channels implement the so-called [Size Modulation](http://ih-patterns.blogspot.com/p/p1-size-modulation-pattern.html) hiding pattern). The README files in the particular folders provide additional details of the setup.

For an introduction on covert storage and timing channels, see (Wendzel et al., 2015) below or the website of our [Information Hiding Patterns](https://ih-patterns.blogspot.com/p/introduction.html) project.

## Brief overview of sub-directories

The Kappa value calculated by the NeFiAS script *kappa_IAT.sh* indicates the presence of a covert timing channel. The script is slightly different to the one used by WoDiCoF in (Keidel et al., 2018), but the essential functionality is the same (the script was simplified for didactic purposes).

* TCC_SCC_ethernet: Both channel types transmitted over a direct and stable Ethernet connection
* TCC_SCC_internet_remotehost: Both channel types transmitted over multiple hosts via Internet-uplink
* TCC_localhost: Both channel types transmitted only on localhost

For each setup, different timings were applied and different content was signaled. For instance, "ABABAB" signals only the ASCII symbols A and B in a loop while "Faust" signals the first lines of the famous "Faust, pt. 1" by German writer J. W. Goethe. Faust_GZ etc. represent the compressed version of Faust being transmitted. The timings are visible in the filename as well, e.g. "40_80" means that the short timing interval (binary zero) takes 0.04s while the long interval (binary one) takes 0.08s.

These traffic recordings were created in 2017.

# References

* (Wendzel et al., 2015) S. Wendzel, S. Zander, B. Fechner, C. Herdin (2015): *[Pattern-based Survey and Categorization of Network Covert Channel Techniques](https://dl.acm.org/citation.cfm?doid=2737799.2684195)*, ACM Computing Surveys (CSUR), Vol. 47, Issue 3, pp. 50:1-26, ACM.
* (Keidel et al., 2018) R. Keidel, S. Wendzel, S. Zillien et al.: [WoDiCoF - A Testbed for the Evaluation of (Parallel) Covert Channel Detection Algorithms](http://dx.doi.org/10.3217/jucs-024-05-0556), Journal of Universal Computer Science (J.UCS), Vol. 24(5), 2018.
