function data = normalizePairsBy95(data)
%% normalize pairs to each otherSampleOrder=unique(data.SampleOrder);
SampleOrder=unique(data.SampleOrder);
c13=[];
for i=1:length(SampleOrder)
    idx=data.SampleOrder==SampleOrder(i);
    c=data(idx,:).C13TotInten;
    c13(i)=sum(c);
end
c13p=c13;
for i=1:2:length(c13)-1
    c13p(i:i+1)=c13p(i:i+1)/max(c13p(i:i+1));
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