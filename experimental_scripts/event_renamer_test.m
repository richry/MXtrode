%% event renamer because it hates me

for f = 1:length(EEG.event)
    if EEG.event(f).type == char('Probe-None-Incongruent')
        EEG.event(f).type = 101;
    elseif EEG.event(f).type == char('Probe-None-Incongruent')
        EEG.event(f).type = 201;
    end 
end

        