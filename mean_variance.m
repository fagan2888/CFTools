%% mean variance per feature - No transformation
nF=max(data.BinID);
featureMean=zeros(nF,1);
featureVar=zeros(nF,1);
for i=1:max(data.BinID)
    idx=find(data.BinID==i);
    featureMean(i)=mean(data(idx,:).C13TotInten);
    featureVar(i)=var(data(idx,:).C13TotInten);
end
figure,subplot(1,2,1)
plot(featureMean,featureVar,'o')
x=sortrows([featureMean,featureVar]);
movingmedian=moving(x(:,2),round(length(x)/10),'median');
hold
plot(x(:,1),movingmedian,'r','linewidth',3)
xlabel('Mean Intensity')
ylabel('Variance of Intensity')
title('Non-Transformed Data')
%savefig2('notrans','png','-r600')
%% mean variance per feature - Log transformation
nF=max(data.BinID);
featureMean=zeros(nF,1);
featureVar=zeros(nF,1);
for i=1:max(data.BinID)
    idx=find(data.BinID==i);
    featureMean(i)=mean(log(data(idx,:).C13TotInten));
    featureVar(i)=var(log(data(idx,:).C13TotInten));
end
subplot(1,2,2)
plot(featureMean,featureVar,'o')
x=sortrows([featureMean,featureVar]);
movingmedian=moving(x(:,2),round(length(x)/10),'median');
hold
plot(x(:,1),movingmedian,'r','linewidth',3)
xlabel('Mean Intensity')
ylabel('Variance of Intensity')
title('Log-Transformed Data')
set(gcf,'paperPositionMode','auto')
%savefig2('transformation_expan','pdf')