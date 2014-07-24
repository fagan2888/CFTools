
%% find features with high CV
cv=[];
for i=1:max(data.BinID)
    s=data(data.BinID==i,:);
    s=s(s.Experimentalgroups=='Control',:);
    cv(i)=std(s.C13TotInten)/mean(s.C13TotInten);
end
idx=find(cv>.05)

%%
fmt='%0.4f';
data.Experimentalgroups=nominal(data.Experimentalgroups);
psname = 'example.ps';
for i=1:max(data.BinID)
s=data(data.BinID==i,:);
s=s(s.Experimentalgroups=='Control',:);
h=figure;, hold on
column='Day';

title([num2str(i), ' ----- ', s.Name{1}, ' ', num2str(s.BinC12mz(1),fmt), '-',...
    num2str(s.BinC13mz(1),fmt), '; ', num2str(s.BinRT(1),'%0.2f'), ' min']);
%title(num2str(i))
cc=hsv(length(unique(s.(column))));
for i=unique(s.(column))'
    plot(s.C12TotInten(s.(column)==i),s.C13TotInten(s.(column)==i),'o','color',cc(i,:),'markerfacecolor',cc(i,:))
end
lim=[get(gca,'xlim');get(gca,'ylim')];
set(gca,'xlim',[min(min(lim)), max(max(lim))])
set(gca,'ylim',[min(min(lim)), max(max(lim))])
xlabel('C12, 5% Int')
ylabel('C13, 95% Int')
hL = legend('Day 1', 'Day 2', 'Day 3', 'Day 4','Location','Best');

if i==1
    print(h,'-dpsc2', psname)
else
    print(h,'-dpsc2', psname, '-append')
end
close(h)
end
%gscatter(s.C12TotInten,s.C13TotInten,{s.Experimentalgroups, s.Day},'rgbcrgbc','oooossss')
%%
ps2pdf('psfile',psname,'pdffile','IROApeaks.pdf', ...
            'gscommand', 'C:\Program Files\gs\gs9.10\bin\gswin64c.exe', ...
            'gsfontpath', 'C:\Program Files\gs\gs9.10\lib', ...
            'gslibpath', 'C:\Program Files\gs\gs9.10\lib')