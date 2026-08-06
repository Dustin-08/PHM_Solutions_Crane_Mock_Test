% Get special data from objective function (boundaries, function name, ...)
%
% The given objective function (filename in ObjFun) is called with 
% a special syntax. Depending on ParaWhat a special parameter or option
% of the objective function is returned.
% By default the following options are supported:
%  - boundaries of the variables (VLUB)
%  - descriptive name of the objective function
%  - global minimum (best objective value)
% Additionally, for a variable number of variables and/or objective values
% this number can be defined/set using a further parameter (see Examples).
% The values for these parameters/options must be set inside the objective
% function. See objfun1 for an example.
% The Example section below will provide examples for all these possibilities.
%
% This function handles all different methods ever used for calling an
% objective function in the GEATbx.
%
% Syntax:  ObjFunPara = geaobjpara(ObjFun, ParaWhat, AddPara)
%
% Input parameter:
%    ObjFun    - String containing the name of the objective function
%    ParaWhat  - (optional) Scalar indicating which parameter/option to return
%                   1: boundaries of variables (defines dimension of problem at the same time)
%                   2: descriptive name for objective function
%                   3: global optimum (when known), not useful for MO functions
%                  11: set the number of objectives (only useful for MO functions 
%                         with a variable number of objectives)
%                  16: get the goals for (multiple) objectives
%                  21: get the association between variables and objective values
%                         (only useful for MO functions, when not every variable 
%                          contributes to each objective value)
%    AddPara   - (optional) additional parameter(s) for objective function
%
% Output parameter:
%    ObjFunPara- requested parameter or option depending on ParaWhat
%
% Examples:
% % Get variable boundaries for objfun1
% >> VLUB = geaobjpara('objfun1')
%
% % Get variable boundaries for objfun2 for exact 12 variables
% >> VLUB = geaobjpara('objfun2', [1 12])
%
% % Define the use of 14 objectives for following calls of the MO function mobjdtlz1
% >> geaobjpara('mobjdtlz1', [11 14])
%
% % Get the goals for the (multiple) objectives of the function
% >> Goals = geaobjpara('mobjbahinconstr', [16])
%
% See also: geamain2, objfun1

% Author:   Hartmut Pohlheim
% History:  06.05.2002  file created
%           05.10.2002  added handling for Var2ObjV parameter
%           23.01.2005  added example for setting number of objectives
%           29.01.2006  added handling for MObjGoals parameter


