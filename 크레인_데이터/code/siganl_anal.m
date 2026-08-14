%% siganl_anal.m  (로그추출 데이터용 · 자체 완결)
%  1초 연속 .mat + state_log.csv 를 읽어, 국면(전체/상승/하강)·사이클별로 시각화.
%  ※ 이 파일 하나로 동작한다(load_run·cycle_group 없어도 됨). 툴박스도 자동 추가.
clear; clc; close all;

%% 1. 경로/설정  (basePath = 이 스크립트가 든 패키지 폴더 자동 인식)
scriptDir = fileparts(mfilename('fullpath'));
basePath  = fileparts(scriptDir);
targetDate = '260811_1';
targetRPM  = '80';
condName   = '정상';          % 상태 폴더 (Vib 상위)
targetCh   = 4;              % 볼 채널 1~9

% ★ 보기 대상 ★  0=전체 / 1=상승(등속) / 2=하강(등속)     (plottype 4 에선 무시)
viewMode = 1;
% ★ 전처리 ★  0=Raw / 1=속도변환 / 2=포락                 (1,2 는 toolbox 필요)
processtype = 0;
% ★ 그래프 ★  0=시계열 / 1=구간RMS / 2=스펙트럼 / 3=스펙트로그램 / 4=사이클별
plottype = 0;

fs = 3200;  en_pw = 0;  normfact = 1;
xlimVal = [1 500];
winTime = 1;  overlapRatio = 0.8;  use_dB = 0;
cycleSel = 0;      % plottype 4: 0=모든 사이클 / N=N번째만
cycleWin = 0.25;   % plottype 4: 이동 RMS 창(초)
steadyBand = 5;    % ★ 정속 판정: 최고 주파수 ± 이 값 안에 있을 때만 정속 (감속 중 중간속 평평 제외)

%% 2. 로드
vibFolder = fullfile(basePath, targetDate, targetRPM, condName, 'Vib');
logPath   = fullfile(basePath, targetDate, targetRPM, condName, 'Log', 'state_log.csv');   % 저장폴더 안 Log
if ~isfile(logPath)   % 구버전 fallback: Data\Log\{날짜_속도_상태}_state_log.csv
    logPath = fullfile(basePath, 'Log', sprintf('%s_%s_%s_state_log.csv', targetDate, targetRPM, condName));
end
[full, fs, codePS, ~] = loadRun(vibFolder, logPath, targetCh, steadyBand);

codeCol = [0.69 0.69 0.69; 0.90 0.49 0.13; 0.95 0.77 0.06; 0.15 0.68 0.38; 0.16 0.50 0.72];
codeName = {'대기','가속','감속','상승','하강'};

