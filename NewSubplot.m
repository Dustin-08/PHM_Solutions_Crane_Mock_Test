%% 9채널(3축센서 x 3개) 축(X/Y/Z)별 그룹 비교 플롯
% 원본: 주파수계산 스펙트럼 시각화 스크립트를 9채널 구조에 맞게 확장
% - 각 .mat 파일에는 signals 변수(9 x N 행렬, 9개 채널이 row로 저장)와 fs가 들어있다고 가정
% - "메인 plot = 축(X,Y,Z)", "서브 plot = 센서 번호(채널)" 구조로 축별 3채널씩 한 번에 비교

%% 1. 경로 및 설정 변수 (사용자 정의 영역)
basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data'; % 경로수정
targetDate = '260806';                          % [변수] 날짜 폴더명
targetRPM = '80';
targetCondition = fullfile('체인이탈1', 'Vib');   % [변수] 상태 및 하위 폴더 경로

% 기본 신호 처리 매개변수
fs = 3200;           % 샘플링 주파수 (Hz) - 파일 내 fs 변수와 다르면 자동으로 파일 값 사용
en_pw = 0;            % 0: Amplitude Spectrum, 1: Power Spectrum
normfact = 1;         % 윈도우 정규화 계수

% ★ 1. 신호 전처리 유형 선택 (processtype) ★
% 0: Raw, 1: convmeas 속도변환('vel'), 2: 힐베르트 포락(Envelope)
processtype = 0;

% ★ 2. 시각화 그래프 유형 선택 (plottype) ★
% 0: 시계열 파형, 1: 파일별 대표 RMS 트렌드, 2: 주파수 스펙트럼, 3: 스펙트로그램
plottype = 2;

% ★ 3. 주파수 관찰 범위 설정 (Hz) ★
xlimVal = [1 300];

% 오버랩(Overlap) 및 시각화 옵션
winTime = 1.5;         % Δf = 1/winTime, [80Hz시 사용]
overlapRatio = 0.8;    % 오버랩 비율 (0.8 = 80% 중첩), plottype=3에서만 사용
use_dB = 0;            % true: dB 스케일(20*log10), false: 선형 스케일

% ▼▼▼ 채널 배치 설정 (담당자 확인 완료: Settings.json useChannels 순서 기준) ▼▼▼
% signals 행렬의 각 행(row 1~9) = 실제 설치 위치 기준
%   row 1,2,3 = Motor   (모터)   X,Y,Z
%   row 4,5,6 = Reducer (감속기) X,Y,Z
%   row 7,8,9 = Bearing (베어링) X,Y,Z
channelLabels = {'Motor-X','Motor-Y','Motor-Z', ...
                 'Reducer-X','Reducer-Y','Reducer-Z', ...
                 'Bearing-X','Bearing-Y','Bearing-Z'};
axisGroupIdx.X = [1 4 7];   % X축 그룹 (센서 라벨 기준, Motor/Reducer/Bearing 순 - 물리방향 불일치 주의)
axisGroupIdx.Y = [2 5 8];   % Y축 그룹 (센서 라벨 기준)
axisGroupIdx.Z = [3 6 9];   % Z축 그룹 (센서 라벨 기준)
axisGroupIdx.Vert = [1 5 8];  % ★ 실제 중력(수직) 방향 그룹 - 센서 라벨이 아니라 실측(사진)으로 확정
axisNames = {'X', 'Y', 'Z', 'Vert'};
axisDisplayNames = {'X(라벨기준)', 'Y(라벨기준)', 'Z(라벨기준)', '실제수직(Vertical)'};

% ⚠ 2026-08-07 센서 라벨 사진 실측 결과 (Vibrasens 131.02-6D-2, 축 다이어그램 판독):
%   센서 자체에 각인된 X/Y/Z 라벨은 "센서 하우징 기준"일 뿐, 설치 자세가 다르면
%   실제 중력(수직) 방향과 일치하는 축이 위치마다 다릅니다. 사진으로 확인한 결과:
%     - Motor   : X축이 실제 수직 (모터는 브라켓에 수직으로 세워서 장착됨)
%     - Reducer : Y축이 실제 수직으로 추정 (Bearing과 동일하게 눕혀서 평행 장착 - 라벨 각인은 눈부심으로 완전판독은 안됨)
%     - Bearing : Y축이 실제 수직 확인 (눕혀서 평행 장착, 라벨 판독 완료)
%   따라서 기존 "Z축 그룹 = 수직 비교 가능"이라는 가정은 틀렸습니다.
%   axisGroupIdx.Vert = [1 5 8] (Motor-X, Reducer-Y, Bearing-Y) 가 실제 수직 비교용 그룹입니다.
%   X/Y/Z(라벨기준) 그룹은 센서 자체 축 이름만 같을 뿐 물리적으로 다른 방향을 가리킬 수 있으니
%   위치간 비교시 axisGroupIdx.Vert 결과를 우선 참고하세요.
% ▲▲▲ 여기까지 채널 설정 ▲▲▲

