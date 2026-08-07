%% 9채널(Motor/Reducer/Bearing x X,Y,Z) - Raw/속도변환/포락 3가지를 각각 별도 화면(3x3)에 표시
% 파일은 한 번만 로드하고, processtype(0:Raw, 1:속도변환, 2:포락)을 순차로 적용해서
% 3개의 figure(각각 9채널 3x3)를 띄웁니다.

%% 1. 경로 및 설정
basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data'; % 경로수정
targetDate = '260807';
targetRPM = '70';
targetCondition = fullfile('등속_상승', 'Vib');   % [변수] 불러올 상태 폴더

fs = 3200;
en_pw = 0;
normfact = 1;
xlimVal = [1 300];
winTime = 1.5;
use_dB = 0;

processTypesToRun = [0, 1, 2];   % 0:Raw, 1:속도변환('vel'), 2:포락(Envelope) - 순서대로 3개 창

% 채널 배치: row 1,2,3=Motor / 4,5,6=Reducer / 7,8,9=Bearing (Settings.json useChannels 순서 확인됨)
channelLabels = {'Motor-X','Motor-Y','Motor-Z', ...
                 'Reducer-X','Reducer-Y','Reducer-Z', ...
                 'Bearing-X','Bearing-Y','Bearing-Z'};

% 3x3 배치용 매핑: row = 축(X/Y/Z, 라벨 기준), col = 위치(Motor/Reducer/Bearing)
gridChannelIdx = [1 4 7;   % X행: Motor-X, Reducer-X, Bearing-X
                  2 5 8;   % Y행: Motor-Y, Reducer-Y, Bearing-Y
                  3 6 9];  % Z행: Motor-Z, Reducer-Z, Bearing-Z

%% 2. 원본(Raw) 데이터는 한 번만 로드 (파일 I/O 절약)
fprintf('=== 원본 데이터 로드 중 (%s) ===\n', targetCondition);
[rawChannelCell, fsData] = loadRaw9Channel(basePath, targetDate, targetRPM, targetCondition, fs);

%% 3. processtype(Raw/속도변환/포락)을 순차 적용하며 각각 별도 창에 표시
for pt = processTypesToRun
    switch pt
        case 0, processLabel = 'Raw Signal';
        case 1, processLabel = 'Velocity Converted';
        case 2, processLabel = 'Envelope Signal';
        otherwise, error('잘못된 processtype입니다.');
    end

    fprintf('=== [%s] 전처리 및 플롯 중 ===\n', processLabel);
    procChannelCell = applyProcessing(rawChannelCell, fsData, pt);

    plotNineChannels(procChannelCell, fsData, gridChannelIdx, channelLabels, ...
                      winTime, en_pw, normfact, use_dB, xlimVal, processLabel, targetDate, targetCondition);
end

%% ===================== 로컬 함수 =====================
function [rawChannelCell, fsOut] = loadRaw9Channel(basePath, targetDate, targetRPM, condition, fsDefault)
% 지정 폴더의 .mat 파일들(signals: 9 x N)을 읽어 채널별로 파일 연결한 "원본" 신호를 반환 (전처리 안 함)
fullFolderPath = fullfile(basePath, targetDate, targetRPM, condition);
matFiles = dir(fullfile(fullFolderPath, '*.mat'));
numFiles = length(matFiles);
if numFiles == 0
    error('지정된 경로에 .mat 파일이 존재하지 않습니다: %s', fullFolderPath);
end

fsOut = fsDefault;
segByFile = cell(numFiles, 1);
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
    segByFile{k} = segData;
end
numChannels = size(segByFile{1}, 1);

rawChannelCell = cell(numChannels, 1);
for ch = 1:numChannels
    chParts = cell(numFiles, 1);
    for k = 1:numFiles
        seg = segByFile{k}(ch, :);
        chParts{k} = seg(:);
    end
    rawChannelCell{ch} = vertcat(chParts{:});
end
fprintf('  -> %d개 파일, %d채널 원본 로드 완료 (%s)\n', numFiles, numChannels, fullFolderPath);
end

function procChannelCell = applyProcessing(rawChannelCell, fs, processtype)
% 원본 채널 신호에 DC제거 + processtype(Raw/속도변환/포락) 전처리를 적용
numChannels = numel(rawChannelCell);
procChannelCell = cell(numChannels, 1);
for ch = 1:numChannels
    seg = rawChannelCell{ch};
    seg = seg - mean(seg);
    switch processtype
        case 0
            % Raw
        case 1
            [seg, ~] = convmeas(seg, fs, 'vel');
        case 2
            seg = abs(hilbert(seg));
    end
    seg = seg - mean(seg);
    procChannelCell{ch} = seg;
end
end

function plotNineChannels(channelCell, fsData, gridChannelIdx, channelLabels, ...
    winTime, en_pw, normfact, use_dB, xlimVal, processLabel, targetDate, targetCondition)
% 9채널을 한 화면(3x3)에 표시

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
end