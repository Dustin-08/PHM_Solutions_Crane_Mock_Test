%% 정상 vs 결함(체인이탈) - 9채널 전체를 한 화면(3x3)에 오버레이 비교
% 하나의 figure 안에 3행(X/Y/Z축) x 3열(Motor/Reducer/Bearing) = 9개 subplot을 배치하고,
% 각 subplot 안에서 정상(파랑) vs 결함(빨강) 스펙트럼을 겹쳐 그려서 9채널을 한눈에 비교합니다.

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

% 채널 배치: row 1,2,3=Motor / 4,5,6=Reducer / 7,8,9=Bearing (Settings.json useChannels 순서 확인됨)
channelLabels = {'Motor-X','Motor-Y','Motor-Z', ...
                 'Reducer-X','Reducer-Y','Reducer-Z', ...
                 'Bearing-X','Bearing-Y','Bearing-Z'};

% 3x3 배치용 매핑: row = 축(X/Y/Z, 라벨 기준), col = 위치(Motor/Reducer/Bearing)
axisRowNames = {'X', 'Y', 'Z'};
locationColNames = {'Motor', 'Reducer', 'Bearing'};
gridChannelIdx = [1 4 7;   % X행: Motor-X, Reducer-X, Bearing-X
                  2 5 8;   % Y행: Motor-Y, Reducer-Y, Bearing-Y
                  3 6 9];  % Z행: Motor-Z, Reducer-Z, Bearing-Z

% ⚠ 참고: 위 배치는 "센서 라벨 기준" X/Y/Z입니다. 2026-08-07 사진 실측 결과 실제 중력(수직)
%   방향은 Motor=X, Reducer=Y(추정), Bearing=Y 로 위치마다 다르니, 해석 시 유의하세요.
%   (실제 수직끼리만 비교하고 싶다면 gridChannelIdx의 해당 칸: Motor는 X행 1열,
%    Reducer/Bearing은 Y행 2,3열을 함께 보시면 됩니다.)

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

%% 3. 한 화면(3x3=9개 subplot)에 정상vs결함 오버레이
figure('Name', sprintf('9채널 전체 정상vs결함 오버레이 [%s]', processLabel), ...
       'NumberTitle', 'off', 'Position', [60 40 1400 1000]);

for r = 1:3
    for c = 1:3
        ch = gridChannelIdx(r, c);
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

        plot(tfN, tvN, 'Color', [0.00 0.45 0.74], 'LineWidth', 1.0, 'DisplayName', '정상'); hold on;
        plot(tfF, tvF, 'Color', [0.85 0.10 0.10], 'LineWidth', 0.9, 'DisplayName', '결함(체인이탈)');
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

sgtitle(sprintf('9채널 정상 vs 결함(체인이탈) 오버레이 - %s [%s]  (행:X/Y/Z축 라벨, 열:Motor/Reducer/Bearing)', ...
        processLabel, targetDate), 'FontSize', 13, 'FontWeight', 'bold');

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