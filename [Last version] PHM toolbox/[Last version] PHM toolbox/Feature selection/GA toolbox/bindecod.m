% BINary DECODing to binary, integer or real numbers
%
% This function decodes binary chromosomes into vectors of binary,
% integer or real numbers. The chromosomes are seen as the concate-
% nation of binary strings and decoded into binary, integer or real
% numbers in a specified interval using either standard binary or 
% Gray decoding.
% Binary variables can be mixed with integer and real variables. A
% binary variable is an integer/real number decoded with one binary
% value and lower bound 0 and upper bound 1, both bounds included.
% For real numbers the variables are scaled between lower and upper
% bound using either arithmetic or logarithmic scaling. The inclusion
% of lower and upper bound can be defined as well.
% The real and integer variables are the discrete values between lower
% and upper bound. The number of intervals is defined by 2^the number
% of binary values. Thus, the bounds of the variables are ensured.
% (A second method can be switched on inside the function for integer
%  variables. The variables can be decoded to direct integer numbers
%  and the lower bound is added to this direct decoded numbers. A 
%  check for upper bound is performed afterwards. Thus, every binary 
%  string decodes to one and only one integer number and vice versa.)
% 
% See examples for more information!
%
% Syntax:  Phen = bindecod(Chrom, FieldD, Coding)
%
% Input parameters:
%    Chrom     - Matrix containing the chromosomes to decode. Each row
%                corresponds to one individual's concatenated binary
%                string representation. Leftmost bits are most significant
%                and rightmost are least significant.
%    FieldD   -  Matrix describing the length and how to decode
%                each substring in the chromosome. It has the
%                following structure:
%                [ NumCols;
%                  LowBound;
%                  UppBound;
%                  BinGray;
%                  Scaling;
%                  LowIncld;
%                  UppIncld ]
%
%                NumCols  - Vector containing number of columns in Chrom
%                           decoding to one variable. sum(NumCols)
%                           should equal the individual length.
%                LowBound - Vector containing lower bound for each variable.
%                UppBound - Vector containing upper bound for each variable. 
%                BinGray  - Vector indicating coding of binary values.
%                           0: standard binary coding
%                           1: gray coding
%                Scaling  - Vector indicating scaling for decoding of
%                           variables.
%                           0: arithmetic scaling
%                           1: logarithmic scaling
%                           always arithmetic scaling for integer variables
%                LowIncld - Vector indicating inclusion of lower bound into
%                           the representation range
%                           0: exclude lower bound
%                           1: include lower bound
%                           always included for integer variables
%                UppIncld - Vector indicating inclusion of upper bound into
%                           the representation range
%                           0: exclude upper bound
%                           1: include upper bound
%                           always included for integer variables
%
%    Coding   - (optional) Scalar containing decoding method
%               0: do not decode, real representation - real variables
%               1: decode binary values to real numbers
%               2: do not decode, integer representation - integer variables 
%               3: decode binary values to integer numbers
%               4: do not decode, binary representation - binary variables 
%               5: do not decode, permutation representation - any variables 
%               if omitted or NaN, 0 (do not decode) is assumed
%               Coding is identical to GEAOpt.VariableFormat in geamain2
%
% Output parameter:
%    Phen     - Matrix containing the phenotypes of the individuals
%               of Chrom.
%
% See also: bin2int, bin2real, initbp, initip, initrp


