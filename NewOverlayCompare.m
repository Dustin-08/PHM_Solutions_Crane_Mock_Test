%% 9채널(Motor/Reducer/Bearing x X,Y,Z) 스펙트럼 + 이론 주파수(fr/GMF/베어링결함) 오버레이
% 주파수계산.xlsx 계산기의 공식을 그대로 코드화하여, 설정 Hz(또는 RPM)만 바꾸면
% Motor/Reducer/Bearing 3곳의 이론 주파수를 자동 계산해서 스펙트럼 위에 점선으로 표시합니다.

%% 1. 경로 및 데이터 설정
basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data'; % 경로수정
targetDate = '260806';
targetRPM = '80';                                % 폴더명 (Hz 표기 폴더)
targetCondition = fullfile('체인이탈1', 'Vib');

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
axisGroupIdx.X = [1 4 7];
axisGroupIdx.Y = [2 5 8];
axisGroupIdx.Z = [3 6 9];
axisNames = {'X', 'Y', 'Z'};
locationNames = {'Motor', 'Reducer', 'Bearing'};   % s=1,2,3 순서와 일치 (axisGroupIdx의 각 원소 순서)

%% 2. ★★★ 이론 주파수 계산용 설정 (주파수계산.xlsx 기준) ★★★
setHz = 80;                 % 인버터 설정 주파수 (Hz). 지금 조건: 80Hz = 2400rpm
motorRpmPerHz = 30;         % 모터 동기속도 비율: RPM = motorRpmPerHz * setHz (4극 모터: 120/4=30)
reducerRatio  = 0.5833;     % 모터축 → 감속기(벨트)측 속도비
loadRatio     = 0.1;        % 감속기측 → 최종 부하(스프라켓/베어링)축 속도비
sprocketTeeth = 18;         % 스프라켓 잇수 (GMF 계산용)

% 베어링 스펙: 위치별로 다르면 [Motor Reducer Bearing] 순서로 3개 값을 넣고,
% 3곳이 동일한 베어링이면 스칼라 하나만 넣어도 됩니다.
bearing_n     = 9;      % 볼/롤러 개수
bearing_d     = 12;     % 볼/롤러 직경
bearing_D     = 60;     % 피치 직경
bearing_alpha = 0;      % 접촉각 (도)

showHarmonics = 3;            % fr의 1x~Nx 배수까지 표시
showGMF       = true;         % GMF 표시 여부 (Bearing 위치에만 표시; 스프라켓이 있는 축)
showBearingDefects = true;    % BPFO/BPFI/BSF/FTF 표시 여부

%% 3. 이론 주파수 계산 (Motor → Reducer → Bearing 순, 엑셀과 동일한 단계식 감속)
motorRPM   = motorRpmPerHz * setHz;
motorHz    = motorRPM / 60;
reducerRPM = motorRPM * reducerRatio;
reducerHz  = reducerRPM / 60;
loadRPM    = reducerRPM * loadRatio;
loadHz     = loadRPM / 60;

frByLocation = [motorHz, reducerHz, loadHz];   % 순서: Motor, Reducer, Bearing(=부하측)
GMF = loadHz * sprocketTeeth;

fprintf('=== 이론 주파수 계산 결과 (설정 %.1fHz 기준) ===\n', setHz);
fprintf('Motor   fr = %.3f Hz (RPM %.1f)\n', motorHz, motorRPM);
fprintf('Reducer fr = %.3f Hz (RPM %.1f)\n', reducerHz, reducerRPM);
fprintf('Bearing fr = %.3f Hz (RPM %.1f)\n', loadHz, loadRPM);
fprintf('GMF (스프라켓 Z=%d) = %.3f Hz\n', sprocketTeeth, GMF);

bnArr = getPerLocationSpec(bearing_n, 3);
bdArr = getPerLocationSpec(bearing_d, 3);
bDArr = getPerLocationSpec(bearing_D, 3);
baArr = getPerLocationSpec(bearing_alpha, 3);

BPFO = zeros(1,3); BPFI = zeros(1,3); BSF = zeros(1,3); FTF = zeros(1,3);
for i = 1:3
    fr = frByLocation(i);
    n = bnArr(i); d = bdArr(i); D = bDArr(i); a = deg2rad(baArr(i));
    ratio = (d/D) * cos(a);
    BPFO(i) = (n/2) * fr * (1 - ratio);
    BPFI(i) = (n/2) * fr * (1 + ratio);
    BSF(i)  = (D/(2*d)) * fr * (1 - ratio^2);
    FTF(i)  = 0.5 * fr * (1 - ratio);
    fprintf('[%s] BPFO=%.3f BPFI=%.3f BSF=%.3f FTF=%.3f Hz\n', ...
            locationNames{i}, BPFO(i), BPFI(i), BSF(i), FTF(i));
end

%% 4. 파일 탐색 및 9채널 원본 신호 로드
fullFolderPath = fullfile(basePath, targetDate, targetRPM, targetCondition);
matFiles = dir(fullfile(fullFolderPath, '*.mat'));
numFiles = length(matFiles);
if numFiles == 0
    error('지정된 경로에 .mat 파일이 존재하지 않습니다: %s', fullFolderPath);
end

rawChannelCell = cell(numFiles, 1);
for k = 1:numFiles
    filePath = fullfile(matFiles(k).folder, matFiles(k).name);
    matData = load(filePath);
    segData = matData.signals;
    if size(segData,1) ~= 9
        error('%s: signals 행 개수가 9가 아닙니다.', matFiles(k).name);
    end
    if isfield(matData,'fs') && ~isempty(matData.fs)
        fs = double(matData.fs(1));
    end
    rawChannelCell{k} = segData;
