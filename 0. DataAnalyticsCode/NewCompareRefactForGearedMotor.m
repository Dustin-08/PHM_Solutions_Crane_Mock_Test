%% NewCompare_4cond_grid.m
% N채널 스펙트럼 - Raw/속도변환/포락을 각각 별도 화면에 표시
% ★ 4개 조건(정상/결함 x 전진/후진)을 한 화면에 2x2 블록으로 동시 비교
%
%   기어드정상_전진 | 기어드결함_전진
%   기어드정상_후진 | 기어드결함_후진
%
% 각 블록 안에는 채널 수만큼(예: 3채널이면 1x3) 서브플롯이 들어갑니다.
% 결과적으로 한 figure 안에 2행 x (조건수*채널수)열 짜리 큰 격자가 그려집니다.

%% 1. 경로 및 설정
basePath   = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data';
targetDate = '260812';
targetRPM  = '40';

% ── 4개 조건과 화면상 배치(row, col) 지정 ───────────────────────────
%   row: 1=전진, 2=후진
%   col: 1=정상, 2=결함
conditions = struct( ...
    'name', {'기어드정상_전진', '기어드결함_전진', '기어드정상_후진', '기어드결함_후진'}, ...
    'row',  {1,                1,                2,                2}, ...
    'col',  {1,                2,                1,                2});
% ─────────────────────────────────────────────────────────────────

fs = 3200;
en_pw = 0;
normfact = 1;
xlimVal = [0 400];
winTime = 4;          % Δf = 1/winTime = 0.25 Hz
use_dB = 0;

% ── 채널 라벨 (채널 수에 따라 자동 선택) ────────────────────────────
labels9 = {'Motor-X','Motor-Y','Motor-Z', ...
           'Reducer-X','Reducer-Y','Reducer-Z', ...
           'Bearing-X','Bearing-Y','Bearing-Z'};
labels3 = {'GearedMotor-X','GearedMotor-Y','GearedMotor-Z'};   % ★ 3채널일 때 쓸 이름
% ─────────────────────────────────────────────────────────────────

% ── 포락용 대역통과 필터 ────────────────────────────────────────────
bpLo = 900;  bpHi = 1300;
% ─────────────────────────────────────────────────────────────────

% ── 파일 이어붙이기 방식 ────────────────────────────────────────────
concatMode = 'auto';
overlapTolRel = 1e-9;
% ─────────────────────────────────────────────────────────────────

processTypesToRun = [0, 1, 2];   % 0:Raw, 1:속도변환, 2:포락

%% 2. 4개 조건 각각 데이터 로드
nCond = numel(conditions);
rawByCond    = cell(nCond, 1);
infoByCond   = cell(nCond, 1);
labelsByCond = cell(nCond, 1);
fsData = fs;

for i = 1:nCond

    condPath = fullfile(conditions(i).name, 'Vib');

    fprintf('=== [%d/%d] %s 로드 중 ===\n', i, nCond, conditions(i).name);

    [rawByCond{i}, fsData, infoByCond{i}] = loadRawNChannel( ...
        basePath, targetDate, targetRPM, condPath, fs, concatMode, overlapTolRel);

    nCh = numel(rawByCond{i});

    switch nCh
        case 9,  labelsByCond{i} = labels9;
        case 3,  labelsByCond{i} = labels3;
        otherwise
            labelsByCond{i} = arrayfun(@(k) sprintf('CH%d', k), 1:nCh, 'UniformOutput', false);
            warning('채널 수 %d에 대한 라벨 정의가 없어 CH1..CH%d로 표시합니다.', nCh, nCh);
    end

    if numel(labelsByCond{i}) ~= nCh
        error('[%s] 라벨 개수(%d)와 채널 수(%d)가 다릅니다.', ...
              conditions(i).name, numel(labelsByCond{i}), nCh);
    end
end

