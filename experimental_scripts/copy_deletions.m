% Made by Ryan R. Rich during his time as a Research Assistant & Research Coordinator
% In the CogNeW Lab cognewlab.com at Drexel University
% 
% PI: John Medaglia
% Additional Mentor: Brian Erickson
% 
% Co-PI on MXtrode EEG Project: Flavia Vitale
% 
% Last updated on Aug 16, 2022
% 
% Contact Ryan: ryrich@umich.edu

%% Notes
% - this is based on my manual preprocessing steps that I did origionally -
% it's all the exact same order and when the filters are set to be the
% same, it produces the exact same results - the order of operations,
% especially in the fringe cases is important - even if it would 'work' in
% a diff order, something would be wrong

% but having said that, it works very well to automatically create the 
% exact same data for analysis - but with different filters - and it is set
% to avoide discontinuities and all that gross problematic stuff


%% Instructions

%  - for each run change the following
%     * the output folder
%     * the filter parameters 


%% Prep
clear
clc

% PATHS
% this is my pre-cleaned data already saved
preproc_input = '/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_PVT_fully_preprocessed_for_AG_comps/PreProc_manually_cleaned_01-35hz_steep_slope/Data';% string, folder name
% this is the data right out of autoclave
raw_input = '/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_PVT_Pre_autoclaved';
% this is where it will be saved - change per run
output = '/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_PVT_fully_preprocessed_for_AG_comps/Preproc_automatic_theta/data';

cd(preproc_input)

files = dir;

% that silly thing to deal with the finder based inconsistancies
if convertCharsToStrings(files(3).name) == ".DS_Store"
    invis_files = 3;
else
    invis_files = 2;
end

%% Big boy loop starts

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

