% Objective function for Sammon mapping, calculates derivatives as well
%
% This function calculates the objective values (stress function)
% for Sammon mapping.
% If a second output parameter is provided, the derivatives are 
% calculated as well.
% This function is normally called from the optimization function.
%
% Syntax:  [ObjV, Grad] = samfun(x, DistDataHigh)
%
% Input parameter:
%    x            - data points, every row presents one low-dimensional data point
%    DistDataHigh - distances betwenn data points in high dimension
%
% Output parameter:
%    ObjV      - objective value
%
% See also: sammon

% Author:   Hartmut Pohlheim
% History:  28.04.1997  file created
%           10.06.1997  check for distances zero or close to zero
%           30.05.2001  Sstressfunction and directional Derivative vectorized


function [ObjV, Grad] = samfun(x, DistDataHigh)

   NAOUT = nargout;
 
   % Produce matrix from vector, use globally defined dimension of data
   Nind = size(DistDataHigh, 1); NDim = length(x) / Nind;
   x = reshape(x, Nind, NDim);

   % Compute low dimensional distance matrix
   DistDataLow = compdiv('distance_chrom_mat_2', x);

   % Check for zeros or very small numbers in distance values
   DistDataLow(DistDataLow < 10*eps) = 10*eps;
   
   % Normalization
   Normed = sum(sum(DistDataHigh, 2), 1) / 2;
   
   % Create objective value
   Jef = sum(sum((DistDataLow - DistDataHigh).^2 ./ DistDataHigh, 2), 1) ./ 2;
   Jef = Jef ./ Normed;

   ObjV = Jef;

   % Calculate the 1st order derivatives
   if NAOUT == 2,
      % Normalization
      Normed = repmat(Normed, [Nind 1 NDim]);
   
      Tens1 = repmat(x , [1 1 Nind]);
      Tens1 = shiftdim(Tens1, 2);
      Tens2 = repmat(x', [1 1 Nind]);
      Tens2 = shiftdim(Tens2, 1);
      TensDiff = Tens1 - Tens2;
      
      % Compute Directional Derivative
      DistDataHigh = repmat(DistDataHigh, [1 1 NDim]);
      DistDataLow = repmat(DistDataLow, [1 1 NDim]);
      Jef = sum((DistDataHigh-DistDataLow) ./ DistDataHigh .* TensDiff ./ DistDataLow, 2);
      Jef = 2 * Jef ./ Normed;
      Jef = squeeze(Jef);
   
      Grad = Jef(:);
   end


% End of function
