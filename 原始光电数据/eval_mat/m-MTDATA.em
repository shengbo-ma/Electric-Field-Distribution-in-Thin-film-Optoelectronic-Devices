# Electrical parameter file for: SETFOS, Semiconducting Thin Film Optics Simulator (c)
#
# m-MTDATA Parameters taken from: 
# J. Staudigel, M.Stössel, F.Steuber, J. Simmerer
# "A quantitative numerical model of multilayer vapor-deposited organic light emitting diodes"
# Journal of Applied Physics Volume 86, Number 7
#

Equation
	FieldDepMob
	Trapping

Parameter

	Epsrel 	3.0
	LUMO		2.4	eV
	HOMO		5.3	eV
	N0			1E21	cm^-3

	# field-dependent mobility
	Gamma.N	3.39E-3	cm^0.5/V^0.5
	Gamma.P	3.39E-3	cm^0.5/V^0.5
	Mue*fd.N	4.79E-8	cm^2/Vs
	Mue*fd.P	4.79E-6	cm^2/Vs

	Et.P	0.5	eV
	Nt.P	4E16	cm^-3
