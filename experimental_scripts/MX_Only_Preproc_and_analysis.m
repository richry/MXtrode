% This script will do automatic cleanina and analysis for MXonly data and
% comparison - that is, the first step will always be to delete all AG data
% - it will automatically pull the following information and store it in
% the 'reportcard' file which will be a single MATLAB Varriable


% for MX-only analysis for a few reasons - first, it deletes all Ag/AgCl
% channels - also, it doesn't delete time segments/samples/epochs

%check: does bad_chans_left_total + bad_chans_right_total + clean_chans =32

% note - I hard coded the index within the subject folder as the first one
% - this only works if you've only processed the PCT pre - if you've done
% post, it will go to post unless changed 

% note - this pipeline does not delete channels with 2Mohm or greater
% impedance that make it through Clean_Rawdata - they are kept in - I just
% do more exclusions for the report card in a seperate section 

%% Prep
clear
clc

% PATHS
input = '/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_PVT_autoclaved';% string, folder name

data_out = '/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_fully_preproc_for_MX_only_stats/PVT_Pre/data'; % string, folder name
stats_out = '/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_fully_preproc_for_MX_only_stats/PVT_Pre/stats/';

cd(input);
files = dir;

report_card = {};

report_card{1,1} = "SUBID";
report_card{1,2} = "array_pair_ID";
report_card{1,3} = "array_use_count";
report_card{1,4} = "samples_start";
report_card{1,5} = "rejchan_iterations";
report_card{1,6} = "good_chans_left_total";
report_card{1,7} = "bad_chans_left_total";
report_card{1,8} = "percent_left_chans_rejected";
report_card{1,9} = "bad_chans_left_name";
report_card{1,10} = "good_chans_right_total";
report_card{1,11} = "bad_chans_right_total";
report_card{1,12} = "percent_right_chans_rejected";
report_card{1,13} = "bad_chans_right_name";
report_card{1,14} = "left_array_median_impedance";
report_card{1,15} = "right_array_median_impedance";
report_card{1,16} = "samples_end";
report_card{1,17} = "percent_chans_kept_total";
report_card{1,18} = "percent_samples_kept_total";
report_card{1,21} = "check_1"; 
report_card{1,22} = "check_2";
report_card{1,23} = "check_3";
report_card{1,24} = "check_4";
report_card{1,25} = "Flag_1_rejsamples";
report_card{1,27} = "2Mohms_plus_rej_names_left";
report_card{1,28} = "total_rejected_chans_CRD&Impedance_left";
report_card{1,29} = "median_impedance_left_2Mo_criteria";
report_card{1,30} = "2Mohms_plus_rej_names_right";
report_card{1,31} = "total_rejected_chans_CRD&Impedance_right";
report_card{1,32} = "median_impedance_right_2Mo_criteria";
report_card{1,33} = "check_5";

load('/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_fully_preproc_for_MX_only_stats/Array_ID_Use_all.mat');

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%start the big boy loop - this does all of the individual subject level
%stuff (preprocessing, and processing) and generates and saves the single
%subject report card and final dataset 

