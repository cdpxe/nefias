SAMPLE_RECORDING=recordings/TCC_localhost/TCC_100-200_quickbrownfox.pcap.csv

a :
	echo "todo"

c : count

e :
	pluma *.sh *.inc

count :
	wc -l *.sh *.inc scripts/*.sh

localtestIAT :
	/bin/bash ./nefias_master.sh --slave-hostconfig=slaves_localhost.cfg --traffic-source=$(SAMPLE_RECORDING) --chunk-size-in-lines=15000 --slave-script=scripts/kappa_IAT.sh

localtestFramelen :
	/bin/bash ./nefias_master.sh --slave-hostconfig=slaves_localhost.cfg --traffic-source=$(SAMPLE_RECORDING) --chunk-size-in-lines=15000 --slave-script=scripts/kappa_framelen.sh

tgz :
	tar -czvf ../nefias_current.tgz *

clean :
	rm -vf chunk_*.gz tmp

