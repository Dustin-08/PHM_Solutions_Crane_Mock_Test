% DEMO for GEATbx, standard functions
%
% This function provides an example for using the GEATbx for 
% the optimization of standard test functions.
% It contains a simple menu driven selection between many objective 
% functions and 3 different evolutionary optimization methods.
% Many of the useful options of the GEATbx are defined and changed,
% most of them just for providing an example.
% This function can be started from the command line defining
% the menu choices as parameters (see examples below).
% This function can be compiled with the Matlab compiler (at least R12).
% The necessary function pragmas are defined (and the GEATbx also
% includes the necessary pragmas). Yes, this function works 
% as an external program on the operating system prompt.
% 
% Syntax:  demogeatbx(ObjFun, OptVariant, NumVar)
%
% Input parameter:
%    ObjFun      - Scalar indicating the objective function to use
%                  if omitted or NaN, a menu will be shown with the 
%                  possible options
%
%    OptVariant  - Scalar or string indicating the optimization method to use
%                  when scalar:
%                     1: globally oriented optimization (multiple subpops)
%                     2: globally oriented optimization (1 subpop)
%                     3: locally oriented optimization
%                  when string:
%                     name of parameter file (including path and 
%                        extension when necessary)
%                  if omitted or NaN, a menu will be shown with the 
%                  possible options
%                  
%    NumVar      - Scalar indicating the number of variables to use 
%                     for the specified objective function
%                  if omitted or NaN, the number defined inside the 
%                     demo function will be used 
%
% Output parameter:
%    xout        - Vector/Matrix containing best/all individuals of last 
%                     generation - including best over all generations
%                     in first row
%    GeaOpt      - Structure with all options
%
% See also: geaoptset, geamain2

% Examples:
%   in Matlab
%   % use first objective function (objfun1), optimize with second 
%   % variant (globally oriented, 1 subpop) and use 4 variables in 
%   % objective function
%   >>demogeatbx(1, 2, 4)
%
%   % Same as above, but parameter file defined 
%   >>demogeatbx(1, 'tbx3specialpara.geaopt', 4)
%
%   % on command line (compiled version)
%   >>demogeatbx 1  2  4
%
%   >>demogeatbx 1 tbx3specialpara.geaopt 4


% Author:   Hartmut Pohlheim
% History:  02.06.1999  file created
%           03.06.1999  compilation successful
%           07.06.1999  many objfun's added
%           10.09.1999  use of parameter file as second parameter possible
%                       examples added to help text
%           12.01.2002  further functions added (objlive)
%           05.05.2002  function checked, screen output options into tbx3output
%                       special stuff for compilation only needed in R11


