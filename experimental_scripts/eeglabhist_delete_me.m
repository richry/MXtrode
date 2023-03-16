% EEGLAB history file generated on the 16-Aug-2022
% ------------------------------------------------
[EEG ALLEEG CURRENTSET] = eeg_retrieve(ALLEEG,1);
EEG = eeg_checkset( EEG );
figure; topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
EEG = pop_loadset('filename','DBAS_Pre.set','filepath','/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_PVT_fully_preprocessed_for_AG_comps/PreProc_manually_cleaned_01-35hz_steep_slope/Data/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'retrieve',1,'study',0); 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'retrieve',2,'study',0); 
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG, 'nochannel',{'A-011'});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
eeglab redraw;
