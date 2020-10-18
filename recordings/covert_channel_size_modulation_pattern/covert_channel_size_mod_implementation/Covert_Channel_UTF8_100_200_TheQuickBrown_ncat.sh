#!/bin/bash

#Skript zum Erzeugen eines Covert Channels des Size Modulation Patterns.

#Der Channel sendet Pakete der Größen 100 Byte (0-Bit) und 200 Byte (1-Bit) mittels ncat.

#Der Channel sendet die Klartext-Nachricht "TheQuickBrownFoxJumpedOverTheLazyDog" binär durch
#die Paketgrößen gemäß UTF-8 kodiert immer wieder. Dies wird über ein Array realisiert, dass immer wieder
#durchlaufen wird.



#Array deklarieren

declare -a kod


#Array initialisieren: Die Bits der kodierten Nachricht ins Array schreiben.

kod[1]=0; kod[2]=1; kod[3]=0; kod[4]=1; kod[5]=0; kod[6]=1; kod[7]=0; kod[8]=0; # T: 01010100
kod[9]=0; kod[10]=1; kod[11]=1; kod[12]=0; kod[13]=1; kod[14]=0; kod[15]=0; kod[16]=0; # h: 01101000
kod[17]=0; kod[18]=1; kod[19]=1; kod[20]=0; kod[21]=0; kod[22]=1; kod[23]=0; kod[24]=1; # e: 01100101
kod[25]=0; kod[26]=1; kod[27]=0; kod[28]=1; kod[29]=0; kod[30]=0; kod[31]=0; kod[32]=1; # Q: 01010001
kod[33]=0; kod[34]=1; kod[35]=1; kod[36]=1; kod[37]=0; kod[38]=1; kod[39]=0; kod[40]=1; # u: 01110101
kod[41]=0; kod[42]=1; kod[43]=1; kod[44]=0; kod[45]=1; kod[46]=0; kod[47]=0; kod[48]=1; # i: 01101001
kod[49]=0; kod[50]=1; kod[51]=1; kod[52]=0; kod[53]=0; kod[54]=0; kod[55]=1; kod[56]=1; # c: 01100011
kod[57]=0; kod[58]=1; kod[59]=1; kod[60]=0; kod[61]=1; kod[62]=0; kod[63]=1; kod[64]=1; # k: 01101011
kod[65]=0; kod[66]=1; kod[67]=0; kod[68]=0; kod[69]=0; kod[70]=0; kod[71]=1; kod[72]=0; # B: 01000010
kod[73]=0; kod[74]=1; kod[75]=1; kod[76]=1; kod[77]=0; kod[78]=0; kod[79]=1; kod[80]=0; # r: 01110010
kod[81]=0; kod[82]=1; kod[83]=1; kod[84]=0; kod[85]=1; kod[86]=1; kod[87]=1; kod[88]=1; # o: 01101111
kod[89]=0; kod[90]=1; kod[91]=1; kod[92]=1; kod[93]=0; kod[94]=1; kod[95]=1; kod[96]=1; # w: 01110111
kod[97]=0; kod[98]=1; kod[99]=1; kod[100]=0; kod[101]=1; kod[102]=1; kod[103]=1; kod[104]=0; # n: 01101110
kod[105]=0; kod[106]=1; kod[107]=0; kod[108]=0; kod[109]=0; kod[110]=1; kod[111]=1; kod[112]=0; # F: 01000110
kod[113]=0; kod[114]=1; kod[115]=1; kod[116]=0; kod[117]=1; kod[118]=1; kod[119]=1; kod[120]=1; # o: 01101111
kod[121]=0; kod[122]=1; kod[123]=1; kod[124]=1; kod[125]=1; kod[126]=0; kod[127]=0; kod[128]=0; # x: 01111000
kod[129]=0; kod[130]=1; kod[131]=0; kod[132]=0; kod[133]=1; kod[134]=0; kod[135]=1; kod[136]=0; # J: 01001010
kod[137]=0; kod[138]=1; kod[139]=1; kod[140]=1; kod[141]=0; kod[142]=1; kod[143]=0; kod[144]=1; # u: 01110101
kod[145]=0; kod[146]=1; kod[147]=1; kod[148]=0; kod[149]=1; kod[150]=1; kod[151]=0; kod[152]=1; # m: 01101101
kod[153]=0; kod[154]=1; kod[155]=1; kod[156]=1; kod[157]=0; kod[158]=0; kod[159]=0; kod[160]=0; # p: 01110000
kod[161]=0; kod[162]=1; kod[163]=1; kod[164]=0; kod[165]=0; kod[166]=1; kod[167]=0; kod[168]=1; # e: 01100101
kod[169]=0; kod[170]=1; kod[171]=1; kod[172]=0; kod[173]=0; kod[174]=1; kod[175]=0; kod[176]=0; # d: 01100100
kod[177]=0; kod[178]=1; kod[179]=0; kod[180]=0; kod[181]=1; kod[182]=1; kod[183]=1; kod[184]=1; # O: 01001111
kod[185]=0; kod[186]=1; kod[187]=1; kod[188]=1; kod[189]=0; kod[190]=1; kod[191]=1; kod[192]=0; # v: 01110110
kod[193]=0; kod[194]=1; kod[195]=1; kod[196]=0; kod[197]=0; kod[198]=1; kod[199]=0; kod[200]=1; # e: 01100101
kod[201]=0; kod[202]=1; kod[203]=1; kod[204]=1; kod[205]=0; kod[206]=0; kod[207]=1; kod[208]=0; # r: 01110010
kod[209]=0; kod[210]=1; kod[211]=0; kod[212]=1; kod[213]=0; kod[214]=1; kod[215]=0; kod[216]=0; # T: 01010100
kod[217]=0; kod[218]=1; kod[219]=1; kod[220]=0; kod[221]=1; kod[222]=0; kod[223]=0; kod[224]=0; # h: 01101000
kod[225]=0; kod[226]=1; kod[227]=1; kod[228]=0; kod[229]=0; kod[230]=1; kod[231]=0; kod[232]=1; # e: 01100101
kod[233]=0; kod[234]=1; kod[235]=0; kod[236]=0; kod[237]=1; kod[238]=1; kod[239]=0; kod[240]=0; # L: 01001100
kod[241]=0; kod[242]=1; kod[243]=1; kod[244]=0; kod[245]=0; kod[246]=0; kod[247]=0; kod[248]=1; # a: 01100001
kod[249]=0; kod[250]=1; kod[251]=1; kod[252]=1; kod[253]=1; kod[254]=0; kod[255]=1; kod[256]=0; # z: 01111010
kod[257]=0; kod[258]=1; kod[259]=1; kod[260]=1; kod[261]=1; kod[262]=0; kod[263]=0; kod[264]=1; # y: 01111001
kod[265]=0; kod[266]=1; kod[267]=0; kod[268]=0; kod[269]=0; kod[270]=1; kod[271]=0; kod[272]=0; # D: 01000100
kod[273]=0; kod[274]=1; kod[275]=1; kod[276]=0; kod[277]=1; kod[278]=1; kod[279]=1; kod[280]=1; # o: 01101111
kod[281]=0; kod[282]=1; kod[283]=1; kod[284]=0; kod[285]=0; kod[286]=1; kod[287]=1; kod[288]=1; # g: 01100111



#Senden der Pakete/Dateien mit ncat.
#Übers Array iterieren und wiederholt durchlaufen. Channel kann mit STRG+C beendet werden.
#Kurze Pause von 300 ms nach jedem Paket.


while true; do

	for i in "${kod[@]}"; do
		
		if [ $i = "0" ]
		then
			cat 0Bit_100ByteSize.txt
		else
			cat 1Bit_200ByteSize.txt
		fi
		
		# Schlafe 300 ms. Ansonsten werden auf Empfangsseite die Pakete nicht schnell genug verarbeitet.
		sleep 0.3
				
	done
	
done



