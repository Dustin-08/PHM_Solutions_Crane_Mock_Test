% SAVing BINary DATA to a file with a Secure Protokoll
%
% Interface to the function savebindata2 employing a secure protokoll
% for the access to the data file by the saving process and an 
% external process.
% Before accessing the data file the existence of a send lock file is
% tested (background: another process accesses the data file for 
% sending it to another computer). When the lock file exists, the 
% reading/saving is delayed.
% Before saving a write lock file is created in the directory of
% the data file. This signals the other process, that the file can 
% not be accessed.
% The name of send and write flag file is created from the name of 
% the data file and the prefix 'send_' and 'write_' respectively.
% The actual saving is done by the standard function savebindata2. 
%
% Syntax:  savebindatasp(FileLS, varargin)
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
%    SaveStatus - Scalar defining the result of the save operation
%
% Example:
%  % mat-file 'filename.mat' doesn't exist
%  >>savebindata2('FileName', 'var2', var2, 'var3', var3)
%  % now mat-file 'filename.mat' contains 1 struct variable 
%  % called 'GEATbxData' with 2 fields called: 'var2' and 'var3'
%
% See also: geamain2

%  Author:  Hartmut Pohlheim
%  History: 22.06.2002  file created


function SaveStatus = savebindatasp(FileLS, varargin)

   % Preset the status of the saving process (not used currently)
   SaveStatus = 0;

   % Get the file name parts
   [FP, FN, FE] = fileparts(FileLS);
      
   % Create Write-Flag file 
   FFE = '.lck';
   WFName = fullfile(FP, ['write_', FN, FFE]);
   [FlagId, ErrMessage] = fopen(WFName, 'w');
   
   if FlagId == -1,
      warning(sprintf('Error during fopen of the Write-Flag file (%s): %s', WFName, ErrMessage)); return;
   else fprintf(FlagId, 'Write-Flag'); fclose (FlagId); end

   % Create file name for send file
   SFName = fullfile(FP, ['send_', FN, FFE]);
   SFFileExist = 1;
   % Wait while send-flag exist, pause reduces processor burden
   while all([SFFileExist >= 1, SFFileExist < 120]),
      [fidgen, error_message] = fopen(SFName, 'r');
      % Flag file does not exist, go out of while loop and proceed
      if fidgen == -1, SFFileExist = 0;
      % Flag file exists, wait till it is deleted by other process
      else
         fclose(fidgen);
         SFFileExist = SFFileExist + 1;
         % Include here the pause (1) command when compiling with R12/Compiler 2.1
         % pause(1)
         for ipause = 1:1e4, a = sqrt(ipause); end
         if SFFileExist == 2,
            warning(sprintf('Waiting with save bin data (max 2min), other process is activ (or flag file %s was not deleted)\n', SFName));
         end
      end
   end

   if SFFileExist == 0,
      savebindata2(FileLS, varargin{:});
   else
      warning(sprintf('Save of binary data failed, other process is still activ (or flag file %s was not deleted)\n', SFName));
   end
      
   % Remove the Write-flag file (the delete command can only be compiled with Matlab6)
   dos(['del ', WFName, ' &;']);
   % delete(WFName);


% End of function
