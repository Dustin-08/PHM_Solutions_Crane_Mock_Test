function re_sig=makeaudible(signal, fs, fsol, startf, endf)
    fft_sig=fft(signal,fs*fsol);
    re_half_fft_sig=fft_sig(startf*fsol:endf*fsol-1);
    re_fft_sig=[re_half_fft_sig;re_half_fft_sig(end:-1:1)];
    re_sig=ifft(re_fft_sig, 'symmetric');
    %     figure, plot(re_sig)
%     re_sig=imresize(re_sig,20000/((endf-startf)*2)*fsol);