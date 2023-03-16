% EEGLAB history file generated on the 12-Apr-2022
% ------------------------------------------------

EEG.etc.eeglabvers = '2021.1'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG= pop_basicfilter( EEG,1:32 , 'Boundary', 'boundary', 'Cutoff',0.1, 'Design', 'butter', 'Filter', 'highpass', 'Order',2, 'RemoveDC', 'on' );% Script: 11-Apr-2022 11:03:54
EEG= pop_basicfilter( EEG,1:32 , 'Boundary', 'boundary', 'Cutoff',35, 'Design', 'fir', 'Filter', 'lowpass', 'Order',84, 'RemoveDC', 'on' );% Script: 11-Apr-2022 11:03:57
EEG = pop_saveset( EEG, 'filename','DALE_PVT_Pre_preproc_for_MX_only_stats.set','filepath','/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_fully_preproc_for_MX_only_stats/PVT_Pre/data/');
EEG = eeg_checkset( EEG );
