# Filename: Alq3-TOF.em
#
# Parameters partially from
# GG. Malliaras et al., Appl. Phys. Lett. 79 (16), 2001

Equation
FieldDepMob
Trapping

Parameter
##############################################
#Charges
HOMO			5.6		eV
LUMO			3.0		eV
Epsrel		3.5
N0			1E27	m^-3	#guessed
OptChargeGen	0.7	#guessed
LangRecEff	0.1		#guessed

##############################################
#Mobilities
#=====Pool-Frenkel======
Mue*fd.N		2.9e-9	cm^2/Vs
Gamma.N		7.3e-3	cm^0.5/V^0.5
Mue*fd.P		1e-8		cm^2/Vs
Gamma.P		0		cm^0.5/V^0.5

##############################################
#Traps (sharp trap levels, Staudigel)
#shallow traps
Et.N			0.212	eV	#guessed
Nt.N			2.3e23 	m^-3	#guessed

#deep traps
#Et.N			0.33		eV	#guessed
#Nt.N			0.5e23	m^-3	#guessed

#needed only to simulate multiple trapping levels with the "Detailed" model
Tau.N		5E-3		us
ReleaseRate.N	2.0		ns^-1