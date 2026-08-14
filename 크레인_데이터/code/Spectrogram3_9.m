%% Spectrogram3_9.m  (단일 폴더 · 로그 참조 · 9채널 스펙트로그램)
%  한 데이터 폴더(예: 260811_1\80\정상)를 로드해 9채널 STFT 스펙트로그램을 3x3 그리드로 표시.
%  viewMode 로 전체/상승/하강 국면만 잘라 볼 수 있음.
clear; clc; close all;

%% 1. 경로/설정  (basePath = 이 스크립트가 든 패키지 폴더 자동 인식)
scriptDir = fileparts(mfilename('fullpath'));
basePath  = fileparts(scriptDir);
targetDate = '260811_1';   % ← 사이클 폴더 (260811_1 ~ 260811_5)
targetRPM  = '80';
condName   = '정상';

% ★ 보기 대상 ★  0=전체 / 1=상승(등속) / 2=하강(등속)
viewMode = 0;              % 스펙트로그램은 전체(0) 권장(시간축 충분)
processtype = 0;           % 0:Raw 1:속도변환 2:포락

fs = 3200;  en_pw = 0;  normfact = 1;  use_dB = 0;
winTime = 0.25;            % STFT 프레임 길이(초) → Δf=1/winTime
overlapRatio = 0.8;
freqLim = [1 500];         % 스펙트로그램 주파수축(Y) 범위
steadyBand = 5;

channelLabels = {'Motor-X','Motor-Y','Motor-Z', ...
                 'Reducer-X','Reducer-Y','Reducer-Z', ...
                 'Bearing-X','Bearing-Y','Bearing-Z'};
gridChannelIdx = [1 4 7; 2 5 8; 3 6 9];

%% 2. 로드 + 국면 필터
[rawCell, fsData, codePS] = loadRun9(basePath, targetDate, targetRPM, condName, fs, steadyBand);
switch viewMode
    case 1, sel=(codePS==3); modeStr='상승 등속';
    case 2, sel=(codePS==4); modeStr='하강 등속';
    otherwise, sel=true(size(codePS)); modeStr='전체';
end
if ~any(sel), error('viewMode=%d(%s) 데이터 없음', viewMode, modeStr); end
rawCell = cellfun(@(x) x(sel), rawCell, 'UniformOutput', false);
switch processtype
    case 0, pLabel='Raw';  case 1, pLabel='Velocity';  case 2, pLabel='Envelope';
end
procCell = applyProcessing(rawCell, fsData, processtype);
fprintf('[%s %s %s] %s / %s → %d샘플(%.2fs)\n', targetDate,targetRPM,condName,modeStr,pLabel, ...
        numel(procCell{1}), numel(procCell{1})/fsData);

%% 3. 9채널 스펙트로그램
winLen = round(fsData*winTime); ov = round(winLen*overlapRatio); stp = winLen-ov; wf = hann(winLen);
figure('Name', sprintf('9채널 Spectrogram [%s|%s]', modeStr, pLabel), 'NumberTitle','off', 'Position',[40 30 1400 1000]);
for r=1:3
    for c=1:3
        ch = gridChannelIdx(r,c); subplot(3,3,(r-1)*3+c);
        x = procCell{ch};
        nF = floor((numel(x)-winLen)/stp)+1;
        if nF < 1
            title(sprintf('%s (신호 짧음)', channelLabels{ch})); axis off; continue;
        end
        [~,tfreq] = getspec(x(1:winLen).*wf, fsData, winTime, en_pw, normfact);
        S = zeros(numel(tfreq), nF); tv = zeros(1,nF);
        for i=1:nF
            a=(i-1)*stp+1; b=a+winLen-1; fr=x(a:b); fr=(fr-mean(fr)).*wf;
            [tval,~] = getspec(fr, fsData, winTime, en_pw, normfact); tval(1)=0;
            S(:,i)=tval; tv(i)=(a+winLen/2-1)/fsData;
        end
        if use_dB, P=20*log10(S+eps); cl='Magnitude (dB)'; else, P=S; cl='Magnitude'; end
        imagesc(tv, tfreq, P); axis xy; colormap('jet'); ylim(freqLim);
        title(channelLabels{ch}, 'FontSize',10);
        if r==3, xlabel('Time (s)','FontWeight','bold'); end
        if c==1, ylabel('Freq (Hz)','FontWeight','bold'); end
    end
