% Add new highdimensional points to an existing Sammon-Map using Distance Mapping
%
% This function adds new highdimensional points to an existing Sammon-Map
% using Distance Mapping
%
% Pekalska, Elzbieta, Dick. de Ridder, Robert P.W. Duin, and Martin A. Kraaijveld.
% A new method of generalizing sammon mapping with application to algorithm speed-up.
% In M. Boasson, J. Karndorp, J. Torino, and M. Vosselman, editors, ASCI'99 
% Proc. 5th Annual Conference of the Advanced School for Computing and Image, 1999.
%
% see also: sammon, samplot

% Author:   Hartmut Pohlheim
% History:  18.07.2001  file created


function DataLowNew = samadd(DataHighOld, DataHighNew, DataLowOld)

   NAIN = nargin; NAOUT = nargout;
   
   if NAIN < 3, DataLowOld = []; end
   
   if isnan(DataLowOld), DataLowOld = []; end
   if isnan(DataHighNew), DataHighNew = []; end
   if isnan(DataHighOld), DataHighOld = []; end
   if any([isempty(DataLowOld), isempty(DataHighNew), isempty(DataHighOld)]),
       warning('values are missing'); return;
   end
   
   if size(DataHighOld, 2) ~= size(DataHighNew, 2),
       warning('High dimensions do not match'); return;
   end
   
   if size(DataHighOld, 1) ~= size(DataLowOld, 1),
       warning('Amount of high and lowdimensional Variables do not match'); return;
   end
   
   
   DistOld = compdiv('distance_chrom_mat_2', DataHighOld);
   DistNew = compdiv('distance_chrom_mat_2', DataHighNew, DataHighOld);
   
   DataLowNew = DistNew * inv(DistOld) * DataLowOld;


% End of function