% Examples:
%  Chrom = [ 0     0     0;
%            0     0     1;
%            0     1     0;
%            0     1     1;
%            1     0     0;
%            1     0     1;
%            1     1     0;
%            1     1     1 ]
%
%
% % real numbers, standard binary coding, include lower and upper bound
% >> FieldD = [ 3; 0; 7; 0; 0; 1; 1]
% >> bindecod(Chrom, FieldD, 1)
%    ans =
%       [ 0; 1; 2; 3; 4; 5; 6; 7]
%     
% % real numbers, standard binary coding, exclude lower and upper bound
% >> FieldD = [ 3; 0; 7; 0; 0; 0; 0]
% >> bindecod(Chrom, FieldD, 1)
%    ans =
%       [ 0.7778; 1.5556; 2.3333; 3.1111; 3.8889; 4.6667; 5.4444; 6.2222 ]
%
% % real numbers, gray coding, include lower and upper bound
% >> FieldD = [ 3; 10; 17; 0; 0; 1; 1]
% >> bindecod(Chrom, FieldD, 1)
%    ans =
%       [ 10; 11; 13; 12; 17; 16; 14; 15 ]
%
% % real numbers, gray coding, include lower and upper bound,
% % logarithmic scaling
% >> FieldD = [ 3; 10; 17; 0; 1; 1; 1]
% >> bindecod(Chrom, FieldD, 1)
%    ans =
%       [ 10.0000; 10.7875; 11.6370; 12.5535; 13.5421; 14.6085; 15.7590; 17.0000 ]
%
% % integer numbers, gray coding, some variables decode to numbers 
% % above upper bound, these variables are set to upper bound
% >> FieldD = [ 3; 20; 25; 0; 0; 1; 1]
% >> bindecod(Chrom, FieldD, 3)
%    ans =
%       [ 20; 21; 23; 22; 25; 25; 24; 25 ]
%
% % integer numbers, standard binary coding, not all possible 
% % values between lower and upper bound can be decoded using
% % 3 binary values (2^3=8 => biggest value is 27)
% >> FieldD = [ 3; 20; 30; 0; 0; 1; 1]
% >> bindecod(Chrom, FieldD, 3)
%    ans =
%       [ 20; 21; 22; 23; 24; 25; 26; 27 ]
%
%
%  Chrom = [ 0     0     0     0     0     0;
%            0     0     1     0     0     1;
%            0     1     0     0     1     0;
%            0     1     1     0     1     1;
%            1     0     0     1     0     0;
%            1     0     1     1     0     1;
%            1     1     0     1     1     0;
%            1     1     1     1     1     1 ]
%
% % integer numbers, standard binary coding, 2 variables
% >> FieldD = [ 4 2; 20 10; 40 15; 0 0; 0 0; 1 1; 1 1]
% >> bindecod(Chrom, FieldD, 3)
%    ans =
%       [ 20 10; 23 12; 25 13; 28 15; 32 10; 35 12; 37 13; 40 15 ]
%
% % integer numbers, standard binary coding, 1 integer and 
% % 2 binary variables
% >> FieldD = [ 4 1 1; 20 0 0; 40 1 1; 0 0 0; 0 0 0; 1 1 1; 1 1 1]
% >> bindecod(Chrom, FieldD, 3)
%    ans =
%       [ 20 0 0; 23 0 1; 25 1 0; 28 1 1; 32 0 0; 35 0 1; 37 1 0; 40 1 1 ]
%

% Author:   Hartmut Pohlheim
% History:  15.10.1996  file created
%           16.10.1996  error in gray decoding removed, when using
%                          binary variables (one column per variable), then
%                          gray decoding produced wrong results due to cumsum,
%                          see code below for solution
%           18.10.1996  comments for every line
%                       many examples for different codings / special effects
%           21.10.1996  meaning of variable Coding changed, is now identical
%                          to variable CODEVARIABLE in geamain
%                       two options in Coding for no decode added, used for
%                          global decoding (no distinction for decode or not
%                          in geamain)
%           17.10.1997  code number 2 changed into 4
%                       new meaning for 2: CodeNoDecodeInteger
%           03.02.1998  update to internal working, decoding from binary and 
%                          real work similar now, integer uses just a round 
%                          at the end, thus integer values are stretched to 
%                          full variable range
%                       the old working with direct decoding is still available
%                          and can be set internally (CodeIntegerDirect)
%                       smarter handling of missing rows in FieldD
%           20.07.1998  new Codevariable 5 added, permutation representation
%                          meaning for 2: CodeNoDecodePermutation


function Phen = bindecod(Chrom, FieldD, Coding)

% Get population size (Nind) and chromosome length (Lind)
   [Nind, ChromLength] = size(Chrom);

% Get number of variables (Nvar)
   [NumRows, Nvar] = size(FieldD);
   
% Check number of rows in decoding information matrix
   if NumRows < 3, 
      error('Matrix with coding information (FieldD) must have at least 3 rows.');
   end

% Check input parameter Coding
   CodeNODecodeReal    = 0; CodeReal    = 1;
   CodeNODecodeInteger = 2; CodeInteger = 3;
   CodeNODecodeBinary  = 4; CodeNODecodePermutation  = 5; 
   CodeIntegerDirect = 13;
   NODecode = [CodeNODecodeReal, CodeNODecodeInteger, CodeNODecodeBinary, CodeNODecodePermutation];
   if nargin < 3, Coding = []; end
   if isnan(Coding), Coding = []; end
   if isempty(Coding), Coding = CodeReal; end
   if ~any(Coding == [NODecode, CodeReal, CodeInteger, CodeIntegerDirect]),
      error('Parameter for coding of variables not in range!');
   end

