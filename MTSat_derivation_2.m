%% Derive expression for MTR in terms of MTSat parameter (delta)

clear; clc

syms a_T1 a_PD TR_T1 TR_PD R1 A delta

S_T1 = (A*a_T1*R1*TR_T1)/((a_T1^2)/2+R1*TR_T1);
S_PD = (A*a_PD*R1*TR_PD)/((a_PD^2)/2+R1*TR_PD);
S_MT = (A*a_PD*R1*TR_PD)/((a_PD^2)/2+delta+R1*TR_PD);

MTR=simplify((S_PD-S_MT)/S_PD)
