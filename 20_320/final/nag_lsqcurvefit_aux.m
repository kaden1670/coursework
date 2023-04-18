function [F, user] = nag_lsqcurvefit_aux(m, n, xc, user)
%Auxilliary file for nag_lsqcurvefit.m
%
%
%Author: Mike Croucher (Michael.Croucher@manchester.ac.uk)
%Author's website:www.walkingrandomly.com
fun=user{1}(xc,user{2});
F = fun-user{3};
