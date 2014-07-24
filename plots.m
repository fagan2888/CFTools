% mean c12 Inten vs C13 Inten for all features in a sample
% each marker is a sample
% control - circle, HS - square

%Plot PairID for day 4
day=4;
data_Day1=data(data.Day==day,:);
x=grpstats(table2dataset(data_Day1),'SampleId','median','datavars',{'C12TotInten','C13TotInten','PairID'});
x.PairID=x.median_PairID;
x.PairID=grp2idx(x.PairID);
x.Experimentalgroups=ones(length(x),1);
idxHS=strfindin(x.SampleId,'HS');
x(idxHS,:).Experimentalgroups=repmat(1,length(idxHS),1);
idxC=strfindin(x.SampleId,'C');
x(idxC,:).Experimentalgroups=repmat(0,length(idxC),1);

figure, hold on
column='PairID';
%title(column,'interpreter','none')
cc=hsv(length(unique(x.(column))));
markers={'o','s'};
for i=1:length(x)
    plot(x.median_C12TotInten(i),x.median_C13TotInten(i),...
        'marker',markers{x.Experimentalgroups(i)+1},...
        'color',cc(x.(column)(i),:),...
        'markerfacecolor',cc(x.(column)(i),:))
end
lim=[get(gca,'xlim');get(gca,'ylim')];
maxdiff=max(diff(lim'));
offset=maxdiff*.10;
set(gca,'xlim',[mean(lim(1,:))-(maxdiff/2)-offset, mean(lim(1,:))+(maxdiff/2)+offset])
set(gca,'ylim',[mean(lim(2,:))-(maxdiff/2)-offset, mean(lim(2,:))+(maxdiff/2)+offset])
xlabel('C12, 5% Int')
ylabel('C13, 95% Int')
set(gca, 'color', [0 0 0])
legend('show')

h = legend('Pair 1', 'Pair 2', 'Pair 3', 'Pair 4', 'Pair 5', 'Pair 6', -1);
markers = {'o','o','o','o','o','o'};
linecolors = mat2cell(cc,ones(size(cc,1),1),3)';
legendlinestyles(h,markers,{},linecolors)
set(h, 'color', [1 1 1])
axis square
set(gcf,'invertHardcopy','off')
print('-dpng','-r600',['day', num2str(day)])
%%
% mean c12 Inten vs C13 Inten for all features in a sample
% each marker is a sample
% control - circle, HS - square

%Color by Day 
x=grpstats(table2dataset(data),'SampleId','median','datavars',{'C12TotInten','C13TotInten','Day'});
x.Day=x.median_Day;
x.Day=grp2idx(x.Day);
x.Experimentalgroups=ones(length(x),1);
idxHS=strfindin(x.SampleId,'HS');
x(idxHS,:).Experimentalgroups=repmat(1,length(idxHS),1);
idxC=strfindin(x.SampleId,'C');
x(idxC,:).Experimentalgroups=repmat(0,length(idxC),1);

figure, hold on
column='Day';
title('median of log transformed intensities for all features in each sample')
cc=hsv(length(unique(x.(column))));
markers={'o','s'};
for i=1:length(x)
    plot(x.median_C12TotInten(i),x.median_C13TotInten(i),...
        'marker',markers{x.Experimentalgroups(i)+1},...
        'color',cc(x.(column)(i),:),...
        'markerfacecolor',cc(x.(column)(i),:))
end
lim=[get(gca,'xlim');get(gca,'ylim')];
set(gca,'xlim',[min(min(lim)), max(max(lim))])
set(gca,'ylim',[min(min(lim)), max(max(lim))])
xlabel('C12, 5% Int')
ylabel('C13, 95% Int')
h = legend('Day 1', 'Day 2', 'Day 3', 'Day 4', -1);
markers = {'o','o','o','o'};
linecolors = mat2cell(cc,ones(size(cc,1),1),3)';
legendlinestyles(h,markers,{},linecolors)
axis square
%print('-dpng','-r600','median Int by sample')
