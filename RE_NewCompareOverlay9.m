%% 정상 vs 결함(체인이탈) - 9채널 3x3 오버레이 + 조건별 실제 1x(fr) 마커 표시
% 정상/결함 각각 실제 회전속도가 미세하게 다를 수 있으므로, 이론 fr을 "검색 중심"으로만 쓰고
% 실제 피크는 정상/결함 신호에서 각각 독립적으로 탐색해서 마커(▽)로 표시합니다.

%% 1. 경로 및 설정
basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data'; % 경로수정
targetDate = '260806';
targetRPM = '80';

normalCondition = fullfile('정상1', 'Vib');
faultCondition  = fullfile('체인이탈1', 'Vib');

fs = 3200;
en_pw = 0;
normfact = 1;
processtype = 0;      % 0: Raw, 1: 속도변환('vel'), 2: 포락(Envelope)
xlimVal = [1 300];
winTime = 1.5;
use_dB = 0;

channelLabels = {'Motor-X','Motor-Y','Motor-Z', ...
                 'Reducer-X','Reducer-Y','Reducer-Z', ...
                 'Bearing-X','Bearing-Y','Bearing-Z'};

axisRowNames = {'X', 'Y', 'Z'};
locationColNames = {'Motor', 'Reducer', 'Bearing'};
gridChannelIdx = [1 4 7;   % X행: Motor-X, Reducer-X, Bearing-X
                  2 5 8;   % Y행: Motor-Y, Reducer-Y, Bearing-Y
                  3 6 9];  % Z행: Motor-Z, Reducer-Z, Bearing-Z

switch processtype
    case 0, processLabel = 'Raw Signal';
    case 1, processLabel = 'Velocity Converted';
    case 2, processLabel = 'Envelope Signal';
    otherwise, error('잘못된 processtype입니다.');
end

%% 2. ★ 1x(fr) 검색용 이론값 계산 (검색 시작점으로만 사용, 최종 표시는 실측값) ★
setHz = 80;
motorRpmPerHz = 30;
reducerRatio  = 0.5833;
loadRatio     = 0.1;

motorRPM   = motorRpmPerHz * setHz;
motorHz    = motorRPM / 60;
reducerRPM = motorRPM * reducerRatio;
reducerHz  = reducerRPM / 60;
loadRPM    = reducerRPM * loadRatio;
loadHz     = loadRPM / 60;

frTheoryByCol = [motorHz, reducerHz, loadHz];   % col 1,2,3 = Motor, Reducer, Bearing
searchRatio = 0.4;   % 이론 fr의 ±40% 범위 안에서 실제 피크를 탐색 (2배 고조파와 안 겹치게)

fprintf('=== 1x(fr) 검색 기준값 (설정 %.0fHz) ===\n', setHz);
fprintf('Motor 이론fr=%.3fHz, Reducer 이론fr=%.3fHz, Bearing 이론fr=%.3fHz\n', ...
        motorHz, reducerHz, loadHz);

%% 3. 정상 / 결함 데이터 각각 로드 + 전처리
fprintf('=== 정상 데이터 로드 중 ===\n');
[normalChannelCell, fsNormal] = loadAndProcess9Channel(basePath, targetDate, targetRPM, normalCondition, fs, processtype);

fprintf('=== 결함(체인이탈) 데이터 로드 중 ===\n');
[faultChannelCell, fsFault] = loadAndProcess9Channel(basePath, targetDate, targetRPM, faultCondition, fs, processtype);

%% 4. 한 화면(3x3=9개 subplot)에 정상vs결함 오버레이 + 조건별 실제 1x 마커
figure('Name', sprintf('9채널 정상vs결함 오버레이 + 실측 1x마커 [%s]', processLabel), ...
       'NumberTitle', 'off', 'Position', [60 40 1450 1000]);

normalColor = [0.00 0.45 0.74];
faultColor  = [0.85 0.10 0.10];

for r = 1:3
    for c = 1:3
        ch = gridChannelIdx(r, c);
        frTheory = frTheoryByCol(c);
        subplot(3, 3, (r-1)*3 + c);

        [tvN, tfN] = getspec(normalChannelCell{ch}, fsNormal, winTime, en_pw, normfact);
        [tvF, tfF] = getspec(faultChannelCell{ch}, fsFault, winTime, en_pw, normfact);
        tvN(1) = 0; tvF(1) = 0;

        if use_dB
            tvN = 20*log10(tvN + eps);
            tvF = 20*log10(tvF + eps);
            yLabelStr = 'Magnitude (dB)';
        else
            yLabelStr = 'Magnitude';
        end

        plot(tfN, tvN, 'Color', normalColor, 'LineWidth', 1.0, 'DisplayName', '정상'); hold on;
        plot(tfF, tvF, 'Color', faultColor, 'LineWidth', 0.9, 'DisplayName', '결함(체인이탈)');

        % --- 조건별 실제 1x(fr) 피크를 각각 독립적으로 탐색 후 마커 표시 ---
        [fN, mN] = findActualPeakNear(tfN, tvN, frTheory, searchRatio);
        [fF, mF] = findActualPeakNear(tfF, tvF, frTheory, searchRatio);

        if ~isnan(fN)
            plot(fN, mN, 'v', 'MarkerSize', 7, 'MarkerFaceColor', normalColor, ...
                 'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
            plot([fN fN], [0 mN], ':', 'Color', normalColor, 'LineWidth', 0.8, 'HandleVisibility', 'off');
            text(fN, mN, sprintf(' %.2fHz', fN), 'Color', normalColor, 'FontSize', 7, ...
                 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
        end
        if ~isnan(fF)
            plot(fF, mF, 'v', 'MarkerSize', 7, 'MarkerFaceColor', faultColor, ...
                 'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
            plot([fF fF], [0 mF], ':', 'Color', faultColor, 'LineWidth', 0.8, 'HandleVisibility', 'off');
            text(fF, mF, sprintf(' %.2fHz', fF), 'Color', faultColor, 'FontSize', 7, ...
                 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');
        end
        hold off;

        grid on;
        title(channelLabels{ch}, 'FontSize', 10);
        xlim(xlimVal);

        if r == 3
            xlabel('Frequency (Hz)', 'FontWeight', 'bold');
        end
        if c == 1
            ylabel(yLabelStr, 'FontWeight', 'bold');
        end
        if r == 1 && c == 1
            legend('Location', 'northeast', 'FontSize', 8);
        end
    end
end

sgtitle(sprintf('9채널 정상 vs 결함 오버레이 + 조건별 실측 1x(▽) - %s [%s]  (행:X/Y/Z축 라벨, 열:Motor/Reducer/Bearing)', ...
        processLabel, targetDate), 'FontSize', 13, 'FontWeight', 'bold');

%% ===================== 로컬 함수 =====================
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

function [peakFreq, peakMag] = findActualPeakNear(freqAxis, magAxis, theoryFreq, searchRatio)
% theoryFreq를 중심으로 ±searchRatio 범위(예: ±40%) 안에서 실제 최대값을 갖는
% (freq, mag) 쌍을 찾아 반환한다. 범위 안에 데이터가 없으면 NaN 반환.
loF = theoryFreq * (1 - searchRatio);
hiF = theoryFreq * (1 + searchRatio);
idx = find(freqAxis >= loF & freqAxis <= hiF);

if isempty(idx)
    peakFreq = NaN; peakMag = NaN;
    return;
end

[peakMag, relIdx] = max(magAxis(idx));
peakFreq = freqAxis(idx(relIdx));
end