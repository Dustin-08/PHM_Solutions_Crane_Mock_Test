%% 1. 경로 및 설정 변수 (사용자 정의 영역)
%basePath = 'C:\Users\UIAI\Desktop\크레인분석\Data\'; % Data  extractData
basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/extractData'; % 경로수정
targetDate = '260806';                          % [변수] 날짜 폴더명
targetRPM = '60';
%targetRPM = '70';
%targetRPM = '80';
targetCondition = fullfile('체인마모1', 'Vib');   % [변수] 상태 및 하위 폴더 경로
%targetCondition = fullfile('정상3', 'Vib');   % [변수] 상태 및 하위 폴더 경로

% 기본 신호 처리 매개변수
fs = 3200;           % 샘플링 주파수 (Hz)
en_pw = 0;            % 0: Amplitude Spectrum, 1: Power Spectrum
normfact = 1;         % 윈도우 정규화 계수

% ★ 1. 신호 전처리 유형 선택 (processtype) ★
% 0: Raw 신호 그대로 사용
% 1: convmeas 함수를 사용한 속도 변환 ('vel')
% 2: 힐베르트 변환 기반 포락 처리 (Envelope Analysis)
processtype = 1;      

% ★ 2. 시각화 그래프 유형 선택 (plottype) ★
% 0: 로우 데이터 / 시계열 파형 (Time-domain Signal)
% 1: 파일별 대표 RMS 트렌드 (File-by-File RMS)
% 2: 주파수 스펙트럼 (1D Frequency Spectrum)
% 3: 스펙트로그램 (2D Time-Frequency Spectrogram)
%plottype = 3;
plottype = 2;

% ★ 3. 주파수 관찰 범위 설정 (Hz) ★
%xlimVal = [1 100];   % [최소주파수 최대주파수] (예: 1Hz ~ 1000Hz)
xlimVal = [1 300];   % [최소주파수 최대주파수] (예: 1Hz ~ 1000Hz)

% 오버랩(Overlap) 및 시각화 옵션
winTime = 2;          % Δf = 1/winTime = 1/2 = 0.5Hz 해상도,  0.5초 단위로 나옴 [60Hz시 사용]
%winTime = 1;         % 이동 윈도우 시간 (초 단위), 1초 단위로 나옴                  [70Hz시 사용]
%winTime = 1.5;      % 0.33초 단위로 나옴                                     [80Hz시 사용]
overlapRatio = 0.8;    % 오버랩 비율 (0.8 = 80% 중첩)
use_dB = 0;        % true: dB 스케일(20*log10), false: 선형 스케일

%% 2. 파일 탐색 및 파일별 데이터 전처리 & RMS 계산
fullFolderPath = fullfile(basePath, targetDate,targetRPM, targetCondition);
matFiles = dir(fullfile(fullFolderPath, '*.mat'));
numFiles = length(matFiles);

if numFiles == 0
    error('지정된 경로에 .mat 파일이 존재하지 않습니다: %s', fullFolderPath);
end

fprintf('총 %d개의 .mat 파일을 로드하여 개별 처리 중...\n', numFiles);

signalCell = cell(numFiles, 1);
fileRMS = zeros(1, numFiles);

for k = 1:numFiles
    filePath = fullfile(matFiles(k).folder, matFiles(k).name);
    matData = load(filePath);
    fields = fieldnames(matData);
    sig = matData.(fields{1});
    sig = sig(:);
    
    % [0Hz/DC 제거 1차]
    sig = sig - mean(sig);
    
    % switch-case 기반 신호 전처리 (processtype)
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
            error('잘못된 processtype입니다. (0: Raw, 1: 속도변환, 2: 포락처리 중 선택)');
    end
    
    % [0Hz/DC 제거 2차]
    sig = sig - mean(sig);
    
    % 데이터(파일) 1개당 단일 RMS 계산
    fileRMS(k) = sqrt(mean(sig.^2));
    
    signalCell{k} = sig;
end

% 전체 연결 신호
totalSignal = vertcat(signalCell{:});

%% 3. switch-case 기반 시각화 출력 (plottype)
figure('Name', sprintf('Plot Mode: %d [%s]', plottype, processLabel), 'NumberTitle', 'off');

