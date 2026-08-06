function peak=get_peak(signal)
peak=20*log10(max(abs(signal))*10000);
