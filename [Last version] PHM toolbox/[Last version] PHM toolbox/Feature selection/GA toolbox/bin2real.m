% BINary string to REAL vector conversion
%
% This function is a high level function to bindecod.
%
% Syntax:  Phen = bin2real(Chrom, FieldD)
%
% Input parameters:
% Output parameter:
%    see bindecod
% 
% See also: bindecod, bin2int

% Author:   Hartmut Pohlheim
% History:  18.10.96    file created


function Phen = bin2real(Chrom, FieldD)

% Call low level decoding function
   Phen = bindecod(Chrom, FieldD, 1);


% End of function