switch plottype
    case 0 % ---------------------------------------------------------------
        % 로우 데이터 / 시계열 파형 (Time-domain Signal)
        % ------------------------------------------------------------------
        timeAxis = (0:length(totalSignal)-1) / fs;
        plot(timeAxis, totalSignal, 'Color', [0 0.4470 0.7410], 'LineWidth', 0.8);
        grid on;
        
        xlabel('Time (seconds)', 'FontSize', 11, 'FontWeight', 'bold');
        ylabel('Amplitude', 'FontSize', 11, 'FontWeight', 'bold');
        title(sprintf('Time Domain Signal [%s - %s]', targetDate, processLabel), 'FontSize', 12, 'FontWeight', 'bold');
        xlim([0 timeAxis(end)]);

    case 1 % ---------------------------------------------------------------
        % 파일별 대표 RMS 트렌드 (File-by-File RMS)
        % ------------------------------------------------------------------
        plot(1:numFiles, fileRMS, '-o', 'Color', [0.8500 0.3250 0.0980], ...
             'LineWidth', 1.2, 'MarkerSize', 5, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
        grid on;
        
        xlabel('File Index', 'FontSize', 11, 'FontWeight', 'bold');
        ylabel('RMS Value', 'FontSize', 11, 'FontWeight', 'bold');
        title(sprintf('File-by-File RMS Trend [%s - %s] (Total %d Files)', ...
              targetDate, processLabel, numFiles), 'FontSize', 12, 'FontWeight', 'bold');
          
        if numFiles > 1
            xlim([1 numFiles]);
        end

    case 2 % ---------------------------------------------------------------
        % 주파수 스펙트럼 (1D Frequency Spectrum)
        % ------------------------------------------------------------------
        [tval, tfreq] = getspec(totalSignal, fs, winTime, en_pw, normfact);
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
        
        xlabel('Frequency (Hz)', 'FontSize', 11, 'FontWeight', 'bold');
        ylabel(yLabelStr, 'FontSize', 11, 'FontWeight', 'bold');
        title(sprintf('Frequency Spectrum [%s - %s] (Range: %d-%d Hz)', ...
              targetDate, processLabel, xlimVal(1), xlimVal(2)), 'FontSize', 12, 'FontWeight', 'bold');
        
        % ★ 주파수 제한 범위 적용 ★
        xlim(xlimVal);

    case 3 % ---------------------------------------------------------------
        % 스펙트로그램 (2D Time-Frequency Spectrogram)
        % ------------------------------------------------------------------
        winLen = round(fs * winTime);
        overlapLen = round(winLen * overlapRatio);
        stepLen = winLen - overlapLen;
        winFunc = hann(winLen);
        numFrames = floor((length(totalSignal) - winLen) / stepLen) + 1;
        
        if numFrames < 1
            error('신호 전체 길이가 winTime보다 짧습니다.');
        end
        
        % 첫 프레임 기준 주파수 축 계산
        firstFrame = totalSignal(1:winLen) .* winFunc;
        [~, tfreq] = getspec(firstFrame, fs, winTime, en_pw, normfact);
        numFreqs = length(tfreq);
        
        spectrogramMatrix = zeros(numFreqs, numFrames);
        timeVec = zeros(1, numFrames);
        
        for i = 1:numFrames
            idxStart = (i - 1) * stepLen + 1;
            idxEnd = idxStart + winLen - 1;
            
            frameSignal = totalSignal(idxStart:idxEnd);
            frameSignal = (frameSignal - mean(frameSignal)) .* winFunc;
            
            [tval, ~] = getspec(frameSignal, fs, winTime, en_pw, normfact);
            tval(1) = 0; % 0Hz 제거
            
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
        cb.Label.FontWeight = 'bold';
        
        xlabel('Time (seconds)', 'FontSize', 11, 'FontWeight', 'bold');
        ylabel('Frequency (Hz)', 'FontSize', 11, 'FontWeight', 'bold');
        title(sprintf('STFT Spectrogram [%s - %s] (Freq Range: %d-%d Hz)', ...
              targetDate, processLabel, xlimVal(1), xlimVal(2)), 'FontSize', 12, 'FontWeight', 'bold');
          
        % ★ 스펙트로그램 주파수 축(Y축) 제한 범위 적용 ★
        ylim(xlimVal);

    otherwise
        error('잘못된 plottype입니다. (0: 로우데이터, 1: RMS, 2: 스펙트럼, 3: 스펙트로그램 중 선택)');
end