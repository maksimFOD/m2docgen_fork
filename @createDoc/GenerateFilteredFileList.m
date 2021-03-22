function GenerateFilteredFileList(obj)
% This function save the filtered list of .m / .mlx files into the
% createDoc object. 
%
%% Description:
% This function save the filtered list of .m / .mlx files into the
% createDoc object. The list is generated by first listing all files that
% end in .m in the obj.mFolder folder (incl .m .mat .mlx...), then filters
% the out the unnecessary struct fields (e.g. date and filesize).
% Additionally, all non .m/.mlx files are filtered out and a new field just
% for the extension and relative path is added. Lastly, all files whose 
% path or names contains elements from opts.excludeFolder or 
% opts.excludeFile areremoved.
%
%% Inputs:
%   no inputs
%
%% Outputs:
%   no direct outputs
%       saves obj.fileList
%
%% Syntax:
%   obj.GenerateFilteredFileList;
%
%% Disclaimer:
%
% Author: Nils Böhnisch
% Copyright (c) 2021

%% generate overview of all files with .m as part of the name
allFileList = dir(fullfile(obj.mFolder, '**\*.m*'));

%% remove unwanted struct fields from allFileList
allFileList = rmfield(allFileList, ["date" "datenum" "bytes" "isdir"]);

%% add fields "ext" + "relPath" and remove extension from name
mypath = "";
myName = "";
myext = "";
relPath = "";
for i = 1:length(allFileList)
    [tmpPath,tmpName, myExt] = fileparts(fullfile(allFileList(i).folder, allFileList(i).name));
    mypath(i)   = tmpPath;
    myName(i)   = tmpName;
    myext(i)    = myExt;
    allFileList(i).name = tmpName;
    relPathtmp	= split(tmpPath, obj.mFolder);
    relPath(i)  = relPathtmp{end};
    
end
% add extension field
[allFileList.ext] = myext{:};
% add relpath field
[allFileList.relPath] = relPath{:};

%% remove all non .m / .mlx files
allExt      = string({allFileList.ext});
idxExt      = allExt == ".m" | allExt == ".mlx";
allFileList = allFileList(idxExt);

%% remove all unwanted folders
allFolders  = string({allFileList.folder});
if obj.excludeFolder == ""
    % no filtering needed
else
    idxFolder   = ~contains(allFolders, obj.excludeFolder);
    allFileList = allFileList(idxFolder);
end

%% remove all unwanted files
allFiles    = string({allFileList.name});
if obj.excludeFile == ""
    % no filtering needed
else
    idxName = ~contains(allFiles, obj.excludeFile);
    allFileList = allFileList(idxName);
end

%% return list to object
obj.fileList = allFileList;
if obj.verbose
    disp("Sucessfully created list of files with " + length(allFileList) + " elements!");
end
end