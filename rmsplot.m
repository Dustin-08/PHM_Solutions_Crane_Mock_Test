%% 1. 경로 및 설정 변수
basePath = 'C:\Users\UIAI\Desktop\크레인분석\Data\';
targetDate = '260806';                          % [변수] 날짜 폴더명
targetRPM = '70';
targetCondition = fullfile('정상1', 'Vib');   % [변수] 상태 및 하위 폴더 경로

fs = 3200;           % 샘플링 주파수 (Hz)
winTime = 1;       % 이동 RMS 계산 윈도우 시간 (초 단위, 공정 주기에 맞게 조정 가능)
processtype = 0;     % 0: Raw, 1: Velocity Converted, 2: Envelope Signal
thresVal = 0.1;
%% 2. 데이터 로드 및 전처리 (전체 신호 연결)
fullFolderPath = fullfile(basePath, targetDate,targetRPM, targetCondition);
matFiles = dir(fullfile(fullFolderPath, '*.mat'));
numFiles = length(matFiles);

if numFiles == 0
    error('지정된 경로에 .mat 파일이 존재하지 않습니다: %s', fullFolderPath);
end

signalCell = cell(numFiles, 1);

for k = 1:numFiles
    filePath = fullfile(matFiles(k).folder, matFiles(k).name);
    matData = load(filePath);
    fields = fieldnames(matData);
    
    sig = matData.(fields{1});
    sig = sig(:);
    
    % DC 성분 제거 및 신호 전처리
    sig = sig - mean(sig);
    switch processtype
        case 0
            processLabel = 'Raw Signal';
        case 1
            processLabel = 'Velocity Converted';
            [sig, ~] = convmeas(sig, fs, 'vel');
        case 2
            processLabel = 'Envelope Signal';
            sig = abs(hilbert(sig));
        otherwise
            error('잘못된 processtype입니다.');
    end
    sig = sig - mean(sig);
    signalCell{k} = sig;
end

% 전체 연속 신호 병합
totalSignal = vertcat(signalCell{:});
timeAxis = (0:length(totalSignal)-1) / fs;

%% 3. 이동 RMS 기반 운전/대기 구간 검출 알고리즘
winLen = round(fs * winTime);

% 1) 시간에 따른 이동 RMS(Moving RMS) 계산
movingRMS = sqrt(movmean(totalSignal.^2, winLen));

% 2) 전체 데이터 중 이동 RMS의 최대값 산출
maxRMS = max(movingRMS);

% 3) 임계값 설정 (최대 RMS의 10%)
thresholdRMS = thresVal * maxRMS;

% 4) 조건 판단: 임계값 초과(운전: true/1), 미만(대기: false/0)
isOperating = movingRMS >= thresholdRMS;

% 5) 최종 운전 데이터만 추출
operatingSignal = totalSignal(isOperating);
operatingTime = timeAxis(isOperating);

%% 4. 검출 결과 요약 출력
fprintf('=== 운전 구간 검출 결과 요약 ===\n');
fprintf('전체 데이터 시간: %.2f 초 (%d 샘플)\n', timeAxis(end), length(totalSignal));
fprintf('최대 Moving RMS: %.6f\n', maxRMS);
fprintf('운전 검출 임계값 (10%%): %.6f\n', thresholdRMS);
fprintf('검출된 운전 시간: %.2f 초 (전체의 %.2f%%)\n', ...
        length(operatingSignal)/fs, (sum(isOperating)/length(isOperating))*100);

%% 5. 시각화 (검출 성능 확인)
figure('Name', 'Operation Detection via Moving RMS', 'NumberTitle', 'off');

% Subplot 1: 시간 영역 신호 (대기/운전 구간 색상 구분)
subplot(2,1,1);
plot(timeAxis, totalSignal, 'Color', [0.75 0.75 0.75], 'LineWidth', 0.5); hold on;
% 운전 데이터 위치만 파란색으로 오버레이
plot(operatingTime, operatingSignal, '.', 'Color', [0 0.4470 0.7410], 'MarkerSize', 1);
grid on;
xlabel('Time (seconds)', 'FontWeight', 'bold');
ylabel('Amplitude', 'FontWeight', 'bold');
title(sprintf('Operation Segment Detection [%s - %s]', targetDate, processLabel), 'FontWeight', 'bold');
legend({'Idle (대기)', 'Operating (운전)'}, 'Location', 'northeast');
xlim([0 timeAxis(end)]);

% Subplot 2: Moving RMS 추이 및 10% 임계값 라인
subplot(2,1,2);
plot(timeAxis, movingRMS, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.0); hold on;
yline(thresholdRMS, 'r--', sprintf('Threshold (10%% Max RMS = %.4f)', thresholdRMS), ...
      'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom', 'FontWeight', 'bold');
grid on;
xlabel('Time (seconds)', 'FontWeight', 'bold');
ylabel('Moving RMS', 'FontWeight', 'bold');
title('Moving RMS Profile with 10% Threshold', 'FontWeight', 'bold');
xlim([0 timeAxis(end)]);