%% 정상 vs 결함(체인이탈) 스펙트럼 - 축별 오버레이(겹쳐그리기) 비교
% 한 축(X 또는 Y 또는 Z)마다 figure 1개, 그 안에 3개 subplot(Motor/Reducer/Bearing)을 두고
% 각 subplot 안에 정상(파랑) / 결함(빨강) 스펙트럼을 함께 겹쳐서 직접 비교합니다.

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
faultAlpha = 0.85;     % 결함 라인 투명도(0~1). 겹칠 때 정상 라인이 가려지지 않게 조절

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

%% 3. 축(X/Y/Z)별 오버레이 비교 플롯
for a = 1:numel(axisNames)
    axisName = axisNames{a};
    chIdxList = axisGroupIdx.(axisName);   % [Motor채널 Reducer채널 Bearing채널]

    figure('Name', sprintf('%s축 정상vs결함 오버레이 비교 [%s]', axisName, processLabel), ...
           'NumberTitle', 'off', 'Position', [100 80 950 850]);

    for s = 1:numel(chIdxList)
        ch = chIdxList(s);
        loc = locationNames{s};
        subplot(numel(chIdxList), 1, s);

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

        plot(tfN, tvN, 'Color', [0.00 0.45 0.74], 'LineWidth', 1.1, 'DisplayName', '정상'); hold on;
        plot(tfF, tvF, 'Color', [0.85 0.10 0.10], 'LineWidth', 1.0, 'DisplayName', '결함(체인이탈)');
        hold off;

        grid on;
        xlabel('Frequency (Hz)', 'FontWeight', 'bold');
        ylabel(yLabelStr, 'FontWeight', 'bold');
        title(sprintf('%s (%s축) - 정상 vs 결함 오버레이', loc, axisName));
        xlim(xlimVal);
        legend('Location', 'northeast');
    end

    sgtitle(sprintf('%s축 정상 vs 결함(체인이탈) 오버레이 - %s [%s]', axisName, processLabel, targetDate), ...
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