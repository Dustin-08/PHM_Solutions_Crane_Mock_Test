%% Combine5cyc_UpDown.m  (5개 사이클 상승/하강 이어붙여 · 9채널 스펙트럼)
%  260811_1 ~ 260811_5 각각에서 국면코드로 상승(3)/하강(4)만 추출, 채널별로 이어붙여
%  NewCompare3_9 와 동일하게 getspec 으로 9채널 스펙트럼 표시.
%  ※ NewCompare 가 원본 폴더의 국면신호를 이어붙여 getspec 하는 것과 동일한 경로라,
%    같은 RPM/조건/국면이면 원본 NewCompare 와 픽셀 단위로 동일하게 나온다.
%  Raw/속도변환/포락 3가지를 각각 별도 창에 표시.
clear; clc; close all;

%% 1. 경로/설정  (basePath = 이 스크립트가 든 패키지 폴더 자동 인식)
scriptDir = fileparts(mfilename('fullpath'));
basePath  = fileparts(scriptDir);
cycleDates = {'260811_1','260811_2','260811_3','260811_4','260811_5'};
targetRPM  = '80';
condName   = '스프라킷';

phaseSel   = [3];            % 추출할 국면: 3=상승, 4=하강 (둘 다=[3 4])
processTypesToRun = [0 1 2]; % 0:Raw 1:속도변환 2:포락 — 순서대로 창 3개

fs = 3200;  en_pw = 0;  normfact = 1;
xlimVal = [1 300];  winTime = 1;  use_dB = 0;   % NewCompare 와 동일 축
steadyBand = 5;

channelLabels = {'Motor-X','Motor-Y','Motor-Z', ...
                 'Reducer-X','Reducer-Y','Reducer-Z', ...
                 'Bearing-X','Bearing-Y','Bearing-Z'};
gridChannelIdx = [1 4 7; 2 5 8; 3 6 9];

%% 2. 5개 사이클 로드 → 국면 추출 → 채널별로 이어붙이기 (NewCompare 와 동일 경로)
combined = [];
for i = 1:numel(cycleDates)
    [rawCell, fsData, codePS] = loadRun9(basePath, cycleDates{i}, targetRPM, condName, fs, steadyBand);
    sel = ismember(codePS, phaseSel);
    if isempty(combined), combined = cell(numel(rawCell),1); end
    for ch = 1:numel(rawCell)
        combined{ch} = [combined{ch}; rawCell{ch}(sel)];
    end
    fprintf('%s: 선택 %d샘플(%.2fs)\n', cycleDates{i}, sum(sel), sum(sel)/fsData);
end
if isempty(combined) || isempty(combined{1}), error('추출된 데이터가 없습니다.'); end
fprintf('합계: 채널당 %d샘플(%.2f초)\n', numel(combined{1}), numel(combined{1})/fs);
phStr = strjoin(arrayfun(@(x) sprintf('%d',x), phaseSel, 'UniformOutput',false), '+');

%% 3. Raw/속도변환/포락 → 각각 9채널 창
for pt = processTypesToRun
    switch pt
        case 0, processLabel='Raw Signal';
        case 1, processLabel='Velocity Converted';
        case 2, processLabel='Envelope Signal';
    end
    procCell = applyProcessing(combined, fs, pt);
    plotNineChannels(procCell, fs, gridChannelIdx, channelLabels, winTime, en_pw, normfact, use_dB, ...
        xlimVal, processLabel, sprintf('5cyc %s %s phase%s', targetRPM, condName, phStr));
end

%% ===================== 로컬 함수 =====================
function plotNineChannels(chanCell, fsData, gridIdx, labels, winTime, en_pw, normfact, use_dB, xlimVal, processLabel, tagStr)
    figure('Name', sprintf('5사이클 9채널 [%s]', processLabel), 'NumberTitle','off', 'Position',[60 40 1400 1000]);
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
    sgtitle(sprintf('9채널 스펙트럼(상승/하강 이어붙임) - %s [%s]  (행:X/Y/Z, 열:Motor/Reducer/Bearing)', ...
        processLabel, tagStr), 'FontSize',13, 'FontWeight','bold');
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
