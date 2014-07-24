load('E:\IROA\IROALot6\2014-04-11\april16.mat')
outAll=table();
stepH=1.00335;
for i=unique(data.BinID)'
    s=data(data.BinID==i,:);
    s=s(s.Experimentalgroups=='Control',:);
    for mz=mean(s.BinC13mz):-stepH:mean(s.BinC12mz)-.1
        out=table(mz,mean(s.BinRT),i,'VariableNames',{'mz','rt','id'});
        outAll=[outAll; out];
    end
end
%writetable(outAll,'mzMineTargeted.csv');
%% get sample names, convert to day or test/control
load('mzMineOutApril16.mat')
fid=fopen('mzMineOutApril16.csv','r');
names=strsplit(fgetl(fid),',');
names=names(5:end-1);
fclose(fid);
for i=1:length(names)
    temp=strsplit(names{i},'.');
    temp=strsplit(temp{1},'-');
    names{i}=['x',temp{1}];
end
namesnox=cellfun(@(x) x(2:end),names,'uniform',0);
mzMineOutApril16.Properties.VariableNames(5:end)=names;
daysRef=[1,1,1,2,2,2,3,3,3]; %convert exp # to day
for i=1:length(names)
    days(i)=daysRef(str2num(namesnox{i}(1)));
    if names{i}(3)=='H'
        exType(i)=1;
    else
        exType(i)=0;
    end
end
exType=logical(exType);
% Add SampleOrder
SampleOrder={'11PHS2';'11PC2';'7PHS2';'7PC2';'4PHS2';'4PC2';'11PHS1';'11PC1';'4PHS1';'4PC1';'3PHS2';'3PC2';'8PC2';'8PHS2';'6PC1';'6PHS1';'8PC1';'8PHS1';'1PC1';'1PHS1';'5PHS1';'5PC1';'12PC1';'12PHS1';'3PC1';'3PHS1';'9PC1';'9PHS1';'9PHS2';'9PC2';'10PHS1';'10PC1';'12PC2';'12PHS2';'1PC2';'1PHS2';'2PC2';'2PHS2';'2PHS1';'2PC1';'7PC1';'7PHS1';'6PHS2';'6PC2';'5PC2';'5PHS2';'10PHS2';'10PC2'};
for i=1:length(names)
    idx=strcmp(names{i}(2:end),SampleOrder);
    mzSampleOrder(i)=find(idx);
end
daysXtype=days;
daysXtype(exType)=days(exType)*10; %extype within days
%
ExperRep=cellfun(@(x) str2num(x(end)),namesnox);
BioRep=cell2mat(cellfun(@(x) str2num(x{1}), cellfun(@(x) regexp(x,'[0-9]*','match'),namesnox,'uniformoutput', 0), 'uniformoutput', 0));
PairID=BioRep*10+ExperRep;
%% throw out rows (isotopic peaks) with ANY zeros (not found in 1 or more samples)
mdata=mzMineOutApril16(:,5:end);
mdata=table2array(mdata);
idx=find(sum(mdata<1000,2)>0);
mzMineOutApril16(idx,:)=[];
mdata(idx,:)=[];
%% throw out iroa peaks that don't have at least the first 2 and last two isotopic peaks (in every sample)
remidx=[];
for i=unique(mzMineOutApril16.Name)'
    idx=find(outAll.id==i);
    c12mz=min(outAll.mz(idx));
    c13mz=max(outAll.mz(idx));
    s=mzMineOutApril16(mzMineOutApril16.Name==i,:);
    s = sortrows(s,'rowmz','descend');
    if ~(abs(c13mz-max(s.rowmz))<0.002 && abs(c12mz-min(s.rowmz))<0.002)
        remidx=[remidx,i];
    elseif ~(abs(c13mz-1.00335-s.rowmz(2))<0.002 && abs(c12mz+1.00335-s.rowmz(end-1))<0.002)
        remidx=[remidx,i];
    end
