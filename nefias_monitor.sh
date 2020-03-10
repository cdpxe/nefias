#!/bin/bash
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

source nefias_common.inc

# nefias progress monitor

while [ ! -e ${NEFIAS_STATUS_FILE} ]; do
	echo "waiting for ${NEFIAS_STATUS_FILE} to become available..."; sleep 2
done

(
	while [ 1 ]; do
		cat ${NEFIAS_STATUS_FILE} | tr '.' ' ' | awk '{print $1}'
		sleep 1
	done
) | dialog --title "NEFIAS Progress" --gauge "Please wait ..." 7 70 0


