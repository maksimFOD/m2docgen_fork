classdef TemplateHTML < handle
% insert text dummys into html template, also does markup
%% Description:
%   This function reads in a template of a HTML document that includes
%   markings where to insert the text dummys from MFile.parse. It will be
%   stored in obj.str. Then it loops through all dummys and inserts them
%   accordingly. While doing that, some highlighting occurs.
%   
%% Syntax:
%   dm = TemplateHTML(name, templateFolder, outFolder, styleFolder, ...
%                       homePath, verbose);
%
%% Input:
% required input values;
%   name            - name of the m-file: "string"
%                     Name of the m-file that is converted to an HTML file 
%                     (including extension) 
%   templateFolder  - folder to template: "string"
%                     Absolute path to the template folder within m2doc 
%                     that contains all html templates and meta files.
%   outFolder       - output folder: "string"
%                     Target folder where to save the HTML document
%   styleFolder     - meta folder path: "string"
%                     relative path to the folder containing meta files
%                     (css, images), relative to the outFolder
%   homePath        - home target site: "string"
%                     relative path to the page that should open when
%                     clicking the home symbol on the website. Relative to
%                     outFolder. 
%   verbose         - debugging flag: logical
%                     if true then infos for each file will be spammed into
%                     the command line.
%
%% Properties:
%   name            - name of m-file, after constructor without extension
%   templateFolder  - see inputs
%   outFolder       - see inputs
%   styleFolder     - see inputs
%   homePath        - see inputs
%   verbose         - see inputs
%   str             - entire html document: "string"
%                     At first only the preformatted html template, but is
%                     filled with all text dummys.
%
%% Disclaimer:
%
% Last editor:  Pierre Ollfisch
% Last edit on: 03.05.2021
% Code version: 1.1
% Copyright (c) 2021
    
    %% Properties
    properties
        name        string;     % name of the currently converting m-file
        str         string;     % at first only template, after parseStr also the entire content
        % Ref Folder
        templFolder string;     % root where templates are located
        % For Output:
        outFolder   string;     % Output folder: Here will the html be stored
        styleFolder string;     % Ref Folder where style are located for the output
        homePath    string;     % Path to home.html
        htmlSegmentPath string = "html_segments"; % path within the @TemplateHTML folder to the folder with the segment blocks
        verbose     logical;    % controls how much spam will be printed to the command window
    end
    properties (Dependent)
        listFilKeys string;
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = TemplateHTML(name,templateFolder,outFolder,styleFolder,homePath, verbose)
            % TemplateHTML Construct an instance of this class
            
            % Set location where template get from
            docTemplate ="html_Template.tpl"; % template for header and footer
            contentTemplate = "mfile.tpl";
            
            [fpath,fname,fext] = fileparts(name);
            obj.name = fname;
            obj.templFolder = templateFolder; % folder with css and logos etc
            docpath = fullfile(obj.templFolder,docTemplate); % global path to general doc file
            thisPath = mfilename('fullpath');
            contPath = fullfile(fileparts(thisPath),obj.htmlSegmentPath,contentTemplate);
            
            % Set Output folder
            obj.outFolder = outFolder;
            obj.styleFolder = styleFolder;
            obj.homePath = homePath;
            
            % Read both template files (general documentation + content)
            fil = fopen(docpath);
            docDat = textscan(fil,'%s','delimiter','\n');
            fclose(fil);
            fil = fopen(contPath);
            contDat = textscan(fil,"%s","delimiter",'\n');
            fclose(fil);
            docStr = string(docDat{1});
            contStr = string(contDat{1});
            % insert the (still empt) content template into the doc
            % template
            obj.str = obj.filSTR(docStr, "<!-- CONTENT_FROM_M2DOC -->",contStr);
            obj.htmlSegmentPath = fileparts(contPath);
            obj.verbose = verbose;
        end

        function tplStr = getTPL(obj,type)
            file = fullfile(obj.htmlSegmentPath,type+".tpl");
            fil = fopen(file);
            dat = textscan(fil,'%s','delimiter','\n');
            fclose(fil);
            tplStr = string(dat{1});
        end  % getTPL      

        function entireTxt = filSTR(obj,entireTxt,strReplaceMarker,strOverwrite)
        % this function looks for a string defined by "strRelaceMarker" and 
        % replaces it with the string defined in "strOverwrite". 
            tline = 0;
            while(1)
                tline = tline+1;
                if(tline>length(entireTxt))
                    break;
                end
                if(contains(entireTxt(tline),strReplaceMarker))
                    splitSTR = split(entireTxt(tline),strReplaceMarker);
                    fil = strOverwrite;
                    fil(1) = splitSTR(1)+fil(1);
                    fil(end) = fil(end) + splitSTR(end);
                    if length(entireTxt) == 1
                        entireTxt = [fil];
                    else
                        if tline == 1
                            entireTxt = [fil; entireTxt(1:end)];
                        elseif tline == length(entireTxt)
                            entireTxt = [entireTxt(1:end-1); fil];
                        else
                            entireTxt = [entireTxt(1:tline-1); fil; entireTxt(tline+1:end)];
                        end
                    end
                    tline = tline + length(fil) -1;
                    %break;
                end
            end
        end % filSTR
        
        function mainHTML = addBlock(obj,mainHTML,strBlock,keyword)
            % this function looks for a magic comment (keyword) and inserts
            % the new content (strBlock) above the magic keyword
            tline = 0;
            while(1)
                tline = tline+1;
                if(tline>length(mainHTML))
                    break;
                end
                if(contains(mainHTML(tline),keyword))
                    mainHTML = [mainHTML(1:tline-1); strBlock; mainHTML(tline:end)];
                    break;
                end
            end
        end % addBlock
        
        function strT = removeBlocks(obj)
            listT = obj.listFilKeys;
            for i = 1:length(listT)
                key = listT(i);
                startKey = "START "+key; endKey = "END "+key; 
                tline = 0; startLine = []; endLine = [];
                while(1)
                    tline = tline+1;
                    if(tline>length(obj.str))
                        break; 
                    end

                    if(contains(obj.str(tline),startKey))
                        startLine = tline;
                    end
                    if(contains(obj.str(tline),endKey))
                        endLine = tline;
                        break;
                    end
                end
                if(~isempty(startLine) || ~isempty(endLine))
                    obj.str = [obj.str(1:startLine); obj.str(endLine:end)];
                end
            end
            strT = obj.str;
        end % function removeBlocks

        %% set Functions
        function set.outFolder(obj,fd)
            tmp = char(fd);
            if(tmp(end)~="\")
                fd = fd+"\";
            end
            obj.outFolder = fd;
        end
        
        function set.styleFolder(obj,fd)
            tmp = char(fd);
            if(tmp(end)~="\")
                fd = fd+"\";
            end
            obj.styleFolder = fd;
        end
        
        function set.templFolder(obj,fd)
            tmp = char(fd);
            if(tmp(end)~="\")
                fd = fd+"\";
            end
            obj.templFolder = fd;
        end
        
        %% get Functions
    
        function listN = get.listFilKeys(obj)
            strT = obj.str;
            j = 0;
            word = strings;
            for i = 1:length(strT)
                if(contains(strT(i),"{"))
                    j = j+1;
                    chStr = char(strT(i));
                    idxS = strfind(chStr,'{');
                    idxE = strfind(chStr,'}');
                    word(j,1) = string(chStr(idxS+1:idxE-1));
                end
            end
            
            listN = word;
        end
    end % methods
    
    %% methods defined in accompanying files
    methods % external methods
        createHTML(obj)
        parseDummysIntoTemplate(obj,dummyList)
    end % methods (external)
end % classdef