% If no decode, return
   if any([Coding == NODecode]),
      Phen = Chrom; return;
   end
   
% Get properties of variables for decoding and check where possible
   NumCols = FieldD(1,:);
   LowBound = FieldD(2,:);
   UppBound = FieldD(3,:);
   if NumRows < 4, BinGray  = ones(1, Nvar); else BinGray  = ~(~FieldD(4,:)); end
   if NumRows < 5, Scaling  = zeros(1,Nvar); else Scaling  = ~(~FieldD(5,:)); end
   if NumRows < 6, LowIncld = ones(1, Nvar); else LowIncld = ~(~FieldD(6,:)); end
   if NumRows < 7, UppIncld = ones(1, Nvar); else UppIncld = ~(~FieldD(7,:)); end

% Check substring properties for consistency
   if sum(NumCols) ~= ChromLength,
	   error('Data in FieldD must agree with chromosome length');
   end

   if any(LowBound > UppBound),
      error('Upper bound of at least one variable is smaller than lower bound!');
   end

% Decode chromosomes
   Phen = zeros(Nind, Nvar);

   % Get start and end column for every variable
   StartCol = cumsum([1 NumCols]);
   EndCol = cumsum(NumCols);

   % Compute new range of variables
   RangeVar = UppBound - LowBound;

   if any(Coding == [CodeReal, CodeInteger]),
      if ~all(LowBound(Scaling) .* UppBound(Scaling) > 0),
       	error('Logarithmic scaled variables can not include 0 in their range!');
      end
      
      % Precision (smallest possible fraction of range of variable) depends
      % on number of columns of variable, calculate for all variables at once
      % Example: 4 columns: 2^-4 precision, 10 columns: 2^-10 precision
      Prec = 2 .^ (-(NumCols));

      % Get sign for logarithmic scaled variables
      LogSign = sign(LowBound(Scaling));
      
      % Logarithmic scaling of lower/upper bound, will be reverse
      % after decoding of variables => logarithmic scaling
      LowBound(Scaling) = log( abs(LowBound(Scaling)) );
      UppBound(Scaling) = log( abs(UppBound(Scaling)) );

      % If lower and/or upper bound is excluded, compute small range
      % (identical to precision), that will be excluded in later deocding 
      RangeLowIncld = (~LowIncld) .* Prec;
      RangeUppIncld = (LowIncld + UppIncld - 1) .* Prec;
   end
   
   for irun = 1:Nvar,
      % Get numbers of columns for current variable
      IxCols = StartCol(irun):EndCol(irun);

      % Change Gray coding to standard binary coding
      if BinGray(irun)
         % if only one column per variable, no cumsum necessary
         % BTW: cumsum would produce wrong result, due to using vector
         % and not a matrix 
         if length(IxCols) == 1,
            Chrom(:, IxCols)=rem(Chrom(:, IxCols), 2);
         else
            Chrom(:, IxCols)=rem(cumsum(Chrom(:, IxCols)')', 2);
         end
      end

      if any(Coding == [CodeReal, CodeInteger]),
         Phen(:, irun) = Chrom(:, IxCols) * [ 2 .^ (-(1:NumCols(irun)))' ];
         Phen(:, irun) = LowBound(irun) + RangeVar(irun) * (Phen(:,irun) + ...
                         RangeLowIncld(irun)) ./ (1 - RangeUppIncld(irun));

      elseif Coding == CodeIntegerDirect,
         % Direct conversion from binary to integer without scaling
         % not used by default
         Phen(:, irun) = Chrom(:, IxCols) * (2 .^ [NumCols(irun)-1:-1:0])';
         Phen(:, irun) = LowBound(irun) + Phen(:, irun);
         % Check for upper bound, if Phen(:,i) greater upper bound,
         % then first part is zero and second part gives upper bound
         Phen(:, irun) = Phen(:, irun) .* (Phen(:, irun) <= UppBound(irun)) + ...
                         UppBound(irun) .* (Phen(:, irun) > UppBound(irun));
      end
   end

   if any(Coding == [CodeReal, CodeInteger]),
      if any(Scaling),
   	   Phen(:,Scaling) = repmat(LogSign, [Nind, 1]) .* exp(Phen(:,Scaling));
      end
   end

   if Coding == CodeInteger,
      Phen = round(Phen);
   end


% End of function
