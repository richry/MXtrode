





time = -1100;
start_times = [];
end_times = [];

values = [];

for x = 1:29
    start_times(x,1) = time+(x*100);
end

end_times = start_times+100;


for y = 1:29
    ALLERP = pop_geterpvalues( ERP, [ start_times(y,1) end_times(y,1)],  1,  1:34 , 'Baseline', 'pre', 'FileFormat', 'long', 'Filename', 'test.txt', 'Fracreplace',...
 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3, 'SendtoWorkspace', 'on' );
    values(y,1:34) = ERP_MEASURES(1,1:34);
end
