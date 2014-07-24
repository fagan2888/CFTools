
data=rankCorrMW('Lib16_1_6.tsv');
SampleOrder={'11PHS2';'11PC2';'7PHS2';'7PC2';'4PHS2';'4PC2';'11PHS1';'11PC1';'4PHS1';'4PC1';'3PHS2';'3PC2';'8PC2';'8PHS2';'6PC1';'6PHS1';'8PC1';'8PHS1';'1PC1';'1PHS1';'5PHS1';'5PC1';'12PC1';'12PHS1';'3PC1';'3PHS1';'9PC1';'9PHS1';'9PHS2';'9PC2';'10PHS1';'10PC1';'12PC2';'12PHS2';'1PC2';'1PHS2';'2PC2';'2PHS2';'2PHS1';'2PC1';'7PC1';'7PHS1';'6PHS2';'6PC2';'5PC2';'5PHS2';'10PHS2';'10PC2'};
%% Normalize by total 95% intensity
x=[];
c13=[];
for i=1:length(SampleOrder)
    idx=strcmp(data.SampleId,SampleOrder{i});
    if sum(idx)>1
        c=data(idx,:).C13TotInten;
        c13(i)=sum(c);
        x(i,:)=[min(c), prctile(c,25), prctile(c,50), prctile(c,75), max(c)];
    end
end
idx=find(logical(c13));
x=x(idx,:);
samples=SampleOrder(idx);
c13=c13(idx);
c13n=c13/max(c13); %output is in order of 'samples', which is dictated by run order, not alphabetical
%% median ff
= median of all values divided by value (i)


%% normalize pairs to each other
% the samples should already be in order by pairs, so every two samples
% should be a pair. If we are continuing from the previous cell
c13p=c13;
for i=1:2:length(c13)-1
    c13p(i:i+1)=c13p(i:i+1)/max(c13p(i:i+1));
end

%% TIC
cd('E:\IROA\IROALot6\01282014_pos_mat')
matfiles=cellfun(@(x) [x, '.mat'],samples,'UniformOutput',0);
for i=1:length(matfiles)
    load(matfiles{i})
    x=cat(1,peaks{:});
    tic(i)=sum(x(:,2));
end



