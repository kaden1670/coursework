function dydt = StandardSystem(~,y,k)

    % 
    % System of ODEs describing EGFR binding
    % Inputs:
    % y: a 1x9 [L, Rs, Cs, Ri, Ds, PDs, PDi, Grb2, PDs-Grb2] 
    % k: a 1x13 [Kf, Kr, Vs, Ker, Krec_r, Kdeg_r, Kdeg_d, Ked, Kcat, Kf_d, ...
    % Kr_d, Kf_g, Kr_g]


    % Output (output is dydt):
    % A 9x1  [dL/dt,dRs/dt,dCs/dt,dRi/dt,dDs/dt,dPDs/dt,dPDi/dt,dGrb2/dt,...
    % dPDs-Grb2/dt]

    dydt = zeros(9,1);
    L = y(1);
    Rs = y(2);
    Cs = y(3);
    Ri = y(4);
    Ds = y(5);
    PDs = y(6);
    PDi = y(7);
    Grb2 = y(8);
    PDs_Grb2 = y(9);

    Kf = k(1);
    Kr = k(2);
    Vs = k(3);
    Ker = k(4);
    Krec_r = k(5);
    Kdeg_r = k(6);
    Kdeg_d = k(7);
    Ked = k(8);
    Kcat = k(9);
    Kf_d = k(10);
    Kr_d = k(11);
    Kf_g = k(12);
    Kr_g = k(13);

    dydt(1,:) = 0; %-Kf.*L.*Rs + Kr.*Cs;% Assuming concentration stays the same
    dydt(2,:) = Vs - Kf.*L.*Rs + Kr.*Cs - Ker.*Rs + Krec_r.*Ri;
    dydt(3,:) = Kf.*L.*Rs - Kr.*Cs - Kf_d.*Cs.*Cs + 2.*Kr_d.*Ds;
    dydt(4,:) = Ker.*Rs - Krec_r.*Ri - Kdeg_r.*Ri;
    dydt(5,:) = Kf_d.*Cs.*Cs - Kcat.*Ds;
    dydt(6,:) = Kcat.*Ds - Ked.*PDs - Kf_g.*Grb2.*PDs + Kr_g.*PDs_Grb2;
    dydt(7,:) = Ked.*PDs - Kdeg_d.*PDi;
    dydt(8,:) = 0;
    dydt(9,:) = Kf_g.*Grb2.*PDs - Kr_g.*PDs_Grb2 - Ked.*PDs_Grb2;

end