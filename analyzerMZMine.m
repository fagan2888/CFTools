
%r=readtable('mzMineResults.csv');
%r(:,end)=[];
%rep=cellfun(@(x) str2num(x(2)),r.Properties.VariableNames(5:end));
%dayLegend=[1 1 1 2 2 2 3 3 3];
%days=dayLegend(rep);
%mzmdata=r(:,5:end);

%plot glutamine, feature 2
c12=mzmdata(66,:);
c13=mzmdata(75,:);

%feature 3
c12=mzmdata(188,:);
c13=mzmdata(191,:);

%29
c12=mzmdata(512,:);
c13=mzmdata(521,:);
%% plot
fmt='%0.4f';
h=figure;, hold on
cc=hsv(length(unique(days)));
for i=unique(days)
    plot(log(table2array(c12(:,days==i))),log(table2array(c13(:,days==i))),'o','color',cc(i,:),'markerfacecolor',cc(i,:))
end
lim=[get(gca,'xlim');get(gca,'ylim')];
set(gca,'xlim',[min(min(lim)), max(max(lim))])
set(gca,'ylim',[min(min(lim)), max(max(lim))])
xlabel('C12, 5% Int')
ylabel('C13, 95% Int')
hL = legend('Day 1', 'Day 2', 'Day 3', 'Day 4','Location','Best');
%print -dpng 2.png