% OBJective function: Structure Testing AND
%
% This function implements .
%
%
% Syntax:  ObjVal = objteststr1(Chrom)
% 
% For Input and Output parameters see objfun1.
%
% Example:
%
% % for plotmesh
% >> plotmesh('objteststr1',[0; 800],200, 52, 156)
% >> print -depsc -tiff NameofGraficFile
%
% See also: objfun1, objfunoptset

% Author:   Hartmut Pohlheim
% History:  29.04.2004  file created


function ObjV = objteststr1(Chrom, ParaA, ParaB);

   if nargin < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   ObjV = [];

   if nargin < 2, ParaA = []; end
   if isnan(ParaA), ParaA = []; end
   if isempty(ParaA), ParaA = 128; end

   if nargin < 3, ParaB = []; end
   if isnan(ParaB), ParaB = []; end
   if isempty(ParaB), ParaB = 128; end
   
   % Create option-structure
   if isnan(Chrom(1,1)), 
      if isnan(Chrom(1,2)),
         if Chrom(1,3) <= 10,
           ObjV = objfunoptset( 'FunctionName', ' ' ...
                              , 'VarBoundMin', 0, 'VarBoundMax', 255 ...
                              , 'NumVarDefault', 2, 'NumVarMin', 1, 'NumVarMax', Inf ...
                              );
         end
      end

   % Calculate objective values
   else
      % 
      ChromMin = min(min(Chrom)); ChromMax = max(max(Chrom));
      ObjEps = 1/(max([10, sqrt(ChromMax-ChromMin)]));
      
      Chrom = round(Chrom);
      ObjV1 = (1 - (1-ObjEps).^(abs(Chrom(:,1)-ParaA)))*0.5 + 0.5;
      ObjV2 = (1 - (1-ObjEps).^(abs(Chrom(:,2)-ParaB)))*0.5;
      ObjV = ObjV1 .* (Chrom(:,1)~=ParaA) + ObjV2 .* (Chrom(:,1)==ParaA);
   end


% End of function