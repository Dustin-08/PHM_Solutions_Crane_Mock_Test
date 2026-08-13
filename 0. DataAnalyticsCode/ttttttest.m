%% NewCompare3_9.m
% 로그추출 데이터용 · 자체 완결
%
% 9채널
% Motor/Reducer/Bearing × X,Y,Z
%
% Raw / 속도변환 / 포락 신호를 각각 별도 창에 표시
% 1초 연속 .mat + state_log.csv를 읽어
% viewMode에 따라 전체/상승 등속/하강 등속 구간만 분석
%
% 주의:
% close all을 사용하지 않으므로 이전 RPM의 figure가 유지됨
%
% 예:
% 1차 실행: targetRPM = '60';
% 2차 실행: targetRPM = '70';
% 결과: 60 Hz figure 3개 + 70 Hz figure 3개

clearvars;
clc;

% 기존 figure를 닫고 싶을 때만 수동으로 실행
% close all;

%% PHM toolbox 자동 추가
% getspec / convmeas 필요
tb = '/Users/dustin08/Documents/MATLAB';
if isfolder(tb)
    addpath(genpath(tb));
end
%% 1. 경로 및 설정
basePath   = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data';
targetDate = '260813_2';
% 비교할 RPM 또는 Hz
% 첫 번째 실행
targetRPM = '80';
% 두 번째 실행 시 아래처럼 변경
% targetRPM = '70';
condName = '베어링외륜';

% 보기 대상
% 0 = 전체
% 1 = 상승 등속
% 2 = 하강 등속
viewMode = 1;

fs = 3200;

en_pw = 0;
normfact = 1;

xlimVal = [0 400];
    
winTime = 1;
use_dB = 0;

% 정속 판정 범위
% 최고 주파수 ± steadyBand
steadyBand = 5;

% 처리 방식
% 0 = Raw
% 1 = 속도변환
% 2 = 포락
processTypesToRun = [0, 1, 2];

%% 채널 설정

% Settings.json의 useChannels 순서
%
% 1~3: Motor
% 4~6: Reducer
% 7~9: Bearing

channelLabels = { ...
    'Motor-X', ...
    'Motor-Y', ...
    'Motor-Z', ...
    'Reducer-X', ...
    'Reducer-Y', ...
    'Reducer-Z', ...
    'Bearing-X', ...
    'Bearing-Y', ...
    'Bearing-Z'};

% 행: X/Y/Z
% 열: Motor/Reducer/Bearing
gridChannelIdx = [ ...
    1 4 7;
    2 5 8;
    3 6 9];

%% 2. 9채널 로드 및 국면 필터

[rawChannelCell, fsData, codePS] = loadRun9( ...
    basePath, ...
    targetDate, ...
    targetRPM, ...
    condName, ...
    fs, ...
    steadyBand);

switch viewMode

    case 1
        sel = (codePS == 3);
        modeStr = '상승 등속';

    case 2
        sel = (codePS == 4);
        modeStr = '하강 등속';

    otherwise
        sel = true(size(codePS));
        modeStr = '전체';
end

if ~any(sel)
    error('viewMode=%d(%s) 데이터가 없습니다.', ...
        viewMode, modeStr);
end

% 선택된 구간만 추출
rawChannelCell = cellfun( ...
    @(x) x(sel), ...
    rawChannelCell, ...
    'UniformOutput', false);

fprintf('\n');
fprintf('========================================\n');
fprintf('분석 정보\n');
fprintf('========================================\n');
fprintf('날짜       : %s\n', targetDate);
fprintf('RPM        : %s Hz\n', targetRPM);
fprintf('조건       : %s\n', condName);
fprintf('보기 모드  : %s\n', modeStr);
fprintf('샘플링 주파수 : %.2f Hz\n', fsData);
fprintf('채널 수    : %d\n', numel(rawChannelCell));
fprintf('샘플 수    : %d\n', numel(rawChannelCell{1}));
fprintf('분석 시간  : %.2f초\n', ...
    numel(rawChannelCell{1}) / fsData);
fprintf('========================================\n');
fprintf('\n');

%% 3. Raw / 속도변환 / 포락 처리 및 플롯

