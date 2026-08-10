%% 9채널(Motor/Reducer/Bearing x X,Y,Z) - 한 조건만 로드해서 한 화면(3x3)에 표시
% 3행(X/Y/Z축) x 3열(Motor/Reducer/Bearing) = 9개 subplot을 한 figure에 그립니다.
% [기능] 엑셀 계산기 기준 1X(회전) 주파수를 자동 산출 -> 그 근처(±tolerancePercent%) 구간에서
%        "그래프에 실제로 보이는 범위(xlimVal) 안의 최고 피크"를 1X로 검출하고,
%        검출된 1X의 배수(2X, 3X, ...) 근처 최대 피크도 함께 찾아 표시합니다.
%
% [이번 수정 사항 - v3]
%  1) (이전 수정) 감속비 계산 버그 수정
%       motorRPM = loadRPM / (beltRatio * finalRatio)   <- 엑셀 D10은 벨트축->부하측 구간비
%  2) (이전 수정) 저주파(Bearing)에서 대역폭이 분해능(df)보다 좁아 피크가 하나도 안 걸리던 문제
%       -> 대역폭 하한을 df로 보정
%  3) [신규] Bearing처럼 1X가 매우 낮은 주파수(~1Hz대)인 채널에서, 오차범위 하한이
%       그래프 표시범위(xlimVal(1)=1Hz) 아래로 내려가면 "0.667Hz 근처 저주파 누설(leakage)"을
%       최고값으로 잘못 잡는 문제 발견 -> 탐색 범위를 xlimVal로 클리핑하여 해결.
%       (실제 업로드된 등속5 데이터로 검증: 클리핑 전 0.667Hz/값0.07~0.11(누설),
%        클리핑 후 1.333Hz/값0.015~0.016(그래프에 실제 보이는 진짜 피크) 로 정상 검출됨)
%  4) [v4] 1X는 오차범위(tolerancePercent) 적용 없이 "표시범위(xlimVal) 내 전체 최고 Y값"
%       지점으로 고정. 오차범위는 2X부터 (검출된 1X의 배수 근처) 적용됨.

%% 1. 경로 및 설정
basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data'; % 경로수정
targetDate = '260807';
targetRPM = '70';                     % <- 엑셀의 "부하측 RPM"과 동일한 값을 사용
targetCondition = fullfile('등속5', 'Vib');   % [변수] 불러올 상태 폴더

fs = 3200;
en_pw = 0;
normfact = 1;
processtype = 2;      % 0: Raw, 1: 속도변환('vel'), 2: 포락(Envelope)
xlimVal = [1 300];     % 그래프에 실제로 표시되는 주파수 범위 (탐색범위도 이 안으로 제한됨)
winTime = 1.5;
use_dB = 0;

% 채널 배치: row 1,2,3=Motor / 4,5,6=Reducer / 7,8,9=Bearing
channelLabels = {'Motor-X','Motor-Y','Motor-Z', ...
                 'Reducer-X','Reducer-Y','Reducer-Z', ...
                 'Bearing-X','Bearing-Y','Bearing-Z'};

% 3x3 배치용 매핑: row = 축(X/Y/Z, 라벨 기준), col = 위치(Motor/Reducer/Bearing)
gridChannelIdx = [1 4 7;   % X행: Motor-X, Reducer-X, Bearing-X
                  2 5 8;   % Y행: Motor-Y, Reducer-Y, Bearing-Y
                  3 6 9];  % Z행: Motor-Z, Reducer-Z, Bearing-Z

switch processtype
    case 0, processLabel = 'Raw Signal';
    case 1, processLabel = 'Velocity Converted';
    case 2, processLabel = 'Envelope Signal';
    otherwise, error('잘못된 processtype입니다.');
end

%% 1-1. 엑셀 계산기 기준 1X 기준 주파수 산출 (구동계_진동_계산기.xlsx 참고)
%   D9  = 0.5833  (모터출력측 -> 벨트연결측 구간비)
%   D10 = 0.1     (벨트연결측 -> 부하측 구간비)   ※ 모터->부하측 전체비가 아님!
beltRatio  = 0.5833;   % 엑셀 D9
finalRatio = 0.1;      % 엑셀 D10 (벨트축->부하측 구간비)

loadRPM  = str2double(targetRPM);              % 부하측 RPM (= 폴더명, Bearing 위치) = 70
motorRPM = loadRPM / (beltRatio * finalRatio);  % 모터출력측 RPM (= Motor 위치)   -> 1200
beltRPM  = motorRPM * beltRatio;                % 벨트연결측 RPM (= Reducer 위치) -> 700

% 열(Motor/Reducer/Bearing) 순서와 매칭되는 1X 기준 주파수(Hz)
f1x_col = [motorRPM, beltRPM, loadRPM] / 60;    % [20, 11.667, 1.167] Hz

