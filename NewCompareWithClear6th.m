%% 정상 vs 결함(체인이탈) 스펙트럼 - 축별 6분할(3행 Motor/Reducer/Bearing x 2열 정상/결함) 비교
% 한 축(X 또는 Y 또는 Z)마다 figure 1개, 그 안에 3x2 subplot으로
%   왼쪽열 = 정상, 오른쪽열 = 결함
%   위->아래 = Motor, Reducer, Bearing
% 을 배치해서 한눈에 6개를 비교합니다.

%% 1. 경로 및 설정
basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data'; % 경로수정
targetDate = '260806';
targetRPM = '80';

normalCondition = fullfile('정상1', 'Vib');       % [변수] 정상 상태 폴더
faultCondition  = fullfile('체인이탈1', 'Vib');    % [변수] 결함(체인이탈) 상태 폴더

fs = 3200;
en_pw = 0;
normfact = 1;
processtype = 0;      % 0: Raw, 1: 속도변환('vel'), 2: 포락(Envelope)
xlimVal = [1 300];
winTime = 1.5;
use_dB = 0;
matchYLimPerRow = true;   % true면 같은 행(같은 위치)의 정상/결함 y축 범위를 통일해서 진폭 비교가 더 직관적임

channelLabels = {'Motor-X','Motor-Y','Motor-Z', ...
                 'Reducer-X','Reducer-Y','Reducer-Z', ...
                 'Bearing-X','Bearing-Y','Bearing-Z'};
axisGroupIdx.X = [1 4 7];
axisGroupIdx.Y = [2 5 8];
axisGroupIdx.Z = [3 6 9];
axisNames = {'X', 'Y', 'Z'};
locationNames = {'Motor', 'Reducer', 'Bearing'};

switch processtype
    case 0, processLabel = 'Raw Signal';
    case 1, processLabel = 'Velocity Converted';
    case 2, processLabel = 'Envelope Signal';
    otherwise, error('잘못된 processtype입니다.');
end

%% 2. 정상 / 결함 데이터 각각 로드 + 전처리
fprintf('=== 정상 데이터 로드 중 ===\n');
[normalChannelCell, fsNormal] = loadAndProcess9Channel(basePath, targetDate, targetRPM, normalCondition, fs, processtype);

fprintf('=== 결함(체인이탈) 데이터 로드 중 ===\n');
[faultChannelCell, fsFault] = loadAndProcess9Channel(basePath, targetDate, targetRPM, faultCondition, fs, processtype);

%% 3. 축(X/Y/Z)별 6분할(3x2) 비교 플롯
for a = 1:numel(axisNames)
    axisName = axisNames{a};
    chIdxList = axisGroupIdx.(axisName);   % [Motor채널 Reducer채널 Bearing채널]

    figure('Name', sprintf('%s축 정상vs결함 6분할 비교 [%s]', axisName, processLabel), ...
           'NumberTitle', 'off', 'Position', [80 60 1100 900]);

    for s = 1:numel(chIdxList)
        ch = chIdxList(s);
        loc = locationNames{s};

        % --- 왼쪽: 정상 ---
        axNormal = subplot(numel(chIdxList), 2, (s-1)*2 + 1);
        [tvN, tfN] = plotSpectrumSimple(normalChannelCell{ch}, fsNormal, winTime, en_pw, normfact, use_dB, xlimVal);
        title(sprintf('[정상] %s (%s축)', loc, axisName));

        % --- 오른쪽: 결함 ---
        axFault = subplot(numel(chIdxList), 2, (s-1)*2 + 2);
        [tvF, tfF] = plotSpectrumSimple(faultChannelCell{ch}, fsFault, winTime, en_pw, normfact, use_dB, xlimVal);
        title(sprintf('[결함-체인이탈] %s (%s축)', loc, axisName));

        if matchYLimPerRow
            yMax = max([tvN; tvF], [], 'omitnan');
            if yMax > 0
                ylim(axNormal, [0 yMax*1.05]);
                ylim(axFault, [0 yMax*1.05]);
            end
        end
    end

    sgtitle(sprintf('%s축 정상 vs 결함(체인이탈) 비교 - %s [%s]', axisName, processLabel, targetDate), ...
            'FontSize', 13, 'FontWeight', 'bold');
end

%% ===================== 로컬 함수 =====================
function [channelCell, fsOut] = loadAndProcess9Channel(basePath, targetDate, targetRPM, condition, fsDefault, processtype)
% 지정 폴더의 .mat 파일들(signals: 9 x N)을 읽어 채널별로 파일 연결 + 전처리한 결과를 반환
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

function [tvalPlot, tfreq] = plotSpectrumSimple(sig, fs, winTime, en_pw, normfact, use_dB, xlimVal)
% 현재 axes(subplot)에 스펙트럼을 그리고, (양축 스케일 통일용으로) tval/tfreq를 반환
[tval, tfreq] = getspec(sig, fs, winTime, en_pw, normfact);
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
xlabel('Frequency (Hz)', 'FontWeight', 'bold');
ylabel(yLabelStr, 'FontWeight', 'bold');
xlim(xlimVal);
end