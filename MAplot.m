%MA plot
M=zeros(height(data),1);
A=zeros(height(data),1);
for i=1:height(data)
    M(i)=(data.C13TotInten(i))-(data.C12TotInten(i));
    A(i)=0.5*((data.C13TotInten(i))+(data.C12TotInten(i)));
end
%% modified MA plot
M=zeros(height(data),1);
A=zeros(height(data),1);
for i=1:height(data)
    M(i)=data.C13TotInten(i)-data.C12TotInten(i);
    A(i)=data.C13TotInten(i);
end
%%
figure,plot(A,M,'*')
hold
YSmooth = malowess(A, M, 'Span', .1);
x=sortrows([A,YSmooth]);
plot(x(:,1),x(:,2),'r-','linewidth',2)
%% Lowess filter