%% 2. 파일 탐색 및 전체 채널(9개) 원본 신호 로드
fullFolderPath = fullfile(basePath, targetDate, targetRPM, targetCondition);
matFiles = dir(fullfile(fullFolderPath, '*.mat'));
numFiles = length(matFiles);

if numFiles == 0
    error('지정된 경로에 .mat 파일이 존재하지 않습니다: %s', fullFolderPath);
end

fprintf('총 %d개의 .mat 파일을 로드하여 9채널 데이터를 구성 중...\n', numFiles);

rawChannelCell = cell(numFiles, 1);
for k = 1:numFiles
    filePath = fullfile(matFiles(k).folder, matFiles(k).name);
    matData = load(filePath);

    if ~isfield(matData, 'signals')
        error('%s 파일에 signals 변수가 없습니다. mat 파일 구조를 확인하세요.', matFiles(k).name);
    end

    segData = matData.signals;   % (9 x N) 예상
    if size(segData, 1) ~= 9
        error('%s 파일의 signals 행 개수가 9가 아닙니다 (실제: %d). 채널 수를 확인하세요.', ...
              matFiles(k).name, size(segData, 1));
    end

    if isfield(matData, 'fs') && ~isempty(matData.fs)
        fs = double(matData.fs(1));  % 파일에 fs가 있으면 그 값을 우선 사용
    end

    rawChannelCell{k} = segData;
end

numChannels = size(rawChannelCell{1}, 1);   % = 9

%% 3. 채널별(9개) 전처리 + 파일별 RMS 계산
switch processtype
    case 0
        processLabel = 'Raw Signal';
    case 1
        processLabel = 'Velocity Converted';
    case 2
        processLabel = 'Envelope Signal';
    otherwise
        error('잘못된 processtype입니다. (0: Raw, 1: 속도변환, 2: 포락처리 중 선택)');
end

fileRMS = zeros(numChannels, numFiles);       % plottype=1용: 채널별 x 파일별 RMS
procChannelCell = cell(numChannels, 1);       % 채널별 전체(파일 연결) 처리 신호

for ch = 1:numChannels
    segProcCell = cell(numFiles, 1);
    for k = 1:numFiles
        seg = rawChannelCell{k}(ch, :);
        seg = seg(:);                          % column vector로 통일
        seg = seg - mean(seg);                 % [0Hz/DC 제거 1차]

        switch processtype
            case 0
                % Raw
            case 1
                [seg, ~] = convmeas(seg, fs, 'vel');
            case 2
                seg = abs(hilbert(seg));
        end

        seg = seg - mean(seg);                 % [0Hz/DC 제거 2차]
        fileRMS(ch, k) = sqrt(mean(seg.^2));    % 파일 1개당 단일 RMS
        segProcCell{k} = seg;
    end
    procChannelCell{ch} = vertcat(segProcCell{:});  % 해당 채널의 전체(파일 연결) 신호
end

%% 4. 축별 그룹 플롯 - 메인 figure: 축(라벨X/Y/Z + 실제수직), 서브플롯: 센서(채널)
for a = 1:numel(axisNames)
    axisName = axisNames{a};
    axisDisp = axisDisplayNames{a};
    chIdxList = axisGroupIdx.(axisName);   % 이 축에 해당하는 channel 번호 3개

    figure('Name', sprintf('%s 비교 [Plot Mode: %d - %s]', axisDisp, plottype, processLabel), ...
           'NumberTitle', 'off', 'Position', [100 100 900 800]);

    for s = 1:numel(chIdxList)
        ch = chIdxList(s);
        subplot(numel(chIdxList), 1, s);

        drawChannelPlot(plottype, procChannelCell{ch}, fileRMS(ch, :), fs, winTime, ...
                         en_pw, normfact, overlapRatio, use_dB, xlimVal, numFiles, ...
                         sprintf('%s (%s, Sensor %d)', channelLabels{ch}, axisDisp, s), ...
                         processLabel, targetDate);
    end

    sgtitle(sprintf('%s 채널 비교 - %s [%s]', axisDisp, processLabel, targetDate), ...
            'FontSize', 13, 'FontWeight', 'bold');
