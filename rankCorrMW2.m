function data=rankCorrMW(name)

%Find features with rank correlation or fail dw test so we can remove them

%% Import, log transform
%name='2mil_negAscr.tsv';
name='8mil_posAscr.tsv';
name='neg_april15.tsv';
data=importCF(name);
data.C13TotInten=log(data.C13TotInten);
data.C12TotInten=log(data.C12TotInten);
% save 8mil_pos
% save 2mil_neg
%% Add SampleOrder field
SampleOrder={'11PHS2';'11PC2';'7PHS2';'7PC2';'4PHS2';'4PC2';'11PHS1';'11PC1';'4PHS1';'4PC1';'3PHS2';'3PC2';'8PC2';'8PHS2';'6PC1';'6PHS1';'8PC1';'8PHS1';'1PC1';'1PHS1';'5PHS1';'5PC1';'12PC1';'12PHS1';'3PC1';'3PHS1';'9PC1';'9PHS1';'9PHS2';'9PC2';'10PHS1';'10PC1';'12PC2';'12PHS2';'1PC2';'1PHS2';'2PC2';'2PHS2';'2PHS1';'2PC1';'7PC1';'7PHS1';'6PHS2';'6PC2';'5PC2';'5PHS2';'10PHS2';'10PC2'};
data.SampleOrder=zeros(size(data,1),1);   
for i=1:length(SampleOrder)
    idx=strcmp(data.SampleId,SampleOrder{i});
    data(idx,:).SampleOrder=repmat(i,sum(idx),1);
end
%% remove features with not enough samples
numFiles=length(unique(data.SampleId));
remidx=[];
for i=1:max(data.BinID)
    s=data(data.BinID==i,:);
    [~,counts]=count_unique(s.Experimentalgroups);
    if any(counts<(.5 * .5 * numFiles)) %less than half in each group (half num of samples)
        remidx=[remidx,i];
    end
end
data(ismember(data.BinID,remidx),:)=[]; % remove bad features
data.BinID=grp2idx(data.BinID);
disp(['Features removed: ', num2str(length(remidx))])

%% rank corr test
rho=[];
pval=[];
for i=1:max(data.BinID)
    s=data(data.BinID==i,:);
    [rho(i),pval(i)]=corr(s.C13TotInten,s.SampleOrder,'type','spearman');
end
alpha=0.05;
remidx=find(((pval<=alpha) & abs(rho)>=0.6)); %corr
disp(['Features removed: ', num2str(length(remidx))])
data(ismember(data.BinID,remidx),:)=[]; % remove bad features
data.BinID=grp2idx(data.BinID);

%% % t-test test vs control
p_ttest=[];
h=[];
for i=1:max(data.BinID)
    s=data(data.BinID==i,:);
    testidx=strcmp(s.Experimentalgroups,'Test');
    [h(i), p_ttest(i)]=ttest2(s(testidx,:).C13TotInten,s(~testidx,:).C13TotInten, 'var','unequal');
end
remidx=find(p_ttest<=0.05);
disp(['Features removed: ', num2str(length(remidx))])
data(ismember(data.BinID,remidx),:)=[]; % remove bad features
data.BinID=grp2idx(data.BinID);

% %% cv of c13 for each feature. Throw away features with CV>=0.05
% cv=[];
% for i=1:max(data.BinID)
%     s=data(find(data.BinID==i),:);
%     cv(i)=std(s.C13TotInten)/mean(s.C13TotInten);
% end
% remidx=find(cv>=0.05);
% disp(['Features removed: ', num2str(length(remidx))])
% data(ismember(data.BinID,remidx),:)=[]; % remove bad features
% data.BinID=remGaps(data.BinID); %remove gaps in binID
%% Normalize by total 95% intensity
[data, NF] = normalizeBy95(data);
%save 2014_03_06
%% plot them 
if 1
    for i=1:max(data.BinID)
    %for i=remidx
        %%
       i=225
        s=data(data.BinID==i,:);
        testidx=strcmp(s.Experimentalgroups,'Test');
        figure, hold, box on
        plot(s.SampleOrder(testidx), s.C13TotInten(testidx),'ro')
        plot(s.SampleOrder(~testidx), s.C13TotInten(~testidx),'bo')
        % linear regression
        pCoeff = polyfit(s.SampleOrder, s.C13TotInten,1);
        yfit = polyval(pCoeff,s.SampleOrder);
        %plot(s.SampleOrder, yfit,'g')
       
        %plot(s.SampleOrder,(s.C12TotInten),'go')
        xlabel('Sample Order')
        ylabel('95% Intensity')
        fmt='%0.3f';
        title({['Feature ' num2str(i) ', ' s(1,:).Name{:}];...
            ['Rho: ', num2str(rho(i),fmt), ' & corr-pval: ', num2str(pval(i),fmt)]});
            %['T-test P=', num2str(p_ttest(i),'%0.2E')]});
        legend('Test','Control')
        input('def')
        %pause(0.5)
        close all
        %savefig2(['Feature ', num2str(i)],'png','-r600')
    end
end

%% Write table to csv for SAS
data2=data;
data2.Name=[];
writetable(data2,[data(1,:).AcqMethod{1}, '.csv'])

