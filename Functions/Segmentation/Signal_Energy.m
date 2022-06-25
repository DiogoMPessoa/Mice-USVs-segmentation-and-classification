function sig_energy=Signal_Energy(y)
F = fft(y);
pow = F.*conj(F);
total_pow = sum(pow);

sig_energy=pow2db(total_pow);