end
idx=ismember(mzMineOutApril16.Name,remidx);
mzMineOutApril16(idx,:)=[];
mdata(idx,:)=[];
%% find the midpoint (as in mean of [c12mz,c13mz]), sum up each half
X12=[];
X13=[];
for i=unique(mzMineOutApril16.Name)'
    s=mdata(mzMineOutApril16.Name==i,:);
    mzs=mzMineOutApril16.rowmz(mzMineOutApril16.Name==i);
    midpoint=floor(mean([max(mzs),min(mzs)]));
    c13mzs=mzs>midpoint;
    c12mzs=mzs<midpoint;
    c13int=sum(s(c13mzs,:),1);
    c12int=sum(s(c12mzs,:),1);
    X13=[X13,c13int'];
    X12=[X12,c12int'];
end
%% Normalize by c13 intensity
c13int=sum(X13,2);
c12int=sum(X12,2);
NF=median(c13int)./c13int;
X13=bsxfun(@times,X13,NF);
X12=bsxfun(@times,X12,NF);
bar(sum(X13,2))
%% visualize
X12control=X12(exType==0,:);
X13control=X13(exType==0,:);
for i=1:size(X12,2)
    plot(log(X12(:,i)),log(X13(:,i)),'o')
    for j=1:size(X12,1)
        if PairID(j)==51 || PairID(j)==61
            text(log(X12(j,i)),log(X13(j,i)),namesnox{j})
       end
    end
    disp(i)
    input('')
    close all
end
%% rank corr test
rho=[];
pval=[];
[~,sortIdx]=sort(mzSampleOrder);
for i=1:size(X12,2)
    [rho(i),pval(i)]=corr(X13(sortIdx,i),[1:36]','type','spearman');
end
alpha=0.05;
remidx=find(((pval<=alpha) & abs(rho)>=0.6)); %corr
disp(['Features removed: ', num2str(length(remidx))])
X13(:,remidx)=[]; % remove bad features
X12(:,remidx)=[];
%% t-test test vs control
p_ttest=[];
h=[];
for i=1:size(X12,2)
    [h(i), p_ttest(i)]=ttest2(X13(exType,i),X13(~exType,i), 'var','unequal');
end
i=26;
boxplot([X13(exType,i),X13(~exType,i)])
remidx=find(p_ttest<=0.05);
disp(['Features removed: ', num2str(length(remidx))])
X13(:,remidx)=[]; % remove bad features
X12(:,remidx)=[];
%% output
out=zeros(size(X12,1),size(X12,2)*2);
out(:,1:2:end)=X12;
out(:,2:2:end)=X13;
out=num2cell(out);
outT=cell2table(out);
fnamec12=arrayfun(@(x) ['c12_', num2str(x)],[1:size(X12,2)]','uniform',0)';
fnamec13=arrayfun(@(x) ['c13_', num2str(x)],[1:size(X12,2)]','uniform',0)';
fname=cell(1,size(X12,2)*2);
fname(1:2:end)=fnamec12;
fname(2:2:end)=fnamec13;
outT.Properties.RowNames=namesnox;
outT.Properties.VariableNames=fname;
outT.Day=days';
outT.experimental=exType';
outT.BioRep=BioRep';
outT.ExperRep=ExperRep';
outT.PairID=PairID';
outT = outT(:,[end 1:end-1]);
outT = outT(:,[end 1:end-1]);
outT = outT(:,[end 1:end-1]);
outT = outT(:,[end 1:end-1]);
outT = outT(:,[end 1:end-1]);
writetable(outT,'mzMineQuant.csv','writerownames',1);
writetable(outT(:,1:5),'mzMineQuantDecoder.csv','writerownames',1);
%% pca
pca=nipalsPCA(log(X13),5);
figure,VisScores(log(X13),pca,[1,2],daysXtype)
for j=1:size(X12,1)
    text(pca.scores(j,1)+.05,pca.scores(j,2),namesnox{j})
end
%h = legend('Day 1', 'Day 2', 'Day 3', -1);
%legendlinestyles(h,{'o','o','o'},[],{'b','g','r'})

%% plot c12 vs c13 intensity. color by day
figure, hold
cc=hsv(3);
for i=1:length(c13int)
    plot(log(c12int(i)),log(c13int(i)),...
        'marker','o',...
        'color',cc(days(i),:),...
        'markerfacecolor',cc(days(i),:))
    text(log(c12int(i))+1,log(c13int(i)),namesnox{i})
end