
function addToLib(library,userLib,mode)

%library='untargeted.cflib'
%userLib='addToLib.xlsx'
ul = ImportUserLib(userLib);
fid=fopen(library,'a');
fprintf(fid,'%s',sprintf('\n'));

%%
f4='%0.4f';
f2='%0.2f';
ID=10000;
ID2=100;
out=[];
for i=1:length(ul.nC)
    if ul.Mode(i)==mode
        out=[num2str(ul.C13mz(i),f4), sprintf('\t'), num2str(ul.Time(i),f2), sprintf('\t'), num2str(ul.nC(i)), sprintf('\t'), ...
        num2str(ID), sprintf('\t'), num2str(ul.C13mz(i)-0.005, f4), ...
        sprintf('\t'), num2str(ul.C13mz(i)+0.005, f4), sprintf('\t'), num2str(ul.Time(i)-.3, f2), sprintf('\t'), num2str(ul.Time(i)+.3, f2),...
        sprintf('\t'), ul.Name{i}, sprintf('\t'), ul.MF{i}, sprintf('\t'), 'N', num2str(ID2), sprintf('\t'), 'NoSmile', sprintf('\n')];
        ID=ID+1;
        ID2=ID2+1;
        fprintf(fid,'%s',out);
    end
end

fclose(fid);