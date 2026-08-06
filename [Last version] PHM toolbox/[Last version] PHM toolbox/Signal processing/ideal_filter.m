function fsignal=ideal_filter(signal, fs, length, start_freq, end_freq)
fft_result = fft(signal);
tfreq=(0:1/length:fs-1/length);
fft_result(tfreq<start_freq | tfreq>end_freq)=0;
fsignal=ifft(fft_result,'symmetric');