% 모든 조건의 채널 수가 같은지 확인 (다르면 격자를 맞출 수 없음)
nChList = cellfun(@numel, rawByCond);
if numel(unique(nChList)) ~= 1
    error('조건마다 채널 수가 다릅니다: %s. 동일한 센서 구성이어야 합니다.', mat2str(nChList.'));
end
nCh = nChList(1);

nRow = max([conditions.row]);
nCol = max([conditions.col]);

fprintf('  -> %d개 조건 로드 완료 (채널 수 %d, 배치 %dx%d 블록, 블록당 1x%d 채널)\n', ...
        nCond, nCh, nRow, nCol, nCh);

%% 3. processtype 순차 적용 (조건 4개를 한 화면에 동시 표시)
for pt = processTypesToRun
    switch pt
        case 0, processLabel = 'Raw Signal';
        case 1, processLabel = 'Velocity Converted';
        case 2, processLabel = 'Envelope Signal';
        otherwise, error('잘못된 processtype입니다.');
    end

    fprintf('=== [%s] 전처리 및 플롯 중 ===\n', processLabel);

    procByCond = cell(nCond, 1);
    for i = 1:nCond
        procByCond{i} = applyProcessing(rawByCond{i}, fsData, pt, bpLo, bpHi);
    end

    plotConditionGrid(procByCond, fsData, conditions, labelsByCond, infoByCond, ...
                       nRow, nCol, nCh, winTime, en_pw, normfact, use_dB, xlimVal, ...
                       processLabel, targetDate, targetRPM);
end

%% ===================== 로컬 함수 =====================

function plotConditionGrid(procByCond, fsData, conditions, labelsByCond, infoByCond, ...
    nRow, nCol, nCh, winTime, en_pw, normfact, use_dB, xlimVal, processLabel, targetDate, targetRPM)

% 전체 열 수 = 조건 열 수(nCol) x 채널 수(nCh)
totalCols = nCol * nCh;

% 채널 하나당 가로 폭, 조건 블록 하나당 세로 높이를 기준으로 비율 계산
figW = min(330 * totalCols, 1800);
figH = min(430 * nRow + 120, 950);

% 예전에 sgtitle로 그림 안에 넣던 정보(Δf 포함)를 창 제목으로 이동
figName = sprintf('4조건 비교 - %s [%s Hz / %s]  (Δf = %.3f Hz)', ...
    processLabel, targetRPM, targetDate, 1/winTime);

figure( ...
    'Name', figName, ...
    'NumberTitle', 'off', ...
    'Position', [40 40 figW figH]);

nCond = numel(conditions);

% ── 바깥 레이아웃: nRow x nCol 블록 배치 ────────────────────────────
% 블록 사이 간격(TileSpacing)을 넉넉히 줘서 구분선/소제목이 들어갈
% 여유 공간을 확보합니다.
outerTL = tiledlayout(gcf, nRow, nCol, ...
    'TileSpacing', 'loose', ...
    'Padding', 'compact');

% 구분선 계산에 쓸 축 핸들을 조건별/채널별로 저장
axByCond = cell(nCond, nCh);

for i = 1:nCond

    r = conditions(i).row;
    c = conditions(i).col;

    procChannelCell = procByCond{i};
    channelLabels = labelsByCond{i};

    % ── 안쪽 레이아웃: 블록 하나 = 1 x nCh 채널 ─────────────────────
    innerTL = tiledlayout(outerTL, 1, nCh, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');
    innerTL.Layout.Tile = (r - 1) * nCol + c;

    % 블록 소제목 (조건 이름)
    title(innerTL, conditions(i).name, ...
        'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');

    for ch = 1:nCh

        ax = nexttile(innerTL);
        axByCond{i, ch} = ax;

        [tval, tfreq] = getspec(procChannelCell{ch}, fsData, winTime, en_pw, normfact);
        tval(1) = 0;

        if use_dB
            tvalPlot = 20 * log10(tval + eps);
            yLabelStr = 'Magnitude (dB)';
        else
            tvalPlot = tval;
            yLabelStr = 'Magnitude';
        end

        plot(ax, tfreq, tvalPlot, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.0);
        grid(ax, 'on');
        xlim(ax, xlimVal);

        title(ax, channelLabels{ch}, 'FontSize', 9);

        % 맨 아랫줄에만 x라벨
        if r == nRow
            xlabel(ax, 'Frequency (Hz)', 'FontWeight', 'bold');
        end

        % 각 블록의 첫 열에만 y라벨
        if ch == 1
            ylabel(ax, yLabelStr, 'FontWeight', 'bold');
        end
    end
end

% ── 블록 사이 구분선 ─────────────────────────────────────────────
% [중요] 중첩 tiledlayout 안의 axes는 Position/OuterPosition이
% "자기가 속한 안쪽 tiledlayout(타일)" 기준 좌표로 나옵니다.
% figure 전체 기준 절대 좌표가 필요하므로, 중첩 부모를 모두 타고
% 올라가 픽셀 좌표로 변환해주는 getpixelposition(ax, true)를 사용합니다.
drawnow;

condRow = [conditions.row];
condCol = [conditions.col];

% figure 크기(픽셀) 확보
figHandle = gcf;
origFigUnits = get(figHandle, 'Units');
set(figHandle, 'Units', 'pixels');
figPixPos = get(figHandle, 'Position');   % [left bottom width height], px
set(figHandle, 'Units', origFigUnits);
figW_px = figPixPos(3);
figH_px = figPixPos(4);

% 라벨(눈금/축이름)까지 포함한 "figure 기준 정규화 좌표" 계산 함수
outerPosFig = @(ax) localAxesOuterPosInFigure(ax, figW_px, figH_px);

allOuter = cell2mat(cellfun(outerPosFig, axByCond(:), 'UniformOutput', false));
fullLeft   = min(allOuter(:,1));
fullRight  = max(allOuter(:,1) + allOuter(:,3));
fullBottom = min(allOuter(:,2));
fullTop    = max(allOuter(:,2) + allOuter(:,4));

% 열(세로) 구분선: 블록 col 경계마다
for c = 1:(nCol - 1)

    leftCondIdx  = find(condCol == c);
    rightCondIdx = find(condCol == c + 1);

    leftEdges  = cellfun(@(a) getOne(outerPosFig(a), 1) + getOne(outerPosFig(a), 3), axByCond(leftCondIdx, end));
    rightEdges = cellfun(@(a) getOne(outerPosFig(a), 1), axByCond(rightCondIdx, 1));

    x = (max(leftEdges) + min(rightEdges)) / 2;

    annotation(figHandle, 'line', [x x], [fullBottom fullTop], ...
        'Color', [0.5 0.5 0.5], 'LineWidth', 1.2, 'LineStyle', '--');
end

% 행(가로) 구분선: 블록 row 경계마다
for r = 1:(nRow - 1)

    topCondIdx    = find(condRow == r);
    bottomCondIdx = find(condRow == r + 1);

    topEdges    = cellfun(@(a) getOne(outerPosFig(a), 2), axByCond(topCondIdx, 1));
    bottomEdges = cellfun(@(a) getOne(outerPosFig(a), 2) + getOne(outerPosFig(a), 4), axByCond(bottomCondIdx, 1));

    y = (min(topEdges) + max(bottomEdges)) / 2;

    annotation(figHandle, 'line', [fullLeft fullRight], [y y], ...
        'Color', [0.5 0.5 0.5], 'LineWidth', 1.2, 'LineStyle', '--');
end

end

% -------------------------------------------------------------------------
function v = getOne(posVec, idx)
% cellfun 안에서 4원소 벡터 중 하나만 뽑기 위한 도우미
v = posVec(idx);
end

% -------------------------------------------------------------------------
function pos = localAxesOuterPosInFigure(ax, figW_px, figH_px)
% 중첩된 tiledlayout 안에 있는 axes라도, getpixelposition(ax, true)로
% 부모 컨테이너를 모두 타고 올라가 figure 기준 절대 픽셀 좌표를 구한 뒤,
% TightInset(축 라벨/눈금이 차지하는 여백)까지 더해서 figure 정규화
% 좌표([left bottom width height], 0~1)로 변환합니다.

pixPos = getpixelposition(ax, true);   % figure 기준 절대 픽셀, [left bottom width height]

origAxUnits = get(ax, 'Units');
set(ax, 'Units', 'pixels');
ti = get(ax, 'TightInset');            % [left bottom right top], pixels
set(ax, 'Units', origAxUnits);

outerLeft   = pixPos(1) - ti(1);
outerBottom = pixPos(2) - ti(2);
outerWidth  = pixPos(3) + ti(1) + ti(3);
outerHeight = pixPos(4) + ti(2) + ti(4);

pos = [outerLeft / figW_px, outerBottom / figH_px, ...
       outerWidth / figW_px, outerHeight / figH_px];
end

% -------------------------------------------------------------------------
function [rawChannelCell, fsOut, info] = loadRawNChannel(basePath, targetDate, targetRPM, ...
                                                         condition, fsDefault, concatMode, tolRel)
% 폴더의 .mat 파일(signals: nCh x N)을 저장시각 순으로 읽고,
% 파일 간 중복 구간을 제거하면서 채널별로 연결합니다.
% ★ 채널 수는 첫 파일에서 자동으로 결정됩니다.

fullFolderPath = fullfile(basePath, targetDate, targetRPM, condition);
matFiles = dir(fullfile(fullFolderPath, '*.mat'));
if isempty(matFiles)
    error('지정된 경로에 .mat 파일이 존재하지 않습니다: %s', fullFolderPath);
end

% --- (1) 파일명 시각 파싱 후 정렬 ---
nF = numel(matFiles);
sortKey = zeros(nF, 2);
for k = 1:nF
    [sortKey(k,1), sortKey(k,2)] = parseStampFromName(matFiles(k).name, matFiles(k).datenum);
end
[sortKey, ord] = sortrows(sortKey, [1 2]);
matFiles = matFiles(ord);

% --- (2) 파일 읽기 (채널 수 자동 인식) ---
fsOut = fsDefault;
segByFile = cell(nF, 1);
nChRef = [];
for k = 1:nF
    matData = load(fullfile(matFiles(k).folder, matFiles(k).name));
    if ~isfield(matData, 'signals')
        error('%s: signals 변수가 없습니다.', matFiles(k).name);
    end
    segData = double(matData.signals);

    % 행=채널, 열=샘플 이 되도록 정렬 (채널 수 < 샘플 수 가정)
    if size(segData,1) > size(segData,2)
        segData = segData.';
    end

    if isempty(nChRef)
        nChRef = size(segData,1);
        fprintf('  채널 수 자동 인식: %d개\n', nChRef);
    elseif size(segData,1) ~= nChRef
        error('%s: 채널 수가 다릅니다 (%d, 기준 %d). 폴더에 다른 형식 파일이 섞여 있습니다.', ...
              matFiles(k).name, size(segData,1), nChRef);
    end

    if isfield(matData,'fs') && ~isempty(matData.fs)
        fsOut = double(matData.fs(1));
    end
    segByFile{k} = segData;
end
numChannels = nChRef;

% --- (3) 겹침 제거하며 연결 ---
acc = segByFile{1};
overlapList = zeros(max(nF-1,0), 1);
rawTotal = size(acc, 2);

for k = 2:nF
    seg = segByFile{k};
    rawTotal = rawTotal + size(seg, 2);

    if strcmpi(concatMode, 'raw')
        L = 0;
    else
        L = detectOverlap(acc, seg, tolRel);
    end
    overlapList(k-1) = L;

    if L >= size(seg,2), continue; end
    acc = [acc, seg(:, L+1:end)];   %#ok<AGROW>
end

rawChannelCell = cell(numChannels, 1);
for ch = 1:numChannels
    rawChannelCell{ch} = acc(ch, :).';
end

% --- (4) 요약 ---
uniqLen = size(acc, 2);
info = struct('numFiles', nF, 'numCh', numChannels, 'fs', fsOut, ...
              'rawSamples', rawTotal, 'uniqueSamples', uniqLen, 'folder', fullFolderPath);

fprintf('  -> %d개 파일, %d채널 로드 (%s)\n', nF, numChannels, fullFolderPath);
fprintf('     fs = %g Hz, 파일당 %d 샘플 (%.3f초)\n', ...
        fsOut, size(segByFile{1},2), size(segByFile{1},2)/fsOut);
if nF > 1
    if any(overlapList > 0)
        hops = zeros(nF-1,1);
        for k = 1:nF-1
            hops(k) = size(segByFile{k+1},2) - overlapList(k);
        end
        fprintf('     [겹침 감지] 중복 = %s 샘플,  hop 평균 %.4f초\n', ...
                mat2str(overlapList.'), mean(hops)/fsOut);
        fprintf('     단순연결 %d샘플 -> 중복제거 %d샘플 (%.1f%% 제거, 유효 %.3f초)\n', ...
                rawTotal, uniqLen, 100*(1-uniqLen/rawTotal), uniqLen/fsOut);
    else
        fprintf('     [겹침 없음] 연결 %d샘플 (%.3f초)\n', uniqLen, uniqLen/fsOut);
        gap = diff(sortKey(:,1))*86400 + diff(sortKey(:,2));
        if any(gap > 1.5*size(segByFile{1},2)/fsOut)
            fprintf('     [주의] 파일 사이 시간 공백 있음 (평균 %.2f초). 불연속 연결입니다.\n', mean(gap));
        end
    end
end
end

% -------------------------------------------------------------------------
function L = detectOverlap(acc, seg, tolRel)
M = min(size(acc,2), size(seg,2));
if M < 1, L = 0; return; end

scale = max(abs(seg(:)));
if scale <= 0, scale = 1; end
tol = tolRel * scale;

tail = acc(:, end-M+1:end);
cand = find(abs(tail(1,:) - seg(1,1)) <= tol);
cand = sort(M - cand + 1, 'descend');

for i = 1:numel(cand)
    L = cand(i);
    if max(max(abs(tail(:, end-L+1:end) - seg(:, 1:L)))) <= tol
        return;
    end
end
L = 0;
end

% -------------------------------------------------------------------------
function [dnum, secOfDay] = parseStampFromName(name, fallbackDatenum)
tok = regexp(name, '^(\d{8})_(\d{2})(\d{2})(\d{2})(?:_(\d{1,3}))?(?:_(\d+))?', 'tokens', 'once');
if isempty(tok)
    dnum = floor(fallbackDatenum);
    secOfDay = (fallbackDatenum - floor(fallbackDatenum)) * 86400;
    return;
end
dnum = datenum(tok{1}, 'yyyymmdd');
ms = 0;
if numel(tok) >= 5 && ~isempty(tok{5})
    ms = str2double(tok{5}) / 1000;
end
secOfDay = str2double(tok{2})*3600 + str2double(tok{3})*60 + str2double(tok{4}) + ms;
end

% -------------------------------------------------------------------------
function procChannelCell = applyProcessing(rawChannelCell, fs, processtype, bpLo, bpHi)
numChannels = numel(rawChannelCell);
procChannelCell = cell(numChannels, 1);
if processtype == 2
    [b,a] = butter(4, [bpLo bpHi]/(fs/2), 'bandpass');
end
for ch = 1:numChannels
    seg = rawChannelCell{ch};
    seg = seg - mean(seg);
    switch processtype
        case 1
            [seg, ~] = convmeas(seg, fs, 'vel');
        case 2
            seg = filtfilt(b, a, seg);
            seg = abs(hilbert(seg));
    end
    seg = seg - mean(seg);
    procChannelCell{ch} = seg;
end
end




% %% N채널 스펙트럼 - Raw/속도변환/포락 3가지를 각각 별도 화면에 표시
% %
% % [v3 변경사항]
% %  1) 채널 수 고정(9) 해제 -> 파일의 signals 행 개수를 그대로 사용합니다.
% %     3채널이든 9채널이든 코드 수정 없이 동작합니다.
% %  2) 서브플롯 격자를 채널 수에 맞춰 자동 계산합니다.
% %     (3채널 -> 1x3,  9채널 -> 3x3,  그 외도 자동)
% %  3) 채널 라벨을 아래 표에서 채널 수로 자동 선택합니다.
% %
% % [v2 기능 유지]
% %  - 파일명 형식 2종 지원: YYYYMMDD_HHMMSS_Vib.mat / YYYYMMDD_HHMMSS_mmm[_N]_Vib.mat
% %  - 파일 간 겹침(슬라이딩 윈도우 저장) 자동 탐지 및 중복 제거
% 
% %% 1. 경로 및 설정
% basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data';
% targetDate = '260812';
% targetRPM = '40';
% targetCondition = fullfile('기어드결함_후진', 'Vib');   % [변수] 불러올 상태 폴더
% 
% fs = 3200;
% en_pw = 0;
% normfact = 1;
% xlimVal = [0 400];
% winTime = 4;          % Δf = 1/winTime = 0.25 Hz
% use_dB = 0;
% 
% % ── 채널 라벨 (채널 수에 따라 자동 선택) ────────────────────────────
% labels9 = {'Motor-X','Motor-Y','Motor-Z', ...
%            'Reducer-X','Reducer-Y','Reducer-Z', ...
%            'Bearing-X','Bearing-Y','Bearing-Z'};
% labels3 = {'GearedMotor-X','GearedMotor-Y','GearedMotor-Z'};   % ★ 3채널일 때 쓸 이름
% % ─────────────────────────────────────────────────────────────────
% 
% % ── 포락용 대역통과 필터 ────────────────────────────────────────────
% bpLo = 900;  bpHi = 1300;
% % ─────────────────────────────────────────────────────────────────
% 
% % ── 파일 이어붙이기 방식 ────────────────────────────────────────────
% %   'auto' : 겹침 자동 탐지 후 중복 제거 (권장)
% %   'raw'  : 무조건 이어붙임 (검증용)
% concatMode = 'auto';
% overlapTolRel = 1e-9;
% % ─────────────────────────────────────────────────────────────────
% 
% processTypesToRun = [0, 1, 2];   % 0:Raw, 1:속도변환, 2:포락
% 
% %% 2. 데이터 로드 (채널 수 자동 인식 + 겹침 제거)
% fprintf('=== 원본 데이터 로드 중 (%s) ===\n', targetCondition);
% [rawChannelCell, fsData, loadInfo] = loadRawNChannel(basePath, targetDate, targetRPM, ...
%     targetCondition, fs, concatMode, overlapTolRel);
% 
% nCh = numel(rawChannelCell);
% 
% % --- 채널 수에 맞는 라벨 선택 ---
% switch nCh
%     case 9,  channelLabels = labels9;
%     case 3,  channelLabels = labels3;
%     otherwise
%         channelLabels = arrayfun(@(k) sprintf('CH%d', k), 1:nCh, 'UniformOutput', false);
%         warning('채널 수 %d에 대한 라벨 정의가 없어 CH1..CH%d로 표시합니다.', nCh, nCh);
% end
% if numel(channelLabels) ~= nCh
%     error('라벨 개수(%d)와 채널 수(%d)가 다릅니다. labels%d 를 확인하세요.', ...
%           numel(channelLabels), nCh, nCh);
% end
% 
% % --- 서브플롯 격자 자동 계산 ---
% [nRow, nCol] = pickGrid(nCh);
% fprintf('  -> %d채널, 서브플롯 %dx%d 배치\n', nCh, nRow, nCol);
% 
% % --- 해상도 확보 확인 ---
% totalLen = numel(rawChannelCell{1});
% if totalLen < round(winTime * fsData)
%     warning(['총 유효 길이 %.3f초 < winTime %.3f초 입니다. ' ...
%              'winTime을 줄이거나 파일을 더 모아야 합니다.'], totalLen/fsData, winTime);
% end
% 
% %% 3. processtype 순차 적용
% for pt = processTypesToRun
%     switch pt
%         case 0, processLabel = 'Raw Signal';
%         case 1, processLabel = 'Velocity Converted';
%         case 2, processLabel = 'Envelope Signal';
%         otherwise, error('잘못된 processtype입니다.');
%     end
% 
%     fprintf('=== [%s] 전처리 및 플롯 중 ===\n', processLabel);
%     procChannelCell = applyProcessing(rawChannelCell, fsData, pt, bpLo, bpHi);
% 
%     plotChannels(procChannelCell, fsData, nRow, nCol, channelLabels, ...
%                  winTime, en_pw, normfact, use_dB, xlimVal, processLabel, ...
%                  targetDate, targetCondition, loadInfo);
% end
% 
% %% ===================== 로컬 함수 =====================
% function [nRow, nCol] = pickGrid(n)
% % 채널 수에 맞는 서브플롯 격자 (가로로 넓게)
% switch n
%     case 1, nRow = 1; nCol = 1;
%     case 2, nRow = 1; nCol = 2;
%     case 3, nRow = 1; nCol = 3;
%     case 4, nRow = 2; nCol = 2;
%     case {5,6}, nRow = 2; nCol = 3;
%     case {7,8,9}, nRow = 3; nCol = 3;
%     otherwise
%         nCol = ceil(sqrt(n));
%         nRow = ceil(n / nCol);
% end
% end
% 
% % -------------------------------------------------------------------------
% function [rawChannelCell, fsOut, info] = loadRawNChannel(basePath, targetDate, targetRPM, ...
%                                                          condition, fsDefault, concatMode, tolRel)
% % 폴더의 .mat 파일(signals: nCh x N)을 저장시각 순으로 읽고,
% % 파일 간 중복 구간을 제거하면서 채널별로 연결합니다.
% % ★ 채널 수는 첫 파일에서 자동으로 결정됩니다.
% 
% fullFolderPath = fullfile(basePath, targetDate, targetRPM, condition);
% matFiles = dir(fullfile(fullFolderPath, '*.mat'));
% if isempty(matFiles)
%     error('지정된 경로에 .mat 파일이 존재하지 않습니다: %s', fullFolderPath);
% end
% 
% % --- (1) 파일명 시각 파싱 후 정렬 ---
% nF = numel(matFiles);
% sortKey = zeros(nF, 2);
% for k = 1:nF
%     [sortKey(k,1), sortKey(k,2)] = parseStampFromName(matFiles(k).name, matFiles(k).datenum);
% end
% [sortKey, ord] = sortrows(sortKey, [1 2]);
% matFiles = matFiles(ord);
% 
% % --- (2) 파일 읽기 (채널 수 자동 인식) ---
% fsOut = fsDefault;
% segByFile = cell(nF, 1);
% nChRef = [];
% for k = 1:nF
%     matData = load(fullfile(matFiles(k).folder, matFiles(k).name));
%     if ~isfield(matData, 'signals')
%         error('%s: signals 변수가 없습니다.', matFiles(k).name);
%     end
%     segData = double(matData.signals);
% 
%     % 행=채널, 열=샘플 이 되도록 정렬 (채널 수 < 샘플 수 가정)
%     if size(segData,1) > size(segData,2)
%         segData = segData.';
%     end
% 
%     if isempty(nChRef)
%         nChRef = size(segData,1);
%         fprintf('  채널 수 자동 인식: %d개\n', nChRef);
%     elseif size(segData,1) ~= nChRef
%         error('%s: 채널 수가 다릅니다 (%d, 기준 %d). 폴더에 다른 형식 파일이 섞여 있습니다.', ...
%               matFiles(k).name, size(segData,1), nChRef);
%     end
% 
%     if isfield(matData,'fs') && ~isempty(matData.fs)
%         fsOut = double(matData.fs(1));
%     end
%     segByFile{k} = segData;
% end
% numChannels = nChRef;
% 
% % --- (3) 겹침 제거하며 연결 ---
% acc = segByFile{1};
% overlapList = zeros(max(nF-1,0), 1);
% rawTotal = size(acc, 2);
% 
% for k = 2:nF
%     seg = segByFile{k};
%     rawTotal = rawTotal + size(seg, 2);
% 
%     if strcmpi(concatMode, 'raw')
%         L = 0;
%     else
%         L = detectOverlap(acc, seg, tolRel);
%     end
%     overlapList(k-1) = L;
% 
%     if L >= size(seg,2), continue; end
%     acc = [acc, seg(:, L+1:end)];   %#ok<AGROW>
% end
% 
% rawChannelCell = cell(numChannels, 1);
% for ch = 1:numChannels
%     rawChannelCell{ch} = acc(ch, :).';
% end
% 
% % --- (4) 요약 ---
% uniqLen = size(acc, 2);
% info = struct('numFiles', nF, 'numCh', numChannels, 'fs', fsOut, ...
%               'rawSamples', rawTotal, 'uniqueSamples', uniqLen, 'folder', fullFolderPath);
% 
% fprintf('  -> %d개 파일, %d채널 로드 (%s)\n', nF, numChannels, fullFolderPath);
% fprintf('     fs = %g Hz, 파일당 %d 샘플 (%.3f초)\n', ...
%         fsOut, size(segByFile{1},2), size(segByFile{1},2)/fsOut);
% if nF > 1
%     if any(overlapList > 0)
%         hops = zeros(nF-1,1);
%         for k = 1:nF-1
%             hops(k) = size(segByFile{k+1},2) - overlapList(k);
%         end
%         fprintf('     [겹침 감지] 중복 = %s 샘플,  hop 평균 %.4f초\n', ...
%                 mat2str(overlapList.'), mean(hops)/fsOut);
%         fprintf('     단순연결 %d샘플 -> 중복제거 %d샘플 (%.1f%% 제거, 유효 %.3f초)\n', ...
%                 rawTotal, uniqLen, 100*(1-uniqLen/rawTotal), uniqLen/fsOut);
%     else
%         fprintf('     [겹침 없음] 연결 %d샘플 (%.3f초)\n', uniqLen, uniqLen/fsOut);
%         gap = diff(sortKey(:,1))*86400 + diff(sortKey(:,2));
%         if any(gap > 1.5*size(segByFile{1},2)/fsOut)
%             fprintf('     [주의] 파일 사이 시간 공백 있음 (평균 %.2f초). 불연속 연결입니다.\n', mean(gap));
%         end
%     end
% end
% end
% 
% % -------------------------------------------------------------------------
% function L = detectOverlap(acc, seg, tolRel)
% M = min(size(acc,2), size(seg,2));
% if M < 1, L = 0; return; end
% 
% scale = max(abs(seg(:)));
% if scale <= 0, scale = 1; end
% tol = tolRel * scale;
% 
% tail = acc(:, end-M+1:end);
% cand = find(abs(tail(1,:) - seg(1,1)) <= tol);
% cand = sort(M - cand + 1, 'descend');
% 
% for i = 1:numel(cand)
%     L = cand(i);
%     if max(max(abs(tail(:, end-L+1:end) - seg(:, 1:L)))) <= tol
%         return;
%     end
% end
% L = 0;
% end
% 
% % -------------------------------------------------------------------------
% function [dnum, secOfDay] = parseStampFromName(name, fallbackDatenum)
% tok = regexp(name, '^(\d{8})_(\d{2})(\d{2})(\d{2})(?:_(\d{1,3}))?(?:_(\d+))?', 'tokens', 'once');
% if isempty(tok)
%     dnum = floor(fallbackDatenum);
%     secOfDay = (fallbackDatenum - floor(fallbackDatenum)) * 86400;
%     return;
% end
% dnum = datenum(tok{1}, 'yyyymmdd');
% ms = 0;
% if numel(tok) >= 5 && ~isempty(tok{5})
%     ms = str2double(tok{5}) / 1000;
% end
% secOfDay = str2double(tok{2})*3600 + str2double(tok{3})*60 + str2double(tok{4}) + ms;
% end
% 
% % -------------------------------------------------------------------------
% function procChannelCell = applyProcessing(rawChannelCell, fs, processtype, bpLo, bpHi)
% numChannels = numel(rawChannelCell);
% procChannelCell = cell(numChannels, 1);
% if processtype == 2
%     [b,a] = butter(4, [bpLo bpHi]/(fs/2), 'bandpass');
% end
% for ch = 1:numChannels
%     seg = rawChannelCell{ch};
%     seg = seg - mean(seg);
%     switch processtype
%         case 1
%             [seg, ~] = convmeas(seg, fs, 'vel');
%         case 2
%             seg = filtfilt(b, a, seg);
%             seg = abs(hilbert(seg));
%     end
%     seg = seg - mean(seg);
%     procChannelCell{ch} = seg;
% end
% end
% 
% % -------------------------------------------------------------------------
% function plotChannels(channelCell, fsData, nRow, nCol, channelLabels, ...
%     winTime, en_pw, normfact, use_dB, xlimVal, processLabel, targetDate, targetCondition, info)
% 
% nCh = numel(channelCell);
% 
% % 채널 수에 맞춰 창 크기 조절
% figW = min(500*nCol, 1600);
% figH = min(340*nRow + 120, 1000);
% figure('Name', sprintf('%d채널 [%s]', nCh, processLabel), 'NumberTitle', 'off', ...
%        'Position', [60 40 figW figH]);
% 
% for ch = 1:nCh
%     subplot(nRow, nCol, ch);
% 
%     [tval, tfreq] = getspec(channelCell{ch}, fsData, winTime, en_pw, normfact);
%     tval(1) = 0;
% 
%     if use_dB
%         tvalPlot = 20 * log10(tval + eps);
%         yLabelStr = 'Magnitude (dB)';
%     else
%         tvalPlot = tval;
%         yLabelStr = 'Magnitude';
%     end
% 
%     plot(tfreq, tvalPlot, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.0);
%     grid on;
%     title(channelLabels{ch}, 'FontSize', 10);
%     xlim(xlimVal);
% 
%     % 맨 아랫줄에만 x라벨, 맨 왼쪽 열에만 y라벨
%     if ch > (nRow-1)*nCol
%         xlabel('Frequency (Hz)', 'FontWeight', 'bold');
%     end
%     if mod(ch-1, nCol) == 0
%         ylabel(yLabelStr, 'FontWeight', 'bold');
%     end
% end
% 
% sgtitle(sprintf(['%d채널 스펙트럼 - %s [%s / %s]\n' ...
%                  '파일 %d개 / 유효 %.2f초 / Δf = %.3f Hz'], ...
%         nCh, processLabel, targetDate, targetCondition, ...
%         info.numFiles, info.uniqueSamples/info.fs, 1/winTime), ...
%         'FontSize', 12, 'FontWeight', 'bold');
% end