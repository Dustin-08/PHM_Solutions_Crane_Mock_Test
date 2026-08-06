% GEATbx  Utility functions (often useful outside GEATbx as well)
%
% Setting GEATbx parameters (incl. load and save of parameter sets)
% geaobjpara    - Get special data from objective function (boundaries, function name, ...)
% geaoptset     - Create/alters GEAOPTions structure for parameter SETtings of GEA Toolbox
% geaoptload    - LOAD OPTions from a text file
% geaoptsave    - SAVE a GEAOPTions structure to a matlab file
% objfunoptset  - Create/alter OPTions structure for parameter SETtings of OBJective FUNctions
% paraoptset    - Create/alter PARAOPTions structure
%
% Output of GEATbx parameters nicely formatted and the GEATbx optimization status
% geaoptprint   - Print GEAOPTions structure of GEA Toolbox nicely formatted into a string
% gearunstatus  - Prints RUN STATUS of GEA Toolbox nicely formatted into a string
%
% Boundary checking and collection of individuals (archive in MO optimization)
% chkbound      - CHecK the boundaries of variables and set to boundaries when outside
% colbestind    - Collect best individuals during an optimization run
%
% Replication and expansion of Matlab variables
% rep           - REPlicate a matrix, utility function
% expandm       - EXPAND a Matrix, utility function
% expandvec     - This function replicates a vector vec
%
% Handling of field names
% fieldnames_full - Create cell array with all full fieldnames of given structure
% fieldnames_parts - Decompose long/full fieldnames into their parts
%
% Search for files by search mask
% findfiles     - Find Files regarding a search mask 
% findfilesup   - Find Files upwards the directory structure regarding a search mask 
%
% Helper functions for visualization
% plotstd       - change appearance of PLOT in a STanDard way
% visuminmaxdiff - Compute minimum and maximum of provided data and a scaling difference between both
% prprintf      - Pretty Print formated of variable
%
% Save the Matlab variables in a named manner (needed for off-line visualization and saving of all results) 
% savebindata   - SAVing BINary DATA to a file by appending variables
% savebindata2  - SAVing BINary DATA to a file and provide the data with any name
% savebindatasp - SAVing BINary DATA to a file with a Secure Protokoll
% loadsave      - LOADing of data from a file and SAVing these data and more to the same file
%
% String handling functions (extend file names, deblank on both sides)
% straddname    - Add a special name to a string/file name
% straddtime    - Add a date and time string to a string base
% deblankall    - Remove leading and trailing Spaces from string or cell array of strings
%
% Special utility functions
% asknondom     - Ask for the percentage of non-dominated individuals in a population
% inteul        - Integration of ODE's using EULER's formula
% intrk4        - INtegration of ODE's using RUNGE-KUTTA-formula 4
% hdrload       - HDRLOAD Load data from an ASCII file containing a text header.
% menutext      - Generate a text menu of choices for user input (no graphical menu)
%%
% AutoAdd
% paraoptexample - Create/alter PARAOPTions structure
% paraoptload   - LOAD PARAOPTions from a text file
% paraoptpropexample - Create a default PARAOPTions cell array containing the definition of possible options
% paraoptsave   - SAVE a PARAOPTions structure to a text or matlab file
% geanumind     - Calculate number of subpopulations and individuals for GEATbx

















