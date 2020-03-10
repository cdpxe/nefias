# This file is part of NeFiAS.
# 
# NeFiAS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# NeFiAS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <https://www.gnu.org/licenses/>.

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