end
numChannels = size(rawChannelCell{1}, 1);

switch processtype
    case 0, processLabel = 'Raw Signal';
    case 1, processLabel = 'Velocity Converted';
    case 2, processLabel = 'Envelope Signal';
    otherwise, error('잘못된 processtype입니다.');
end

procChannelCell = cell(numChannels, 1);
for ch = 1:numChannels
    segProcCell = cell(numFiles, 1);
    for k = 1:numFiles
        seg = rawChannelCell{k}(ch, :);
        seg = seg(:);
        seg = seg - mean(seg);
        switch processtype
            case 1, [seg, ~] = convmeas(seg, fs, 'vel');
            case 2, seg = abs(hilbert(seg));
        end
        seg = seg - mean(seg);
        segProcCell{k} = seg;
    end
    procChannelCell{ch} = vertcat(segProcCell{:});
end

%% 5. 축(X/Y/Z)별 그룹 플롯 + 이론 주파수 오버레이
for a = 1:numel(axisNames)
    axisName = axisNames{a};
    chIdxList = axisGroupIdx.(axisName);

    figure('Name', sprintf('%s축 비교 + 이론주파수 [%s, %.0fHz]', axisName, processLabel, setHz), ...
           'NumberTitle', 'off', 'Position', [100 100 950 850]);

    for s = 1:numel(chIdxList)
        ch = chIdxList(s);
        loc = s;   % s=1 Motor, 2 Reducer, 3 Bearing (axisGroupIdx 정의 순서와 일치)
        subplot(numel(chIdxList), 1, s);

        theoryLines = buildTheoryLines(loc, frByLocation, GMF, BPFO, BPFI, BSF, FTF, ...
                                        showHarmonics, showGMF, showBearingDefects, xlimVal);

        drawSpectrumWithTheory(procChannelCell{ch}, fs, winTime, en_pw, normfact, use_dB, ...
                                xlimVal, channelLabels{ch}, processLabel, theoryLines);
    end

    sgtitle(sprintf('%s축 채널 비교 + 이론주파수선 - %s [설정 %.0fHz / %.0frpm]', ...
            axisName, processLabel, setHz, motorRPM), 'FontSize', 13, 'FontWeight', 'bold');
end

%% ===================== 로컬 함수 =====================
function arr = getPerLocationSpec(val, n)
% 스칼라면 n개로 복제, 이미 n개짜리 배열이면 그대로 반환
if isscalar(val)
    arr = repmat(val, 1, n);
else
    arr = val(:).';
    if numel(arr) ~= n
        error('베어링 스펙 배열의 길이는 %d 이어야 합니다.', n);
    end
end
end

function lines = buildTheoryLines(loc, frByLocation, GMF, BPFO, BPFI, BSF, FTF, ...
                                   showHarmonics, showGMF, showBearingDefects, xlimVal)
% loc: 1=Motor, 2=Reducer, 3=Bearing. 해당 위치의 이론선 목록(freq,label,color,style)을 만든다.
lines = struct('freq', {}, 'label', {}, 'color', {}, 'style', {});

fr = frByLocation(loc);
for m = 1:showHarmonics
    f = fr * m;
    if f >= xlimVal(1) && f <= xlimVal(2)
        lines(end+1) = struct('freq', f, 'label', sprintf('%dxfr', m), ...
                               'color', [0.5 0.5 0.5], 'style', '--'); %#ok<AGROW>
    end
end

if showGMF && loc == 3   % GMF는 스프라켓이 있는 Bearing(부하)축에서만 표시
    if GMF >= xlimVal(1) && GMF <= xlimVal(2)
        lines(end+1) = struct('freq', GMF, 'label', 'GMF', ...
                               'color', [0.85 0.10 0.10], 'style', '-.');
    end
end

if showBearingDefects
    defectVals = [BPFO(loc), BPFI(loc), BSF(loc), FTF(loc)];
    defectNames = {'BPFO','BPFI','BSF','FTF'};
    defectColors = {[0.00 0.45 0.74], [0.47 0.67 0.19], [0.49 0.18 0.56], [0.30 0.75 0.93]};
    for i = 1:4
        f = defectVals(i);
        if f >= xlimVal(1) && f <= xlimVal(2)
            lines(end+1) = struct('freq', f, 'label', defectNames{i}, ...
                                   'color', defectColors{i}, 'style', ':'); %#ok<AGROW>
        end
    end
end
end

function drawSpectrumWithTheory(sig, fs, winTime, en_pw, normfact, use_dB, xlimVal, ...
                                 chanLabel, processLabel, theoryLines)
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
grid on; hold on;

for i = 1:numel(theoryLines)
    tl = theoryLines(i);
    xline(tl.freq, tl.style, tl.label, 'Color', tl.color, 'LineWidth', 1.1, ...
          'LabelOrientation', 'horizontal', 'LabelVerticalAlignment', 'top', ...
          'FontSize', 8, 'Interpreter', 'none');
end
hold off;

xlabel('Frequency (Hz)', 'FontWeight', 'bold');
ylabel(yLabelStr, 'FontWeight', 'bold');
title(sprintf('%s - Spectrum [%s]', chanLabel, processLabel));
xlim(xlimVal);
end