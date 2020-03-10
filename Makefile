a :
	echo "todo"

c : count

e :
	pluma *.sh *.inc

count :
	wc -l *.sh *.inc scripts/*.sh

localtestIAT :
	/bin/bash ./nefias_master.sh --slave-hostconfig=slaves_localhost.cfg --traffic-source=TCC_RedBrownFox_80_160.pcap.csv --chunk-size-in-lines=15000 --slave-script=scripts/kappa_IAT.sh

localtestFramelen :
	/bin/bash ./nefias_master.sh --slave-hostconfig=slaves_localhost.cfg --traffic-source=TCC_RedBrownFox_80_160.pcap.csv --chunk-size-in-lines=15000 --slave-script=scripts/kappa_framelen.sh

tgz :
	tar -czvf ../nefias_current.tgz *

