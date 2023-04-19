function [ x,fsumsq ] = nag_lsqcurvefit(func,x0,xdata,ydata)
%A version of the lsqcurvefit command that uses the NAG Toolbox for MATLAB
%Provides non-linear least squares curve fitting using a syntax similar to
%the lsqcurvefit routine in the optimisation toolbox.
%requires the nag_lsqcurvefit_aux.m file while should have been included
%with this file.
%
%Author: Mike Croucher (Michael.Croucher@manchester.ac.uk)
%Author's website:www.walkingrandomly.com

user = {func,xdata,ydata};
switch computer 
    case 'GLNX86'
        m=int32(length(xdata));
    case 'GLNXA64'
        m=int64(length(xdata));
    case 'PCWIN'
        m=int32(length(xdata));
    case 'PCWIN64'
        m=int64(length(xdata));
    case 'MACI'
        m=int32(length(xdata));
    case 'MACI64'
        m=int64(length(xdata));
end
[x, fsumsq,~, ~] = e04fy(m, 'nag_lsqcurvefit_aux', x0, 'user', user);
% Older Matlab versions did not have ~
%[x, fsumsq,junk, junk1] = e04fy(m, 'nag_lsqcurvefit_aux', x0, 'user', user);
end
