# Electrical Data of MEH-PPV
# mobility parameters taken from L. Bozano et al. Appl. Phys. Lett. 74 6 p.1132 (1999)

Equation

FieldTempDepMob

Parameter

HOMO			5.4		eV
LUMO			3.0		eV

Mue*id.N		5e-9		cm^2/Vs
Mue*id.P		1e-6		cm^2/Vs

Mue*fd.N		5e-9		cm^2/Vs
Mue*fd.P		1e-6		cm^2/Vs
Gamma.N		5e-4		cm^0.5/V^0.5
Gamma.P		7e-4		cm^0.5/V^0.5

Mue*ftd.N	1e-3		cm^2/Vs
Mue*ftd.P	2e-1		cm^2/Vs
Ea.N			0.34		eV
Ea.P			0.38		eV
B.N			2.6e-5	eV*m^0.5/V^0.5
B.P			2.3e-5	eV*m^0.5/V^0.5
T0ftd.N		880		K
T0ftd.P		600		K


# estimated exciton values:

# host singlet:
Exc.RadRate.1		50e-3	ns^-1
Exc.GenEff.1 		0.25
Exc.DiffConst.1		0.5	nm^2/ns		#l0^2*RadRate: 10^2*50e-3=5

# host triplet:
#Exc.RadRate.2		1		  us^-1
#Exc.GenEff.2 		0.75
#Exc.DiffConst.2	2500		nm^2/us		#l0^2*RadRate: 50^2*1=50^2

# guest triplet,phosphor:
#Exc.RadRate.3		50e-3		ns^-1
#Exc.Transfer.2.3	1		  us^-1
#Exc.DiffConst.3	2500		nm^2/us		#l0^2*RadRate: 50^2*1=50^2



