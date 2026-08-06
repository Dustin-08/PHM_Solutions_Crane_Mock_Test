% Multidimensional scaling (SAMMON mapping)
%
% This function performs SAMMON mapping, a multidimensional
% scaling (MDS) method used for scaling multidimensional data 
% to a lower dimension (normally to two or three dimensions).
% The scaled data give an abstract picture of the multi-
% dimensional data.
% When no optimization function (optimization toolbox) is available
% a classical scaling method is used (producing good results as well). 
%
% Syntax:  [DataLow, Sstress, PCAinit] = sammon(DataHigh, SamOpt, Labels, DataLowStart)
%
% Input parameter:
%    DataHigh  - Matrix of multidimensional data
%                   every row corresponds to one multidimensional
%                   data point 
%
%    SamOpt    - Vector containing options for sammon mapping
%                SamOpt(1): SplitCoef - Split coefficient, scalar in [0.5  1]
%                   which percentage of the data points is used for direct MDS,
%                   the remaining part is added later; for many data points this
%                   speeds up the MDS - trading against less accurate results 
%                    1: exact sammon algorithm with all data points (standard)
%                   <1: faster mapping producing a not so accurate result
%                  only used with more than 100 data points
%                SamOpt(2): DimDataLow - dimension of low dimensional data
%                   DimDataLow: [ 1 2 3 ... ]
%                   if omitted or NaN, DataLowDim = 2 is assumed 
%                SamOpt(3): DoSamPlot - scalar indicating plotting of results
%                   0: no plot
%                   1+: plot results (when low dimension is 2D or 3D)
%                       for each distinc number a new figure is opened or 
%                       the figure with this number is reused
%                SamOpt(4): DoRandInit - initialization of low-dimensional data
%                   0: pca (principal component analysis)
%                   1: random initialization (uniform at random)
%                   (Cox&Cox bzw. Borg/Groenen) see below
%
%   Labels     - Matrix containing strings used for labeling data points
%                   if empty, no labels are plotted
%                   if NaN, row number of data points are used
%                   if less labels are provided than points, omitted
%                      labels are produced using row number of data points
%
%   DataLowStart- Matrix of initial low dimensional data
%                 if empty random values are generated or PCA-initialization is used
%
% Output parameter:
%    DataLow   - Matrix of lowdimensional data
%                   every row corresponds to one lowdimensional
%                   data point and corresponds with DataHigh
%
%    Sstress   -  
%
%    PCAinit   - 
%
% see also: samplot, samadd
%
% References:
%   J.W. Sammon: A nonlinear Mapping for Data Structure Analysis. IEEE Trans. on Computers, 18, 401-409, 19??.
%   Ingwer Borg and Patrick Groenen: Modern Multidimensional Scaling. Springer, New York, 1997.
%   Trevor F. Cox and Michael A.A. Cox: Multidimensional Scaling. Chapman&Hall, London 1994.

% Author: 	Hartmut Pohlheim
% History:	15.09.2000  file recreated (partly based on old sammon implementation))
%           18.07.2001  added distance mapping and initialization based on 
%                          pca (principal components analysis)
%           19.09.2001  check for optimization function license included
%           15.02.2002  classical scaling added when no optimization function available
%           17.02.2002  documentation updated
%                       parameter checking extended


