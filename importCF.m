function data = importCF(filename)
% Function for importing data output from ClusterFinder:
%

%% Initialize variables.
%filename = 'E:\IROA\IROALot6\Lot6\Results\data.tsv';
delimiter = '\t';
startRow = 2;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,4,5,6,7,13,14,15,16,17,18,19]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [1,4,5,6,7,13,14,15,16,17,18,19]);
rawCellColumns = raw(:, [2,3,8,9,10,11,12]);


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
data = table;
data.BinID = cell2mat(rawNumericColumns(:, 1));
data.AcqMethod = rawCellColumns(:, 1);
data.SampleId = rawCellColumns(:, 2);
data.BinC12mz = cell2mat(rawNumericColumns(:, 2));
data.BinC13mz = cell2mat(rawNumericColumns(:, 3));
data.BinRT = cell2mat(rawNumericColumns(:, 4));
data.NumC = cell2mat(rawNumericColumns(:, 5));
data.ID = rawCellColumns(:, 3);
data.Name = rawCellColumns(:, 4);
data.MF = rawCellColumns(:, 5);
data.Experimentalgroups = rawCellColumns(:, 6);
data.FileName = rawCellColumns(:, 7);
data.C12TotInten = cell2mat(rawNumericColumns(:, 6));
data.C13TotInten = cell2mat(rawNumericColumns(:, 7));
data.BaseRatio = cell2mat(rawNumericColumns(:, 8));
data.NormC12Inten = cell2mat(rawNumericColumns(:, 9));
data.NormC13Inten = cell2mat(rawNumericColumns(:, 10));
data.NormRatio = cell2mat(rawNumericColumns(:, 11));
data.ZScore = cell2mat(rawNumericColumns(:, 12));
%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;

%% Some more things
data(:,'NormC12Inten') = [];
data(:,'NormC13Inten') = [];
data(:,'NormRatio') = [];
data(:,'ZScore')=[];
data(:,'BaseRatio')=[];
data(:,'FileName')=[];

%fix the 'Experimentalgroups' field
idxHS=strfindin(data.SampleId,'HS');
data(idxHS,:).Experimentalgroups=repmat({'Test'},length(idxHS),1);
idxC=strfindin(data.SampleId,'C');
data(idxC,:).Experimentalgroups=repmat({'Control'},length(idxC),1);

data.BinID=grp2idx(data.BinID); %remove gaps in binID, start at 1 instead of 0
[~,data.SampleId]=cellfun(@(x) fileparts(x),data.SampleId,'uniformoutput',0); %fix sampleID
if strcmp(data(1,:).AcqMethod{:},'neg') %remove '-neg'
    data.SampleId=cellfun(@(x) x(1:end-4),data.SampleId,'uniformoutput',0); 
end
data.ExperRep=cellfun(@(x) str2num(x(end)),data.SampleId);
data.BioRep=cell2mat(cellfun(@(x) str2num(x{1}), cellfun(@(x) regexp(x,'[0-9]*','match'),data.SampleId,'uniformoutput', 0), 'uniformoutput', 0));
data.PairID=data.BioRep*10+data.ExperRep;