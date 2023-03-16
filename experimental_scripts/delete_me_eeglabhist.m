% EEGLAB history file generated on the 15-Aug-2022
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename','MXAttn_DBIV_PVT_Pre_RR_211111_125645_MXeneIntanImport_chlc_evExtract.set','filepath','/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_PVT_Pre_autoclaved/MXAttn_DBIV/MXAttn_DBIV_PVT_Pre_RR_211111_125645/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',35,'plotfreqz',1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
eeglab redraw;
