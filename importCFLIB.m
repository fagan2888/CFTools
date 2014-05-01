function group = importCFLIB(filename)
% importCFLIB: Import cflib data from a text file as a table.
% Generated using importdata

delimiter = '\t';
startRow = 2;
endRow = inf;

% Format string for each line of text:
formatSpec = '%f%f%f%f%f%f%f%f%s%s%s%s%[^\n\r]';

fileID = fopen(filename,'r'); % Open the text file.

% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end
fclose(fileID); % Close the text file.

% Create output variable
group = table(dataArray{1:end-1}, 'VariableNames', {'C13mz','RT','numC','ID','mzMin','mzMax','rtMin','rtMax','name','MF','CID','SMILES'});