end
cb = colorbar('Position',[0.94 0.11 0.015 0.8]); cb.Label.String = cl;
sgtitle(sprintf('9채널 스펙트로그램 - %s [%s %s %s - %s]  (행:X/Y/Z, 열:Motor/Reducer/Bearing)', ...
    pLabel, targetDate, targetRPM, condName, modeStr), 'FontSize',13, 'FontWeight','bold');

%% ===================== 로컬 함수 =====================
function [chanCell, fs, codePS] = loadRun9(basePath, targetDate, targetRPM, condName, fsDefault, steadyBand)
    if nargin<6 || isempty(steadyBand), steadyBand=5; end
    vibFolder = fullfile(basePath, targetDate, targetRPM, condName, 'Vib');
    logPath   = fullfile(basePath, targetDate, targetRPM, condName, 'Log', 'state_log.csv');
    if ~isfile(logPath)
        logPath = fullfile(basePath, 'Log', sprintf('%s_%s_%s_state_log.csv', targetDate, targetRPM, condName));
    end
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
    fs = fsDefault; segByFile = cell(numel(fl),1);
    for k=1:numel(fl)
        md = load(fullfile(fl(k).folder, fl(k).name));
        if isfield(md,'signals'), seg = md.signals;
        else, fn=fieldnames(md); nel=cellfun(@(x)numel(md.(x)),fn); [~,mi]=max(nel); seg=md.(fn{mi}); end
        if size(seg,1) < size(seg,2), else, seg = seg.'; end
        if isfield(md,'fs') && ~isempty(md.fs), fs=double(md.fs(1)); end
        segByFile{k} = seg;
    end
    nCh = size(segByFile{1},1);
    chanCell = cell(nCh,1);
    for ch=1:nCh
        p = cell(numel(fl),1);
        for k=1:numel(fl), s=segByFile{k}(ch,:); p{k}=s(:); end
        chanCell{ch} = vertcat(p{:});
    end
    N = numel(chanCell{1});
    sigStart = ts(1) - (round(fs*1)/fs)/86400;
    codePS = nan(N,1);
    if isfile(logPath)
        T = readtable(logPath);
        if isdatetime(T.timestamp), lt=datenum(T.timestamp);
        else, lt=datenum(string(T.timestamp),'yyyy-mm-dd HH:MM:SS.FFF'); end
        lf=double(T.freq); lm=double(T.mw1); lsec=(lt-sigStart)*86400;
        [lsec,ia]=unique(lsec,'stable'); lf=lf(ia); lm=lm(ia);
        idleMax=3; db=8;
        pkUp = max([lf(lm==1); idleMax]); pkDn = max([lf(lm==3); idleMax]);
        nL=numel(lf); c2=zeros(nL,1);
        for i=1:nL
            if lf(i) <= idleMax,                            c2(i)=0;
            elseif lm(i)==1 && lf(i) >= pkUp - steadyBand,  c2(i)=3;
            elseif lm(i)==3 && lf(i) >= pkDn - steadyBand,  c2(i)=4;
            elseif i<nL && lf(i+1) > lf(i) + db,            c2(i)=1;
            elseif i>1  && lf(i-1) > lf(i) + db,            c2(i)=2;
            else,                                           c2(i)=2;
            end
        end
        codePS = interp1(lsec,c2,((0:N-1).')/fs,'previous',NaN);
    else
        warning('state_log 없음: %s', string(logPath));
    end
    fprintf('  -> %d파일 %d채널 로드 (%s)\n', numel(fl), nCh, vibFolder);
end

function procCell = applyProcessing(rawCell, fs, processtype)
    n = numel(rawCell); procCell = cell(n,1);
    for ch=1:n
        seg = rawCell{ch}; seg = seg - mean(seg);
        switch processtype
            case 1, [seg,~] = convmeas(seg, fs, 'vel');
            case 2, seg = abs(hilbert(seg));
        end
        seg = seg - mean(seg); procCell{ch} = seg;
    end
end
