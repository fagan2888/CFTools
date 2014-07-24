
c13mz=456.3148;
tillmz=451;
fromMin=10;
toMin=10.7;
ppmerr=10;

sampleList=dir('*.mat');
sampleList={sampleList.name};

for sample=1:length(sampleList)
    int=[];
    ints=[];
    mzN=0;
    load(sampleList{sample})
    
    [~,scanFromIdx]=min(abs(fromMin*60-time));
    [~,scanToIdx]=min(abs(toMin*60-time));
    for c12mz=c13mz:-1.00335:tillmz
        mzN=mzN+1;
        int=[];
        for i=scanFromIdx:scanToIdx
            [d,idx]=min(abs(c12mz-peaks{i}(:,1)));
            if d<0.005 || d<ppmerr/1e6*c12mz
                int=[int;peaks{i}(idx,2)];
            else
                int=[int;0];
            end
        end
        ints(:,mzN)=int;
    end
    sampleEIC{sample}=[time(scanFromIdx:scanToIdx)./60,sum(ints,2)];
end
%%
figure, hold
for i=1:length(sampleEIC)
plot(sampleEIC{i}(:,1),sampleEIC{i}(:,2),randColor())
x(i)=sum(sampleEIC{i}(:,2));
end


figure,plot(time(scanFromIdx:scanToIdx)./60,ints)
figure,plot(time(scanFromIdx:scanToIdx)./60,i2)
%legend(strsplit(num2str(456.3148:-1.00335:452)))