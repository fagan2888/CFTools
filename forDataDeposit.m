


BinID=s.BinID;
MetaboliteID=s.ID;


s5=s;
s95=s;
s5(:,'C12TotInten') = [];
s5(:,'C13TotInten') = [];
s95(:,'C12TotInten') = [];
s95(:,'C13TotInten') = [];
s5(:,'Intensity') = s(:,'C12TotInten');
s95(:,'Intensity') = s(:,'C13TotInten');

s5.SampleId = cellfun(@(x) strcat(x,'-5'), s5.SampleId,'UniformOutput', 0);
s95.SampleId = cellfun(@(x) strcat(x,'-95'), s5.SampleId,'UniformOutput', 0);