for pt = processTypesToRun

    switch pt

        case 0
            processLabel = 'Raw Signal';

        case 1
            processLabel = 'Velocity Converted';

        case 2
            processLabel = 'Envelope Signal';

        otherwise
            error('processtype은 0, 1, 2 중 하나여야 합니다.');
    end

    fprintf('=== [%s] 처리 및 플롯 시작 ===\n', ...
        processLabel);

    procChannelCell = applyProcessing( ...
        rawChannelCell, ...
        fsData, ...
        pt);

    plotNineChannels( ...
        procChannelCell, ...
        fsData, ...
        gridChannelIdx, ...
        channelLabels, ...
        winTime, ...
        en_pw, ...
        normfact, ...
        use_dB, ...
        xlimVal, ...
        sprintf('%s [%s]', processLabel, modeStr), ...
        targetDate, ...
        condName, ...
        targetRPM);

end

fprintf('\n모든 처리가 완료되었습니다.\n');


%% ============================================================
% 로컬 함수
%% ============================================================

function [chanCell, fs, codePS] = loadRun9( ...
    basePath, targetDate, targetRPM, condName, fsDefault, steadyBand)

    if nargin < 6 || isempty(steadyBand)
        steadyBand = 5;
    end

    %% 1. 데이터 경로 설정

    vibFolder = fullfile( ...
        basePath, ...
        targetDate, ...
        targetRPM, ...
        condName, ...
        'Vib');

    logPath = fullfile( ...
        basePath, ...
        targetDate, ...
        targetRPM, ...
        condName, ...
        'Log', ...
        'state_log.csv');

    fprintf('Vib 경로:\n%s\n', vibFolder);
    fprintf('Log 경로:\n%s\n', logPath);

    %% 2. Vib 파일 검색

    fl = dir(fullfile(vibFolder, '*.mat'));

    if isempty(fl)
        error('Vib .mat 파일이 없습니다:\n%s', vibFolder);
    end

    %% 3. 파일명에서 timestamp 추출

    ts = nan(numel(fl), 1);

    for k = 1:numel(fl)

        tk = regexp( ...
            fl(k).name, ...
            '(\d{8}_\d{6}_\d{3})', ...
            'tokens', ...
            'once');

        if ~isempty(tk)
            ts(k) = datenum( ...
                tk{1}, ...
                'yyyymmdd_HHMMSS_FFF');
        end
    end

    ok = ~isnan(ts);

    fl = fl(ok);
    ts = ts(ok);

    if isempty(ts)
        error('timestamp가 포함된 .mat 파일이 없습니다:\n%s', ...
            vibFolder);
    end

    % 시간순 정렬
    [ts, ord] = sort(ts);
    fl = fl(ord);

    %% 4. .mat 데이터 로드

    fs = fsDefault;
    segByFile = cell(numel(fl), 1);

    for k = 1:numel(fl)

        matPath = fullfile(fl(k).folder, fl(k).name);
        md = load(matPath);

        % signals 변수가 있으면 우선 사용
        if isfield(md, 'signals')

            seg = md.signals;

        else

            % 가장 큰 변수를 신호 데이터로 사용
            fn = fieldnames(md);
            nel = cellfun(@(x) numel(md.(x)), fn);

            [~, mi] = max(nel);
            seg = md.(fn{mi});
        end

        % 채널 x 샘플 형태로 변환
        %
        % 일반적으로 9 x N이면 그대로 사용
        % N x 9이면 transpose
        if size(seg, 1) >= size(seg, 2)
            seg = seg.';
        end

        % .mat 내부에 fs가 있으면 사용
        if isfield(md, 'fs') && ~isempty(md.fs)
            fs = double(md.fs(1));
        end

        segByFile{k} = seg;
    end

    %% 5. 채널별로 모든 파일 연결

    nCh = size(segByFile{1}, 1);

    if nCh < 9
        error('채널 수가 9개보다 적습니다. 현재 채널 수: %d', nCh);
    end

    chanCell = cell(nCh, 1);

    for ch = 1:nCh

        p = cell(numel(fl), 1);

        for k = 1:numel(fl)

            s = segByFile{k}(ch, :);
            p{k} = s(:);
        end

        chanCell{ch} = vertcat(p{:});
    end

    N = numel(chanCell{1});

    %% 6. state_log를 이용한 상태 코드 생성

    codePS = nan(N, 1);

    if isfile(logPath)

        fprintf('state_log 파일을 읽습니다.\n');

        T = readtable(logPath);

        % timestamp 확인
        if ~ismember('timestamp', T.Properties.VariableNames)
            error('state_log에 timestamp 열이 없습니다.');
        end

        % freq 확인
        if ~ismember('freq', T.Properties.VariableNames)
            error('state_log에 freq 열이 없습니다.');
        end

        % mw1 확인
        if ~ismember('mw1', T.Properties.VariableNames)
            error('state_log에 mw1 열이 없습니다.');
        end

        %% timestamp 변환

        if isdatetime(T.timestamp)

            lt = datenum(T.timestamp);

        else

            timestampString = string(T.timestamp);
            timestampString = strrep( ...
                timestampString, 'T', ' ');

            try

                lt = datenum( ...
                    timestampString, ...
                    'yyyy-MM-dd HH:mm:ss.FFF');

            catch

                lt = datenum( ...
                    timestampString, ...
                    'yyyy-MM-dd HH:mm:ss');
            end
        end

        %% 로그 데이터 읽기

        lf = double(T.freq);
        lm = double(T.mw1);

        % 첫 번째 Vib 파일보다 1초 전에 신호가 시작한다고 가정
        sigStart = ts(1) - ...
            (round(fs * 1) / fs) / 86400;

        % 로그 기준 상대 시간
        lsec = (lt - sigStart) * 86400;

        % 유효한 로그만 선택
        validLog = ...
            isfinite(lsec) & ...
            isfinite(lf) & ...
            isfinite(lm);

        lsec = lsec(validLog);
        lf = lf(validLog);
        lm = lm(validLog);

        if isempty(lsec)
            error('유효한 state_log 데이터가 없습니다.');
        end

        % 시간순 정렬
        [lsec, sortIdx] = sort(lsec);
        lf = lf(sortIdx);
        lm = lm(sortIdx);

        % 중복 시간 제거
        [lsec, ia] = unique(lsec, 'stable');
        lf = lf(ia);
        lm = lm(ia);

        %% 주파수 기준 상태 분류

        % 대기 상태 최대 주파수
        idleMax = 3;

        % 상승/하강 판단용 주파수 차이
        db = 8;

        % 로그에서 측정된 최고 주파수
        peakFreq = max(lf);

        nL = numel(lf);
        c2 = zeros(nL, 1);

        for i = 1:nL

            % 0: 정지 또는 idle
            if lf(i) <= idleMax

                c2(i) = 0;

            % 최고 주파수 근처의 정속 구간
            elseif lf(i) >= peakFreq - steadyBand

                % mw1 == 3이면 하강 등속
                % 그 외에는 상승 등속
                if lm(i) == 3
                    c2(i) = 4;
                else
                    c2(i) = 3;
                end

            % 상승 구간
            elseif i < nL && ...
                    lf(i + 1) > lf(i) + db

                c2(i) = 1;

            % 하강 구간
            elseif i > 1 && ...
                    lf(i - 1) > lf(i) + db

                c2(i) = 2;

            % 기타 구간은 하강 코드로 분류
            else

                c2(i) = 2;
            end
        end

        %% 로그 상태를 진동 샘플 단위로 변환

        queryTime = (0:N-1).' / fs;

        % 로그의 시작 이전과 마지막 이후 구간은 NaN이 될 수 있음
        codePS = interp1( ...
            lsec, ...
            c2, ...
            queryTime, ...
            'previous', ...
            NaN);

        % 상태 코드 분포 출력
        validCode = codePS(~isnan(codePS));

        fprintf('state_log 유효 샘플: %d / %d\n', ...
            numel(validCode), numel(codePS));

        if ~isempty(validCode)
            fprintf('생성된 상태 코드: ');
            fprintf('%g ', unique(validCode));
            fprintf('\n');
        end

    else

        warning(['state_log 없음 → 전체 분석만 가능합니다.\n' ...
            '확인 경로: %s'], logPath);
    end

    %% 결과 출력

    fprintf('-> %d개 파일, %d개 채널 로드 완료\n', ...
        numel(fl), nCh);

    fprintf('-> Vib 경로: %s\n', vibFolder);