for i = 1:length(dir)-invis_files

   
    % open the hand-cleaned "preproc" data to pull everything we need
    EEG = pop_loadset('filename',files(i+invis_files).name,'filepath',strcat(files(i+invis_files).folder,'/'));
    
    % copy the event structure and clean sample mask to varriables
    preproc_event = EEG.event;
    preproc_mask = EEG.etc.clean_sample_mask;
    
    % fun fact, the clean_sample_mask overwrites itself each time you run
    % clean_rawdata - so I had to go back and re-pre-process it and save
    % each iteration in it's own new struct in the EEG structure for DCUX
    % because I had to run it 4 times - it's the only one I had to run more
    % than once so it wasn't bad, but note for future
    if sum(files(i+invis_files).name(1:4) == 'DCUX') == 4
        preproc_mask_1 = EEG.masks.m1;
        preproc_mask_2 = EEG.masks.m2;
        preproc_mask_3 = EEG.masks.m3;
        preproc_mask_4 = EEG.masks.m4;
    end
    
    % for a host of reasons, it was easier and more accurate to pull the
    % channels that were kept than the ones that were deleted (I figured
    % that out after I did it the other way)
    preproc_chans = {};
    
    for j = 1:size(EEG.chanlocs,2)
        preproc_chans{j,1} = EEG.chanlocs(j).labels;
    end
    
    % it takes this much work to then go find the correct autoclave file to
    % open
    file_name_helper = strcat('MXAttn_', files(i+invis_files).name(1:4));
    
    filepath_helper = dir(strcat(raw_input, '/', file_name_helper));
    filepath_helper = filepath_helper(size(filepath_helper,1)).name;
    
    filepath = strcat(raw_input, '/', file_name_helper, '/', filepath_helper, '/');
    filename = strcat(filepath_helper, '_MXeneIntanImport_chlc_evExtract.set');

    % boom - opened the autoclaved 'raw' file
    EEG = pop_loadset('filename',filename,'filepath',filepath);
    
    % iterate through, find all channels that aren't in the preproc channel
    % list, and delete them
    preproc_rej_chans = {};
    helper = 0;
    
    for j = 1:size(EEG.chanlocs,2)
        for k = 1:size(preproc_chans)
            if EEG.chanlocs(j).labels == preproc_chans{k}
                helper = 1;
            end
        end
        
        if helper == 0
            preproc_rej_chans{size(preproc_rej_chans,1)+1,1} = EEG.chanlocs(j).labels;
        end
        
        helper = 0;
    end
    
    %% Don't forget to do one without any filters
    
    %% OG "Shallow" Broadband 1-35Hz filters - HPF: IIR order 2 - LPF: FIR order 84
    
    %EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  0.1, 'Design', 'butter', 'Filter', 'highpass', 'Order',  2, 'RemoveDC', 'on' );
    %EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  35, 'Design', 'fir', 'Filter', 'lowpass', 'Order',  84, 'RemoveDC', 'on' );
    
    %% OG "Steep" Broadband 1-35Hz filters - based on ERPLab IIR butterworth filters with high orders

    %EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  0.1, 'Design', 'butter', 'Filter', 'highpass', 'Order',  6, 'RemoveDC', 'on' );
    %EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  35, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  8, 'RemoveDC', 'on' );
    
    %% Automatic broadband filters - no attenuation 1-35Hz, .5 transition bands - based on EEGLab Basic FIR filter (new, standard)
    
    %EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',35);
    
    %% Automatic alpha filters - no attenuation 8-13Hz, 2Hz transition bands - based on EEGLab Basic FIR filter (new, standard)
    
    %EEG = pop_eegfiltnew(EEG, 'locutoff',8,'hicutoff',13);
    
    %% Automatic beta filters - no attenuation 13-30Hz, 3.25Hz transition bands - based on EEGLab Basic FIR filter (new, standard)
    
    %EEG = pop_eegfiltnew(EEG, 'locutoff',13,'hicutoff',30);
    
    %% Automatic Delta filters - no attenuation 1-4Hz*, 1Hz transition band - based on EEGLab Basic FIR filter (new, standard)
    
    %EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',4);
    
    %% Automatic Theta filters - no attenuation 4-8Hz, 2Hz transition band - based on EEGLab Basic FIR filter (new, standard)
    
    EEG = pop_eegfiltnew(EEG, 'locutoff',4,'hicutoff',8);
    
    %% After filtering, we can do rejections
    
    % this deletes all the channels that were rejected
    EEG = pop_select( EEG, 'nochannel',preproc_rej_chans);
    
    % this applies the clean mask (deletes samples)
    if sum(file_name_helper(8:11) == 'DCUX') ~= 4
        EEG.data(:,~preproc_mask) = [];
    %again, DCUX is special and needs its own case
    elseif sum(file_name_helper(8:11) == 'DCUX') == 4
        EEG.data(:,~preproc_mask_1) = [];
        EEG.data(:,~preproc_mask_2) = [];
        EEG.data(:,~preproc_mask_3) = [];
        EEG.data(:,~preproc_mask_4) = [];
    end
    
    % these two had manual rejections after clean_rawdata was run, so we
    % mimic them here
    if sum(file_name_helper(8:11) == 'DCUX') == 4
        EEG = eeg_eegrej( EEG, [1744 2475;5994 6710;19160 20091;24556 25424;26293 26746;28275 28975;38251 38867;40765 41096;42840 43455;48473 49166;52201 52816;59172 60933;64137 65021;66143 67058;76211 77841;79539 80239;83336 84021;85849 86541;88255 90607;91790 92329;104249 104887;107662 108177;113333 113780;114909 115663;116623 117384;118260 118952;130865 132533;137259 140173;141240 143362;147697 148004;148880 149611;154267 154722;155728 157811;159586 160086;168425 168871;172844 173559;175672 176288;187624 188155;191612 192820;195848 196540;198960 201136;207476 208353;210835 211512;215946 217221;219589 220204;221910 222886;224370 225400;235160 235898;239695 240494;243123 243792;244752 245060;245966 246436;247134 247857;252569 255712;257725 258410;264827 265519;269347 269731;275602 276348;277947 278815;281981 283781;285686 286394;289245 290366;294056 294756;295562 296416;297100 297592;298867 299529;301004 301327;302195 302933;306237 307153;307913 309612;312256 312779;316921 317337;318443 319258;322662 323377;329510 329918;330909 331294;356518 357179;375271 376017;382426 383080;384240 384917;395493 396254;401679 402264;404892 405822;409580 410219;415959 416559;417835 418573;420379 421455;424667 425375;430463 430947;435097 435489;436611 437326;438786 439186;441806 442591;443735 444620;459038 459300;459991 462113;463534 464096;465256 466194;471842 472527;474963 475816;477768 478460;484409 485124;488735 490381;497097 497682;499642 500272;507665 508289;516619 517219;518349 519141;520447 520724;529916 530447;531046 532029;544457 544888;554764 555364;555840 556524;563111 563780;571142 571750;575469 575854;579865 580450;582079 582556;587390 587606;589473 590180;592393 592985;594415 595130;599710 600371;602347 603177;604160 604752;607104 607934;618048 618502]);
        EEG = eeg_eegrej( EEG, [356 668;145106 145444;183876 184323;309328 309791;323469 323743;351620 352042;366083 366599;447271 447607]);
    elseif sum(file_name_helper(8:11) == 'DGAR') == 4
         EEG = eeg_eegrej( EEG, [11411 12545;64045 64921;65270 65579;72961 73412;74245 75387;77003 77570;85770 86462;90511 91062;103553 104112;106961 107878;115345 116012;126795 128229;143445 144037;159320 159695;162128 162545;163253 164029;166486 167570;171120 171453;192245 193212;194236 195362;200403 200970;220503 223012;224928 225761;229278 229862;249428 252761;256028 257812;260811 262261;265136 265462;266087 267661;276820 278728;285003 288062;291179 292595;295870 296261;316346 318245;359028 361436]);
    end
    
    % we have to give it an event structure, somehow it gets deleted in the
    % process and we need it for processing 
    EEG.event = preproc_event;
    
    %% Save the data appropriatley 
    
    save_name = strcat(files(i+invis_files).name(1:4), '_Pre');
    EEG = pop_saveset( EEG, 'filename',save_name,'filepath',output);
    
    %% Print all timeseries for review (use only on first run as a check)
    
    %pop_eegplot( EEG, 1, 1, 1);
    
    %% clear the needed things to not mess things up
    
    clear EEG ans file_name_helper filename filepath filepath_helper helper j k preproc_chans preproc_event preproc_mask preproc_rej_chans save_name
    
end
    
 %% These are the tests I ran on all 8 datasets with the origional filters to make sure everything worked exactly the same
 
% % should be 1 
% corrcoef(ALLEEG(1).data, ALLEEG(2).data)
% 
% f = [2:35]; 
% string_f = string(f);
% fs = 2000;
% 
% %cxy should all be 1
% [cxy, f] = mscohere(ALLEEG(1).data(1:8000), ALLEEG(2).data(1:8000),hamming(2000),[],f,fs);
% 
% %dtw should be 0
% dtw(ALLEEG(1).data(1:4000), ALLEEG(2).data(1:4000))
    
%% This is how to set priority of an application on a mac

% to set priority of a running program do the following
% 1. ps aux | top %% this will give you the PID of the program running that
% is using the most resources
% 2. sudo renice -n value "pid"
% value is -20 (top priority) to 20 (lowest priority)
% the "___" are needed around the PID


% can also search for all processes by name
% ps aux | grep MATLAB (then zoom out/stretch horizontally)


% I honestly can't tell if this made any difference