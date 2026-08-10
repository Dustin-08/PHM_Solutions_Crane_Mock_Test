%% 9채널(Motor/Reducer/Bearing x X,Y,Z) - 한 조건만 로드해서 한 화면(3x3)에 표시
% 3행(X/Y/Z축) x 3열(Motor/Reducer/Bearing) = 9개 subplot을 한 figure에 그립니다.
%
% ============================== v4 수정 사항 ==============================
%  [문제 진단 - 실제 데이터(등속5) 재분석 결과]
%   1) tolerancePercent(5%)와 주파수분해능 df(=1/winTime)가 충돌.
%        halfWidth = max(fTarget*tol/100, df) 공식에서
%        fTarget < df/tol*100 (예: winTime=1.5s -> df=0.667Hz -> 임계값 13.3Hz)
%        인 채널(Bearing 1.17Hz, Reducer 11.67Hz 등 9채널 중 6채널!)은
%        tolerance%가 무시되고 halfWidth가 df로 고정 -> 탐색폭이 FFT bin
%        1~3개로 쪼그라들어 "피크 탐색"이 아니라 "근처 bin 아무거나 줍기"가 됨.
%        (실측: Bearing X/Y/Z가 채널과 무관하게 전부 1.333/2.000/4.000Hz라는
%         동일 grid 값에 찍힘 -> 실신호가 아니라 quantization 증거)
%   2) 이 좁은 창 안에서 저주파 broadband 성분(모든 채널에 공통으로 나타나는
%      DC 인접 에너지)이 계속 "1X"로 오검출됨.
%   3) 단순 max()는 노이즈 튐이나 broadband 성분을 "피크"로 오인하기 쉬움
%      -> findpeaks(prominence 기준)로 국소 최댓값 우선 채택, 없으면 fallback.
%   4) 1X 검출용 tolerance와 2X/3X(고조파) 탐색용 tolerance를 분리.
%      1X는 슬립/이론값 오차를 감안해 넓게 + 절대 최소대역폭(Hz) 보장.
%      고조파는 검출된 1X 기준 배수라서 상대적으로 좁게 탐색.
%   5) winTime을 1.5s -> 3.0s로 늘려 df를 0.667Hz -> 0.333Hz로 개선
%      (데이터 총 길이가 12s이므로 가능). 저주파(Bearing) 채널의 유효 bin
%      개수가 늘어나 "진짜 탐색"이 가능해짐. (파일 개수가 적어 평균 횟수는
%      줄지만, 저RPM 채널에서는 분해능 확보가 더 중요)
%   6) 1X/2X/3X 텍스트 라벨이 서로 겹쳐 안 보이던 문제 -> order별 y오프셋 부여.
%   7) (참고, 버그 아님) Bearing-Y의 ~170Hz 부근 큰 피크는 1X~3X 오더트래킹
%      범위(약 1~3.5Hz) 밖의 신호라서 이 알고리즘의 탐색 대상이 아닙니다.
%      기어치합/공진 성분일 가능성이 있어 별도로 다뤄야 합니다.
%   8) (참고) Reducer 채널 실측 피크가 이론 1X(11.667Hz)보다 20~21Hz 부근에서
%      더 강하게 나타남 -> beltRatio/finalRatio 재검증을 권장합니다.
% ============================================================================

%% 1. 경로 및 설정
basePath = '/Users/dustin08/Documents/Github/PHM_Solutions_Crane_Mock_Test/Data'; % 경로수정
targetDate = '260807';
targetRPM = '70';                     % <- 엑셀의 "부하측 RPM"과 동일한 값을 사용
targetCondition = fullfile('등속5', 'Vib');   % [변수] 불러올 상태 폴더

fs = 3200;
en_pw = 0;
normfact = 1;
processtype = 2;      % 0: Raw, 1: 속도변환('vel'), 2: 포락(Envelope)
xlimVal = [1 300];     % 그래프에 실제로 표시되는 주파수 범위 (탐색범위도 이 안으로 제한됨)
winTime = 3.0;         % [수정] 1.5 -> 3.0s : df를 0.667Hz -> 0.333Hz로 개선(저주파 채널 분해능 확보)
use_dB = 0;

% 채널 배치: row 1,2,3=Motor / 4,5,6=Reducer / 7,8,9=Bearing
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

