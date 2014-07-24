%% t-test w unequal var HS vs control Intensity 5%
h=[];
p_ttest=[];
for i=1:max(data.BinID)
    s=data(data.BinID==i,:);
    testidx=strcmp(s.Experimentalgroups,'Test');
    test=s(testidx,:).C12TotInten;
    control=s(~testidx,:).C12TotInten;
    ref=s.C13TotInten;
    [h(i), p_ttest(i)]=ttest2(test,control,'vartype','unequal');
    if 1 && p_ttest(i)<=0.05
        group = [repmat({'Test'}, sum(testidx), 1); repmat({'Control'}, sum(~testidx), 1);...
            repmat({'95%'}, length(testidx), 1)];
        boxplot([test;control;ref], group)
        input('d')
        close
    end
end
tidx1=find(p_ttest<=0.05)
plot(p_ttest,'o')
% The pairs are much closer to each other than any other, so we shouldn't
% do this. (24 features)

%% Int 5% - Int 95% t-test unequ var
h=[];
p_ttest=[];
for i=1:max(data.BinID)
    s=data(data.BinID==i,:);
    testidx=strcmp(s.Experimentalgroups,'Test');
    c12_c13=s.C12TotInten-s.C13TotInten;
    test=c12_c13(testidx);
    control=c12_c13(~testidx);
    [h(i), p_ttest(i)]=ttest2(test,control,'vartype','unequal');
    if 0 && p_ttest(i)<=0.05
        group = [repmat({'Test'}, length(test), 1); repmat({'Control'}, length(control), 1)];
        boxplot([test;control], group)
        input('d')
        close
    end
end
tidx2=find(p_ttest<=0.05)
plot(p_ttest,'o')
% 29 features. 20 features in common with above (tidx).

%% anova
is=[];
p=[];
for i=1:max(data.BinID)
    s=data(data.BinID==i,:);
    g1=s.Experimentalgroups;
    g2=s.ExperRep;
    g3=s.BioRep;
    p(i,:)=anova1(s.C13TotInten,g3,'off');
end
%% 5c. 5% vs 95% Control & 5v95 Test correlation
testCorr=[];
controlCorr=[];
for i=1:max(data.BinID)
    s=data(data.BinID==i,:);
    testidx=strcmp(s.Experimentalgroups,'Test');
    test5=s(testidx,:).C12TotInten;
    control5=s(~testidx,:).C12TotInten;
    test95=s(testidx,:).C13TotInten;
    control95=s(~testidx,:).C13TotInten;
    testCorr(i)=corr(test5,test95);
    controlCorr(i)=corr(control5,control95);
end
boxplot([testCorr;controlCorr]','labels',{'Test','Control'})

%% pair
p_ttest=[];
for i=1:max(data.BinID)
    s=data(find(data.BinID==i),:);
    s.PairID=s.BioRep*10+s.ExperRep;
    %remove lone members of a pair
    [q,w]=count_unique(s.PairID);
    if sum(w==1)
        [~,d]=intersect(s.PairID,q(w==1));
        s(d,:)=[];
    end
    s = sortrows(s,{'PairID','Experimentalgroups'},'ascend');
    c12_c13=s.C12TotInten-s.C13TotInten;
    control=c12_c13(1:2:end);
    test=c12_c13(2:2:end);
    fc=test-control;
    [h,p_ttest(i)]=ttest(fc);
    if 0 && p_ttest(i)<=0.05
        boxplot(fc)
        input('d')
        close
    end
end
plot(p_ttest,'o')
tidx3=find(p_ttest<=0.05)
% 53 features, 23 intersect(tidx1,tidx3)

%% 6 - CV (std/mean) of 95% across all features
for i=1:max(data.BinID)
    s=data(data.BinID==i,:);
    testidx=strcmp(s.Experimentalgroups,'Test');
    
    fMean95(i)=mean(s.C13TotInten);
    fStd95(i)=std(s.C13TotInten);
    fCV95(i)=fStd95(i)/fMean95(i);
    
    fMean5T(i)=mean(s.C12TotInten(testidx));
    fStd5T(i)=std(s.C12TotInten(testidx));
    fCV5T(i)=fStd5T(i)/fMean5T(i);
    
    fMean5C(i)=mean(s.C12TotInten(~testidx));
    fStd5C(i)=std(s.C12TotInten(~testidx));
    fCV5C(i)=fStd5C(i)/fMean5C(i);
end
figure, hold
plot(fCV5T, fCV95, '*r')
plot(fCV5C, fCV95, '*b')
xlabel('CV 5%')
ylabel('CV 95%')
legend('Test','Control')

figure, hold
plot(fMean5T, fMean95, '*r')
plot(fMean5C, fMean95, '*b')
xlabel('Mean 5%')
ylabel('Mean 95%')
legend('Test','Control')

figure, hold
plot(fStd5T, fStd95, '*r')
plot(fStd5C, fStd95, '*b')
xlabel('Std 5%')
ylabel('Std 95%')
legend('Test','Control')