function [xout, GeaOpt] = demogeatbx(ObjFun, OptVariant, NumVar)

   % for compilation; 0: compilation, 1: no compilation, use menus
   CompVariant = 1;
   % Name of file with options
   OptionFile = '';

   % Check input
   if nargin < 1, ObjFun = []; end
   if ischar(ObjFun), ObjFun = str2num(ObjFun); end
   if isnan(ObjFun), ObjFun = []; end

   if nargin < 2, OptVariant = []; end
   if ischar(OptVariant),
      % Name of option file given
      if length(OptVariant) > 2, OptionFile = OptVariant;
      % Number of option variant given
      else OptVariant = str2num(OptVariant); end     % name of option variant given as number
   end
   if isnan(OptVariant), OptVariant = []; end

   if nargin < 3, NumVar = []; end
   if ischar(NumVar), NumVar = str2num(NumVar); end
   if isnan(NumVar), NumVar = []; end

   % Here are multiple variants of objective functions
   % Define objective function to use and the standard number of variables
   %#function objfun1 objfun1a objfun1b objfun1c objfun2 objfun6 objfun7 objfun8 objfun9 objfun10 objfun11 objfun12 
   %#function objbran objeaso objgold objsixh
   %#function objint1 objone1
   %#function mobjfonseca1 mobjfonseca2
   ObjFunStrings = {  'objfun1',     20 ...
                    ; 'objfun2',     10 ...
                    ; 'objfun6',     10 ...
                    ; 'objfun7',     10 ...
                    ; 'objfun8',     10 ...
                    ; 'objfun9',     10 ...
                    ; 'objfun10',    10 ...
                    ; 'objfun11',     5 ...
                    ; 'objfun12',    10 ...
                    ; 'objfun1a',    10 ...
                    ; 'objfun1b',    10 ...
                    ; 'objfun1c',    10 ...
                    ; 'objlive1',     2 ...
                    ; 'objlive1',    10 ...
                    ; 'mobjfonseca1', 2 ...
                    ; 'mobjfonseca2', 6 ...
                   };
   % Check for input parameter defining number of function to use, otherwise present menu
   if isempty(ObjFun),
      HeaderFunStrings = 'Please select objective function to use'; 
      % Menu text of function names can be created automatically (the objective functions know their descriptive name)
      ObjFunNames = {};
      for iname = 1:size(ObjFunStrings,1),
         CurObjFunName = geaobjpara(ObjFunStrings{iname,1}, [2, ObjFunStrings{iname,2}]);
         ObjFunNames = [ObjFunNames; {sprintf(' %s   (%s, %3d var)', CurObjFunName, ...
                                               ObjFunStrings{iname,1}, ObjFunStrings{iname,2})}];
      end
      if CompVariant == 1, ObjFun = menutext(HeaderFunStrings, ObjFunNames);
      else
         sprintf('Set first parameter of function\n   %s\n%s\n', ...
                   HeaderFunStrings, prprintf('      %s', '\n', [num2str((1:size(ObjFunStrings,1))','%4g. ') char(ObjFunNames)])),
         xnew = NaN; GeaOpt = []; return;
      end
   end
   objfun = ObjFunStrings{ObjFun, 1};
   GeaOpt = geaoptset( 'System.ObjFunFilename', objfun);
   
   % Get variable boundaries from objective function and set additional parameter
   if isempty(NumVar), NumDim = ObjFunStrings{ObjFun, 2}; else NumDim = NumVar; end
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [1, NumDim]);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB ...
                              , 'System.ObjFunAddPara', {} );
   
   % Use MO ranking only for MO functions
   if strcmp(GeaOpt.System.ObjFunFilename(1:4), 'mobj'),
      GeaOpt = geaoptset( GeaOpt , 'Selection.RankingMultiobj', 15 );
   end
                              
   % Definition of multiple variants of optimization methods with their 
   % corrsponding parameters
   VariantHeader =  'Please select the optimization method to use!';
   VariantData = {  'Globally oriented optimization (multiple subpops)' ...
                  , 'Globally oriented optimization (1 subpop)' ...
                  , 'Locally oriented optimization'  ...
                 };
   if isempty(OptVariant),
      if CompVariant == 1, OptVariant = menutext(VariantHeader, VariantData);
      else
         sprintf('Set second parameter of function\n   %s\n%s\n', ...
                   VariantHeader, prprintf('      %s', '\n', [num2str((1:length(VariantData))','%4g. ') char(VariantData)])),
         xnew = NaN; return;
      end
   end

   % Check value of OptVariant
   if ~(ischar(OptVariant)), 
      if ~(any(OptVariant == (1:3))), OptVariant = 1; end
      % Get parameters for 'Globally oriented optimization (multiple subpops)'
      if OptVariant == 1,
         % Get default parameters for real variables (globally oriented)
         GeaOpt = geaoptset(GeaOpt, tbx3real);    % mutation, recombination, variable format
         % Define special parameters
         GeaOpt = geaoptset( GeaOpt ...
                            , 'NumberSubpopulation',        4 ...       % Number of subpopulations
                            , 'NumberIndividuals',         [50] ...     % Number of individuals per subpopulation
                           );
      % Get parameters for 'Globally oriented optimization (1 subpop)'
      elseif OptVariant == 2,
         % Get default parameters for real variables (globally oriented)
         GeaOpt = geaoptset(GeaOpt, tbx3real);    % mutation, recombination, variable format
         % Define special parameters
         GeaOpt = geaoptset( GeaOpt ...
                            , 'NumberSubpopulation',        1 ...        % Number of subpopulations
                            , 'NumberIndividuals',         [200] ...     % Number of individuals per subpopulation
                            , 'Mutation.Range',            [1e-2] ...    % mutation range
                            , 'Mutation.Precision',        [24] ...      % mutation precision
                           );
      % Get parameters for 'Locally oriented optimization'
      elseif OptVariant == 3,
         % Get default parameters for real variables (globally oriented)
         GeaOpt = geaoptset(GeaOpt, tbx3es1);    % mutation, recombination, variable format, selection
      end
   
      % Define the screen output options
      GeaOpt = geaoptset( GeaOpt, tbx3output2 ...
                         , 'Output.TextInterval',        5 ...           % Text output every 5 generations
                         , 'Output.GrafikInterval',      20 ...          % Grafic results every 10 generations
                        );
      % Define the file output options, path and name of result data files, used for all optimization variants
      FileNameBase = straddtime(straddname('demogeatbx_01_', GeaOpt.System.ObjFunFilename));
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Output.SaveTextInterval',     0 ...                    % Text to File every xx generations
                         , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                         , 'Output.SaveBinDataInterval',  0 ...                   % Binary Data to File every xx generations
                         , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                        );
   
      % termination criteria with their options
      % maximal number of generations depending on number of variables
      MaxGenerations = 100 * floor(sqrt(NumDim));
      % MaxGenerations = 300;
      GeaOpt = geaoptset( GeaOpt ...
                            , 'Termination.Method',         [1 2] ...             % Termination method: use max gen and max time
                            , 'Termination.MaxGenerations', MaxGenerations  ...   % Terminate after xx generations
                            , 'Termination.MaxTime',        2.45  ...             % Maximal time (in minutes)
                           );

      % geaoptsave(GeaOpt, 'tbxreal_more.geaopt', '', 't');
   end

   % Load the parameter for optimization from special parameter option file
   if ischar(OptVariant), 
      % Check input data file name
      [OptFilePath, OptFileName, OptFileExt] = fileparts(OptVariant);
      OptionFileNamePath = fullfile(OptFilePath, [OptFileName OptFileExt]);
      % Get option data from file
      OptionData = geaoptload(OptionFileNamePath);
      % Set the options
      GeaOpt = geaoptset( GeaOpt , OptionData);
   end


   % Call main function for optimization
   PopInit = [];
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, PopInit);
   
   xout = xnew(1,:);


% End of function
