% SAVing BINary DATA to a file and provide the data with any name
%
% The even input variables in varargin ({1}, {3}, ...) are assigned 
% to variables. The names of these variables are given in the odd input 
% variables in varargin ({2}, {4}, ...). Thus, the name can be defined 
% freely in the calling function.
% Then all variables are saved to the data mat-file defined in FileLS.
% However, the new variables are appended to the mat file, variables of 
% the same name are replaced.
%
% This function is written for Matlab >=5.x.
% For Matlab 4.x please use loadsave with a similar functionality.
%
% Syntax:  savebindata2(FileLS, varargin)
%
% Input parameters:
%    FileLS    - String containing the name of the mat-file
%                   if the file doesn't exist, it will be created
%    P1-Pxx    - (optional) input variables (all in varargin)
%                   even numbers: string containing name of next variable
%                   odd  numbers: variable
%                   example: P1 contains the name of the variable in P2
%                            P3 the name of the variable in P4 and so on
%
% Output parameter:
%    no output parameter
%
% Example:
%  % mat-file 'filename.mat' doesn't exist
%  >>savebindata2('FileName', 'var2', var2, 'var3', var3)
%  % now mat-file 'filename.mat' contains 1 struct variable 
%  % called 'GEATbxData' with 2 fields called: 'var2' and 'var3'
%
%  >>savebindata2('FileName', 'hell5', hell5, 'blurr2', blurr2)
%  % now mat-file 'filename.mat' contains 1 struct variable 
%  % called 'GEATbxData' with 4 fields called: 'var2', 'var3', 'hell5', 'blurr2'
%
% See also: geamain2

%  Author:  Hartmut Pohlheim
%  History: 02.12.2001  file created (copy from savebindata.m)
%                       variables are saved in struct, thus dynamical
%                       naming possible (can be compiled)
%           22.06.2002  direct save command inside try catch, prevents
%                       some very rare error messages (file is locked 
%                       by external process)



function savebindata2(FileLS, varargin)

   % Set internal variables
   GEATbxData = []; 
   
   % Get the data stuff
   sbdData = varargin;

   % Create a full file name (extension)
   [FP, FN, FE] = fileparts(FileLS);
   if isempty(FE), FE = '.mat'; end
   FileLSFull = fullfile(FP, [FN, FE]);
   
   % Try to open the save file
   [fidgen, error_message] = fopen(FileLSFull, 'r');
   FileLSexists = 1;
   % When file could not be opened for reading, file does not exist (normally)
   if fidgen == -1,
      FileLSexists = 0;
      [fidgen, error_message] = fopen(FileLSFull, 'w+');
      % When file could not be created, a serious error occured
      if fidgen == -1,
         warning(sprintf('Error during fopen of file for saving binary data (%s): %s', ...
                      FileLSFull, error_message));
         return;
      else fclose(fidgen); end
   else fclose(fidgen); end

   % Load the contents from the data file (but only, when file exists)
   if FileLSexists == 1,
      try,
         FileData = load(FileLSFull);
         if isfield(FileData, 'GEATbxData'),
            GEATbxData = getfield(FileData, 'GEATbxData');
         end
      catch,
         warning('Loading of existing BinData file failed, proceed with writing file anew.');
      end
   end

   % Assign values of variables to correctly named variables 
   % length(Data)
   for irun = 1:2:length(sbdData)-1,
      GEATbxData = setfield(GEATbxData, sbdData{irun}, sbdData{irun+1});
      % prprintf(GEATbxData)
   end

   % clear varargin sbdData irun sbdvariant sbdFileAppend FileData

   % Save struct variable to file (in a secure context)
   try,
      save(FileLSFull, 'GEATbxData');
   catch,
      warning('Saving of binary data failed (save command failed). Sorry, no further help.');
   end


% End of function
