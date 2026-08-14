%% RMS3_9.m  (단일 폴더 · 로그 참조 · RMS만 출력)
%  한 데이터 폴더(예: 260811_1\80\정상)를 로드해 9채널 이동 RMS 시계열만 표시.
%  (국면 배경색은 참고용, 다른 그래프/표는 없음)
clear; clc; close all;

%% 1. 경로/설정  (basePath = 이 스크립트가 든 패키지 폴더 자동 인식)
scriptDir = fileparts(mfilename('fullpath'));
basePath  = fileparts(scriptDir);            % 패키지 루트 (260811_1..5 있는 곳)
targetDate = '260811_1';   % ← 사이클 폴더 (260811_1 ~ 260811_5)
targetRPM  = '80';
condName   = '정상';

fs = 3200;
rmsWin = 0.1;      % 이동 RMS 창(초)
processtype = 0;   % 0:Raw 1:속도변환 2:포락  (RMS 계산 전 전처리)
steadyBand = 5;
showPhaseBg = true;   % 국면 배경색 표시 (false면 순수 RMS만)

channelLabels = {'Motor-X','Motor-Y','Motor-Z', ...
                 'Reducer-X','Reducer-Y','Reducer-Z', ...
                 'Bearing-X','Bearing-Y','Bearing-Z'};
gridChannelIdx = [1 4 7; 2 5 8; 3 6 9];
phaseColors = [0.85 0.85 0.85;    % 0 대기
               1.00 0.90 0.60;    % 1 가속
               0.75 0.90 1.00;    % 2 감속
               0.70 0.90 0.70;    % 3 상승등속
               1.00 0.75 0.75];   % 4 하강등속

%% 2. 로드
[rawCell, fsData, codePS] = loadRun9(basePath, targetDate, targetRPM, condName, fs, steadyBand);
switch processtype
    case 0, pLabel='Raw';  case 1, pLabel='Velocity';  case 2, pLabel='Envelope';
end
procCell = applyProcessing(rawCell, fsData, processtype);
N = numel(procCell{1});  t = (0:N-1).'/fsData;
codeFilled = codePS; codeFilled(isnan(codeFilled)) = 0;
runs = findRuns(codeFilled);

%% 3. 9채널 이동 RMS (RMS만 출력)
w = round(rmsWin*fsData);
figure('Name', sprintf('9채널 이동RMS [%s]', pLabel), 'NumberTitle','off', 'Position',[50 30 1400 1000]);
for r=1:3
    for c=1:3
        ch = gridChannelIdx(r,c); ax = subplot(3,3,(r-1)*3+c); hold(ax,'on');
        mrms = sqrt(movmean(procCell{ch}.^2, w));
        ymax = max(mrms)*1.05 + eps;
        if showPhaseBg
            for i=1:size(runs,1)
                cd = runs(i,3); if cd<0||cd>4, continue; end
                x1=t(runs(i,1)); x2=t(runs(i,2));
                patch([x1 x2 x2 x1],[0 0 ymax ymax], phaseColors(cd+1,:), ...
                      'EdgeColor','none','FaceAlpha',0.5);
            end
        end
        plot(t, mrms, 'k', 'LineWidth', 0.8);
        ylim([0 ymax]); xlim([0 t(end)]); grid on;
        title(channelLabels{ch}, 'FontSize',10);
        if r==3, xlabel('Time (s)','FontWeight','bold'); end
        if c==1, ylabel('RMS','FontWeight','bold'); end
    end
end
sgtitle(sprintf('9채널 이동 RMS (%.2fs창) - %s [%s %s %s]', ...
    rmsWin, pLabel, targetDate, targetRPM, condName), 'FontSize',13, 'FontWeight','bold');

%% ===================== 로컬 함수 =====================
function runs = findRuns(code)
    code = code(:); n=numel(code); runs=zeros(0,3); s=1;
    for i=2:n
        if code(i)~=code(s), runs(end+1,:)=[s i-1 code(s)]; s=i; end %#ok<AGROW>
    end
    runs(end+1,:)=[s n code(s)];
end

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
