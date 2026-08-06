% INtegration of ODE's using RUNGE-KUTTA-formula 4
%
% This function implements the vectorized RUNGE-KUTTA-Integrator 4.
%
% Syntax:  [Timevec, Result] = intrk4(SIM_F, Times, XINIT, Options, Control, P1-Px)
%
% Input parameters:
%    SIM_F     - function to simulate
%    Times     - vector containing TStart (start time - optional) and TEnd (end time)
%    XINIT     - initial values for the simulation of the individuals
%                every row contains the initial values for 1 individual
%    Options   - vector containing [ERRMAX: max. rel. error, STEPMIN: min. stepsize, STEPMAX: max. stepsize, ...
%                                   (optional) NCONTR: number of control variables]
%    Control   - control vector/matrix, every row is one control vector
%                format:   1. ControlVariable  2. ControlVariable ...  NCONTR. ControlVariable
%                         --------------------------------------------------------------------
%                  Ind1: | 1:ControlSteps      1:ControlSteps     ...  1:ControlSteps
%                  Ind2: | 1:ControlSteps      1:ControlSteps     ...  1:ControlSteps
%    P1 - Px   - (optional) parameters passed through to simulation function
%
% Output parameters:
%    Timesim   - vector containing time of simulation steps
%    Result    - results, state vectors
%                format:   1. ControlVariable  2. ControlVariable ...  NCONTR. ControlVariable
%                         --------------------------------------------------------------------
%                  Ind1: | 1:ControlSteps      1:ControlSteps     ...  1:ControlSteps
%                  Ind2: | 1:ControlSteps      1:ControlSteps     ...  1:ControlSteps
%
% See also: objdopi, inteul

% Author:     Hartmut Pohlheim
% History:    24.10.94     file created
%             26.02.95     aditional parameters added
%             16.05.95     same format as rk23/rk45, here vectorized
%             17.05.95     final definition of parameterformat (quite complicated)
%             18.05.95     renamed to intrk4.m, Runge-Kutta 4 implemented
%             29.04.96     definition of simevalstr changed, made problem with error
%             21.01.98     small adjustement for Matlab5 (TIMEVEC(:), Part(:))


function [Timesim, Result] = intrk4(SIM_F, Times, XINIT, Options, Control, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10)

% Time construction
   if nargin < 2, Times = []; end
   if isempty(Times), error('At least the end time must be defined for the simulation.'); end
   [ts, te] = size(Times);
   if (ts*te) == 1, Times = [ 0, Times(1)]; end
   TStart = Times(1); TEnd = Times(2);
   
% check input parameter XINIT
   if nargin < 3, XINIT = []; end
   if isempty(XINIT), error('The initial value(s) must be defined for the simulation.'); end

% check input parameter Options
   if nargin < 4, Options = []; end
   if isempty(Options), Options = 1e-3; end
   if length(Options) < 2, Options(2) = (TEnd-TStart)/2000; end
   if length(Options) < 3, Options(3) = (TEnd-TStart)/50; end
   if length(Options) < 4, Options(4) = 0; end
   ERRMAX = Options(1); STEPMIN = Options(2); STEPMAX = Options(3); NCONTR = Options(4);

% check input parameter Control
   if nargin < 5, Control = []; end
   if isempty(Control),
      if NCONTR ~= 0, error('No control vector/matrix defined for the simulation.'); end,
   end

% Compute population parameters
   [NIND, Nvar] = size(XINIT);
   [NI, NCont] = size(Control);

% wenn Control noch nicht kopiert oder konstant fuer alle Schritte
   if NCONTR > 0,
      if rem(NCont, NCONTR) ~= 0, error('NCONTR and size of Control matrix disagree.'); end
      % compute number of control steps
      ControlSteps = NCont/NCONTR;
      % if Control is konstant for all steps, we need only one Control for all steps;
      % however, 2 steps are needed for table lookup
      if ControlSteps == 1,
         Control = expandm(Control, [1, 2]);
         NCont = 2 * NCONTR; ControlSteps = 2;
      end
      % compute time vector according to number of control steps
      TIMEVEC = linspace(TStart, TEnd, ControlSteps);
      TIMEVEC = TIMEVEC(:);
      % reshape Control for table lookup, every row contains all variables for one time step
      % format:                  1. Ind      2. Ind
      %         ControlStep 1    1:NCONTR    1:NCONTR
      %         ControlStep 2    1:NCONTR    1:NCONTR
      ControlTable = [];
      for i = 1:ControlSteps, 
         % Part(:) = Control(:, (i-1)*NCONTR+1:i*NCONTR)';
         Part = Control(:, i:ControlSteps:i+(NCONTR-1)*ControlSteps)';
         Part = Part(:);
         ControlTable = [ControlTable; Part'];
      end
   end

% Build string of simulation function
   simevalstr = ['xdot = ' SIM_F]; flag = 1;
   simevalstr = [simevalstr, '(Trk, Xrk, U, flag'];
   for i = 1:nargin-5
      simevalstr = [simevalstr, ',P', int2str(i)];
   end
   simevalstr = [simevalstr, ');'];

% perform simulation steps
   T = TStart; Timesim = T; DoSim = 1; X = XINIT'; Result = XINIT;
   SimStep = STEPMIN;
   while DoSim == 1,
      % compute size of next step
      if (TEnd-TStart) > 0,
         if T+SimStep > TEnd, SimStep = TEnd - T; end,
      else 
         if T+SimStep < TEnd, SimStep = TEnd - T; end,
      end
      % check, if simulation reached end of time, depends on direction of simulation
      if (TEnd-TStart) > 0, if T+eps >= TEnd, DoSim = 0; end,
      else                  if T+eps <= TEnd, DoSim = 0; end, end

      if DoSim == 1,
         RKTime = [0, .5, .5, 1];
         RKPart = [.5, .5, 1, 0];
         RKValue = [1/6, 1/3, 1/3, 1/6];
         % Xval = zeros(size(X,1),4*size(X,2));
         Xrk = X; Xnew = X; 
         for i = 1:4,
            if NCONTR ~= 0,
               % lookup the contol values for the actual step
               U = table1([TIMEVEC, ControlTable], T+SimStep*RKTime(i)); 
               U = reshape(U, NCONTR, NIND);      % one column per individium
            else U = []; end

            Trk = T + SimStep*RKTime(i);
            % compute 1 simulation step
            eval(simevalstr);
            % Xval(:,(i-1)*Nind+1:i*Nind) = xdot * SimStep;
            Xrk = X + RKPart(i) * xdot * SimStep;
            Xnew = Xnew + RKValue(i) * xdot * SimStep;
         end
         X = Xnew;
         T = T + SimStep;

         % save Result in 1 row per individual,
         % all individuals of 1 time step at once in rows underneath,
         % then the individuls of the next time step 
         Result = [Result; X'];
         Timesim = [Timesim; T];

      end
   end


% End of function
