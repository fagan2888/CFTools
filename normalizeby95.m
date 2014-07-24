function [data, NF] = normalizeBy95(data)
%% Normalize by total 95% intensity
SampleOrder=unique(data.SampleOrder);
c13=zeros(size(SampleOrder));
for i=1:length(SampleOrder)
    c13(i)=median(data(data.SampleOrder==SampleOrder(i),:).C13TotInten);
end
NF=median(c13)./c13;
%apply normalization to C12 and C13 intensity
for i=1:length(SampleOrder)
    idx=data.SampleOrder==SampleOrder(i);
    s=data(idx,:);
    s.C13TotInten=s.C13TotInten*NF(i);
    s.C12TotInten=s.C12TotInten*NF(i);
    data(idx,:)=s;
end

%% boxplot of feature intensity in every sample
c13=[];
SampleOrder=unique(data.SampleOrder);
for i=1:length(SampleOrder)
    c13{i}=data(data.SampleOrder==SampleOrder(i),:).C13TotInten;
end

[X,groups] = boxplotGroups(c13);
hBox1=boxplot(X,groups);

xlabel('Sample Number')
ylabel('Log Intensity')
set(gcf,'paperPositionMode','auto')
set(gca,'xTick',[1:2:48])
set(gca,'xtickLabel',[1:2:48])
%print('-dpng','-r300','boxplot95%')