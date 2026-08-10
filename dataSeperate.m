%% 1. 경로 및 설정 변수
%basePath = 'C:\Users\UIAI\Desktop\크레인분석\Data\';
basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data'; % 경로수정
targetDate = '260810';                          % [변수] 날짜 폴더명
%targetRPM = '60';
targetRPM = '70';
%targetRPM = '80';
targetCondition = fullfile('정상_등속_상승', 'Vib');   % [변수] 상태 및 하위 폴더 경로
%baseOutputPath = 'C:\Users\UIAI\Desktop\크레인분석\extractData\';
baseOutputPath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/extractData'; % 경로수정
% 운전 데이터가 분리 저장될 폴더 경로
outputFolder = fullfile(baseOutputPath, targetDate,targetRPM, targetCondition);

fs = 3200;           % 샘플링 주파수 (Hz) -> 1초당 3200 샘플
winTime = 1;       % 이동 RMS 계산 윈도우 시간 (초)
processtype = 0;     % 상태 검출용 전처리 (0: Raw, 1: Velocity, 2: Envelope)
%thresVal = 0.1;
thresVal = 0.2; % 임계치 상향 조정

% 저장 폴더 생성 (없는 경우)
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% 2. 데이터 로드 (원본 신호와 검출 판단용 신호 분리)
fullFolderPath = fullfile(basePath, targetDate,targetRPM, targetCondition);
matFiles = dir(fullfile(fullFolderPath, '*.mat'));
numFiles = length(matFiles);

if numFiles == 0
    error('지정된 경로에 .mat 파일이 존재하지 않습니다: %s', fullFolderPath);
end

rawSignalCell = cell(numFiles, 1);
procSignalCell = cell(numFiles, 1);
varName = ''; % 원본 .mat 파일 내부 변수명 보존용

for k = 1:numFiles
    filePath = fullfile(matFiles(k).folder, matFiles(k).name);
    matData = load(filePath);
    fields = fieldnames(matData);
    
    if isempty(varName)
        varName = fields{1}; % 원본 파일 내부의 변수명 저장 (동일하게 복원용)
    end
    
    % [A] 원본 그대로의 순수 Raw 신호 (변형 없음)
    rawSig = matData.(fields{1});
    rawSig = rawSig(:);
    rawSignalCell{k} = rawSig;
    
    % [B] 운전 검출 알고리즘 적용 전용 신호 (변환 적용)
    sigProc = rawSig - mean(rawSig);
    switch processtype
        case 0
            % Raw
        case 1
            [sigProc, ~] = convmeas(sigProc, fs, 'vel');
        case 2
            sigProc = abs(hilbert(sigProc));
    end
    sigProc = sigProc - mean(sigProc);
    procSignalCell{k} = sigProc;
end

% 전체 신호 병합
rawTotalSignal = vertcat(rawSignalCell{:});   % 원본 데이터 전체
procTotalSignal = vertcat(procSignalCell{:}); % 검출 판단용 데이터 전체

%% 3. Moving RMS 기반 운전 데이터 인덱스 검출
winLen = round(fs * winTime);
movingRMS = sqrt(movmean(procTotalSignal.^2, winLen));

maxRMS = max(movingRMS);
%thresholdRMS = 0.10 * maxRMS;
thresholdRMS = thresVal * maxRMS;

% 운전 상태 여부 판단 (True/False 논리 배열)
isOperating = movingRMS >= thresholdRMS;

% 원본 신호(rawTotalSignal)에서 운전 구간의 샘플만 순수 추출
rawOperatingSignal = rawTotalSignal(isOperating);

%% 4. 원본 규격(초당 fs 샘플 단위)을 유지하여 .mat 파일로 분리 저장
samplesPerSec = fs; % 1초당 샘플 수 (3200개)
totalOperatingSamples = length(rawOperatingSignal);

% 1초로 딱 떨어지는 완전한 초 단위 파일 개수 계산
numOperatingSeconds = floor(totalOperatingSamples / samplesPerSec);

fprintf('=== 원본 운전 데이터 분리 저장 시작 ===\n');
fprintf('전체 추출된 운전 샘플 수: %d 개\n', totalOperatingSamples);
fprintf('저장될 초(1초) 단위 .mat 파일 수: %d 개\n', numOperatingSeconds);

for i = 1:numOperatingSeconds
    % 1초(fs = 3200 샘플) 단위 데이터 슬라이싱
    idxStart = (i - 1) * samplesPerSec + 1;
    idxEnd = i * samplesPerSec;
    
    secData = rawOperatingSignal(idxStart:idxEnd);
    
    % 원본 .mat 파일의 변수 구조 보존
    saveStruct = struct();
    saveStruct.(varName) = secData;
    
    % 저장 파일명 지정 (예: Operating_Raw_0001.mat)
    saveFileName = sprintf('Operating_Raw_%04d.mat', i);
    savePath = fullfile(outputFolder, saveFileName);
    
    % .mat 파일 저장 (-struct 구문으로 원본과 동일 형태 저장)
    save(savePath, '-struct', 'saveStruct');
end

fprintf('성공적으로 저장되었습니다: %s\n', outputFolder);