%% the system is constructed & simulated in the block

% define a BioSystem: this object will hold the parts and compositors
sys = BioSystem();

% define constants. assume that concentration units are in nM and time in s

sys.AddConstant(Const('k_if', 1000));
sys.AddConstant(Const('k_ir', 100));
sys.AddConstant(Const('k_arf', 10));
sys.AddConstant(Const('k_arr', 1));
sys.AddConstant(Const('k_rf', 10));
sys.AddConstant(Const('k_rr', 1));
sys.AddConstant(Const('k_oc1', 0.1));
sys.AddConstant(Const('k_oc2', 0.1));
sys.AddConstant(Const('k_tln', 0.1));
sys.AddConstant(Const('k_mdeg', 0.1)); % mRNA degradation &amp; dilution
sys.AddConstant(Const('k_pdeg', 0.01)); % protein degradation &amp; dilution
sys.AddConstant(Const('k_f', 10)); % rate of activator binding DNA
sys.AddConstant(Const('k_r', 1)); % rate of activator unbinding DNA

% add compositors: these are for the concentrations of species in the system.
% use the short-hand version to add the compositors right away,
% the second parameter is the initial concentration

dInddt = sys.AddCompositor('Ind', 0); % inducer, set value later
dactdt = sys.AddCompositor('act', 5); % nM, about 5 molecules in E. coli
dActdt = sys.AddCompositor('act_ind', 0);
dP1dt = sys.AddCompositor('P1', 0);
dP2dt = sys.AddCompositor('P2', 0);
dRNAPdt = sys.AddCompositor('RNAP', 1); % nM, about 1 copy in an E. coli
% TODO: add the rest of the compositors

dDNA1dt = sys.AddCompositor('DNA1',1);
dActDNA1dt = sys.AddCompositor('act_indDNA1',0);
dActDNA1RNAPdt = sys.AddCompositor('act_indDNA1RNAP',0);
dmRNA1dt = sys.AddCompositor('mRNA1',0);
dDNA2dt = sys.AddCompositor('DNA2',.3);
dDNA2RNAPdt = sys.AddCompositor('DNA2RNAP',0);
dmRNA2dt = sys.AddCompositor('mRNA2',0);

% TODO: define parts and add them to the system

P1 = Part('Ind + act ->act_ind', [dInddt dactdt dActdt],...
    [Rate('(k_ir * act_ind) - (k_if * act * Ind)') ...
    Rate('(k_ir * act_ind) - (k_if * act * Ind)'), ...
    Rate('-(k_ir * act_ind) + (k_if * act * Ind)')]);


P2 = Part('act_ind-(DNA1)->act_indDNA1', [dActdt dDNA1dt dActDNA1dt],...
    [Rate('(k_r * act_indDNA1) - (k_f * act_ind * DNA1)') ...
    Rate('(k_r * act_indDNA1) - (k_f * act_ind * DNA1)'), ...
    Rate('-(k_r * act_indDNA1) + (k_f * act_ind * DNA1)')]);

P3 = Part('act_indDNA1-(RNAP)->act_indDNA1RNAP', [dActDNA1dt dRNAPdt dActDNA1RNAPdt],...
    [Rate('(k_arr * act_indDNA1RNAP) - (k_arf * act_indDNA1 * RNAP)') ...
    Rate('(k_arr * act_indDNA1RNAP) - (k_arf * act_indDNA1 * RNAP)'), ...
    Rate('-(k_arr * act_indDNA1RNAP) + (k_arf * act_indDNA1 * RNAP)')]);

P4 = Part('act_indDNA1RNAP->mRNA1-(act_indDNA1)-(RNAP)', [dActDNA1RNAPdt dmRNA1dt dActDNA1dt dRNAPdt], ...
    [Rate('(-k_oc1 * act_indDNA1RNAP)') ...
    Rate('k_oc1 * act_indDNA1RNAP'), ...
    Rate('k_oc1 * act_indDNA1RNAP'), ...
    Rate('k_oc1 * act_indDNA1RNAP')]);

P5 = Part('DNA2-(RNAP)->DNA2RNAP', [dDNA2dt dRNAPdt dDNA2RNAPdt], ...
    [Rate('k_rr * DNA2RNAP - k_rf * DNA2 * RNAP') ...
    Rate('k_rr * DNA2RNAP - k_rf * DNA2 * RNAP'), ...
    Rate('-(k_rr * DNA2RNAP) + k_rf * DNA2 * RNAP')]);

P6 = Part('DNA2RNAP->mRNA2-(DNA2)-(RNAP)', [dDNA2RNAPdt dmRNA2dt dDNA2dt dRNAPdt], ...
    [Rate('-k_oc2 * DNA2RNAP') ...
    Rate('k_oc2 * DNA2RNAP'), ...
    Rate('k_oc2 * DNA2RNAP'), ...
    Rate('k_oc2 * DNA2RNAP')]);

P7 = Part('mRNA1->mRNA1-(P1)', [dP1dt], ...
    [Rate('k_tln * mRNA1')]);

P8 = Part('mRNA2->mRNA2-(P2)', [ dP2dt], ...
    [Rate('k_tln * mRNA2')]);

P9 = Part('mRNA1->0', [dmRNA1dt], ...
    Rate('-k_mdeg * mRNA1'));

P10 = Part('mRNA2->0', [dmRNA2dt], ...
    Rate('-k_mdeg * mRNA2'));

P11 = Part('P1->0', [dP1dt], ...
    Rate('-k_pdeg * P1'));

P12 = Part('P2->0', [dP2dt], ...
    Rate('-k_pdeg * P2'));
sys.AddPart(P1);
sys.AddPart(P2);
sys.AddPart(P3);
sys.AddPart(P4);
sys.AddPart(P5);
sys.AddPart(P6);
sys.AddPart(P7);
sys.AddPart(P8);
sys.AddPart(P9);
sys.AddPart(P10);
sys.AddPart(P11);
sys.AddPart(P12);

% Remember to use the same parts as in the Groundwork section of this problem set

% solve/simulate the system. change the amount of inducer at 3 times
[T, Y] = sys.run_pulses([...
    Pulse(0, 'Ind', 0), ...     % initial conditions
    Pulse(1000, 'Ind', 10), ... % spike in 10 nM of inducer @ t = 1000
    Pulse(2000, '', 0), ...     % stop the simulation at time 2000
]);


% plot
% figure();
% plot(T, Y(:, sys.CompositorIndex('P1')), ...
%      T, Y(:, sys.CompositorIndex('P2')), ...
%      T, Y(:, sys.CompositorIndex('RNAP')), ...
%      T, Y(:, sys.CompositorIndex('Ind')))
% ylim([0 12]);
% legend('P1', 'P2', 'RNAP', 'Ind', 'Location', 'best')
% xlabel('Time (s)');
% ylabel('Concentration (nM)');

%at T =57, it is at 915 seconds
P2_ss1 = Y(58,5);
P2_ss2 = Y(160,5);

change = (P2_ss1-P2_ss2)/P2_ss1;

disp(change)
%plot all compositors, useful for debugging:
%figure();
%num_compositors = size(Y, 2);
%for i = 1:num_compositors
  %   subplot(num_compositors, 1, i);
 %    plot(T, Y(:, i));
  %   xlabel('Time');
 %    ylabel(sprintf('[%s]', sys.compositors(i).name), 'Rotation', 0);
% end