tolerancePercent = 5;      % 오차범위(%)
harmonicOrders   = 1:3;    % 표시할 하모닉 차수 (1X, 2X, 3X). 필요시 1:5 등으로 확장
harmonicColors   = [1 0 0; 0.85 0.33 0.10; 0.47 0.67 0.19; 0 0.45 0.74; 0.49 0.18 0.56];

fprintf('=== 1X 기준 주파수 (오차범위 ±%.1f%%, 탐색범위 %.1f~%.1fHz) ===\n', ...
    tolerancePercent, xlimVal(1), xlimVal(2));
fprintf('  Motor   1X = %.4f Hz (RPM=%.2f)\n', f1x_col(1), motorRPM);
fprintf('  Reducer 1X = %.4f Hz (RPM=%.2f)\n', f1x_col(2), beltRPM);
fprintf('  Bearing 1X = %.4f Hz (RPM=%.2f)\n', f1x_col(3), loadRPM);

%% 2. 데이터 로드 + 전처리 (한 조건만)
fprintf('=== 데이터 로드 중 (%s) ===\n', targetCondition);
[channelCell, fsData] = loadAndProcess9Channel(basePath, targetDate, targetRPM, targetCondition, fs, processtype);

%% 3. 9채널을 한 화면(3x3)에 표시 + 1X/2X/3X 피크 검출/표시
figure('Name', sprintf('9채널 [%s]', processLabel), 'NumberTitle', 'off', 'Position', [60 40 1400 1000]);

resultRows = {};   % {Channel, Order, TargetFreq, DetectedFreq, DetectedVal}

for r = 1:3
    for c = 1:3
        ch = gridChannelIdx(r, c);
        subplot(3, 3, (r-1)*3 + c);

        [tval, tfreq] = getspec(channelCell{ch}, fsData, winTime, en_pw, normfact);
        tval(1) = 0;

        if use_dB
            tvalPlot = 20 * log10(tval + eps);
            yLabelStr = 'Magnitude (dB)';
        else
            tvalPlot = tval;
            yLabelStr = 'Magnitude';
        end

        plot(tfreq, tvalPlot, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.0);
        grid on;
        title(channelLabels{ch}, 'FontSize', 10);
        xlim(xlimVal);

        if r == 3
            xlabel('Frequency (Hz)', 'FontWeight', 'bold');
        end
        if c == 1
            ylabel(yLabelStr, 'FontWeight', 'bold');
        end

        %% [1X/2X/3X 검출 및 표시]
        %  - 1X: 오차범위 적용 없이, 표시범위(xlimVal) 안에서 "가장 높은 Y값(전체 최고 피크)"으로 고정
        %  - 2X, 3X...: 검출된 1X의 배수 근처 ±tolerancePercent% 구간에서 최고 피크 탐색
        hold on;

        % --- 1X: 표시범위 내 전체 최고 피크 ---
        [detectedF1x, peakVal1x, found1x] = findGlobalPeak(tfreq, tvalPlot, xlimVal);

        if found1x
            plot(detectedF1x, peakVal1x, 'o', 'MarkerSize', 7, ...
                 'MarkerEdgeColor', harmonicColors(1,:), 'MarkerFaceColor', harmonicColors(1,:));
            text(detectedF1x, peakVal1x, sprintf(' 1X %.3fHz', detectedF1x), ...
                 'FontSize', 7, 'Color', harmonicColors(1,:), 'FontWeight', 'bold');
            resultRows(end+1,:) = {channelLabels{ch}, 1, NaN, detectedF1x, peakVal1x}; %#ok<SAGROW>
        else
            detectedF1x = NaN;
            resultRows(end+1,:) = {channelLabels{ch}, 1, NaN, NaN, NaN}; %#ok<SAGROW>
            warning('[%s] 1X 탐색 실패 (표시범위 내 데이터 없음)', channelLabels{ch});
        end

        % --- 2X, 3X, ...: 검출된 1X의 배수 근처 ±tolerancePercent%에서 최고 피크 ---
        for hIdx = 2:numel(harmonicOrders)
            n = harmonicOrders(hIdx);
            if isnan(detectedF1x)
                break;   % 1X 검출 실패 시 배수 탐색도 의미 없으므로 skip
            end
            fTarget = n * detectedF1x;

            [peakFreq, peakVal, found] = findPeakNearFreq(tfreq, tvalPlot, fTarget, tolerancePercent, xlimVal);

            if found
                plot(peakFreq, peakVal, 'o', 'MarkerSize', 7, ...
                     'MarkerEdgeColor', harmonicColors(hIdx,:), 'MarkerFaceColor', harmonicColors(hIdx,:));
                text(peakFreq, peakVal, sprintf(' %dX %.3fHz', n, peakFreq), ...
                     'FontSize', 7, 'Color', harmonicColors(hIdx,:), 'FontWeight', 'bold');
                resultRows(end+1,:) = {channelLabels{ch}, n, fTarget, peakFreq, peakVal}; %#ok<SAGROW>
            else
                resultRows(end+1,:) = {channelLabels{ch}, n, fTarget, NaN, NaN}; %#ok<SAGROW>
            end
        end
        hold off;
    end