%% 1-1. 엑셀 계산기 기준 1X 기준 주파수 산출 (구동계_진동_계산기.xlsx 참고)
%   D9  = 0.5833  (모터출력측 -> 벨트연결측 구간비)
%   D10 = 0.1     (벨트연결측 -> 부하측 구간비)   ※ 모터->부하측 전체비가 아님!
beltRatio  = 0.5833;   % 엑셀 D9
finalRatio = 0.1;      % 엑셀 D10 (벨트축->부하측 구간비)

loadRPM  = str2double(targetRPM);              % 부하측 RPM (= 폴더명, Bearing 위치) = 70
motorRPM = loadRPM / (beltRatio * finalRatio);  % 모터출력측 RPM (= Motor 위치)   -> 1200
beltRPM  = motorRPM * beltRatio;                % 벨트연결측 RPM (= Reducer 위치) -> 700

% 열(Motor/Reducer/Bearing) 순서와 매칭되는 1X 기준 주파수(Hz)
f1x_col = [motorRPM, beltRPM, loadRPM] / 60;    % [20, 11.667, 1.167] Hz

% [수정] 1X 탐색용 tolerance(넓게, 슬립/이론오차 감안) vs 고조파 탐색용 tolerance(좁게)
baseTolerancePercent      = 15;    % 1X 탐색 - 상대 오차 허용치(%)
harmonicTolerancePercent  = 6;     % 2X,3X 탐색 - 검출된 1X 배수 기준 상대 오차(%)
minBandwidthHz            = 1.0;   % [신규] 1X 탐색용 절대 최소 반폭(Hz). df에만 의존하지 않도록 하한을 둠
harmonicMaxWidthFraction  = 0.4;   % [v5 신규] 고조파 탐색 반폭 상한 = detectedF1x * 이 비율
                                    %   (예: detectedF1x=1.333Hz -> 반폭<=0.53Hz -> 2X/3X 창이 서로 안 겹침)
minPeakProminenceRatio    = 0.15;  % [신규] findpeaks prominence 기준 = 구간 내 최댓값의 15%

harmonicOrders   = 1:3;    % 표시할 하모닉 차수 (1X, 2X, 3X). 필요시 1:5 등으로 확장
harmonicColors   = [1 0 0; 0.85 0.33 0.10; 0.47 0.67 0.19; 0 0.45 0.74; 0.49 0.18 0.56];

fprintf('=== 1X 기준 주파수 (1X tol=±%.1f%%, 고조파 tol=±%.1f%%, 최소대역폭=%.2fHz, 탐색범위 %.1f~%.1fHz) ===\n', ...
    baseTolerancePercent, harmonicTolerancePercent, minBandwidthHz, xlimVal(1), xlimVal(2));
fprintf('  Motor   1X = %.4f Hz (RPM=%.2f)\n', f1x_col(1), motorRPM);
fprintf('  Reducer 1X = %.4f Hz (RPM=%.2f)\n', f1x_col(2), beltRPM);
fprintf('  Bearing 1X = %.4f Hz (RPM=%.2f)\n', f1x_col(3), loadRPM);

%% 2. 데이터 로드 + 전처리 (한 조건만)
fprintf('=== 데이터 로드 중 (%s) ===\n', targetCondition);
[channelCell, fsData] = loadAndProcess9Channel(basePath, targetDate, targetRPM, targetCondition, fs, processtype);

%% 3. 9채널을 한 화면(3x3)에 표시 + 1X/2X/3X 피크 검출/표시
figure('Name', sprintf('9채널 [%s]', processLabel), 'NumberTitle', 'off', 'Position', [60 40 1400 1000]);