% becasue of the way autoclave spits out the files (in folders in their
% folder) I had to do this silly thing - also, it seems that Mac OS only
% creates .ds_storefile when you have interacted with a folder through
% Finder (so created the folder, deleted, copied, pasted, etc.) but not
% when MATLAB created the folder and everything in it - so getting
% frustrated I just made a for loop to handle both situations - as well as
% situations where the wrong task somehow snuck in but meets the index
% requirements
for i = 1:length(dir)-3
    cd(strcat(files(i+3).folder,'/',files(i+3).name))
    sub_folder = dir;
    if length(sub_folder) == 4 && convertCharsToStrings(sub_folder(3).name) == ".DS_Store" && convertCharsToStrings(sub_folder(4).name(17:19)) == "Pre"
        cd(strcat(sub_folder(4).folder,'/',sub_folder(4).name))
    elseif length(sub_folder) == 4 && convertCharsToStrings(sub_folder(3).name) ~= ".DS_Store"
        disp('WARNING, FILE STRUCTURE INCORRECT - probably no .DS file and both pre and post PVT files')
        keyboard
    elseif length(sub_folder) == 4 && convertCharsToStrings(sub_folder(4).name(17:19)) ~= "Pre"
        disp('WARNING, FILE STRUCTURE INCORRECT - probably no .DS file and both pre and post PVT files')
        keyboard
    elseif length(sub_folder) == 3 && convertCharsToStrings(sub_folder(3).name(17:19)) == "Pre"
        cd(strcat(sub_folder(3).folder,'/',sub_folder(3).name))
    elseif length(sub_folder) == 3 && convertCharsToStrings(sub_folder(3).name(17:19)) ~= "Pre"
        cd(strcat(sub_folder(3).folder,'/',sub_folder(3).name))
        disp('WARNING, FILE STRUCTURE INCORRECT - probably no .DS file and only have post file and not pre')
        keyboard
    else 
        disp('WARNING, FILE STRUCTURE INCORRECT - in some wonky way')
        keyboard
    end
    set = dir;

    
    EEG = pop_loadset('filename',set(3).name,'filepath',strcat(set(3).folder,'/'));
    
    
    report_card{2,1} = files(i+3).name(8:11); %SUBID
    report_card{2,4} = length(EEG.data); %samples start
    
    for w =2:length(Array_Info)
        if Array_Info{w,1} == report_card{2,1}
            report_card{2,2} = Array_Info(w,2); %Array ID
            report_card(2,3) = Array_Info(w,3); % Use Count
        end
    end

    %we only want the MX channels - so this gets rid of all others
    EEG = pop_select(EEG,'channel', 1:32);
    %the order is based on automin of 11 hand processed files - they were
    %all the same
    EEG  = pop_basicfilter( EEG,  1:32 , 'Boundary', 'boundary', 'Cutoff',  0.1, 'Design', 'butter', 'Filter', 'highpass', 'Order',  2, 'RemoveDC', 'on' ); %if you just don't specify an order, it uses this: it might be the automin - gotta check: default 3*fix(srate/locutoff)
    EEG  = pop_basicfilter( EEG,  1:32 , 'Boundary', 'boundary', 'Cutoff',  35, 'Design', 'fir', 'Filter', 'lowpass', 'Order',  84, 'RemoveDC', 'on' );
    
    %here we iterativley run the clean_rawdata chan rejector at default
    %values until no further chans are deleted
    chans = EEG.nbchan;
    rejchan_iteration = 1;
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',[],'ChannelCriterion',[],'LineNoiseCriterion',[],'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    while EEG.nbchan ~= chans
        chans = EEG.nbchan;
        rejchan_iteration = rejchan_iteration+1;
        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',[],'ChannelCriterion',[],'LineNoiseCriterion',[],'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    end
    
    report_card{2,5} = rejchan_iteration; %rejected chan iterations
    
    
    % you will notice that this pipelie does not reject any samples/epochs
    % - that is correct - none of the analyses that uses the outputs care
    % about the timeseries data - silly me put a check in for percentage
    % samples deleted anyway out of habit
    
    
    
    % here we sort all of our remaining channels into the left and right
    % arrays
    right_helper = 1;
    left_helper = 1;
    left_array = {};
    right_array = {};
    for j = 1:EEG.nbchan
        if EEG.chanlocs(j).labels(1) == 'A'
            left_array{left_helper,1} = EEG.chanlocs(j).labels;
            left_helper = left_helper+1;
        else
            right_array{right_helper,1} = EEG.chanlocs(j).labels;
            right_helper = right_helper+1;
        end
    end 
    
    report_card{2,6} = length(left_array); %left array good chans total
    report_card{2,10} = length(right_array); % right array good chans total  

    % the same loop is used here to find and log both the bad
    % channels and the good channel impedances - left only
    helper = 0;
    rc_helper = 1;
    impedance_helper = 0;
    left_impedances = [];
    left_impedances_names = {};
    for k = 1:16
        for n = 1:length(left_array)
            if EEG.IntanMetadata(k).native_channel_name(3:5) == left_array{n}(3:5)
                helper = 1;
                impedance_helper = impedance_helper+1;
            end
        end
        if helper == 0
            report_card{2,9}(rc_helper,1) = cellstr(EEG.IntanMetadata(k).native_channel_name); %left array bad chan names
            rc_helper = rc_helper+1;
        else
            left_impedances(impedance_helper,1) = EEG.IntanMetadata(k).electrode_impedance_magnitude;
            left_impedances_names{impedance_helper,1} = strcat("A-", cellstr(EEG.IntanMetadata(k).native_channel_name(3:5)));
        end
        helper = 0;
    end
    report_card{2,7} = length(report_card{2,9}); %left array bad chans total
    report_card{2,8} = report_card{2,7}/16; % percent left chans rejected
    report_card{2,14} = median(left_impedances); % left array meadian impedance
    
    % this block (which is also used again belwo for right array) pulls out
    % the names and impedances of channels over 2Mohms which was a cutoff
    % criterian defined a-priori then takes a new median impedance of the
    % remaining channels -but no channels are deleted here
    two_Mohm_criteria_holder = [];
    holder_helper = 1;
    reject_helper = 1;
    helper = length(left_impedances);
    for t = 1:helper
        if left_impedances(t) >= 2000000
            report_card{2,27}(reject_helper,1) = left_impedances_names(t);%right array chan names that are over 2Mohms
            reject_helper = reject_helper+1;
        else
            two_Mohm_criteria_holder(holder_helper) = left_impedances(t);
            holder_helper = holder_helper+1;
        end
    end
    
    report_card{2,28} = length(report_card{2,27})+report_card{2,7}; %"total_rejected_chans_CRD&Impedance_left"
    report_card{2,29} = median(two_Mohm_criteria_holder); %median impedance of left after 2Mohm rule applied
  
    % repeat of above, but for the right side - the same loop is used here to find and log both the bad
    % channels and the good channel impedances - right side    
    helper = 0;
    rc_helper = 1;
    impedance_helper = 0;
    right_impedances = [];
    right_impedances_names = {};
    for k = 17:32
        for n = 1:length(right_array)
            if EEG.IntanMetadata(k).native_channel_name(3:5) == right_array{n}(3:5)
                helper = 1;
                impedance_helper = impedance_helper+1;
            end
        end
        if helper == 0
            report_card{2,13}(rc_helper,1) = cellstr(EEG.IntanMetadata(k).native_channel_name); %right array bad chan names
            rc_helper = rc_helper+1;
        else
            right_impedances(impedance_helper) = EEG.IntanMetadata(k).electrode_impedance_magnitude;
            right_impedances_names{impedance_helper,1} = strcat("B-", cellstr(EEG.IntanMetadata(k).native_channel_name(3:5)));
        end
        helper = 0;
    end
    report_card{2,11} = length(report_card{2,13}); % right array bad chans total
    report_card{2,12} = report_card{2,11}/16; % right array percent bad chans
    report_card{2,15} = median(right_impedances); %right array median impedance
    
    two_Mohm_criteria_holder = [];
    holder_helper = 1;
    reject_helper = 1;
    helper = length(right_impedances);
    for t = 1:helper
        if right_impedances(t) >= 2000000
            report_card{2,30}(reject_helper,1) = right_impedances_names(t);%right array chan names that are over 2Mohms
            reject_helper = reject_helper+1;
        else
            two_Mohm_criteria_holder(holder_helper) = right_impedances(t);
            holder_helper = holder_helper+1;
        end
    end
    
    report_card{2,31} = length(report_card{2,30})+report_card{2,11}; %"total_rejected_chans_CRD&Impedance_right"
    report_card{2,32} = median(two_Mohm_criteria_holder); %median impedance of right after 2Mohm rule applied
    
    
    report_card{2,16} = length(EEG.data); % samples end (currently useless)
    report_card{2,17} = EEG.nbchan/32; %percent chans kept total
    report_card{2,18} = report_card{2,16}/report_card{2,4}; % percent samples kept total
    
    % check 1 - for correctness in number chans
    if EEG.nbchan+report_card{2,7}+report_card{2,11} == 32
        report_card{2,21} = "t";
    else
        report_card{2,21} = "FALSE";
    end
    
    % check 2 - does nbchan = the sum of left and right good chans
    if EEG.nbchan == report_card{2,6}+report_card{2,10}
        report_card{2,22} = "t";
    else
        report_card{2,22} = "FALSE";
    end
    
    %check 3 - does the total of left impedances = the toal of good left chans
    if report_card{2,6} == length(left_impedances)
        report_card{2,23} = "t";
    else
        report_card{2,23} = "FALSE";
    end
    
    %check 4 - does the total of right impedances = total of good right chans
    if report_card{2,10} == length(right_impedances)
        report_card{2,24} = "t";
    else
        report_card{2,24} = "FALSE";
    end
    
    
    
    %flag one - for 30% samples deleted threshold (currently useless)
    if report_card{2,18} <= .7
        report_card{2,25} = "FLAG";
    end
                
    
    eeg_save_name = strcat(report_card{2,1}, '_PVT_Pre_preproc_for_MX_only_stats');
    EEG = pop_saveset(EEG, 'filename', eeg_save_name, 'filepath', data_out);
    
    report_card_save_name = strcat(stats_out,report_card{2,1},'_PVT_Pre_preproc_for_MX_only_stats_Report_card.mat');
    save(report_card_save_name,'report_card');
    
    cd(input);
    report_card(2,:) = [];