end

sgtitle(sprintf('9채널 스펙트럼 - %s [%s / %s]  (행:X/Y/Z축 라벨, 열:Motor/Reducer/Bearing)', ...
        processLabel, targetDate, targetCondition), 'FontSize', 13, 'FontWeight', 'bold');

%% [결과 표 출력]
peakResults = cell2table(resultRows, ...
    'VariableNames', {'Channel','Order','Target_Hz','Detected_Hz','Detected_Val'});
disp('=== 채널별 1X/2X/3X 검출 결과 ===');
disp(peakResults);

%% ===================== 로컬 함수 =====================
function [peakFreq, peakVal, found] = findGlobalPeak(tfreq, tvalPlot, xlimVal)
% 표시범위(xlimVal) 안에서 가장 높은 Y값(전체 최고 피크)을 찾는다. 오차범위 미적용.
idxRange = tfreq >= xlimVal(1) & tfreq <= xlimVal(2);
if any(idxRange)
    freqsInRange = tfreq(idxRange);
    valsInRange  = tvalPlot(idxRange);
    [peakVal, relIdx] = max(valsInRange);
    peakFreq = freqsInRange(relIdx);
    found = true;
else
    peakFreq = NaN; peakVal = NaN; found = false;
end
end

function [peakFreq, peakVal, found] = findPeakNearFreq(tfreq, tvalPlot, fTarget, tolerancePercent, xlimVal)
% fTarget 근처 ±tolerancePercent% 구간에서 최대값을 찾는다.
%  - 구간이 주파수 분해능(df)보다 좁아지는 저주파 영역에서는 최소 df만큼은
%    확보되도록 대역폭 하한을 보정한다.
%  - 탐색 구간은 그래프 표시범위(xlimVal) 밖으로 나가지 않도록 클리핑한다.
%    (표시범위 밖의 DC 근접 누설(leakage) 등을 1X로 잘못 잡는 것을 방지)
df = tfreq(2) - tfreq(1);
halfWidth = max(fTarget * tolerancePercent / 100, df);
fLow  = max(fTarget - halfWidth, xlimVal(1));
fHigh = min(fTarget + halfWidth, xlimVal(2));

idxRange = tfreq >= fLow & tfreq <= fHigh;
if any(idxRange)
    freqsInRange = tfreq(idxRange);
    valsInRange  = tvalPlot(idxRange);
    [peakVal, relIdx] = max(valsInRange);   % <- 구간 내 "가장 높은 피크"
    peakFreq = freqsInRange(relIdx);
    found = true;
else
    peakFreq = NaN; peakVal = NaN; found = false;
end
end

function [channelCell, fsOut] = loadAndProcess9Channel(basePath, targetDate, targetRPM, condition, fsDefault, processtype)
fullFolderPath = fullfile(basePath, targetDate, targetRPM, condition);
matFiles = dir(fullfile(fullFolderPath, '*.mat'));
numFiles = length(matFiles);
if numFiles == 0
    error('지정된 경로에 .mat 파일이 존재하지 않습니다: %s', fullFolderPath);
end

fsOut = fsDefault;
rawChannelCell = cell(numFiles, 1);
for k = 1:numFiles
    filePath = fullfile(matFiles(k).folder, matFiles(k).name);
    matData = load(filePath);
    segData = matData.signals;
    if size(segData,1) ~= 9
        error('%s: signals 행 개수가 9가 아닙니다.', matFiles(k).name);
    end
    if isfield(matData,'fs') && ~isempty(matData.fs)
        fsOut = double(matData.fs(1));
    end
    rawChannelCell{k} = segData;
end
numChannels = size(rawChannelCell{1}, 1);

channelCell = cell(numChannels, 1);
for ch = 1:numChannels
    segProcCell = cell(numFiles, 1);
    for k = 1:numFiles
        seg = rawChannelCell{k}(ch, :);
        seg = seg(:);
        seg = seg - mean(seg);
        switch processtype
            case 1, [seg, ~] = convmeas(seg, fsOut, 'vel');
            case 2, seg = abs(hilbert(seg));
        end
        seg = seg - mean(seg);
        segProcCell{k} = seg;
    end
    channelCell{ch} = vertcat(segProcCell{:});
end
fprintf('  -> %d개 파일, %d채널 로드 완료 (%s)\n', numFiles, numChannels, fullFolderPath);
end