resultRows = {};   % {Channel, Order, TargetFreq, DetectedFreq, DetectedVal}

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

        %% [1X/2X/3X 검출 및 표시] - 1X는 탐색구간 내 "진짜 국소 피크" 우선 채택
        f0 = f1x_col(c);
        detectedF1x = NaN;   % 검출된 1X (배수 탐색의 기준으로 사용)

        % [v5 신규] 라벨은 데이터 좌표에 흩뿌리지 않고, 검출 결과를 모아뒀다가
        % subplot 우측상단에 고정된 텍스트 박스 하나로 표시 -> 겹침 문제 원천 차단
        detectedList = {};  % {order, freq, val, colorIdx, found}

        hold on;
        for hIdx = 1:numel(harmonicOrders)
            n = harmonicOrders(hIdx);

            if n == 1 || isnan(detectedF1x)
                fTarget = n * f0;              % 이론값 기반 (1X, 또는 1X 검출 실패시)
                tolPct  = baseTolerancePercent;
                maxHalfWidth = Inf;             % 1X는 폭 상한 없음
            else
                fTarget = n * detectedF1x;     % 검출된 1X의 배수 기반 (슬립 등 오차 반영)
                tolPct  = harmonicTolerancePercent;
                % [v5 핵심 수정] 고조파 탐색 반폭은 오더 간격(detectedF1x)을 넘지 않도록 캡을 씌움.
                % 이게 없으면 저주파(예: Bearing 1X~1.3Hz) 채널에서 2X/3X 탐색창이 서로 겹쳐
                % 같은 피크를 중복 검출하는 문제가 생김(예: 2X, 3X가 똑같은 주파수로 찍히는 버그).
                maxHalfWidth = harmonicMaxWidthFraction * detectedF1x;
            end

            [peakFreq, peakVal, found] = findPeakNearFreq(tfreq, tvalPlot, fTarget, tolPct, ...
                                                            xlimVal, minBandwidthHz, minPeakProminenceRatio, maxHalfWidth);

            if found
                if n == 1
                    detectedF1x = peakFreq;
                end
                plot(peakFreq, peakVal, 'o', 'MarkerSize', 7, ...
                     'MarkerEdgeColor', harmonicColors(hIdx,:), 'MarkerFaceColor', harmonicColors(hIdx,:));
                resultRows(end+1,:) = {channelLabels{ch}, n, fTarget, peakFreq, peakVal}; %#ok<SAGROW>
            else
                resultRows(end+1,:) = {channelLabels{ch}, n, fTarget, NaN, NaN}; %#ok<SAGROW>
                if n == 1
                    warning('[%s] 1X 탐색 실패 (목표 %.4f Hz 근처 표시범위 내 데이터 없음)', channelLabels{ch}, fTarget);
                end
            end
            detectedList(end+1,:) = {n, peakFreq, peakVal, hIdx, found}; %#ok<SAGROW>
        end
        hold off;

        % [v5 신규] 우측상단 고정 텍스트 박스에 결과 정리해서 표시 (겹침 없음, 항상 가독)
        lines = {};
        lineColors = {};
        for i = 1:size(detectedList,1)
            n = detectedList{i,1}; fD = detectedList{i,2}; okD = detectedList{i,5}; hIdx = detectedList{i,4};
            if okD
                lines{end+1} = sprintf('%dX: %.3f Hz', n, fD); %#ok<SAGROW>
            else
                lines{end+1} = sprintf('%dX: 미검출', n); %#ok<SAGROW>
            end
            lineColors{end+1} = harmonicColors(hIdx,:); %#ok<SAGROW>
        end
        for i = 1:numel(lines)
            text(0.98, 0.98 - (i-1)*0.09, lines{i}, 'Units', 'normalized', ...
                 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', ...
                 'FontSize', 8, 'FontWeight', 'bold', 'Color', lineColors{i}, ...
                 'BackgroundColor', [1 1 1 0.65], 'Margin', 0.5);
        end
    end
end

sgtitle(sprintf('9채널 스펙트럼 - %s [%s / %s]  (행:X/Y/Z축 라벨, 열:Motor/Reducer/Bearing)', ...
        processLabel, targetDate, targetCondition), 'FontSize', 13, 'FontWeight', 'bold');

%% [결과 표 출력]
peakResults = cell2table(resultRows, ...
    'VariableNames', {'Channel','Order','Target_Hz','Detected_Hz','Detected_Val'});
disp('=== 채널별 1X/2X/3X 검출 결과 ===');
disp(peakResults);

%% [v7 수정] 이론값에 의존하지 않는 "데이터 기반 실제 1X 추정" - 국소 피크 매칭 방식
%   [v6 문제점] 이전 버전은 후보 f0의 배수 위치 진폭을 그냥 곱하는 방식(HPS)이었는데,
%     envelope 스펙트럼 특유의 저주파 broadband 에너지(1.333/2.667/4.0Hz 등)에
%     크게 낚여서 Motor-Y/Z처럼 명백히 엉뚱한 값(1.333Hz)을 "실측 1X"로 잘못 추정함.
%     -> 진폭을 곱하는 방식이 아니라, "진짜 국소 피크들끼리 배수 관계가 맞는지"를
%        매칭하는 방식(peak-matching)으로 교체. 노이즈/broadband에 훨씬 강함.
fprintf('\n=== [교차검증] 이론 1X vs 데이터 기반 추정 1X (국소피크 매칭 방식) ===\n');
hpsSearchRange = [1 60];   % 기본주파수 후보를 탐색할 범위(Hz) - 필요시 조정
hpsNumHarmonics = 5;       % 몇 차 배수까지 매칭해서 점수를 매길지
hpsMatchTolPercent = 4;    % 배수 매칭 허용 오차(%)
hpsPeakProminenceRatio = 0.10;  % 후보로 인정할 최소 prominence(구간 내 최댓값 대비 비율)

