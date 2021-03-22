function GenerateTocXml(obj)
% this function generates the helptoc.xml file that controls the displayed
% table of contents in the matlab documentation of the toolbox.
%% Description:
%   Here comes a description. The Code-Word ist "Description" starting with
%   two %%. The Block ends when the next comment-Block starts (next two %%)
%   Each Block does contain a "Code-Word". Those will be stored in a dummy
%   object. 
%   
%% Syntax:
%   obj.GenerateTocXml
%
%% Input:
%   no direct inputs
%       requires obj.outputFolder
%       requires obj.fileList
%       requires obj.toc
%
%% Output:
%   saves helptoc.xml to the folder specified by obj.outputFolder
%
%% References:
%   m2html - lines 654 - 690 - used as inspiration
%
%% Disclaimer:
%
% Author: Pierre Ollfisch
% Copyright (c) 2021

%% generate file to write toc to
tocFile = fullfile(obj.outputFolder,"helptoc.xml");
[tocFid, debugMsg] = fopen(tocFile,'wt');

%% write standard beginning of file
fprintf(tocFid,'<?xml version=''1.0'' encoding=''utf-8'' ?>\n');
fprintf(tocFid,'<!-- $Date: %s $ -->\n\n', datestr(now,31));
fprintf(tocFid,'<toc version="2.0">\n\n');
%% write toc struture of toolbox into file
writeTocRec(tocFid, obj.fileList, obj.toc, "", "");

%% close file
fprintf(tocFid,'\n</toc>');
fclose(tocFid);
disp("Generated the helptoc.xml file!")
end % end function GenerateTocXml
% ---------------- start local functions ---------------

function writeTocRec(tocFid, fileList, tocCell, preTxt, tocPath)
currTocCell = tocCell;
currPreTxt  = preTxt; % preTxt are the spaces before a line in the xml document
% index i:  toc element from currToc
% index ii: file element from fileList
for i = 1:size(currTocCell,1)
    % loop through the currrent elements in the toc cell
    % add files to that element if available
    currTocElement  = currTocCell{i,1};
    currTocPath     = fullfile(tocPath, currTocElement);
    % write current element to file
    pathToHtml      = ".html"; % complete path to html file (link of text) 
    pathToHtml      = getHeadingHTMLPath(currTocElement);
    tocName         = currTocElement; % Text that will appear in the toc
    % fprintf(%s spaces  %s relative-path-to-html-file  %s displayed name)
    fprintf(tocFid,['%s<tocitem target="%s" ', ... 
        'image="$toolbox/matlab/icons/book_mat.gif">%s\n'], ...
        currPreTxt, pathToHtml, tocName); 
    
    % loop throoug file list and add all files that belong to that toc
    for ii = 1:size(fileList,1)
        tmpFileToc  = fileList(ii).toc;
        tmpFileName = fileList(ii).name;
        if tmpFileToc == currTocPath
            % fprintf(%s spaces  %s path_to_html_file  %s displayed name);
            preSpaces = preTxt + "    ";
            htmlpath  = fullfile(fileList(ii).htmlOutputPath, tmpFileName + ".html");
            fileName = tmpFileName;
            fprintf(tocFid,'%s<tocitem target="%s">%s</tocitem>\n', ...
					preSpaces, htmlpath, fileName);
        end
    end
    
    % if available, do the loop on subelements of that toc
    if ~isempty(currTocCell{i,3}) && iscell(currTocCell{i,3})
        newPreTxt = currPreTxt + "    ";
        writeTocRec(tocFid, fileList, currTocCell{i,3}, newPreTxt, currTocPath);
    end
    
    % close current toc element
    fprintf(tocFid,'%s</tocitem>\n', currPreTxt);
end % end for i
end % end local function writeTocRec

function htmlPath = getHeadingHTMLPath(myName)
% by default it should display a html file with the same name
htmlPath = myName + ".html";
end % end function getHeadingPath