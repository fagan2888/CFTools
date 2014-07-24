% compare targeted analysis from libraries built from only HS, only control
% or both.

%% Load in files, remove bad features
files={'group1_0.cflib','group2_0.cflib','group3_0.cflib'};
names=[];
for i=1:length(files)
    [~,names{i}]=fileparts(files{i});
    data=curateCF(files{i});
    [~,idx]=unique(data.BinID);
    eval([names{i}, '=data;']);
    eval([names{i}, 'single=data(idx,:);']);
end
clear data idx
all=table();
for i=1:length(files)
    eval([names{i}, '.type=repmat(i,height(', names{i}, '),1);'])
    eval([names{i}, 'single.type=repmat(i,height(', names{i}, 'single),1);'])
    eval(['all=[all;', names{i}, 'single];']);
end

%% group binIDs
for t=1:height(all)
    ts=t;
    target=all(t,:);
    for i=setdiff([1:length(files)],target.type)
        [d1,idx1]=sort(abs(all(all.type==i,:).BinC12mz-target.BinC12mz));
        idx1=idx1(d1<=0.01);
        d1=d1(d1<=0.01);
        [d2,idx2]=sort(abs(all(all.type==i,:).BinC13mz-target.BinC13mz));
        idx2=idx2(d2<=0.01);
        d2=d2(d2<=0.01);
        [d3,idx3]=sort(abs(all(all.type==i,:).BinRT-target.BinRT));
        idx3=idx3(d3<=0.1);
        d3=d3(d3<=0.1);
        temp=find(all.type==i);
        idx1=temp(idx1);
        idx2=temp(idx2);
        idx3=temp(idx3);
        scores=NaN(3,height(all));
        scores(1,idx1)=d1;
        scores(2,idx2)=d2;
        scores(3,idx3)=d3./10;
        scores=sum(scores);
        [d,idx]=nanmin(scores);
        if ~isnan(d)
            ts=[ts,idx];
        else
            ts=[ts,d];
        end
    end
    bins{t}=ts;
end
% remove single bins
%bins(cellfun(@(x) sum(isnan(x))>=2,bins))=[];
%% dereplicate
i=1;
bins2=[];
while i<=height(all)
    idx=find(cellfun(@(x) sum(x==i),bins));
    temp=bins(idx);
    temp=unique(cat(2,temp{:}));
    temp=temp(~isnan(temp));
    if length(temp)<=3
        bins2=[bins2,{temp}];
    end
    bins(idx)=[];
    i=i+1;
end
bins=bins2(~cellfun(@isempty,bins2));

%% how many features are found in how many analyis?
na=zeros(length(bins),3);
bad=0;
for i=1:length(bins)
    x=all(bins{i},:).type';
    if length(x)~=length(unique(x))
        bad=bad+1;
    end
    na(i,x)=na(i,x)+1;
end
sum(na(:,1) & ~na(:,2)  & ~na(:,3))
%% assign back in to original
for i=1:length(names)
    eval([names{i}, '.NewBinID=nan(height(', names{i}, '),1);'])
end
for bin=1:length(bins)
    s=all(bins{bin},:);
    for i=1:height(s)
        idx=eval([names{s.type(i)}, '.BinID==s(i,:).BinID']);
        eval([names{s.type(i)}, '(find(idx),:).NewBinID=repmat(bin,sum(idx),1);']);
    end
end
    
%% compare!
sample='3PC1';
%sample='2PHS1';

%pull out the sample, remove unmatched bins
idxHS=find(strcmp(HS.SampleId,sample));
idxControl=find(strcmp(control.SampleId,sample));
idxBoth=find(strcmp(both.SampleId,sample));
sHS=HS(idxHS,:);
sControl=control(idxControl,:);
sBoth=both(idxBoth,:);
sHS(isnan(sHS.NewBinID),:)=[];
sControl(isnan(sControl.NewBinID),:)=[];
sBoth(isnan(sBoth.NewBinID),:)=[];

numBins=max([max(sHS.NewBinID), max(sBoth.NewBinID), max(sHS.NewBinID)]);
hsInt=zeros(numBins,1);
cInt=zeros(numBins,1);
bInt=zeros(numBins,1);

hsInt(sHS.NewBinID)=sHS.C13TotInten;
cInt(sControl.NewBinID)=sControl.C13TotInten;
bInt(sBoth.NewBinID)=sBoth.C13TotInten;

%% plot1
idx=and(logical(hsInt), logical(cInt)); % only plot ones that show up in both
x=mean([hsInt(idx),cInt(idx)],2);
y=hsInt(idx)-cInt(idx);
figure,plot(x,y,'o')
xlabel('Mean Int')
ylabel('Difference')
title([sample, ' HS and Control'])
set(gca,'xlim',[10,25])
set(gca,'ylim',[-5,5])
textbp({['Features with no Int difference: ', num2str(sum(abs(y)<0.0001)), '/', num2str(length(y))];...
    ['Features with Int difference < 1: ', num2str(sum(abs(y)<1)), '/', num2str(length(y))]}, ...
    'BackgroundColor',[.7 .9 .7]);
savefig2([sample, ' HS and Control'],'png','-r600')
%% plot2
idx=and(logical(hsInt), logical(bInt)); % only plot ones that show up in both
x=mean([hsInt(idx),bInt(idx)],2);
y=hsInt(idx)-bInt(idx);
figure,plot(x,y,'o')
xlabel('Mean Int')
ylabel('Difference')
title([sample, ' HS and Both'])
set(gca,'xlim',[10,25])
set(gca,'ylim',[-5,5])
textbp({['Features with no Int difference: ', num2str(sum(abs(y)<0.0001)), '/', num2str(length(y))];...
    ['Features with Int difference < 1: ', num2str(sum(abs(y)<1)), '/', num2str(length(y))]}, ...
    'BackgroundColor',[.7 .9 .7]);
savefig2([sample, ' HS and Both'],'png','-r600')
%% plot3
idx=and(logical(cInt), logical(bInt)); % only plot ones that show up in both
x=mean([cInt(idx),bInt(idx)],2);
y=cInt(idx)-bInt(idx);
figure,plot(x,y,'o')
xlabel('Mean Int')
ylabel('Difference')
title([sample, ' Control and Both'])
set(gca,'xlim',[10,25])
set(gca,'ylim',[-5,5])
textbp({['Features with no Int difference: ', num2str(sum(abs(y)<0.0001)), '/', num2str(length(y))];...
    ['Features with Int difference < 1: ', num2str(sum(abs(y)<1)), '/', num2str(length(y))]}, ...
    'BackgroundColor',[.7 .9 .7]);
savefig2([sample, ' Control and Both'],'png','-r600')

