%% NewCompare3_9.m  (로그추출 데이터용 · 자체 완결)
%  9채널(Motor/Reducer/Bearing × X,Y,Z)을 3x3 그리드로 스펙트럼 비교.
%  Raw/속도변환/포락 3가지를 각각 별도 창(각 9채널)에 표시.
%  1초 연속 .mat + state_log.csv 를 읽어, viewMode(전체/상승/하강)로 국면만 잘라 분석.
%  ※ 이 파일 하나로 동작(load_run 없어도 됨), 툴박스 자동 추가.
clear; clc; close all;

%% 1. 경로/설정  (basePath = 이 스크립트가 든 패키지 폴더 자동 인식)
scriptDir = fileparts(mfilename('fullpath'));
basePath  = fileparts(scriptDir);
targetDate = '260811_1';
targetRPM  = '80';
condName   = '정상';

% ★ 보기 대상 ★  0=전체 / 1=상승(등속) / 2=하강(등속)
viewMode = 1;

fs = 3200;  en_pw = 0;  normfact = 1;
xlimVal = [1 300];  winTime = 1;  use_dB = 0;
steadyBand = 5;   % ★ 정속 판정: 최고 주파수 ± 이 값 안만 정속

processTypesToRun = [0, 1, 2];   % 0:Raw 1:속도변환 2:포락 — 순서대로 창 3개

% 채널 배치(Settings.json useChannels 순서): 1~3 Motor / 4~6 Reducer / 7~9 Bearing
channelLabels = {'Motor-X','Motor-Y','Motor-Z', ...
                 'Reducer-X','Reducer-Y','Reducer-Z', ...
                 'Bearing-X','Bearing-Y','Bearing-Z'};
gridChannelIdx = [1 4 7; 2 5 8; 3 6 9];   % 행:X/Y/Z / 열:Motor/Reducer/Bearing

%% 2. 9채널 로드 + 국면 필터
[rawChannelCell, fsData, codePS] = loadRun9(basePath, targetDate, targetRPM, condName, fs, steadyBand);
switch viewMode
    case 1, sel = (codePS==3); modeStr = '상승 등속';
    case 2, sel = (codePS==4); modeStr = '하강 등속';
    otherwise, sel = true(size(codePS)); modeStr = '전체';
end
if ~any(sel), error('viewMode=%d(%s) 데이터가 없습니다.', viewMode, modeStr); end
rawChannelCell = cellfun(@(x) x(sel), rawChannelCell, 'UniformOutput', false);
fprintf('viewMode=%d(%s) → 9채널 각 %d샘플(%.2f초)\n', viewMode, modeStr, numel(rawChannelCell{1}), numel(rawChannelCell{1})/fsData);

%% 3. Raw/속도변환/포락 순차 적용 → 각각 창
for pt = processTypesToRun
    switch pt
        case 0, processLabel = 'Raw Signal';
        case 1, processLabel = 'Velocity Converted';
        case 2, processLabel = 'Envelope Signal';
        otherwise, error('processtype 0/1/2');
    end
    fprintf('=== [%s] 처리·플롯 ===\n', processLabel);
    procChannelCell = applyProcessing(rawChannelCell, fsData, pt);
    plotNineChannels(procChannelCell, fsData, gridChannelIdx, channelLabels, ...
        winTime, en_pw, normfact, use_dB, xlimVal, sprintf('%s [%s]', processLabel, modeStr), targetDate, condName);
end

%% ===================== 로컬 함수 =====================
function [chanCell, fs, codePS] = loadRun9(basePath, targetDate, targetRPM, condName, fsDefault, steadyBand)
    if nargin<6 || isempty(steadyBand), steadyBand=5; end
% 1초 연속 .mat(9xN) 들을 채널별로 이어붙이고, state_log 로 각 샘플 상태코드 매핑
    vibFolder = fullfile(basePath, targetDate, targetRPM, condName, 'Vib');
    logPath   = fullfile(basePath, targetDate, targetRPM, condName, 'Log', 'state_log.csv');   % 저장폴더 안 Log
    if ~isfile(logPath)   % 구버전 fallback
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
        if size(seg,1) < size(seg,2), else, seg = seg.'; end   % 채널 x 샘플 로 맞춤
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
        % ★ 로그 code 무시, freq로 재분류. 정속='방향별 최고 주파수 ± steadyBand' 안만 ★
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
        warning('state_log 없음 → 전체만: %s', string(logPath));
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

function plotNineChannels(chanCell, fsData, gridIdx, labels, winTime, en_pw, normfact, use_dB, xlimVal, processLabel, targetDate, condName)
    figure('Name', sprintf('9채널 [%s]', processLabel), 'NumberTitle','off', 'Position',[60 40 1400 1000]);
    for r=1:3
        for c=1:3
            ch = gridIdx(r,c); subplot(3,3,(r-1)*3+c);
            [tval,tfreq] = getspec(chanCell{ch}, fsData, winTime, en_pw, normfact); tval(1)=0;
            if use_dB, y=20*log10(tval+eps); yl='Magnitude (dB)'; else, y=tval; yl='Magnitude'; end
            plot(tfreq, y, 'Color',[0.494 0.184 0.556], 'LineWidth',1.0); grid on;
            title(labels{ch}, 'FontSize',10); xlim(xlimVal);
            if r==3, xlabel('Frequency (Hz)','FontWeight','bold'); end
            if c==1, ylabel(yl,'FontWeight','bold'); end
        end
    end
    sgtitle(sprintf('9채널 스펙트럼 - %s [%s / %s] (행:X/Y/Z, 열:Motor/Reducer/Bearing)', ...
        processLabel, targetDate, condName), 'FontSize',13, 'FontWeight','bold');
end