for r2 = 1:3
    for c2 = 1:3
        ch2 = gridChannelIdx(r2, c2);
        [tval2, tfreq2] = getspec(channelCell{ch2}, fsData, winTime, en_pw, normfact);
        tval2(1) = 0;
        f0est = estimateFundamentalPeakMatch(tfreq2, tval2, hpsSearchRange, hpsNumHarmonics, ...
                                              xlimVal, hpsMatchTolPercent, hpsPeakProminenceRatio);
        f0theory = f1x_col(c2);
        if isnan(f0est)
            fprintf('  %-10s : 이론 1X=%7.3fHz  |  실측 기반 추정 1X= (유효 피크 없음)\n', ...
                channelLabels{ch2}, f0theory);
        else
            diffPct = 100 * (f0est - f0theory) / f0theory;
            fprintf('  %-10s : 이론 1X=%7.3fHz  |  실측 기반 추정 1X=%7.3fHz  (차이 %+.1f%%)\n', ...
                channelLabels{ch2}, f0theory, f0est, diffPct);
        end
    end
end
fprintf('  (참고) 차이가 ±20%%를 크게 넘으면 이론 감속비/센서 위치 가정을 재검토해보시길 권장합니다.\n');

%% ===================== 로컬 함수 =====================
function f0est = estimateFundamentalPeakMatch(tfreq, tvalPlot, searchRange, numHarmonics, ...
                                                xlimVal, matchTolPercent, peakProminenceRatio)
% 이론값과 무관하게, "실제 국소 피크들끼리 정수배 관계가 맞는지"를 매칭해서
% 가장 그럴듯한 기본주파수를 추정한다.
%  [v8 수정]
%   - 배수매칭이 1개만 우연히 맞아도 후보로 인정되던 문제 -> 최소 2개 이상 요구.
%     (Bearing처럼 단일 스파이크만 있고 하모닉 시리즈가 없는 채널에서 노이즈의
%      우연한 일치를 "1X"로 잘못 뽑던 버그 수정)
%   - 동점(매칭 개수 같음) 처리 시 진폭 합이 큰 쪽을 우선하던 게 "옥타브 오류"
%     (2X를 1X로 착각)를 유발 -> 매칭 개수가 근접(차이<=1)하면 더 낮은 주파수를
%     우선하도록 변경 (진짜 1X는 보통 2X/3X보다 매칭개수가 같거나 비슷함).
%   - 위 기준을 만족하는 후보가 전혀 없으면(신뢰 불가) NaN 대신, 스펙트럼에서
%     가장 뚜렷한 단일 피크를 fallback으로 반환(하모닉 시리즈가 없는 신호에도
%     의미있는 정보를 줌).
mask = tfreq >= xlimVal(1) & tfreq <= xlimVal(2);
f_r = tfreq(mask); v_r = tvalPlot(mask);
if numel(v_r) < 5
    f0est = NaN; return;
end

globalMax = max(v_r);
minProm = max(globalMax * peakProminenceRatio, eps);
try
    [pkVals, pkLocs] = findpeaks(v_r, 'MinPeakProminence', minProm);
catch
    pkVals = []; pkLocs = [];
end
if isempty(pkVals)
    f0est = NaN; return;
end
peakFreqs = f_r(pkLocs);
peakVals  = pkVals;

% 후보 기본주파수 = searchRange 안에 있는 피크들만
candMask = peakFreqs >= searchRange(1) & peakFreqs <= searchRange(2);
candFreqs = peakFreqs(candMask);
if isempty(candFreqs)
    f0est = NaN; return;
end
[candFreqs, sortIdx] = sort(candFreqs);   % 낮은 주파수부터 평가(동점시 낮은 쪽 우선 로직과 맞춤)