function [DataLow, Sstress, PCAinit] = sammon(DataHigh, SamOpt, Labels, DataLowStart)

   NAIN = nargin; NAOUT = nargout;
   
   % SplitCoef = 1; DimDataLow = 2; DoSamPlot = 1, DoRandInit = 0;
   SamOptStandard = [1, 2, 1, 0];
   % Initialize the random number generator
   rand('state', sum(100*clock));
   % Preset internal and output variables
   PlotFigName = '';
   DataLow = [];

   % Check input parameters
   if NAIN < 1, DataHigh = []; end
   if isnan(DataHigh), DataHigh = []; end
   if isempty(DataHigh); warning('No high-dimensional data available.'); return; end
   [NPoints, DimDataHigh] = size(DataHigh);
   
   % Check the provided options
   if NAIN < 2, SamOpt = []; end
   if isnan(SamOpt), SamOpt = []; end
   if isempty(SamOpt), SamOpt = SamOptStandard; end
   if length(SamOpt) > length(SamOptStandard),
      SamOpt = SamOpt(1:length(SamOptStandard));
      warning(' Too many parameters in SamOpt');
   end
   SamOptIntern = SamOptStandard; SamOptIntern(1:length(SamOpt)) = SamOpt;
   SplitCoef = SamOptIntern(1); DimDataLow = SamOptIntern(2);
   DoSamPlot = SamOptIntern(3); DoRandInit = SamOptIntern(4);

   if any([SplitCoef > 1, SplitCoef <= 0]), SplitCoef = SamOptStandard(1); end

   if ~(all([DimDataLow >= 1, DimDataLow < DimDataHigh])), 
      DimDataLow = SamOptStandard(2);
      if ~(isnan(DimDataLow)),
         warning(sprintf('Dimension of low-dimensional data must be >= 1 and < DimDataHigh! Reset to %g.', DimDataLow));
      end
   end
   
   % Check Labels, create all or add missing labels
   if NAIN < 3, Labels = []; end
   NoLabels = 0;
   if isempty(Labels), NoLabels = 1; end
   if isnan(Labels), Labels = []; end
   if isempty(Labels), Labels = num2str([1:NPoints]');
   else
      [NLabels, DimLabels] = size(Labels);
      if NLabels > NPoints, Labels = Labels(1:NPoints, :);
      elseif NLabels < NPoints,
         LabelsAdd = num2str([NLabels+1:NPoints]');
         Labels = strvcat(Labels, LabelsAdd);
      end
   end

   % Check for provided init data
   if NAIN < 4, DataLowStart = []; end
   if isnan(DataLowStart), DataLowStart = []; end
   if size(DataLowStart, 1) ~= NPoints, DataLowStart = []; end
   if size(DataLowStart, 2) >= DimDataHigh, DataLowStart = []; end

   % De-mean and norm input data points
   % MeanDataHigh = mean(DataHigh(:));
   % DataHigh = DataHigh -MeanDataHigh;
   % MinDataHigh = min(min(DataHigh));
   % MaxDataHigh = max(max(DataHigh));
   % DataHigh = (DataHigh - MinDataHigh) ./ (MaxDataHigh - MinDataHigh);

   MeanDataHigh = mean(DataHigh(:));
   DataHigh = DataHigh -MeanDataHigh;
   MinDataHigh = min(min(DataHigh));
   MaxDataHigh = max(max(DataHigh));
   DataHigh = (DataHigh - MinDataHigh) ./ (MaxDataHigh - MinDataHigh);
   % UBH = max(max(DataHigh));
   % LBH = min(min(DataHigh));
   % DataHigh = DataHigh / (UBH-LBH);

   % Perform random initialization of low-dimensional data points
   if DoRandInit == 1,
      % Create uniformly distributed random start-values
      DataLowStart = rand(NPoints, DimDataLow) .* (MaxDataHigh-MinDataHigh) + MinDataHigh;
   end
   if ~(isempty(DataLowStart)),
      DimDataLow = size(DataLowStart, 2);
      % De-mean and norm low-dimensional points
      MeanDataLow = mean(DataLowStart(:));
      DataLowStart = DataLowStart -MeanDataLow;
      MinDataLow = min(min(DataLowStart));
      MaxDataLow = max(max(DataLowStart));
      DataLowStart = (DataLowStart - MinDataLow) ./ (MaxDataLow - MinDataLow);
      % UBL = max(max(DataLowStart));
      % LBL = min(min(DataLowStart));
      % DataLowStart = DataLowStart / (UBL-LBL);
   end
   
   % Split data randomly, some points are used for Sammons mapping
   % the remaining are added by samadd at the end
   chBase = rand(NPoints, 1);                 % Split matrix into base points and later-to-add-points,
   temp = sort(chBase);                       % get a vector of randomly chosen values between one and zero, length is NPoints
   border = temp(ceil(NPoints * SplitCoef));  % the Element who divides exactly the choose vector at the appropriate point (e.g. 50/50)
   xBase = find(chBase <= border);
   xNew =  find(chBase >  border);
   Base = DataHigh(xBase, :);
   New = DataHigh(xNew, :);
   % Split preinitialized startvalues too
   if ~isempty(DataLowStart), BaseL = DataLowStart(xBase, :); end
   % Sort Labels if necessary
   if ~isempty(xNew),
      BaseLabels = Labels(xBase, :);
      NewLabels = Labels(xNew, :);
      IstLabels = [BaseLabels; NewLabels];
   else IstLabels = Labels; end
   % Get the dimension of the two data matrices
   [NPointsBase, NDims] = size(Base);
   [NPointsNew,  NDims] = size(New);
   
   % Computing the Euklidean distances in the high-dimensional space
   DistData = compdiv('distance_chrom_mat_2', Base);
   DistData(DistData < 10*eps) = 10*eps;
   
   % Performing Principal Component Analysis to find good start values
   if DoRandInit == 0,
      % Perform pca (principal component analysis)
      [lEV, EW, rEV] = svd(DistData);
      EW = sum(EW);
      BaseL = rEV(1:DimDataLow, :)' .* repmat(EW(1:DimDataLow), [size(DistData, 1) 1]);
      % BaseL = pca(DistData, DimDataLow);
      if NAOUT > 2, PCAinit = BaseL; end
   end
   
   % Transforming matrix to vector for optimization
   BaseLow = BaseL(:);

   % Optimization
   optim = optimset('GradObj', 'on', 'DerivativeCheck', 'off', ...
                    'Display', 'off', 'LargeScale', 'off', ...
                    'MaxIter', 2^10, 'MaxFunEvals', 2^32, ...
                    'LevenbergMarquardt', 'off', 'LineSearchType', 'quadcubic', ...
                    'TolFun', 1e-17, 'TolX', 1e-16 ...
                   );

   try,
      [DataLow, Sstress] = fminunc('samfun', BaseLow, optim, DistData);
      PlotFigName = 'Sammon-Mapping';
   catch
      warning('No License for Optimization Toolbox available or fminunc not in path. Classical Scaling used!');
      % Perform classical scaling (reference ???)
      [lEV, EW, rEV] = svd(DataHigh*DataHigh');
      Lambda = sqrt(EW); Q = lEV;
      Lambda = Lambda(1:DimDataLow, 1:DimDataLow); Q = Q(:, 1:DimDataLow);
      DataLow = Q*Lambda;
      % DataLow = classicalscaling(DataHigh, DimDataLow, Labels, 1);
      DataLow = DataLow(:); NPointsBase = NPoints; xNew = [];
      PlotFigName = 'Classical MDS Scaling';
      if NAOUT > 1,
         DistData = compdiv('distance_chrom_mat_2', DataHigh);
         DistData(DistData < 10*eps) = 10*eps;
         Sstress = samfun(DataLow, DistData);
      end
   end

   % DataLowBase is a vector --> transforming back to a new matrix
   DataLow = reshape(DataLow, NPointsBase, DimDataLow);

   % Add remaining points by Distance Mapping if desired
   if ~isempty(xNew)
      DataLowNew = samadd(Base, New, DataLow);
      % Adding new points to the sammon map
      DataLow = [DataLow; DataLowNew];
      % Computing the Euklidean distances in the high-dimensional space
      if NAOUT > 1,
         DistData = compdiv('distance_chrom_mat_2', DataHigh);
         DistData(DistData < 10*eps) = 10*eps;
         Sstress = samfun(DataLow(:), DistData);
      end
   end
   
   
   % plot
   if all([any(DimDataLow == [2, 3]), DoSamPlot >= 1]),
      if NoLabels == 1, IstLabels = ''; end
      samplot(DataLow, BaseL, IstLabels, DoSamPlot, PlotFigName);
   end


% End of function