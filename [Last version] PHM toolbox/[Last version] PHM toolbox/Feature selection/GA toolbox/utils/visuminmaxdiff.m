% Compute minimum and maximum of provided data and a scaling difference between both
%
% Compute minimum, maximum and difference between both of provided data,
% employ some special scalings to the difference value. Additionally,
% only a certain percentage of the data points can be used to compute the 
% maximum, thus excluding the worst points during minimization.
% The results are used for scaling the axes limits in a very tight manner
% and adding a small (empty) area around the data (preventing data points
% to lay exactly on the axes).
% All possible exceptions (minimum and maximum are identical, NaN, Inf, or 0 
% at the same time) are handled here. This function returns even for these 
% cases "useful" values (DataMin = 0, DataMax = 1, DataDiffScaled = 0.02).
%
% Synatx: [DataMin, DataMax, DataDiffScaled] = visuminmaxdiff(DataIn, OptMinMax)
%
% Input parameters:
%    DataIn    - Vector/Matrix with variables
%    OptMinMax - (optional) Options (both options may be omitted): 
%                OptMinMax(1): Data2Use4Max, scalar 
%                OptMinMax(2): scalar with scaling value for difference (used for small area of
%                       axes added to maximum/subtracted from minimum value)
%                       if omitted, 0.02 (2%) is used
%                OptMinMax(3): scalar with scaling value, if no difference between minimum and 
%                       maximum (this ensures error free axes scaling)
%                       if omitted, 1e-5 is used
%              - (optional) Structure containing non-standard options
% 
% Output parameters:
%     DataMin  - Scalar containing minimum of whole vector/matrix
%     DataMax  - Scalar containing maximum of whole vector/matrix
%     DataDiffScaled  - Scalar containing scaled difference between minimum 
%                       and maximum, checked for zero minimum and scaled accordingly
% 
% Examples:
% % 
% >> 
% 
% See also: visuplot, resplot

% Author:   Hartmut Pohlheim
% History:  26.01.2002  file created (taken from compplot/'get_min_max_diff')
%           12.11.2002  when constant data, DataMin and DataMax are set to 0.5 above and below the data value


function [DataMin, DataMax, DataDiffScaled] = visuminmaxdiff(DataIn, OptMinMax)

   % Preset output variables
   MinStd = 0; MaxStd = 1; DiffScaledStd = 0.02; ScaleMinStd = 1e-5;
   DataDiffScaled = DiffScaledStd; 
   
   % Check input variables
   if nargin < 1, DataMin = MinStd; DataMax = MaxStd; return; end

   if nargin < 2, OptMinMax = []; end
   if isempty(OptMinMax), OptMinMax = 1; end
   % OptMinMax(1): Percentage of smaller data points to use for maximum calculation
   if ~isnan(OptMinMax(1)),
      Data2Use4Max = OptMinMax(1);
      if Data2Use4Max > 1, Data2Use4Max = 1; end
      if Data2Use4Max <= 0, Data2Use4Max = 0.9; end
   else Data2Use4Max = 1;
   end
   % OptMinMax(2): scaling factor for diff
   if length(OptMinMax) > 1 & ~isnan(OptMinMax(2)), ScaleMinMax = OptMinMax(2); else ScaleMinMax = DiffScaledStd; end
   % OptMinMax(3): minimal quotient between minimum and diff
   %        (can't be near zero for scaling diff in YLim)
   if length(OptMinMax) > 2 & ~isnan(OptMinMax(3)), ScaleMin = OptMinMax(3); else ScaleMin = ScaleMinStd; end
   SortedDataIn = sort(DataIn(:));
   % OptMinMax(4): user defined minimum and maximum
   if length(OptMinMax) > 4 & ~any([isnan(OptMinMax(4)), isnan(OptMinMax(5))]), 
      DataMin = OptMinMax(4);  DataMax = OptMinMax(5);
   else
      DataMin = SortedDataIn(1);
      DataMax = SortedDataIn(ceil(length(SortedDataIn) * (Data2Use4Max)));
   end

   
   % When DataMin and DataMax both are NaN, Inf, or 0 then return some useful values
   if any([all(isnan([DataMin, DataMax])), ...
            all(isinf([DataMin, DataMax])), ...
            all([DataMin == 0, DataMax == 0])]), 
      DataMin = MinStd; DataMax = MaxStd;
   elseif DataMin == DataMax, DataMin = DataMin - 0.5; DataMax = DataMax + 0.5;
   else
      % When DataMax is NaN, set it to the next real number in DataIn
      if isnan(DataMax), DataMax = max(SortedDataIn); end
      % If DataMax is Inf, set it to the next not Inf number in DataIn
      if isinf(DataMax), DataMax = max(SortedDataIn(find(~isinf(SortedDataIn)))); end
      
      % Compute the scaled difference between minimum and maximum
      DataDiffScaled = abs(ScaleMinMax * (DataMax - DataMin));
      
      % Compute the smallest allowed scaled difference based on the DataMin
      % Handle the cases where one of DataMin/DataMax is 0
      MinScaleValue = abs(DataMin * ScaleMin);
      if MinScaleValue == 0, 
         MinScaleValue = ScaleMin; if DataMax == 0, DataMax = MinScaleValue; end
      end
      
      % Take the maximum between the "real" scaled difference and the smallest allowed one 
      DataDiffScaled = max([DataDiffScaled, MinScaleValue]);
   end

   
% End of function