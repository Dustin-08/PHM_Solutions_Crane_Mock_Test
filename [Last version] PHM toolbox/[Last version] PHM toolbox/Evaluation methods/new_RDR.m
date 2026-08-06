function peakRatio = new_RDR(pwspec, freq, speed, fsol, type)
order=3;
defectfreq = [5.24 2.488*2 7.76];       % defect frequencies at 900 RPM (outer, roller, inner)
faultFreq = (defectfreq.*speed/60);

err=0.025;
k=10^-4;
fc=0.4032*speed/60;
fr=speed/60;
fside=[0, fc, fr];

Nw=2*fsol;
figure;
hold on
peakRatio=0;

pwspec(1:3*fsol)=0;
faultCentFreq= faultFreq(type);
Nrdef=(2*fside(type)+(2*fside(type)+faultFreq(type))*err*2);
for i=1:order
    if i>1
        faultCentFreq=freq(cidx)*i;
        Nrdef=2*fside(type)+2;
    end
    range = (freq >= (faultCentFreq-Nrdef)) & (freq<= (faultCentFreq+Nrdef));
    
    alpha=estalpha(2*Nrdef*fsol,Nw,fsol,k);
    cor_mask=gausswin(round(2*Nrdef*fsol),alpha);
    mask=cor_mask;
    if type>1
        alpha=estalpha(Nw,Nw,fsol,k);
        c_idx1=round(length(cor_mask)/2-fside(type)*fsol);
        c_idx2=round(length(cor_mask)/2+fside(type)*fsol);
        cor_mask(c_idx1-round(Nw/2)+1:c_idx1+round(Nw/2))=gausswin(Nw,alpha)*.5;
        mask(c_idx1-round(Nw/2)+1:c_idx1+round(Nw/2))=gausswin(Nw,alpha);
        cor_mask(c_idx2-round(Nw/2)+1:c_idx2+round(Nw/2))=gausswin(Nw,alpha)*.5;
        mask(c_idx2-round(Nw/2)+1:c_idx2+round(Nw/2))=gausswin(Nw,alpha);
        alpha=estalpha(Nw,Nw,fsol,k);
        c_idx1=round(length(cor_mask)/2-2*fside(type)*fsol);
        c_idx2=round(length(cor_mask)/2+2*fside(type)*fsol);
        cor_mask(c_idx1-round(Nw/2)+1:c_idx1+round(Nw/2))=gausswin(Nw,alpha)*.25;
        mask(c_idx1-round(Nw/2)+1:c_idx1+round(Nw/2))=gausswin(Nw,alpha);
        cor_mask(c_idx2-round(Nw/2)+1:c_idx2+round(Nw/2))=gausswin(Nw,alpha)*.25;
        mask(c_idx1-round(Nw/2)+1:c_idx1+round(Nw/2))=gausswin(Nw,alpha);
    end
    
    x = freq(range);
    y = pwspec(range);
    [c, lags]=xcorr(y,cor_mask);
    [~,idx]=max(c);
    if i==1
        cidx=floor(x(1)*10+lags(idx))+round(length(cor_mask)/2);
    end
    if lags(idx)+1>0
        start_i=lags(idx)+1;
        start_i_mask=1;
    else
        start_i=1;
        start_i_mask=-lags(idx)+1;
    end
    if lags(idx)+length(cor_mask)>length(y)
        end_i=length(y);
        end_i_mask=length(y)-start_i+1;
    else
        end_i=lags(idx)+length(cor_mask);
        end_i_mask=length(mask);
    end
    
    start_i=x(1)*10+lags(idx)+1;
    start_i_mask=1;
    end_i=start_i+length(cor_mask)-1;
    end_i_mask=length(mask);
    
    dcomp=pwspec(start_i:end_i);
    plot(freq(freq < faultFreq(type)*3.5),pwspec(freq < faultFreq(type)*3.5));
    plot(freq(start_i:end_i),cor_mask(start_i_mask:end_i_mask)*max(dcomp)*1.2,'r-');    
end