end

%% ===================== 로컬 함수 =====================
function drawChannelPlot(plottype, sig, chFileRMS, fs, winTime, en_pw, normfact, ...
                          overlapRatio, use_dB, xlimVal, numFiles, chanLabel, processLabel, targetDate)
% 채널 1개에 대해 plottype에 따라 현재 axes(subplot)에 그림을 그린다.

switch plottype
    case 0 % ----- 시계열 파형 -----
        timeAxis = (0:length(sig)-1) / fs;
        plot(timeAxis, sig, 'Color', [0 0.4470 0.7410], 'LineWidth', 0.8);
        grid on;
        xlabel('Time (s)', 'FontWeight', 'bold');
        ylabel('Amplitude', 'FontWeight', 'bold');
        title(sprintf('%s - Time Domain [%s]', chanLabel, processLabel));
        xlim([0 timeAxis(end)]);

    case 1 % ----- 파일별 RMS 트렌드 -----
        plot(1:numFiles, chFileRMS, '-o', 'Color', [0.8500 0.3250 0.0980], ...
             'LineWidth', 1.2, 'MarkerSize', 5, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
        grid on;
        xlabel('File Index', 'FontWeight', 'bold');
        ylabel('RMS', 'FontWeight', 'bold');
        title(sprintf('%s - File RMS Trend [%s]', chanLabel, processLabel));
        if numFiles > 1
            xlim([1 numFiles]);
        end

    case 2 % ----- 주파수 스펙트럼 -----
        [tval, tfreq] = getspec(sig, fs, winTime, en_pw, normfact);
        tval(1) = 0; % 0Hz 제거

        if use_dB
            tvalPlot = 20 * log10(tval + eps);
            yLabelStr = 'Magnitude (dB)';
        else
            tvalPlot = tval;
            yLabelStr = 'Magnitude';
        end

        plot(tfreq, tvalPlot, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.0);
        grid on;
        xlabel('Frequency (Hz)', 'FontWeight', 'bold');
        ylabel(yLabelStr, 'FontWeight', 'bold');
        title(sprintf('%s - Spectrum [%s]', chanLabel, processLabel));
        xlim(xlimVal);

    case 3 % ----- 스펙트로그램 -----
        winLen = round(fs * winTime);
        overlapLen = round(winLen * overlapRatio);
        stepLen = winLen - overlapLen;
        winFunc = hann(winLen);
        numFrames = floor((length(sig) - winLen) / stepLen) + 1;

        if numFrames < 1
            error('%s: 신호 전체 길이가 winTime보다 짧습니다.', chanLabel);
        end

        firstFrame = sig(1:winLen) .* winFunc;
        [~, tfreq] = getspec(firstFrame, fs, winTime, en_pw, normfact);
        numFreqs = length(tfreq);

        spectrogramMatrix = zeros(numFreqs, numFrames);
        timeVec = zeros(1, numFrames);

        for i = 1:numFrames
            idxStart = (i - 1) * stepLen + 1;
            idxEnd = idxStart + winLen - 1;

            frameSignal = sig(idxStart:idxEnd);
            frameSignal = (frameSignal - mean(frameSignal)) .* winFunc;

            [tval, ~] = getspec(frameSignal, fs, winTime, en_pw, normfact);
            tval(1) = 0;

            spectrogramMatrix(:, i) = tval;
            timeVec(i) = (idxStart + winLen/2 - 1) / fs;
        end

        if use_dB
            plotData = 20 * log10(spectrogramMatrix + eps);
            cLabelStr = 'Magnitude (dB)';
        else
            plotData = spectrogramMatrix;
            cLabelStr = 'Magnitude';
        end

        imagesc(timeVec, tfreq, plotData);
        axis xy;
        colormap('jet');
        cb = colorbar;
        cb.Label.String = cLabelStr;

        xlabel('Time (s)', 'FontWeight', 'bold');
        ylabel('Frequency (Hz)', 'FontWeight', 'bold');
        title(sprintf('%s - STFT [%s]', chanLabel, processLabel));
        ylim(xlimVal);

    otherwise
        error('잘못된 plottype입니다. (0: 파형, 1: RMS, 2: 스펙트럼, 3: 스펙트로그램 중 선택)');
end
end