end


%% ============================================================

function procCell = applyProcessing(rawCell, fs, processType)

    n = numel(rawCell);
    procCell = cell(n, 1);

    for ch = 1:n

        seg = rawCell{ch};

        % DC 성분 제거
        seg = seg - mean(seg);

        switch processType

            case 0
                % Raw Signal
                % 별도 처리 없음

            case 1
                % 속도 변환
                [seg, ~] = convmeas(seg, fs, 'vel');

            case 2
                % 포락선
                seg = abs(hilbert(seg));

            otherwise
                error('processType은 0, 1, 2 중 하나여야 합니다.');
        end

        % 처리 후 DC 성분 제거
        seg = seg - mean(seg);

        procCell{ch} = seg;
    end
end


%% ============================================================

function plotNineChannels( ...
    chanCell, ...
    fsData, ...
    gridIdx, ...
    labels, ...
    winTime, ...
    en_pw, ...
    normfact, ...
    use_dB, ...
    xlimVal, ...
    processLabel, ...
    targetDate, ...
    condName, ...
    targetRPM)

    %% RPM을 포함한 고유 figure 생성

    figName = sprintf( ...
        '9채널 [%s Hz] [%s]', ...
        targetRPM, ...
        processLabel);

    figure( ...
        'Name', figName, ...
        'NumberTitle', 'off', ...
        'Position', [60 40 1400 1000]);

    %% 3 x 3 스펙트럼 플롯

    for r = 1:3

        for c = 1:3

            ch = gridIdx(r, c);

            subplot(3, 3, (r-1)*3+c);

            [tval, tfreq] = getspec( ...
                chanCell{ch}, ...
                fsData, ...
                winTime, ...
                en_pw, ...
                normfact);

            % 0 Hz 성분 제거
            if ~isempty(tval)
                tval(1) = 0;
            end

            if use_dB

                y = 20 * log10(tval + eps);
                yl = 'Magnitude (dB)';

            else

                y = tval;
                yl = 'Magnitude';
            end

            plot( ...
                tfreq, ...
                y, ...
                'Color', [0.494 0.184 0.556], ...
                'LineWidth', 1.0);

            grid on;
            xlim(xlimVal);

            title(labels{ch}, 'FontSize', 10);

            if r == 3
                xlabel('Frequency (Hz)', ...
                    'FontWeight', 'bold');
            end

            if c == 1
                ylabel(yl, ...
                    'FontWeight', 'bold');
            end
        end
    end

    %% 전체 figure 제목

    sgtitle(sprintf( ...
        ['9채널 스펙트럼 - %s ' ...
         '[%s Hz / %s / %s] ' ...
         '(행:X/Y/Z, 열:Motor/Reducer/Bearing)'], ...
        processLabel, ...
        targetRPM, ...
        targetDate, ...
        condName), ...
        'FontSize', 13, ...
        'FontWeight', 'bold');
