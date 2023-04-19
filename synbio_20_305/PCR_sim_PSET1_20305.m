cycles = 30; % how many cycles of PCR to simulate?

% TODO: replace ? with a number
error_rates = [4.4 36.7 220] * 10^(-7) * 6000;


% such that this vector holds the error rates per DNA molecule per PCR cycle
%initial_dsDNA = 10^10;
initial_dsDNA = 10^10;

num_polmerases = length(error_rates);
cycle_num = 0:1:cycles; % start with cycle 0, then cycle 1, etc
frac_correct = ones(num_polmerases, cycles + 1); % a matrix where each row is a
% polymerase and each column is the fraction of correct products at a cycle

correct_dsDNA = zeros(num_polmerases, cycles); % a matrix where each row is a
% polymerase and each column is the number of correct dsDNA at a cycle
for i = 1:num_polmerases
    correct_dsDNA(i, 1) = initial_dsDNA;
end
incorrect_dsDNA = zeros(num_polmerases, cycles); % dsDNA with both strands being incorrect
half_correct_dsDNA = zeros(num_polmerases, cycles); % dsDNA with exactly one strand being incorrect rof

total_dsDNA = [];
total_dsDNA(1) = initial_dsDNA;
for i = 2:cycles+1

    total_dsDNA(i) = total_dsDNA(i-1)*2;

end

%num_mistakes = zeros(3,cycles+1);
for j = 2:(cycles+1) % iterate over cycles
    % At each cycle, dsDNA is melted into ssDNA and each undergoes replication.
    % A correct ssDNA might be the basis of making an incorrect ssDNA.
    % An incorrect ssDNA will be the basis of making an incorrect ssDNA.
    % Remember that we always have any ssDNA from the previous cycle.

    for i = 1:num_polmerases % iterate over polymerases
        error_r8 = error_rates(i);
      %  num_mistakes(i,j) = total_dsDNA(i)*error_rates(i);
       correct_ssDNA = correct_dsDNA(i,j-1)*2 + half_correct_dsDNA(i,j-1);
       incorrect_ssDNA = incorrect_dsDNA(i,j-1)*2 + half_correct_dsDNA(i,j-1);
       
       half_correct_dsDNA(i,j) = correct_ssDNA*error_r8;
       incorrect_dsDNA(i,j) = incorrect_ssDNA;
       correct_dsDNA(i,j) = (1-error_r8)*correct_ssDNA;
       frac_correct(i,j) = correct_dsDNA(i,j)/total_dsDNA(j);
        
    end
end

plot(cycle_num, frac_correct, 'o-') % plot the results
xlabel("Cycle Number")
ylabel("Fraction of Correct PCR Products")
% TODO: label axes
axis([0 cycles 0 1])