% BINary string to INTeger string conversion
%
% This function is a high level function to bindecod.
%
% Syntax:  Phen = bin2int(Chrom, FieldD)
%
% Input parameters:
% Output parameter:
%    see bindecod
% 
% See also: bindecod, bin2real

% Author:   Hartmut Pohlheim
% History:  18.10.96    file created


function Phen = bin2int(Chrom, FieldD)

% Call low level decoding function
   Phen = bindecod(Chrom, FieldD, 3);


% End of function