end



% %% NewCompare3_9.m
% % 로그추출 데이터용 · 자체 완결
% %
% % 9채널
% % Motor/Reducer/Bearing × X,Y,Z
% %
% % Raw / 속도변환 / 포락 신호를 각각 별도 창에 표시
% % 1초 연속 .mat + state_log.csv를 읽어
% % viewMode에 따라 전체/상승 등속/하강 등속 구간만 분석
% %
% % 주의:
% % close all을 사용하지 않으므로 이전 RPM의 figure가 유지됨
% %
% % 예:
% % 1차 실행: targetRPM = '60';
% % 2차 실행: targetRPM = '70';
% % 결과: 60 Hz figure 3개 + 70 Hz figure 3개
% 
% clearvars;
% clc;
% 
% % 기존 figure를 닫고 싶을 때만 수동으로 실행
% % close all;
% 
% %% PHM toolbox 자동 추가
% % getspec / convmeas 필요
% tb = '/Users/dustin08/Documents/MATLAB';
% 
% if isfolder(tb)
%     addpath(genpath(tb));
% end
% 
% %% 1. 경로 및 설정
% 
% basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data';
% 
% targetDate = '260811';
% 
% % 비교할 RPM 또는 Hz
% % 첫 번째 실행
% targetRPM = '80';
% 
% % 두 번째 실행 시 아래처럼 변경
% % targetRPM = '70';
% 
% condName = '스프라킷';
% 
% % 보기 대상
% % 0 = 전체
% % 1 = 상승 등속
% % 2 = 하강 등속
% viewMode = 1;
% 
% fs = 3200;
% 
% en_pw = 0;
% normfact = 1;
% 
% xlimVal = [1 300];
% 
% winTime = 1;
% use_dB = 0;
% 
% % 정속 판정 범위
% % 최고 주파수 ± steadyBand
% steadyBand = 5;
% 
% % 처리 방식
% % 0 = Raw
% % 1 = 속도변환
% % 2 = 포락
% processTypesToRun = [0, 1, 2];
% 
% %% 채널 설정
% 
% % Settings.json의 useChannels 순서
% %
% % 1~3: Motor
% % 4~6: Reducer
% % 7~9: Bearing
% 
% channelLabels = { ...
%     'Motor-X', ...
%     'Motor-Y', ...
%     'Motor-Z', ...
%     'Reducer-X', ...
%     'Reducer-Y', ...
%     'Reducer-Z', ...
%     'Bearing-X', ...
%     'Bearing-Y', ...
%     'Bearing-Z'};
% 
% % 행: X/Y/Z
% % 열: Motor/Reducer/Bearing
% gridChannelIdx = [ ...
%     1 4 7;
%     2 5 8;
%     3 6 9];
% 
% %% 2. 9채널 로드 및 국면 필터
% 
% [rawChannelCell, fsData, codePS] = loadRun9( ...
%     basePath, ...
%     targetDate, ...
%     targetRPM, ...
%     condName, ...
%     fs, ...
%     steadyBand);
% 
% switch viewMode
% 
%     case 1
%         sel = (codePS == 3);
%         modeStr = '상승 등속';
% 
%     case 2
%         sel = (codePS == 4);
%         modeStr = '하강 등속';
% 
%     otherwise
%         sel = true(size(codePS));
%         modeStr = '전체';
% end
% 
% if ~any(sel)
%     error('viewMode=%d(%s) 데이터가 없습니다.', ...
%         viewMode, modeStr);
% end
% 
% % 선택된 구간만 추출
% rawChannelCell = cellfun( ...
%     @(x) x(sel), ...
%     rawChannelCell, ...
%     'UniformOutput', false);
% 
% fprintf('\n');
% fprintf('========================================\n');
% fprintf('분석 정보\n');
% fprintf('========================================\n');
% fprintf('날짜       : %s\n', targetDate);
% fprintf('RPM        : %s Hz\n', targetRPM);
% fprintf('조건       : %s\n', condName);
% fprintf('보기 모드  : %s\n', modeStr);
% fprintf('샘플링 주파수 : %.2f Hz\n', fsData);
% fprintf('채널 수    : %d\n', numel(rawChannelCell));
% fprintf('샘플 수    : %d\n', numel(rawChannelCell{1}));
% fprintf('분석 시간  : %.2f초\n', ...
%     numel(rawChannelCell{1}) / fsData);
% fprintf('========================================\n');
% fprintf('\n');
% 
% %% 3. Raw / 속도변환 / 포락 처리 및 플롯
% 
% for pt = processTypesToRun
% 
%     switch pt
% 
%         case 0
%             processLabel = 'Raw Signal';
% 
%         case 1
%             processLabel = 'Velocity Converted';
% 
%         case 2
%             processLabel = 'Envelope Signal';
% 
%         otherwise
%             error('processtype은 0, 1, 2 중 하나여야 합니다.');
%     end
% 
%     fprintf('=== [%s] 처리 및 플롯 시작 ===\n', ...
%         processLabel);
% 
%     procChannelCell = applyProcessing( ...
%         rawChannelCell, ...
%         fsData, ...
%         pt);
% 
%     plotNineChannels( ...
%         procChannelCell, ...
%         fsData, ...
%         gridChannelIdx, ...
%         channelLabels, ...
%         winTime, ...
%         en_pw, ...
%         normfact, ...
%         use_dB, ...
%         xlimVal, ...
%         sprintf('%s [%s]', processLabel, modeStr), ...
%         targetDate, ...
%         condName, ...
%         targetRPM);
% 
% end
% 
% fprintf('\n모든 처리가 완료되었습니다.\n');
% 
% 
% %% ============================================================
% % 로컬 함수
% %% ============================================================
% 
% function [chanCell, fs, codePS] = loadRun9( ...
%     basePath, targetDate, targetRPM, condName, fsDefault, steadyBand)
% 
%     if nargin < 6 || isempty(steadyBand)
%         steadyBand = 5;
%     end
% 
%     %% 1. 데이터 경로 설정
% 
%     vibFolder = fullfile( ...
%         basePath, ...
%         targetDate, ...
%         targetRPM, ...
%         condName, ...
%         'Vib');
% 
%     logPath = fullfile( ...
%         basePath, ...
%         'Log', ...
%         sprintf('%s_%s_%s_state_log.csv', ...
%         targetDate, targetRPM, condName));
% 
%     fprintf('Vib 경로:\n%s\n', vibFolder);
%     fprintf('Log 경로:\n%s\n', logPath);
% 
%     %% 2. Vib 파일 검색
% 
%     fl = dir(fullfile(vibFolder, '*.mat'));
% 
%     if isempty(fl)
%         error('Vib .mat 파일이 없습니다:\n%s', vibFolder);
%     end
% 
%     %% 3. 파일명에서 timestamp 추출
% 
%     ts = nan(numel(fl), 1);
% 
%     for k = 1:numel(fl)
% 
%         tk = regexp( ...
%             fl(k).name, ...
%             '(\d{8}_\d{6}_\d{3})', ...
%             'tokens', ...
%             'once');
% 
%         if ~isempty(tk)
%             ts(k) = datenum( ...
%                 tk{1}, ...
%                 'yyyymmdd_HHMMSS_FFF');
%         end
%     end
% 
%     ok = ~isnan(ts);
% 
%     fl = fl(ok);
%     ts = ts(ok);
% 
%     if isempty(ts)
%         error('timestamp가 포함된 .mat 파일이 없습니다:\n%s', ...
%             vibFolder);
%     end
% 
%     % 시간순 정렬
%     [ts, ord] = sort(ts);
%     fl = fl(ord);
% 
%     %% 4. .mat 데이터 로드
% 
%     fs = fsDefault;
%     segByFile = cell(numel(fl), 1);
% 
%     for k = 1:numel(fl)
% 
%         matPath = fullfile(fl(k).folder, fl(k).name);
%         md = load(matPath);
% 
%         % signals 변수가 있으면 우선 사용
%         if isfield(md, 'signals')
% 
%             seg = md.signals;
% 
%         else
% 
%             % 가장 큰 변수를 신호 데이터로 사용
%             fn = fieldnames(md);
%             nel = cellfun(@(x) numel(md.(x)), fn);
% 
%             [~, mi] = max(nel);
%             seg = md.(fn{mi});
%         end
% 
%         % 채널 x 샘플 형태로 변환
%         %
%         % 일반적으로 9 x N이면 그대로 사용
%         % N x 9이면 transpose
%         if size(seg, 1) >= size(seg, 2)
%             seg = seg.';
%         end
% 
%         % .mat 내부에 fs가 있으면 사용
%         if isfield(md, 'fs') && ~isempty(md.fs)
%             fs = double(md.fs(1));
%         end
% 
%         segByFile{k} = seg;
%     end
% 
%     %% 5. 채널별로 모든 파일 연결
% 
%     nCh = size(segByFile{1}, 1);
% 
%     if nCh < 9
%         error('채널 수가 9개보다 적습니다. 현재 채널 수: %d', nCh);
%     end
% 
%     chanCell = cell(nCh, 1);
% 
%     for ch = 1:nCh
% 
%         p = cell(numel(fl), 1);
% 
%         for k = 1:numel(fl)
% 
%             s = segByFile{k}(ch, :);
%             p{k} = s(:);
%         end
% 
%         chanCell{ch} = vertcat(p{:});
%     end
% 
%     N = numel(chanCell{1});
% 
%     %% 6. state_log를 이용한 상태 코드 생성
% 
%     codePS = nan(N, 1);
% 
%     if isfile(logPath)
% 
%         fprintf('state_log 파일을 읽습니다.\n');
% 
%         T = readtable(logPath);
% 
%         % timestamp 확인
%         if ~ismember('timestamp', T.Properties.VariableNames)
%             error('state_log에 timestamp 열이 없습니다.');
%         end
% 
%         % freq 확인
%         if ~ismember('freq', T.Properties.VariableNames)
%             error('state_log에 freq 열이 없습니다.');
%         end
% 
%         % mw1 확인
%         if ~ismember('mw1', T.Properties.VariableNames)
%             error('state_log에 mw1 열이 없습니다.');
%         end
% 
%         %% timestamp 변환
% 
%         if isdatetime(T.timestamp)
% 
%             lt = datenum(T.timestamp);
% 
%         else
% 
%             timestampString = string(T.timestamp);
%             timestampString = strrep( ...
%                 timestampString, 'T', ' ');
% 
%             try
% 
%                 lt = datenum( ...
%                     timestampString, ...
%                     'yyyy-MM-dd HH:mm:ss.FFF');
% 
%             catch
% 
%                 lt = datenum( ...
%                     timestampString, ...
%                     'yyyy-MM-dd HH:mm:ss');
%             end
%         end
% 
%         %% 로그 데이터 읽기
% 
%         lf = double(T.freq);
%         lm = double(T.mw1);
% 
%         % 첫 번째 Vib 파일보다 1초 전에 신호가 시작한다고 가정
%         sigStart = ts(1) - ...
%             (round(fs * 1) / fs) / 86400;
% 
%         % 로그 기준 상대 시간
%         lsec = (lt - sigStart) * 86400;
% 
%         % 유효한 로그만 선택
%         validLog = ...
%             isfinite(lsec) & ...
%             isfinite(lf) & ...
%             isfinite(lm);
% 
%         lsec = lsec(validLog);
%         lf = lf(validLog);
%         lm = lm(validLog);
% 
%         if isempty(lsec)
%             error('유효한 state_log 데이터가 없습니다.');
%         end
% 
%         % 시간순 정렬
%         [lsec, sortIdx] = sort(lsec);
%         lf = lf(sortIdx);
%         lm = lm(sortIdx);
% 
%         % 중복 시간 제거
%         [lsec, ia] = unique(lsec, 'stable');
%         lf = lf(ia);
%         lm = lm(ia);
% 
%         %% 주파수 기준 상태 분류
% 
%         % 대기 상태 최대 주파수
%         idleMax = 3;
% 
%         % 상승/하강 판단용 주파수 차이
%         db = 8;
% 
%         % 로그에서 측정된 최고 주파수
%         peakFreq = max(lf);
% 
%         nL = numel(lf);
%         c2 = zeros(nL, 1);
% 
%         for i = 1:nL
% 
%             % 0: 정지 또는 idle
%             if lf(i) <= idleMax
% 
%                 c2(i) = 0;
% 
%             % 최고 주파수 근처의 정속 구간
%             elseif lf(i) >= peakFreq - steadyBand
% 
%                 % mw1 == 3이면 하강 등속
%                 % 그 외에는 상승 등속
%                 if lm(i) == 3
%                     c2(i) = 4;
%                 else
%                     c2(i) = 3;
%                 end
% 
%             % 상승 구간
%             elseif i < nL && ...
%                     lf(i + 1) > lf(i) + db
% 
%                 c2(i) = 1;
% 
%             % 하강 구간
%             elseif i > 1 && ...
%                     lf(i - 1) > lf(i) + db
% 
%                 c2(i) = 2;
% 
%             % 기타 구간은 하강 코드로 분류
%             else
% 
%                 c2(i) = 2;
%             end
%         end
% 
%         %% 로그 상태를 진동 샘플 단위로 변환
% 
%         queryTime = (0:N-1).' / fs;
% 
%         % 로그의 시작 이전과 마지막 이후 구간은 NaN이 될 수 있음
%         codePS = interp1( ...
%             lsec, ...
%             c2, ...
%             queryTime, ...
%             'previous', ...
%             NaN);
% 
%         % 상태 코드 분포 출력
%         validCode = codePS(~isnan(codePS));
% 
%         fprintf('state_log 유효 샘플: %d / %d\n', ...
%             numel(validCode), numel(codePS));
% 
%         if ~isempty(validCode)
%             fprintf('생성된 상태 코드: ');
%             fprintf('%g ', unique(validCode));
%             fprintf('\n');
%         end
% 
%     else
% 
%         warning(['state_log 없음 → 전체 분석만 가능합니다.\n' ...
%             '확인 경로: %s'], logPath);
%     end
% 
%     %% 결과 출력
% 
%     fprintf('-> %d개 파일, %d개 채널 로드 완료\n', ...
%         numel(fl), nCh);
% 
%     fprintf('-> Vib 경로: %s\n', vibFolder);
% end
% 
% 
% %% ============================================================
% 
% function procCell = applyProcessing(rawCell, fs, processType)
% 
%     n = numel(rawCell);
%     procCell = cell(n, 1);
% 
%     for ch = 1:n
% 
%         seg = rawCell{ch};
% 
%         % DC 성분 제거
%         seg = seg - mean(seg);
% 
%         switch processType
% 
%             case 0
%                 % Raw Signal
%                 % 별도 처리 없음
% 
%             case 1
%                 % 속도 변환
%                 [seg, ~] = convmeas(seg, fs, 'vel');
% 
%             case 2
%                 % 포락선
%                 seg = abs(hilbert(seg));
% 
%             otherwise
%                 error('processType은 0, 1, 2 중 하나여야 합니다.');
%         end
% 
%         % 처리 후 DC 성분 제거
%         seg = seg - mean(seg);
% 
%         procCell{ch} = seg;
%     end
% end
% 
% 
% %% ============================================================
% 
% function plotNineChannels( ...
%     chanCell, ...
%     fsData, ...
%     gridIdx, ...
%     labels, ...
%     winTime, ...
%     en_pw, ...
%     normfact, ...
%     use_dB, ...
%     xlimVal, ...
%     processLabel, ...
%     targetDate, ...
%     condName, ...
%     targetRPM)
% 
%     %% RPM을 포함한 고유 figure 생성
% 
%     figName = sprintf( ...
%         '9채널 [%s Hz] [%s]', ...
%         targetRPM, ...
%         processLabel);
% 
%     figure( ...
%         'Name', figName, ...
%         'NumberTitle', 'off', ...
%         'Position', [60 40 1400 1000]);
% 
%     %% 3 x 3 스펙트럼 플롯
% 
%     for r = 1:3
% 
%         for c = 1:3
% 
%             ch = gridIdx(r, c);
% 
%             subplot(3, 3, (r-1)*3+c);
% 
%             [tval, tfreq] = getspec( ...
%                 chanCell{ch}, ...
%                 fsData, ...
%                 winTime, ...
%                 en_pw, ...
%                 normfact);
% 
%             % 0 Hz 성분 제거
%             if ~isempty(tval)
%                 tval(1) = 0;
%             end
% 
%             if use_dB
% 
%                 y = 20 * log10(tval + eps);
%                 yl = 'Magnitude (dB)';
% 
%             else
% 
%                 y = tval;
%                 yl = 'Magnitude';
%             end
% 
%             plot( ...
%                 tfreq, ...
%                 y, ...
%                 'Color', [0.494 0.184 0.556], ...
%                 'LineWidth', 1.0);
% 
%             grid on;
%             xlim(xlimVal);
% 
%             title(labels{ch}, 'FontSize', 10);
% 
%             if r == 3
%                 xlabel('Frequency (Hz)', ...
%                     'FontWeight', 'bold');
%             end
% 
%             if c == 1
%                 ylabel(yl, ...
%                     'FontWeight', 'bold');
%             end
%         end
%     end
% 
%     %% 전체 figure 제목
% 
%     sgtitle(sprintf( ...
%         ['9채널 스펙트럼 - %s ' ...
%          '[%s Hz / %s / %s] ' ...
%          '(행:X/Y/Z, 열:Motor/Reducer/Bearing)'], ...
%         processLabel, ...
%         targetRPM, ...
%         targetDate, ...
%         condName), ...
%         'FontSize', 13, ...
%         'FontWeight', 'bold');
% end