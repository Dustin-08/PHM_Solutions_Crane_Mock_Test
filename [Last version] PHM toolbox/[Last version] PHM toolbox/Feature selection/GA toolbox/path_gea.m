% Set all paths for the GEA toolbox (Matlab search path)
%
% This file is configured to add all paths of the GEATbx to
% the Matlab search path. It must be started from the main 
% directory of the GEATbx
%
% This file can work for multiple Matlab installations (multi 
% user and multi version) and multiple operating systems.
% For multiple users put it in a central place. Then all 
% users can access this file to add the defined paths 
% to their Matlab search path.
% The existing Matlab search path is just extended. Thus, 
% this m-file works for all users on the same network.
%
% Syntax: path_gea
% 
% This file can be called by hand at the beginning of a 
% Matlab session (just change to the directory of the GEATbx
% and call path_gea).
%   Or
% This file can be called by the startup-file in
% MATLABROOT\toolbox\local    for WIN32
% ~/matlab                    for UNIX
%   Or
% Include the main directory (where this file is) in the matlab 
% search path and call path_gea everywhere
% 
% Examples:
% % change to main GEATbx directory  - user specific (recommended)
% >> cd MATLABROOT\toolbox\geatbx
% % call path script, adding all necessary search paths for GEATbx
% >> path_gea
% % the extended path may be saved for later sessions by calling: 
% % File / Set path ...  and selecting Save.
%
% % inclusion in startup m-file (startup.m).
% pwdact = pwd;
% % change directory to find path_gea.m
% if strcmp(computer,'PCWIN')
%    cd P:ATH\TO\geatbx;
% else cd /PATH/TO/geatbx; end;
% % set the new path
% path_gea;
% % and return
% cd(pwdact);
%
% Then, all the necesary path information will be included 
% in the MATLAB path (added at the end of the MATLAB path).

% Author:   Hartmut Pohlheim
% History:  30.02.2000  reworked
%           26.08.2001  docu extended
%           08.12.2002  relative paths used
%           28.05.2005  tsp and vrp path for examples added 
%           19.08.2006  script name changed to path_gea (better naming)
%                       use of addpath instead of matlabpath (no Div necessary)
%                       no differentiation between operating systems necessary
%           11.11.2006  can be called from everywhere, when main directory is on path


   % Path2GEATbx = 'I:NCLUDE\ABSOLUTE\PATH\geatbx\';   % absolute path
   % Path2GEATbx = [pwd, filesep];                       % relative path, current dir
   Path2GEATbx = [fileparts(which(mfilename)) , filesep];  % this file is on the Matlab search path

   % Add the directory and all subdirectories of GEATbx to the Matlab search path
   addpath(  Path2GEATbx ...           
          , [Path2GEATbx 'objfun' ] ...    
          , [Path2GEATbx 'plotext'] ...   
          , [Path2GEATbx 'scripts'] ...   
          , [Path2GEATbx 'utils'  ] ...
          , [Path2GEATbx 'objfun' filesep 'tsp'] ...    
          , [Path2GEATbx 'objfun' filesep 'vrp'] ...   
          , '-end' ... 
       );

   clear Path2GEATbx;


% End of script