%% 3-A. 사이클별 보기 (plottype 4)
if plottype == 4
    isUp = (codePS==3); upOn = find(isUp & [true; ~isUp(1:end-1)]);
    isDn = (codePS==4); dnOn = find(isDn & [true; ~isDn(1:end-1)]);
    if isempty(upOn), error('상승(_3) 구간이 없어 사이클을 못 나눔.'); end
    bnd = [upOn; numel(full)+1]; cyc = {};
    for i = 1:numel(upOn)
        s = bnd(i); e = bnd(i+1)-1;
        if any(dnOn>=s & dnOn<=e), cyc{end+1} = [s e]; end %#ok<AGROW>
    end
    nCyc = numel(cyc);
    if nCyc==0, error('상승+하강 쌍(사이클)이 없음.'); end
    fprintf('유효 사이클 %d개 (상승+하강=1)\n', nCyc);
    if cycleSel>=1 && cycleSel<=nCyc, cl = cycleSel; else, cl = 1:nCyc; end
    nP = numel(cl); nW = round(fs*cycleWin);
    figure('Name','사이클별','NumberTitle','off','Position',[50 50 1000 max(220,180*nP)]);
    for ci = 1:nP
        c = cl(ci); s = cyc{c}(1); e = cyc{c}(2); seg = full(s:e); segC = codePS(s:e);
        m = floor(numel(seg)/nW); tt=zeros(1,m); rr=zeros(1,m); cc=zeros(1,m);
        for w=1:m, a=(w-1)*nW+1; b=w*nW; rr(w)=sqrt(mean(seg(a:b).^2)); tt(w)=(a+nW/2)/fs; cc(w)=mode(segC(a:b)); end
        subplot(nP,1,ci); hold on; plot(tt,rr,'-','Color',[.8 .8 .8],'LineWidth',.6);
        for w=1:m, col=[0 0 0]; if ~isnan(cc(w))&&cc(w)>=0&&cc(w)<=4, col=codeCol(cc(w)+1,:); end
            plot(tt(w),rr(w),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',5); end
        grid on; xlim([0 max(tt)+eps]); ylabel('RMS');
        title(sprintf('사이클 %d (%.1f초, ch%d)', c, numel(seg)/fs, targetCh),'FontWeight','bold');
        if ci==nP, xlabel('사이클 내 시간 (s)'); end
    end
    lg=gobjects(1,5);
    for k=0:4, lg(k+1)=plot(nan,nan,'o','MarkerFaceColor',codeCol(k+1,:),'MarkerEdgeColor',codeCol(k+1,:)); end
    legend(lg,codeName,'Orientation','horizontal','Location','southoutside');
    sgtitle(sprintf('사이클별 RMS [%s %s]', targetDate, targetRPM),'FontWeight','bold');
    return;
end

%% 3-B. 국면 필터 (viewMode)
switch viewMode
    case 1, sel = (codePS==3); modeStr = '상승 등속';
    case 2, sel = (codePS==4); modeStr = '하강 등속';
    otherwise, sel = true(size(full)); modeStr = '전체';
end
sig = full(sel);
if isempty(sig), error('viewMode=%d(%s) 데이터가 없습니다.', viewMode, modeStr); end
fprintf('viewMode=%d(%s), ch%d → %d샘플(%.2f초)\n', viewMode, modeStr, targetCh, numel(sig), numel(sig)/fs);

sig = sig - mean(sig);
switch processtype
    case 0, processLabel='Raw Signal';
    case 1, processLabel='Velocity Converted'; [sig,~]=convmeas(sig,fs,'vel');
    case 2, processLabel='Envelope Signal';      sig=abs(hilbert(sig));
    otherwise, error('processtype 0/1/2');
end
sig = sig - mean(sig); totalSignal = sig;

nPer = round(fs*winTime); nChunk = max(1,floor(numel(sig)/nPer)); segRMS=zeros(1,nChunk);
for i=1:nChunk, seg=sig((i-1)*nPer+1:i*nPer); segRMS(i)=sqrt(mean(seg.^2)); end

chStr = sprintf('ch%d', targetCh);
figure('Name',sprintf('[%s] Plot %d [%s|%s]',modeStr,plottype,processLabel,chStr),'NumberTitle','off');
switch plottype
    case 0
        t=(0:numel(totalSignal)-1)/fs; plot(t,totalSignal,'Color',[0 .447 .741],'LineWidth',.8); grid on;
        xlabel('Time (s)','FontWeight','bold'); ylabel('Amplitude','FontWeight','bold');
        title(sprintf('Time [%s %s - %s - %s]',targetDate,targetRPM,modeStr,chStr),'FontWeight','bold'); xlim([0 t(end)]);
    case 1
        plot(1:nChunk,segRMS,'-o','Color',[.85 .325 .098],'LineWidth',1.2,'MarkerFaceColor',[.85 .325 .098]); grid on;
        xlabel('구간(1초)','FontWeight','bold'); ylabel('RMS','FontWeight','bold');
        title(sprintf('구간별 RMS [%s %s - %s - %s] (%d구간)',targetDate,targetRPM,modeStr,chStr,nChunk),'FontWeight','bold');
        if nChunk>1, xlim([1 nChunk]); end
    case 2
        [tval,tfreq]=getspec(totalSignal,fs,winTime,en_pw,normfact); tval(1)=0;
        if use_dB, y=20*log10(tval+eps); yl='Magnitude (dB)'; else, y=tval; yl='Magnitude'; end
        plot(tfreq,y,'Color',[.494 .184 .556],'LineWidth',1); grid on;
        xlabel('Frequency (Hz)','FontWeight','bold'); ylabel(yl,'FontWeight','bold');
        title(sprintf('Spectrum [%s %s - %s - %s]',targetDate,targetRPM,modeStr,chStr),'FontWeight','bold'); xlim(xlimVal);
    case 3
        winLen=round(fs*winTime); ov=round(winLen*overlapRatio); st=winLen-ov; wf=hann(winLen);
        nF=floor((numel(totalSignal)-winLen)/st)+1; if nF<1, error('신호가 winTime보다 짧음'); end
        [~,tfreq]=getspec(totalSignal(1:winLen).*wf,fs,winTime,en_pw,normfact); S=zeros(numel(tfreq),nF); tv=zeros(1,nF);
        for i=1:nF, a=(i-1)*st+1; b=a+winLen-1; fr=totalSignal(a:b); fr=(fr-mean(fr)).*wf;
            [tval,~]=getspec(fr,fs,winTime,en_pw,normfact); tval(1)=0; S(:,i)=tval; tv(i)=(a+winLen/2-1)/fs; end
        if use_dB, P=20*log10(S+eps); cl2='Magnitude (dB)'; else, P=S; cl2='Magnitude'; end
        imagesc(tv,tfreq,P); axis xy; colormap('jet'); cb=colorbar; cb.Label.String=cl2;
        xlabel('Time (s)','FontWeight','bold'); ylabel('Frequency (Hz)','FontWeight','bold');
        title(sprintf('Spectrogram [%s %s - %s - %s]',targetDate,targetRPM,modeStr,chStr),'FontWeight','bold'); ylim(xlimVal);
    otherwise, error('plottype 0/1/2/3/4');
end

%% ===== 로컬 함수 (load_run 을 여기 포함 — 별도 파일 불필요) =====
function [full, fs, codePS, sigStart] = loadRun(vibFolder, logPath, targetCh, steadyBand)
    if nargin<4 || isempty(steadyBand), steadyBand=5; end
    fl = dir(fullfile(vibFolder,'*.mat'));
    if isempty(fl), error('Vib .mat 없음: %s', vibFolder); end
    ts = nan(numel(fl),1);
    for k=1:numel(fl)
        tk = regexp(fl(k).name,'(\d{8}_\d{6}_\d{3})','tokens','once');
        if ~isempty(tk), ts(k)=datenum(tk{1},'yyyymmdd_HHMMSS_FFF'); end
    end
    ok=~isnan(ts); fl=fl(ok); ts=ts(ok);
    if isempty(ts), error('타임스탬프 있는 .mat 없음: %s', vibFolder); end
    [ts,ord]=sort(ts); fl=fl(ord);
    parts=cell(numel(fl),1); fs=[];
    for k=1:numel(fl)
        md=load(fullfile(fl(k).folder,fl(k).name)); fn=fieldnames(md);
        nel=cellfun(@(x)numel(md.(x)),fn); [~,mi]=max(nel); raw=md.(fn{mi});
        if isvector(raw), s=raw(:);
        elseif size(raw,1)<=size(raw,2), s=raw(min(targetCh,size(raw,1)),:).';
        else, s=raw(:,min(targetCh,size(raw,2))); end
        if isempty(fs)&&isfield(md,'fs'), fs=double(md.fs(1)); end
        parts{k}=s;
    end
    if isempty(fs), fs=3200; end
    full=vertcat(parts{:}); N=numel(full);
    sigStart = ts(1) - (round(fs*1)/fs)/86400;
    codePS=nan(N,1);
    if nargin>=2 && ~isempty(logPath) && isfile(logPath)
        T=readtable(logPath);
        if isdatetime(T.timestamp), lt=datenum(T.timestamp);
        else, lt=datenum(string(T.timestamp),'yyyy-mm-dd HH:MM:SS.FFF'); end
        lf=double(T.freq); lm=double(T.mw1); lsec=(lt-sigStart)*86400;
        [lsec,ia]=unique(lsec,'stable'); lf=lf(ia); lm=lm(ia);
        % ★ 로그 code 무시, freq 로 재분류 ★
        %  G100이 freq를 ~0.2초마다 갱신 → 로그 code가 램프 중 정속으로 오판. 그래서 freq로 판정.
        %  정속 = '방향별 최고 주파수 ± steadyBand' 안에 있을 때만.
        %  (상승/하강 최고속이 다를 수 있어 각각 기준. band 작게=최고속만(균일)/크게=넓게 포함)
        idleMax=3; db=8;
        pkUp = max([lf(lm==1); idleMax]);   % 상승 최고속
        pkDn = max([lf(lm==3); idleMax]);   % 하강 최고속
        nL=numel(lf); c2=zeros(nL,1);
        for i=1:nL
            if lf(i) <= idleMax,                            c2(i)=0;      % 대기
            elseif lm(i)==1 && lf(i) >= pkUp - steadyBand,  c2(i)=3;      % 상승 정속(최고속)
            elseif lm(i)==3 && lf(i) >= pkDn - steadyBand,  c2(i)=4;      % 하강 정속(최고속)
            elseif i<nL && lf(i+1) > lf(i) + db,            c2(i)=1;      % 가속(오름)
            elseif i>1  && lf(i-1) > lf(i) + db,            c2(i)=2;      % 감속(내림)
            else,                                           c2(i)=2;      % 그 외(중간)=감속쪽
            end
        end
        codePS=interp1(lsec,c2,((0:N-1).')/fs,'previous',NaN);
    else
        warning('state_log 없음 → 전체만 사용: %s', string(logPath));
    end
end
