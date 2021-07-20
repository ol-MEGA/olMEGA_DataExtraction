function [vTimeStamps]=getTimeStampQuest(obj)
% function to get time stamps with questionnaires
% Usage [vTimeStamps]=getTimeStampQuest(obj)
%
% Parameters
% ----------
% obj : class olMEGA_DataExtraction, contains all informations
%
% Returns
% -------
% vTimeStamps : datetime array, contains time stamps with questionnaires
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 15-Jul-2021  JP

% get path to questionnaire folder
sQuestFolder = [obj.stSubject.Folder filesep [obj.stSubject.Name '_Quest']];

% list all questionnaires
stQuestionnaires = dir([sQuestFolder, '/*.xml']);
idxInValid = arrayfun(@(x)(contains(x.name, '._')), stQuestionnaires);
stQuestionnaires(idxInValid) = [];

% get time stamps, if questionnaires exist
if isempty(stQuestionnaires)
    vTimeStamps = [];
else
    vTimeStamps = arrayfun(@(x)(datetime(x.name(end-21:end-4), 'InputFormat', 'yyyyMMdd_HHmmSSSS')), stQuestionnaires);
end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2021> J. Pohlhausen
% Jade University of Applied Sciences
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.