end

%% Class Report - it has every subject with both arrays and some checks - not to be used for analysis 

% this pulls out all of the information for everyone - this will be used in
% the chan rejeciton data that doesn't depend on impedance
clear
cd '/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_fully_preproc_for_MX_only_stats/PVT_Pre/stats'
files = dir;

Class_Report_raw = {};
load(files(4).name);
Class_Report_raw(1:2,:) = report_card(1:2,:);
clear report_card

for i = 5:length(dir)
    load(files(i).name);
    size_RC = size(Class_Report_raw);
    Class_Report_raw(size_RC(1)+1,:) = report_card(2,:);
    clear report_card
end


Class_Report_raw_save_name = strcat('/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_fully_preproc_for_MX_only_stats/PVT_Pre/Class_Report_raw.mat');
save(Class_Report_raw_save_name,'Class_Report_raw');


% this then pulls only the subjects that were recorded at 100Hz for
% impedance related analysis 
load('/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_fully_preproc_for_MX_only_stats/Subs_Recorded_at_100hz.mat')
helper = 2;
Class_report_raw_100hz_only = {};
Class_report_raw_100hz_only(1,:) = Class_Report_raw(1,:);
for i = 1:length(Subs_Recorded_at_100hz)
    for j = 1:length(Class_Report_raw)-1
        if Subs_Recorded_at_100hz{i} == Class_Report_raw{j+1,1}
            Class_report_raw_100hz_only(helper,:) = Class_Report_raw(j,:);
            helper = helper+1;
        end
    end
