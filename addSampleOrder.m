function addSampleOrder()
SampleOrder={'11PHS2';'11PC2';'7PHS2';'7PC2';'4PHS2';'4PC2';'11PHS1';'11PC1';'4PHS1';'4PC1';'3PHS2';'3PC2';'8PC2';'8PHS2';'6PC1';'6PHS1';'8PC1';'8PHS1';'1PC1';'1PHS1';'5PHS1';'5PC1';'12PC1';'12PHS1';'3PC1';'3PHS1';'9PC1';'9PHS1';'9PHS2';'9PC2';'10PHS1';'10PC1';'12PC2';'12PHS2';'1PC2';'1PHS2';'2PC2';'2PHS2';'2PHS1';'2PC1';'7PC1';'7PHS1';'6PHS2';'6PC2';'5PC2';'5PHS2';'10PHS2';'10PC2'};
names=fileprops(:,1);
for i=1:length(names)
    idx=strcmp(names{i}(1:end-8),SampleOrder);
    mzSampleOrder(i)=find(idx);
end
%fileprops(:,6)=num2cell(mzSampleOrder);