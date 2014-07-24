function data=rankCorrMW(name)

%Find features with rank correlation or fail dw test so we can remove them

%% Import, log transform
%name='both.tsv';
data=importCF(name);
data.C13TotInten=log(data.C13TotInten);
data.C12TotInten=log(data.C12TotInten);
data.SampleId=cellfun(@(x) x(1:end-4),data.SampleId,'uniformoutput',0); %fix sampleID
if strfind(data(1,:).SampleId{:},'neg')
    data.SampleId=cellfun(@(x) x(1:end-6),data.SampleId,'uniformoutput',0); %fix neg
end
data.BinID=remGaps(data.BinID); %remove gaps in binID
%% Add SampleOrder field
SampleOrder={'11PHS2';'11PC2';'7PHS2';'7PC2';'4PHS2';'4PC2';'11PHS1';'11PC1';'4PHS1';'4PC1';'3PHS2';'3PC2';'8PC2';'8PHS2';'6PC1';'6PHS1';'8PC1';'8PHS1';'1PC1';'1PHS1';'5PHS1';'5PC1';'12PC1';'12PHS1';'3PC1';'3PHS1';'9PC1';'9PHS1';'9PHS2';'9PC2';'10PHS1';'10PC1';'12PC2';'12PHS2';'1PC2';'1PHS2';'2PC2';'2PHS2';'2PHS1';'2PC1';'7PC1';'7PHS1';'6PHS2';'6PC2';'5PC2';'5PHS2';'10PHS2';'10PC2'};
data.SampleOrder=zeros(size(data.BaseRatio));
for i=1:max(data.BinID)
    idx=find(data.BinID==i);
    s=data(idx,:);
    sidx=sortStringsBy(s.SampleId, SampleOrder);
    s=s(sidx,:);
    s.SampleOrder=sortStringsBy(s.SampleId, SampleOrder)';
    data(idx,:)=s;
end

%% rank corr & durbin-watson test
numFiles=length(unique(data.FileName));
rho=[];
p=[];
pval=[];
dw=[];
for i=1:max(data.BinID)
    idx=find(data.BinID==i);
    s=data(idx,:);
    [~,counts]=count_unique(s.Experimentalgroups);
    if any(counts<(.5 * .5 * numFiles)) %less than half in each group (half num of samples)
        rho(i)=NaN;
        p(i)=NaN;
        pval(i)=NaN;
        dw(i)=NaN;
    else
        y = s.C13TotInten;
        n = length(s.SampleOrder);
        x = [ones(n,1),s.SampleOrder];
        [b,bint,r] = regress(y, x);
        [p(i), dw(i)] = dwtest(r,x);
        [rho(i),pval(i)]=corr(s.C13TotInten,s.SampleOrder,'type','spearman');
    end
end
%alpha=0.05/sum(~isnan(rho));
alpha=0.05;
remidx=find( (p<=alpha) | (pval<=alpha) | isnan(rho) ); %features to remove
remidx=find( pval<=alpha);
%% plot them
if 1
for i=remidx
    %i=remidx(j);
    %%
    idx=find(data.BinID==i);
    s=data(idx,:);
    figure,plot(s.SampleOrder,s.C13TotInten,'bo-'), hold
    plot(s.SampleOrder(strcmp(s.Experimentalgroups,'Test')), s(strcmp(s.Experimentalgroups,'Test'),:).C13TotInten,'ro')
    plot(s.SampleOrder(strcmp(s.Experimentalgroups,'Control')), s(strcmp(s.Experimentalgroups,'Control'),:).C13TotInten,'bo')
    
    %plot(s.SampleOrder,log(s.C12TotInten),'go')
    xlabel('Sample Order')
    ylabel('95% Intensity')
    title({['Feature ' num2str(i) ', ' s(1,:).Name{:}];...
        ['Rho: ', num2str(rho(i)), ' & corr-pval: ', num2str(pval(i))];...
        ['DW: ', num2str(dw(i)), ' & DW-pval: ', num2str(p(i))]})
    %legend('95%','5%')
    %print -depsc2 -r600 1394.eps
    input('df')
    close all
    %savefig2(['Feature ', num2str(i)],'png','-r600')
end
end
%% remove bad features
remidx2=[];
for i=1:length(remidx)
    idx=find(data.BinID==remidx(i));
    remidx2=[remidx2;idx];
end
data(remidx2,:)=[];

end