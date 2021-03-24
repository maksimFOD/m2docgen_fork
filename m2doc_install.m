% installing m2doc Toolbox
%% Description
% The Toolbox will be installed by adding the folder to the matlab search path
% 
% Hint: you can fast install the toolbox by marking this file in the MATLAB
% "Current Folder Browser" and pressing F9. So you do not need to open the
% script. 

cd(fileparts(which(mfilename)));
addpath(genpath('.'));
disp("m2doc is Installed / Added!");
% eof;