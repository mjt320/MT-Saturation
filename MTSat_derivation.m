%% Derive formulae for MTSat and compare to those in Helms et al., MRM, 2008, 60:1396–1407
%% and Lema et al., J Neuroimaging 2016

clear; clc

syms S_T1 S_PD S_MT a_T1 a_PD TR_T1 TR_PD R1 A delta

%% start with approximations for steady-state FLASH signal in Helms (Eqs. 1 and 6)
eqn_S_T1 = (S_T1 == (A*a_T1*R1*TR_T1)/((a_T1^2)/2+R1*TR_T1));
eqn_S_PD = (S_PD == (A*a_PD*R1*TR_PD)/((a_PD^2)/2+R1*TR_PD));
eqn_S_MT = (S_MT == (A*a_PD*R1*TR_PD)/((a_PD^2)/2+delta+R1*TR_PD));

%% solve for A, R1 and MTSat (delta) parameters
Sol_A_R1=solve([eqn_S_PD,eqn_S_T1],[R1,A])
Sol_Delta=solve([eqn_S_MT],[delta])


%% Check whether formulae are same as in Helm and Lema papers by
%% subtracting them from expressions derived above...

syms T a

exprHelm_A =  (((S_PD*a_PD)/TR_PD)/(S_T1*a_T1-S_PD*a_PD)) * (a_T1/a_PD - a_PD/a_T1); % Eqn 7b
exprHelm_R1 = (S_T1*a_T1-S_PD*a_PD)/(2*T*(S_PD/a_PD-S_T1/a_T1)); % Eqn 7a
exprHelm_delta = (A*(a/S_MT)-1)*R1*T - (a^2)/2; % Eqn 8
exprLema_A = ((2*TR_PD)/a_PD^2 - ((2*TR_T1)/a_T1^2))/... % Eqn 3
    ( (2*TR_PD)/(a_PD*S_PD) - (2*TR_T1)/(a_T1*S_T1) );
exprLema_T1 = (S_PD/a_PD - S_T1/a_T1) / ((S_PD*a_PD)/(2*TR_PD)) -... % Eqn 4
    (S_T1*a_T1)/(2*TR_T1);

simplify(subs(Sol_A_R1.A,TR_T1,TR_PD)-exprHelm_A) %assume TR_T1=TR_PD; Helms equation for A (does not match)
simplify(subs(Sol_A_R1.R1,[TR_PD,TR_T1],[T,T])-exprHelm_R1) %assume TR_PD=TR_T1=T,; Helms equation for R1 (matches)
simplify(subs(Sol_Delta,[TR_PD,a_PD],[T,a])-exprHelm_delta) %Helm equation for delta (matches)
simplify(Sol_A_R1.A-exprLema_A) %Lema equation for A (matches)
simplify(Sol_A_R1.R1-1/exprLema_T1) %Lema equation for T1 (does not match)
