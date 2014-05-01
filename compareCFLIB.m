% Compares cflib for 3 different sets of samples
% an entry is deemed a match if 1) the retention times all fall withih the
% RT range (rtMax to rtMin) (2) the C13mz falls within the mz range (3) the
% number of carbons is the same
group1 = importCFLIB('group1.cflib');
group2 = importCFLIB('group2.cflib');
group3 = importCFLIB('group3.cflib');
match=zeros(height(group1),1);
for i=1:height(group1)
    mz=group1.C13mz(i);
    rt=group1.RT(i);
    c=group1.numC(i);
    %Compare m/z, RT, and numC between Group1 and Group2
    massOK = mz>group2.mzMin & mz<group2.mzMax;
    rtOK = rt>group2.rtMin & rt<group2.rtMax;
    cOK = c == group2.numC;
    group2Idx=find(massOK & rtOK & cOK,1,'first');
    if isempty(group2Idx)
        continue
    end
    
    %Compare m/z, RT, and numC between Group1 and Group3
    massOK = mz>group3.mzMin & mz<group3.mzMax;
    rtOK = rt>group3.rtMin & rt<group3.rtMax;
    cOK = c == group3.numC;
    group3Idx=find(massOK & rtOK & cOK,1,'first');
    if isempty(group3Idx)
        continue
    end
    %If there is a match for both
    %won't reach here otherwise
    match(i)=1;
    group2(group2Idx,:)=[]; %remove the entries so they can't match twice
    group3(group3Idx,:)=[];
end
group1(logical(match),:)=[];
disp(['Number in common: ', num2str(sum(match))])
%%
number in common:
Group1 & Group2 - 179 / 213 & 208
Group1 & Group3 - 184 / 213 & 200
Group2 & Group3 - 179 / 208 & 200
179 & 179 - 166

Group1 & Group2 & Group3 - 166