%% 9채널(Motor/Reducer/Bearing x X,Y,Z) - 한 조건만 로드해서 한 화면(3x3)에 표시
% 정상/결함 둘 다 로드하지 않고, targetCondition 폴더 하나만 읽어서
% 3행(X/Y/Z축) x 3열(Motor/Reducer/Bearing) = 9개 subplot을 한 figure에 그립니다.

%% 1. 경로 및 설정
basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data'; % 경로수정
targetDate = '260806';
targetRPM = '80';
targetCondition = fullfile('체인이탈1', 'Vib');   % [변수] 불러올 상태 폴더 (정상1, 체인이탈1 등)

fs = 3200;
en_pw = 0;
normfact = 1;
processtype = 0;      % 0: Raw, 1: 속도변환('vel'), 2: 포락(Envelope)
xlimVal = [1 300];
winTime = 1.5;
use_dB = 0;

% 채널 배치: row 1,2,3=Motor / 4,5,6=Reducer / 7,8,9=Bearing (Settings.json useChannels 순서 확인됨)
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

%% 2. 데이터 로드 + 전처리 (한 조건만)
fprintf('=== 데이터 로드 중 (%s) ===\n', targetCondition);
[channelCell, fsData] = loadAndProcess9Channel(basePath, targetDate, targetRPM, targetCondition, fs, processtype);

%% 3. 9채널을 한 화면(3x3)에 표시
figure('Name', sprintf('9채널 [%s]', processLabel), 'NumberTitle', 'off', 'Position', [60 40 1400 1000]);

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
    end
end

sgtitle(sprintf('9채널 스펙트럼 - %s [%s / %s]  (행:X/Y/Z축 라벨, 열:Motor/Reducer/Bearing)', ...
        processLabel, targetDate, targetCondition), 'FontSize', 13, 'FontWeight', 'bold');

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