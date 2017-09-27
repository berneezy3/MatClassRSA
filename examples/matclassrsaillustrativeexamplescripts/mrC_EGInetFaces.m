function F = mrC_EGInetFaces(includeRef)
% handpicked rather than delaunayed Faces matrix for 128-electrode EGI net
%
% F = mrC.EGInetFaces(includeRef)
% if includeRef = true, uses reference electrode Cz at vertex 129
%            otherwise, builds mesh only from 128 electrodes
%
% (c) Spero Nicholas with input from Justin Ales and Benoit Cottereau
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com

if includeRef
	Finit = [ 129 7 31; 129 106 7; 129 80 106; 129 55 80; 129 31 55 ];
else
	Finit = [ 31 55 7; 7 55 106; 106 55 80 ];
end

F = [ Finit;...
		7 106 6;...
		106 80 105;...
		80 55 79;...
		55 31 54;...
		31 7 30;...
		6 106 112;...
		112 106 105;...
		105 80 87;...
		80 79 87;...
		79 55 54;...
		79 54 62;...
		54 31 37;...
		37 31 30;...
		30 7 13;...
		13 7 6;...
		13 6 12;...
		6 112 5;...
		112 105 111;...
		105 87 104;...
		87 79 86;...
		79 62 78;...
		62 54 61;...
		54 37 53;...
		37 30 36;...
		30 13 29;...
		6 5 12;...
		112 118 5;...
		112 111 118;...
		111 105 104;...
		104 87 93;...
		93 87 86;...
		86 79 78;...
		61 54 53;...
		53 37 42;...
		42 37 36;...
		36 30 29;...
		29 13 20;...
		20 13 12;...
		12 5 11;...
		5 118 4;...
		118 111 117;...
		111 104 110;...
		104 93 103;...
		93 86 92;...
		86 78 85;...
		78 62 77;...
		62 61 67;...
		61 53 60;...
		53 42 52;...
		42 36 41;...
		36 29 35;...
		29 20 28;...
		20 12 19;...
		5 4 11;...
		118 124 4;...
		118 117 124;...
		117 111 110;...
		110 104 103;...
		103 93 98;...
		98 93 92;...
		92 86 85;...
		85 78 77;...
		77 62 72;...
		72 62 67;...
		67 61 60;...
		60 53 52;...
		52 42 47;...
		47 42 41;...
		41 36 35;...
		35 29 28;...
		28 20 24;...
		24 20 19;...
		19 12 11;...
		11 4 10;...
		4 124 3;...
		124 117 123;...
		117 110 116;...
		110 103 109;...
		103 98 102;...
		98 92 97;...
		92 85 91;...
		85 77 84;...
		77 72 76;...
		72 67 71;...
		67 60 66;...
		60 52 59;...
		52 47 51;...
		47 41 46;...
		41 35 40;...
		35 28 34;...
		28 24 27;...
		24 19 23;...
		19 11 18;...
		11 10 16;...
		10 4 3;...
		3 124 123;...
		123 117 116;...
		116 110 109;...
		109 103 102;...
		102 98 97;...
		97 92 91;...
		91 85 84;...
		84 77 76;...
		76 72 71;...
		71 67 66;...
		66 60 59;...
		59 52 51;...
		51 47 46;...
		46 41 40;...
		40 35 34;...
		34 28 27;...
		27 24 23;...
		23 19 18;...
		18 11 16;...
		16 10 15;...
		10 3 9;...
		3 123 2;...
		123 116 122;...
		116 109 115;...
		109 102 108;...
		102 97 101;...
		97 91 96;...
		91 84 90;...
		84 76 83;...
		76 71 75;...
		71 66 70;...
		66 59 65;...
		59 51 58;...
		51 46 50;...
		46 40 45;...
		40 34 39;...
		34 27 33;...
		27 23 26;...
		23 18 22;...
		18 16 15;...
		15 10 9;...
		9 3 2;...
		2 123 122;...
		122 116 115;...
		115 109 108;...
		108 102 101;...
		101 97 96;...
		96 91 90;...
		90 84 83;...
		83 76 75;...
		75 71 70;...
		70 66 65;...
		65 59 58;...
		58 51 50;...
		50 46 45;...
		45 40 39;...
		39 34 33;...
		33 27 26;...
		26 23 22;...
		22 18 15;...
		15 9 14;...
		9 2 8;...
		2 122 1;...
		122 115 121;...
		115 108 114;...
		101 96 100;...
		96 90 95;...
		90 83 89;...
		83 75 82;...
		75 70 74;...
		70 65 69;...
		65 58 64;...
		58 50 57;...
		45 39 44;...
		39 33 38;...
		33 26 32;...
		26 22 25;...
		22 15 21;...
		21 15 14;...
		14 9 8;...
		8 2 1;...
		1 122 121;...
		121 115 114;...
		100 96 95;...
		100 95 99;...
		95 90 89;...
		95 89 94;...
		89 83 82;...
		89 82 88;...
		82 75 74;...
		82 74 81;...
		74 70 69;...
		74 69 73;...
		69 65 64;...
		69 64 68;...
		64 58 57;...
		64 57 63;...
		44 39 38;...
		38 33 32;...
		32 26 25;...
		25 22 21;...
		21 14 17;...
		1 121 125;...
		121 114 120;...
		114 108 113;...
		100 99 107;...
		63 57 56;...
		45 44 49;...
		44 38 43;...
		38 32 128;...
		120 114 113;...
		120 113 119;...
		49 44 43;...
		49 43 48;...
		125 121 120;...
		125 120 119;...
		108 101 100;...
		108 100 107;...
		113 108 107;...
		99 95 94;...
		94 89 88;...
		88 82 81;...
		81 74 73;...
		73 69 68;...
		68 64 63;...
		57 50 45;...
		57 45 56;...
		56 45 49;...
		43 38 128;...
		43 128 48;...
		125 119 126;...
48 128 127];