function ObjFunPara = geaobjpara(ObjFun, ParaWhat, varargin)

   NAIN = nargin; NAOUT = nargout;
   ObjFunPara = [];

   % Check input parameters
   if NAIN < 1, warning('Nothing to do.'); return; end
   if NAIN < 2, ParaWhat = []; end
   if isnan(ParaWhat), ParaWhat = []; end
   if isempty(ParaWhat), ParaWhat = 1; end
   if length(ParaWhat) > 1, ParaWhatPara = ParaWhat(2); else ParaWhatPara = []; end
   if isnan(ParaWhatPara), ParaWhatPara = []; end
   ParaWhat = ParaWhat(1);

   % Test for the diferent parameter providing methods, first the newest, then ...
   CallMethod = 'Struct2NaN';
   try,
      % Use the newest calling method (version 3.4 and up)
      ObjFunStruct = feval(ObjFun, [NaN, NaN, 1], varargin{:});
      % Check if the returned stuff is a struct, if yes, we have all parameters and can start the work
      if ~(isstruct(ObjFunStruct)), error('Just for producing an error and triggering the catch branch.'); end

   catch 
      % message only activated in GEATbx version 3.5 and higher
      % sprintf('Function %s uses an old method to provide its parameters. Please rewrite it the the new method used in GEATbx version 3.4 and newer.', ObjFunFilename);
      CallMethod = 'Vector1NaN';
      try,
         % Look for VLUB with older calling method (up to version 3.3), must have 2 rows
         ObjFunPara = feval(ObjFun, [NaN, 1], varargin{:});
         % When VLUB contains two rows, it looks correct
         if ~(size(ObjFunPara, 1) == 2), error('Just for producing an error and triggering the catch branch.'); end

      catch,
         CallMethod = 'VectorEmpty';
         try,
            % very old calling method, used in version 1.9x and partly 2.x
            ObjFunPara = feval(ObjFun, [], 1, varargin{:});
            if ~(size(ObjFunPara, 1) == 2), error('Just for producing an error and triggering the catch branch.'); end

         catch,
            warning(sprintf('Could not get the special data (boundaries, name or global optimum) automatically from the objective function (%s)!', ObjFun));
         end
      end
   end

   if strcmp(CallMethod, 'Struct2NaN'),
      if isstruct(ObjFunStruct),
         ObjFunStruct = objfunoptset(ObjFunStruct);
         % boundaries of variables 
         if ParaWhat == 1,
            ObjFunPara = [ObjFunStruct.VarBoundMin; ObjFunStruct.VarBoundMax];
            if isempty(ParaWhatPara), ParaWhatPara = ObjFunStruct.NumVarDefault; end
            ParaWhatPara = max(ObjFunStruct.NumVarMin, min(ParaWhatPara, ObjFunStruct.NumVarMax));
         % Name of function
         elseif ParaWhat == 2, ObjFunPara = ObjFunStruct.FunctionName;
         % Global minimum
         elseif ParaWhat == 3, ObjFunPara = ObjFunStruct.GlobalMinObjV;
         % Set the number of (multi-) objective values to use
         elseif ParaWhat == 11, 
            if isempty(ParaWhatPara), ParaWhatPara = ObjFunStruct.NumObjDefault; end
            ParaWhatPara = max(ObjFunStruct.NumObjMin, min(ParaWhatPara, ObjFunStruct.NumObjMax));
            feval(ObjFun, [NaN, NaN, 11, ParaWhatPara]);
            % disp(sprintf('  %s: number of objective values was set to %d.', ObjFun, ParaWhatPara));
         % Get the goals for the (multi) objective function
         elseif ParaWhat == 16,
            if isfield(ObjFunStruct, 'MObjGoals'),
               ObjFunPara = ObjFunStruct.MObjGoals;
            else
               ObjFunPara = [];
            end
         % Special cell array with the variables to objective values association
         elseif ParaWhat == 21, 
            if isempty(ParaWhatPara), ParaWhatPara = ObjFunStruct.NumVarDefault; end
            ParaWhatPara = max(ObjFunStruct.NumVarMin, min(ParaWhatPara, ObjFunStruct.NumVarMax));
            Var2ObjV = feval(ObjFun, [NaN, NaN, 21, ParaWhatPara]);
            % disp(sprintf('  %s: Var2ObjV is set to:\n%s.', ObjFun, prprintf(Var2ObjV)));
            ObjFunPara = Var2ObjV;
         % Return just the complete parameter structure
         elseif isinf(ParaWhat), ObjFunPara = ObjFunStruct;
         else warning('Parameter is not assigned to an option of objective function.'); ObjFunPara = [];
         end
      end

   elseif strcmp(CallMethod, 'Vector1NaN'),
      if ParaWhat == 1, % the correct data is already known
      else ObjFunPara = feval(ObjFun, [NaN, ParaWhat], varargin{:}); end

   elseif strcmp(CallMethod, 'VectorEmpty'),
      if ParaWhat == 1,  % the correct data is already known
      else ObjFunPara = feval(ObjFun, [], ParaWhat, varargin{:}); end
   end

   % Set the number of variable boundaries to the asked for number
   if all([ParaWhat == 1, ~(isempty(ParaWhatPara)), ~(isempty(ObjFunPara))]),  
      if size(ObjFunPara, 2) ~= ParaWhatPara,
         ObjFunPara = repmat(ObjFunPara, [1, ceil(ParaWhatPara/size(ObjFunPara, 2))]);
         ObjFunPara = ObjFunPara(:, 1:ParaWhatPara);
      end
   end


% End of function