end
    

Class_Report_raw_100hz_only_save_name = strcat('/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_fully_preproc_for_MX_only_stats/PVT_Pre/Class_Report_raw_100hz_only');
save(Class_Report_raw_100hz_only_save_name,'Class_report_raw_100hz_only');


%% Array Report raw - broken down to each array = 1 row (aka, not by subject any more) - still raw - not to be used for analysis


% again - first we do it for all subjects here
Array_Report_raw = {};


Array_Report_raw{1,1} = "SUBID";
Array_Report_raw{1,2} = "array_pair_ID";
Array_Report_raw{1,3} = "use_count";
Array_Report_raw{1,4} = "left or right";
Array_Report_raw{1,5} = "total_rejected_chans_CRD_only";
Array_Report_raw{1,6} = "bad_chans_name_CRD_only";
Array_Report_raw{1,7} = "median_impedance_CRD_only";

Array_Report_raw{1,9} = "check"; %over 10 chans have been deleted CRD only

Array_Report_raw{1,11} = "bad_chan_names_2Mohm_only";
Array_Report_raw{1,12} = "total_rej_chans_CRD_and_2Mohm";
Array_Report_raw{1,13} = "median_impedance_CDR_and+2Mohm";

Array_Report_raw{1,14} = "check"; %over 10 chans have been deleted CRD and 2Mohm

CRr_size = size(Class_Report_raw);

left_array = {};
left_array(1,:) = Array_Report_raw(1,:);

for i = 1:CRr_size(1)-1
    left_array(i+1,1:3) = Class_Report_raw(i+1,1:3);
    left_array{i+1,4} = "left";
    left_array(i+1,5) = Class_Report_raw(i+1,7);
    left_array(i+1,6) = Class_Report_raw(i+1,9);
    left_array(i+1,7) = Class_Report_raw(i+1,14);
    left_array(i+1,11:13) = Class_Report_raw(i+1,27:29);
    
    if Class_Report_raw{i+1,7} >= 10
        left_array{i+1,9} = "FLAG";
    end
    
    if Class_Report_raw{i+1,28} >= 10
        left_array{i+1,14} = "FLAG";
    end
end

right_array = {};

for i = 1:CRr_size(1)-1
    right_array(i,1:3) = Class_Report_raw(i+1,1:3);
    right_array{i,4} = "right";
    right_array(i,5) = Class_Report_raw(i+1,11);
    right_array(i,6) = Class_Report_raw(i+1,13);
    right_array(i,7) = Class_Report_raw(i+1,15);
    right_array(i,11:13) = Class_Report_raw(i+1,30:32);
    
    if Class_Report_raw{i+1,11} >= 10
        right_array{i,9} = "FLAG";
    end
    
    if Class_Report_raw{i+1,31} >= 10
        right_array{i,14} = "FLAG";
    end
end


Array_Report_raw = [left_array; right_array];

Array_Report_raw_save_name = strcat('/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_fully_preproc_for_MX_only_stats/PVT_Pre/Array_Report_raw.mat');
save(Array_Report_raw_save_name,'Array_Report_raw');


% then we iterate through and pull out only those that were at 100hz
helper = 2;
Array_report_raw_100hz_only = {};
Array_report_raw_100hz_only(1,:) = Array_Report_raw(1,:);
for i = 1:length(Subs_Recorded_at_100hz)
    for j = 1:length(Array_Report_raw)-1
        if Subs_Recorded_at_100hz{i} == Array_Report_raw{j+1,1}
            Array_report_raw_100hz_only(helper,:) = Array_Report_raw(j,:);
            helper = helper+1;
        end
    end
end

Array_Report_raw_save_name = strcat('/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_fully_preproc_for_MX_only_stats/PVT_Pre/Array_Report_raw_100hz_only.mat');
save(Array_Report_raw_save_name,'Array_report_raw_100hz_only');

% Then I hand deleted the flagged data as well as any uneeded data for the
% relevent analyses and made the final preproc/cleaned varriables and hand
% saved them. 

% then I pulled the Gamry data and added it to the relevent varriable and
% saved a new final varriable 