minRequiredMatches = 2;   % [v8] 최소 이만큼은 배수매칭이 있어야 신뢰
bestScore = -1; bestAmp = -Inf; f0est = NaN;
for i = 1:numel(candFreqs)
    f0 = candFreqs(i);
    matches = 0;
    matchAmp = 0;
    for n = 2:numHarmonics
        target = n * f0;
        if target > xlimVal(2)
            break;
        end
        [diffHz, relIdx] = min(abs(peakFreqs - target));
        if (diffHz / target) * 100 <= matchTolPercent
            matches = matches + 1;
            matchAmp = matchAmp + peakVals(relIdx);
        end
    end
    if matches < minRequiredMatches
        continue;   % [v8] 매칭 2개 미만이면 후보에서 제외(노이즈 우연매칭 배제)
    end
    % [v8] 매칭 개수가 현재 최고와 근접(<=1 차이)하면 "더 낮은 주파수" 우선(옥타브 오류 방지)
    if matches > bestScore + 1
        bestScore = matches; bestAmp = matchAmp; f0est = f0;
    elseif matches >= bestScore - 1 && isnan(f0est)
        bestScore = max(bestScore, matches); bestAmp = matchAmp; f0est = f0;
    end
    % 낮은 주파수부터 순회하므로, 이미 답이 정해진 뒤에는 비슷하거나 낮은 점수의
    % 더 높은 주파수 후보로 덮어쓰지 않음(자연스럽게 최저 f0가 우선됨).
end

if isnan(f0est)
    % [v8 신규] 신뢰할 만한 배수매칭 후보가 없으면, 가장 뚜렷한 단일 피크를 반환
    [~, maxIdx] = max(peakVals);
    f0est = peakFreqs(maxIdx);
end
end

function [peakFreq, peakVal, found] = findPeakNearFreq(tfreq, tvalPlot, fTarget, tolerancePercent, ...
                                                         xlimVal, minBandwidthHz, minPeakProminenceRatio, maxHalfWidth)
% fTarget 근처 구간에서 "진짜 국소 피크"를 찾는다.
%  [v4 변경점]
%   - 대역폭 하한을 df뿐 아니라 절대값(minBandwidthHz)으로도 보정.
%     -> 저주파 채널에서 tolerance%가 df에 묻혀 무시되던 문제 해결.
%   - 탐색 구간은 그래프 표시범위(xlimVal) 밖으로 나가지 않도록 클리핑
%     (표시범위 밖 DC 근접 성분을 1X로 잘못 잡는 것을 방지).
%   - 단순 max()가 아니라 findpeaks()로 국소 최댓값(prominence 기준)을
%     우선 채택. 국소 피크가 없으면(예: 구간 경계에 단조 증가/감소만 있는
%     경우) 기존처럼 구간 내 최댓값으로 fallback.
%  [v5 변경점]
%   - maxHalfWidth(오더 간격 기반 상한)를 추가. 고조파(2X,3X) 탐색시 이 상한이
%     없으면 저주파 채널에서 인접 오더끼리 탐색창이 겹쳐 같은 피크를 중복
%     검출하는 버그가 생김 -> half-width를 min(..., maxHalfWidth)로 캡.
if nargin < 8 || isempty(maxHalfWidth)
    maxHalfWidth = Inf;
end
df = tfreq(2) - tfreq(1);
halfWidth = max([fTarget * tolerancePercent / 100, df, minBandwidthHz]);
halfWidth = min(halfWidth, max(maxHalfWidth, df));  % 상한 적용(단, 최소 df는 보장)
fLow  = max(fTarget - halfWidth, xlimVal(1));
fHigh = min(fTarget + halfWidth, xlimVal(2));

idxRange = tfreq >= fLow & tfreq <= fHigh;
if ~any(idxRange)
    peakFreq = NaN; peakVal = NaN; found = false;
    return;
end

freqsInRange = tfreq(idxRange);
valsInRange  = tvalPlot(idxRange);

found = false; peakFreq = NaN; peakVal = NaN;

if numel(valsInRange) >= 3
    localMax = max(valsInRange);
    minProm = max(localMax * minPeakProminenceRatio, eps);
    try
        [pkVals, pkLocs] = findpeaks(valsInRange, 'MinPeakProminence', minProm);
    catch
        pkVals = []; pkLocs = [];
    end
    if ~isempty(pkVals)
        [peakVal, relIdx] = max(pkVals);
        peakFreq = freqsInRange(pkLocs(relIdx));
        found = true;
    end
end

if ~found
    % fallback: 국소 피크가 없으면 구간 내 최댓값 사용 (경계값 포함)
    [peakVal, relIdx] = max(valsInRange);
    peakFreq = freqsInRange(relIdx);
    found = true;
end
end

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