
tic;
        
%% Notes for user

% since this script is very repetative by nature, I only included comments
% on the first use of a specific thing - i.e. if I did something specific
% to choose a winner between 3 equidistant electrodes, then used that same
% code for each iteration, I only commented on it the first time - so if
% you are way down in the script and wonder why there are not comments, it
% because that section is recycled and there are comments way higher -
% search for the exact line minus the Electrode specific names


% the indicies are different depending on if I'm referencing the Intan
% Metadata or the chaninfo - I would need to reference Intan Metadata to
% see what was origionally in the array - but chaninfo should work for most
% other situations - this is notable in that in the Intan Metadata, Ag1
% would be B002 and index 33 and in the chaninfo Ag1 would be P001 and
% index 33


%% Notes for me 

% there are a few instances where all of the "equidistant" electrodes are
% not equidistant - it would seem that I occasionally added a diagonal as
% if it was the same as a parallel - ignoring this for now

%% Prep
clear
clc

% PATHS
% this is my pre-cleaned data already saved
input = '/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_PVT_fully_preprocessed_for_AG_comps/Preproc_automatic_no_filter/data';% string, folder name
output = '/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXene_PVT_fully_preprocessed_for_AG_comps/PreProc_manually_cleaned_01-35hz_steep_slope/Metrics';

cd(input)

files = dir;

% this is for MacOS - if you mess with files from Finder (delete, create,
% etc.) it generates these .DS_Store invisible files, but they aren't
% generated if Matlab generates the folder, files, and such
if convertCharsToStrings(files(3).name) == ".DS_Store"
    invis_files = 3;
else
    invis_files = 2;
end

% I really need to figure out a way to add things sections and have the
% index auto update - I spend too much time adding stuff later then moving
% everything, plus I generally miss at least one data entry update and have
% to go back 
report_card = {};

report_card{1,1} = "ID";

% the main takaway is the MX:AG - in this section, it will be the closest
% of both and if ties, lowest impedance - but I do want to go deeper as
% will be clear as you scroll - our big 3 metrics are as shown - notabley,
% none of them rely on impedance values and non incooperate those into the
% calculations
report_card{1,6} = "Correlation_MX:AG";
report_card{1,7} = "Coherence_MX:AG";
report_card{1,8} = "DTW_MX:AG";

% I want these for comparrison - I did it by hand in my origional hand
% cleaning and basic analysis of the data, but it became clear that I need
% it automated (the by hand work guided and confirmed that automated work)
% - these were the simplist data wrangling parts becasue it's pretty much
% binary
report_card{1,9} = "Correlation_Ag:Ag";
report_card{1,10} = "Coherence_Ag:Ag";
report_card{1,11} = "DTW_Ag:Ag";

% I also really want to be looking at the MX metrics as well - if they are
% high with neighboring MX and lower with AG, that indicates that they are
% systemically biased some way - either less accurate or more, but
% consistant - if worse, and constant, it could be corrected. If better,
% that's great. We have reason to predict that there will be differences in
% the higher frequencies based on electrode size. --** a big deal here is
% that I want to use the same MXtrode that I used in the MX:AG metrics with
% it's nearest electrode **-- so that's a lot more data wrangling
report_card{1,12} = "Correlation_MX:MX";
report_card{1,13} = "Coherence_MX:MX";
report_card{1,14} = "DTW_MX:MX";

%I also want to look at the furthest MXtrodes - which will be
%corner to corner - so I have 2 shots at this - I think it will be valuable
%because that's closer to the distance between 2 AG electrodes on a normal 
%standard cap

report_card{1,15} = "Correlation_Q1:Q3";
report_card{1,16} = "Coherence_Q1:Q3";
report_card{1,17} = "DTW_Q1:Q3";

report_card{1,18} = "Correlation_Q2:Q4";
report_card{1,19} = "Coherence_Q2:Q4";
report_card{1,20} = "DTW_Q2:Q4";

%I will also want the furthest MX:Ag comparisons, same logic as corners
%directly above. 

report_card{1,21} = "Furthest MX:Ag Correlation";
report_card{1, 22} = "Furthest MX:Ag Coherence";
report_card{1, 23} = "Furthest MX:Ag DTW";

%I decided to do the permutation stats at the end instead of within each
%pair type group because they blend together MX:Ag and Ag:Ag comps and can
%always be rearanged in the group level/summary stats sheet - it also made
%it easier with report card index numbering

report_card{1,24} = "Permuted Correlation MX:Perm_Ag";
report_card{1,25} = "Permuted Correlation Ag:Perm_Ag";
report_card{1,26} = "Permuted Coherence MX:Perm_Ag";
report_card{1,27} = "Permuted Coherence Ag:Perm_Ag";
report_card{1,28} = "Permuted DTW MX:Perm_AG";
report_card{1,29} = "Permuted DTW Ag:Perm_AG";
report_card{1, 30} = "Permuted Correlation Mx:Perm_MX";
report_card{1, 31} = "Permuted Furthest Coherence Mx:Perm_MX";
report_card{1, 32} = "Permuted Furthest DTW Mx:Perm_MX";


% we love flags/warnings/checks/failsafes/etc - here they are

report_card{1,33} = "# 2-sec epochs for DTW and mscohere non-permuted";
report_card{1,35} = "Array Possibley Plugged in Backwards";
report_card{1,36} = "Left and Right Arrays Possibley Flipped Ag:MX";
report_card{1,37} = "Left and Right Arrays Possibley Flipped Ag:Ag";
report_card{1,38} = "# epochs in perm calcs";

% metrics added on later - these names need to be hear, before things are
% transfered to the class reports, so that the lengths are the same and
% things don't break

report_card{1,40} = "AG_msr";
report_card{1,41} = "MX_msr";
report_card{1,42} = "Comp_AG_msr";
report_card{1,43} = "Comp_MX_msr";
report_card{1,44} = "Q1_msr";
report_card{1,45} = "Q3_msr";
report_card{1,46} = "Q2_msr";
report_card{1,47} = "Q4_msr";
report_card{1,48} = "Furthest_MX_msr";

report_card{1,51} = "AG PSD";
report_card{1,52} = "MX PSD";
report_card{1,53} = "Comp_AG_PSD";
report_card{1,54} = "Comp_MX_PSD";
report_card{1,55} = "Q1_PSD";
report_card{1,56} = "Q3_PSD";
report_card{1,57} = "Q2_PSD";
report_card{1,58} = "Q4_PSD";
report_card{1,59} = "Furthest_MX_PSD";

report_card{1,61} = "perm_unshuffled_correlation";
report_card{1,62} = "perm_unshuffled_dtw";
report_card{1,63} = "perm_unshuffled_coherence";

report_card{1,65} = "MX:AG Corr P";
report_card{1,66} = "AG:AG Corr P";
report_card{1,67} = "MX:MX-Near Corr P";
report_card{1,68} = "Q1:Q3 Corr P";
report_card{1,69} = "Q2:Q4 Corr P";
report_card{1,70} = "MX:MX-Far Corr P";


class_report_left = report_card;
class_report_right = report_card;


[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
%% Big boy loop starts

for i = 1:length(dir)-invis_files
   %% set things up
   
    loop_start = tic;
   
    EEG = pop_loadset('filename',files(i+invis_files).name,'filepath',strcat(files(i+invis_files).folder,'/'));
    
    report_card{2,1} = strcat(EEG.filename(1:4), '_L');
    report_card{3,1} = strcat(EEG.filename(1:4), '_R');
    %first I just pull the chan locs info into a varriable so it's easier
    %to referenc
    chan_info = {};
    for j = 1:length(EEG.chanlocs)
        chan_info{j,1} = EEG.chanlocs(j).labels;
    end
    
    helper_p1 = {};
    for d = 1:length(EEG.IntanMetadata)
        helper_p1{d,1} = EEG.IntanMetadata(d).native_channel_name;
    end
    
    % this is jut pulling the impedance values of all of them because I
    % wanted that info - it is useless now that we discredit these values
    % (check that pair maker doesn't use these and if not delete)
%     if ismember('P-001', chan_info)
%         report_card{2,2} = EEG.IntanMetadata(33).electrode_impedance_magnitude;
%     end
%     if ismember('P-002', chan_info)
%         report_card{2,3} = EEG.IntanMetadata(34).electrode_impedance_magnitude;
%     end
%     if ismember('P-004', chan_info)
%         report_card{2,4} = EEG.IntanMetadata(36).electrode_impedance_magnitude;
%     end
%     if ismember('P-005', chan_info)
%         report_card{2,5} = EEG.IntanMetadata(37).electrode_impedance_magnitude;
%     end
    
    
    %% Left side (subject's) Only - choose electrodes
    
    %So this section is finding how many AG electrodes are next to this
    %array and if multiple, doing the work to pick the best one. It was
    %also the easiest place to build in the AG:AG metrics if applicable (I
    %think I actually moved the Ag:AgCl metrics)
    
    if ismember('P-001', chan_info) && ismember('P-004', chan_info)
        impedances = [];
        impedances(1) = EEG.IntanMetadata(33).electrode_impedance_magnitude;
        impedances(2) = EEG.IntanMetadata(36).electrode_impedance_magnitude;
        
        if impedances(1) < impedances(2)
            winning_AG_L = 'P-001';
            loosing_AG_L = 'P-004';
        else
            winning_AG_L = 'P-004';
            loosing_AG_L = 'P-001';
        end 
    elseif ismember('P-001', chan_info)
        winning_AG_L = 'P-001';
    elseif ismember('P-004', chan_info)
        winning_AG_L = 'P-004';
    end
        
    % now the data-wrangling gets intense - it was hard enough to get the
    % AG:MX pairs, but then the MX:MX pairs from that was a lot - I had a
    % map of the electrode layout that I was referenceing for it all - just
    % a lot of if logic for every possible outcome (I didn't continue until
    % all combinations were exhosted because I didn't think that was needed
    % based on my previous cleaning
    if ismember('P-001', chan_info) && ismember('P-004', chan_info) && convertCharsToStrings(winning_AG_L) == "P-001"
        % first we find the closest MX to the Ag/AgCl electrode
        if ismember('A-004', chan_info) && ismember('A-005', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(5).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(6).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                winning_MX_L = 'A-004';
            else
                winning_MX_L = 'A-005';
            end
        % they will either both be there or only one will be there    
        elseif ismember('A-004', chan_info)
            winning_MX_L = 'A-004';
        elseif ismember('A-005', chan_info)
            winning_MX_L = 'A-005';
        else
            % when more than 3 electrodes had to be directly comparied, the
            % for loops got to be a lot, so I cheated and just made a fixed
            % vector with X slots in it and entered all of the impedances
            % for the relevent channels - if that channel didn't exist, I
            % just made it's impedance huge so that it wouldn't be selected
            % as the min
            impedances = [];
            if ismember('A-007', chan_info)
                impedances(1) = EEG.IntanMetadata(8).electrode_impedance_magnitude;
            else
                impedances(1) = 999999999999999999999;
            end
            if ismember('A-006', chan_info)
                impedances(2) = EEG.IntanMetadata(7).electrode_impedance_magnitude;
            else
                impedances(2) = 999999999999999999999;
            end
            if ismember('A-002', chan_info)
                impedances(3) = EEG.IntanMetadata(3).electrode_impedance_magnitude;
            else
                impedances(3) = 999999999999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                winning_MX_L = 'A-007';
            elseif I == 2 
                winning_MX_L = 'A-006';
            elseif I == 3
                winning_MX_L = 'A-002';
            end
        end
        %now we use the exact same code to find the furthest MXtrode from the Ag/AgCl
        if ismember('A-010', chan_info) && ismember('A-011', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(11).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(12).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_L = 'A-010';
            else
                furthest_MX_L = 'A-011';
            end   
        elseif ismember('A-010', chan_info)
            furthest_MX_L = 'A-010';
        elseif ismember('A-011', chan_info)
            furthest_MX_L = 'A-011';
        else
            impedances = [];
            if ismember('A-008', chan_info)
                impedances(1) = EEG.IntanMetadata(9).electrode_impedance_magnitude;
            else
                impedances(1) = 999999999999999999999;
            end
            if ismember('A-009', chan_info)
                impedances(2) = EEG.IntanMetadata(10).electrode_impedance_magnitude;
            else
                impedances(2) = 999999999999999999999;
            end
            if ismember('A-013', chan_info)
                impedances(3) = EEG.IntanMetadata(14).electrode_impedance_magnitude;
            else
                impedances(3) = 999999999999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                furthest_MX_L = 'A-008';
            elseif I == 2 
                furthest_MX_L = 'A-009';
            elseif I == 3
                furthest_MX_L = 'A-013';
            end
        end
    % and now we reapeat    
    elseif ismember('P-001', chan_info) && ismember('P-004', chan_info) && convertCharsToStrings(winning_AG_L) == "P-004"
        if ismember('A-000', chan_info) && ismember('A-002', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(1).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(3).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                winning_MX_L = 'A-000';
            else
                winning_MX_L = 'A-002';
            end
        elseif ismember('A-000', chan_info)
            winning_MX_L = 'A-000';
        elseif ismember('A-002', chan_info)
            winning_MX_L = 'A-002';
        else
            impedances = [];
            if ismember('A-001', chan_info)
                impedances(1) = EEG.IntanMetadata(2).electrode_impedance_magnitude;
            else
                impedances(1) = 99999999999999;
            end
            if ismember('A-003', chan_info)
                impedances(2) = EEG.IntanMetadata(4).electrode_impedance_magnitude;
            else
                impedances(2) = 99999999999999;
            end
            if ismember('A-004', chan_info)
                impedances(3) = EEG.IntanMetadata(5).electrode_impedance_magnitude;
            else
                impedances(3) = 99999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                winning_MX_L = 'A-001';
            elseif I == 2
                winning_MX_L = 'A-003';
            elseif I == 3 
                winning_MX_L = 'A-004';
            end
        end
        if ismember('A-013', chan_info) && ismember('A-015', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(14).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(16).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_L = 'A-013';
            else
                furthest_MX_L = 'A-015';
            end
        elseif ismember('A-013', chan_info)
            furthest_MX_L = 'A-013';
        elseif ismember('A-015', chan_info)
            furthest_MX_L = 'A-015';
        else
            impedances = [];
            if ismember('A-010', chan_info)
                impedances(1) = EEG.IntanMetadata(11).electrode_impedance_magnitude;
            else
                impedances(1) = 99999999999999;
            end
            if ismember('A-012', chan_info)
                impedances(2) = EEG.IntanMetadata(13).electrode_impedance_magnitude;
            else
                impedances(2) = 99999999999999;
            end
            if ismember('A-014', chan_info)
                impedances(3) = EEG.IntanMetadata(15).electrode_impedance_magnitude;
            else
                impedances(3) = 99999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                furthest_MX_L = 'A-010';
            elseif I == 2
                furthest_MX_L = 'A-012';
            elseif I == 3 
                furthest_MX_L = 'A-014';
            end
        end
    
    % In the case that only P-001 exists, it's a little more tricky becuase
    % it could be that there was only P-001 - in that case it would be in
    % the middle - or it could be that P-004 was rejected - in that case
    % P-001 would be on the top - it moves, so we need 2 elseifs for it -
    % the deciding factor will be if P-004 existed origionally in the Intan
    % Metadata - there is is B-005 - if it does, it's the same combos as 
    % above, if not, it's novel combos
    
    
    % we will do the case where they both exist first for simplicity ( I
    % can say if it does, do this, else do the other instead of more
    % complex logic) - this uses the same combos as before - - I would have
    % loved to just make that a compound OR statement to save lines,
    % however, it needs an elseif statement after it checked to see if they
    % were both there - I couldn't have it do an OR statement and have the
    % heiarchy needed 
   
    elseif ismember('P-001', chan_info) && ismember('B-005', helper_p1)
        if ismember('A-004', chan_info) && ismember('A-005', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(5).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(6).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                winning_MX_L = 'A-004';
            else
                winning_MX_L = 'A-005';
            end  
        elseif ismember('A-004', chan_info)
            winning_MX_L = 'A-004';
        elseif ismember('A-005', chan_info)
            winning_MX_L = 'A-005';
        else
            impedances = [];
            if ismember('A-007', chan_info)
                impedances(1) = EEG.IntanMetadata(8).electrode_impedance_magnitude;
            else
                impedances(1) = 999999999999999999999;
            end
            if ismember('A-006', chan_info)
                impedances(2) = EEG.IntanMetadata(7).electrode_impedance_magnitude;
            else
                impedances(2) = 999999999999999999999;
            end
            if ismember('A-002', chan_info)
                impedances(3) = EEG.IntanMetadata(3).electrode_impedance_magnitude;
            else
                impedances(3) = 999999999999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                winning_MX_L = 'A-007';
            elseif I == 2 
                winning_MX_L = 'A-006';
            elseif I == 3
                winning_MX_L = 'A-002';
            end
        end
        if ismember('A-010', chan_info) && ismember('A-011', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(11).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(12).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_L = 'A-010';
            else
                furthest_MX_L = 'A-011';
            end   
        elseif ismember('A-010', chan_info)
            furthest_MX_L = 'A-010';
        elseif ismember('A-011', chan_info)
            furthest_MX_L = 'A-011';
        else
            impedances = [];
            if ismember('A-008', chan_info)
                impedances(1) = EEG.IntanMetadata(9).electrode_impedance_magnitude;
            else
                impedances(1) = 999999999999999999999;
            end
            if ismember('A-009', chan_info)
                impedances(2) = EEG.IntanMetadata(10).electrode_impedance_magnitude;
            else
                impedances(2) = 999999999999999999999;
            end
            if ismember('A-013', chan_info)
                impedances(3) = EEG.IntanMetadata(14).electrode_impedance_magnitude;
            else
                impedances(3) = 999999999999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                furthest_MX_L = 'A-008';
            elseif I == 2 
                furthest_MX_L = 'A-009';
            elseif I == 3
                furthest_MX_L = 'A-013';
            end
        end
    
    % this is if P-001 is centered - i.e. new combinations not previously
    % made
    elseif ismember('P-001', chan_info)
        if ismember('A-002', chan_info) && ismember('A-004', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(3).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(5).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                winning_MX_L = 'A-002';
            else
                winning_MX_L = 'A-004';
            end
        elseif ismember('A-002', chan_info)
            winning_MX_L = 'A-002';
        elseif ismember('A-004', chan_info)
            winning_MX_L = 'A-004';
        else
            impedances = [];
            if ismember('A-000', chan_info)
                impedances(1) = EEG.IntanMetadata(1).electrode_impedance_magnitude;
            else
                impedances(1) = 999999999999999999999;
            end
            if ismember('A-003', chan_info)
                impedances(2) = EEG.IntanMetadata(4).electrode_impedance_magnitude;
            else
                impedances(2) = 999999999999999999999;
            end
            if ismember('A-006', chan_info)
                impedances(3) = EEG.IntanMetadata(7).electrode_impedance_magnitude;
            else
                impedances(3) = 999999999999999999999;
            end
            if ismember('A-005', chan_info)
                impedances(4) = EEG.IntanMetadata(6).electrode_impedance_magnitude;
            else 
                impedances(3) = 999999999999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                winning_MX_L = 'A-000';
            elseif I == 2
                winning_MX_L = 'A-003';
            elseif I == 3
                winning_MX_L = 'A-006';
            elseif I == 4
                winning_MX_L = 'A-005';
            end
        end
        if ismember('A-010', chan_info) && ismember('A-013', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(11).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(14).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_L = 'A-010';
            else
                furthest_MX_L = 'A-013';
            end
        elseif ismember('A-010', chan_info)
            furthest_MX_L = 'A-010';
        elseif ismember('A-013', chan_info)
            furthest_MX_L = 'A-013';
        end
        if ismember('A-011', chan_info) && ismember('A-015', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(12).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(16).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_L = 'A-011';
            else
                furthest_MX_L = 'A-015';
            end
        elseif ismember('A-011', chan_info)
            furthest_MX_L = 'A-011';
        elseif ismember('A-015', chan_info)
            furthest_MX_L = 'A-015';
        end
    % origionally, I did not have this final iteration of winning AG because there was no situation where
    % we only placed a P-004 electrode - however, I added it because I
    % realized that there could be situations where they were both there
    % but the P-001 was rejected - this is simplier than only P-001 because
    % P-004 does not move - if it exists, it will always be on the lower
    % side
    
    % notice that it's the exact same combinations and such as the if both
    % P-001 and P-004 and P-004 is the winner from above - I would have
    % loved to just make that a compound OR statement to save lines,
    % however, it needs an elseif statement after it checked to see if they
    % wree both there - I couldn't have it do an OR statement and have the
    % heiarchy needed
    elseif ismember('P-004', chan_info)
        if ismember('A-000', chan_info) && ismember('A-002', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(1).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(3).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                winning_MX_L = 'A-000';
            else
                winning_MX_L = 'A-002';
            end
        elseif ismember('A-000', chan_info)
            winning_MX_L = 'A-000';
        elseif ismember('A-002', chan_info)
            winning_MX_L = 'A-002';
        else
            impedances = [];
            if ismember('A-001', chan_info)
                impedances(1) = EEG.IntanMetadata(2).electrode_impedance_magnitude;
            else
                impedances(1) = 99999999999999;
            end
            if ismember('A-003', chan_info)
                impedances(2) = EEG.IntanMetadata(4).electrode_impedance_magnitude;
            else
                impedances(2) = 99999999999999;
            end
            if ismember('A-006', chan_info)
                impedances(3) = EEG.IntanMetadata(7).electrode_impedance_magnitude;
            else
                impedances(3) = 99999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                winning_MX_L = 'A-001';
            elseif I == 2
                winning_MX_L = 'A-003';
            elseif I == 3 
                winning_MX_L = 'A-006';
            end
        end
        if ismember('A-013', chan_info) && ismember('A-015', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(14).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(16).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_L = 'A-013';
            else
                furthest_MX_L = 'A-015';
            end
        elseif ismember('A-013', chan_info)
            furthest_MX_L = 'A-013';
        elseif ismember('A-015', chan_info)
            furthest_MX_L = 'A-015';
        else
            impedances = [];
            if ismember('A-010', chan_info)
                impedances(1) = EEG.IntanMetadata(11).electrode_impedance_magnitude;
            else
                impedances(1) = 99999999999999;
            end
            if ismember('A-012', chan_info)
                impedances(2) = EEG.IntanMetadata(13).electrode_impedance_magnitude;
            else
                impedances(2) = 99999999999999;
            end
            if ismember('A-014', chan_info)
                impedances(3) = EEG.IntanMetadata(15).electrode_impedance_magnitude;
            else
                impedances(3) = 99999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                furthest_MX_L = 'A-010';
            elseif I == 2
                furthest_MX_L = 'A-012';
            elseif I == 3 
                furthest_MX_L = 'A-014';
            end
        end
    end
        
    % I was origionally going to do the MX:MX pairings within the loops
    % that already exist - it seemed logical to just determin the
    % wining MX:MX pair when the OG winning MX was chosen - however 2
    % reasons not to - A. that would make the for loops up to 4 deeper
    % and that's ridiculous, tedious, and leads to mistakes and B.
    % there are only so many options and the winner is saved, so there
    % is no reason I can't take it out of the loop and save some
    % repetitivity and lines so here we go

    % here is a list of all potential winning MXtrodes
    % A-005, A-004, A-002, A-000, A-001, A-003, A-006, A-002, A-007

    % There is no heiarchy here - aka - the order we iterate through
    % these does not matter, they could all be their own if statements
    % - however, to package them up, I will use a single if/elseif
    % statement - however, the order I do it does not matter, so I'll
    % just go in order by electrode number - also note, they all had at
    % least 3 equidistant neighbors, so I didn't go to 2nd closest
    % neighbots, that seemed excessive 
        
    if convertCharsToStrings(winning_MX_L) == "A-000"
        impedances = [];
        if ismember('A-001', chan_info)
            impedances(1) = EEG.IntanMetadata(2).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('A-003', chan_info)
            impedances(2) = EEG.IntanMetadata(4).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('A-002', chan_info)
            impedances(3) = EEG.IntanMetadata(3).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_L = 'A-001';
        elseif I == 2
            MX_buddy_L = 'A-003';
        elseif I == 3 
            MX_buddy_L = 'A-002';
        end
    elseif convertCharsToStrings(winning_MX_L) == "A-001"
        impedances = [];
        if ismember('A-000', chan_info)
            impedances(1) = EEG.IntanMetadata(1).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('A-003', chan_info)
            impedances(2) = EEG.IntanMetadata(4).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('A-014', chan_info)
            impedances(3) = EEG.IntanMetadata(15).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_L = 'A-000';
        elseif I == 2
            MX_buddy_L = 'A-003';
        elseif I == 3 
            MX_buddy_L = 'A-014';
        end
    elseif convertCharsToStrings(winning_MX_L) == "A-002"
        impedances = [];
        if ismember('A-000', chan_info)
            impedances(1) = EEG.IntanMetadata(1).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('A-004', chan_info)
            impedances(2) = EEG.IntanMetadata(5).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('A-003', chan_info)
            impedances(3) = EEG.IntanMetadata(4).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_L = 'A-000';
        elseif I == 2
            MX_buddy_L = 'A-004';
        elseif I == 3 
            MX_buddy_L = 'A-003';
        end
    elseif convertCharsToStrings(winning_MX_L) == "A-003"
        impedances = [];
        if ismember('A-001', chan_info)
            impedances(1) = EEG.IntanMetadata(2).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('A-002', chan_info)
            impedances(2) = EEG.IntanMetadata(3).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('A-006', chan_info)
            impedances(3) = EEG.IntanMetadata(7).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end
        if ismember('A-012', chan_info)
            impedances(4) = EEG.IntanMetadata(13).electrode_impedance_magnitude;
        else
            impedances(4) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_L = 'A-001';
        elseif I == 2
            MX_buddy_L = 'A-002';
        elseif I == 3 
            MX_buddy_L = 'A-006';
        elseif I == 4
            MX_buddy_L = 'A-012';
        end
    elseif convertCharsToStrings(winning_MX_L) == "A-004"
        impedances = [];
        if ismember('A-002', chan_info)
            impedances(1) = EEG.IntanMetadata(3).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('A-005', chan_info)
            impedances(2) = EEG.IntanMetadata(6).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('A-006', chan_info)
            impedances(3) = EEG.IntanMetadata(7).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_L = 'A-002';
        elseif I == 2
            MX_buddy_L = 'A-005';
        elseif I == 3 
            MX_buddy_L = 'A-006';
        end
    elseif convertCharsToStrings(winning_MX_L) == "A-005"
        impedances = [];
        if ismember('A-004', chan_info)
            impedances(1) = EEG.IntanMetadata(5).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('A-006', chan_info)
            impedances(2) = EEG.IntanMetadata(7).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('A-007', chan_info)
            impedances(3) = EEG.IntanMetadata(8).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_L = 'A-004';
        elseif I == 2
            MX_buddy_L = 'A-006';
        elseif I == 3 
            MX_buddy_L = 'A-007';
        end
    elseif convertCharsToStrings(winning_MX_L) == "A-006"
        impedances = [];
        if ismember('A-003', chan_info)
            impedances(1) = EEG.IntanMetadata(4).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('A-004', chan_info)
            impedances(2) = EEG.IntanMetadata(5).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('A-007', chan_info)
            impedances(3) = EEG.IntanMetadata(8).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end
        if ismember('A-008', chan_info)
            impedances(4) = EEG.IntanMetadata(9).electrode_impedance_magnitude;
        else
            impedances(4) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_L = 'A-003';
        elseif I == 2
            MX_buddy_L = 'A-004';
        elseif I == 3 
            MX_buddy_L = 'A-007';
        elseif I == 4 
            MX_buddy_L = 'A-008';
        end
    elseif convertCharsToStrings(winning_MX_L) == "A-007"
        impedances = [];
        if ismember('A-005', chan_info)
            impedances(1) = EEG.IntanMetadata(6).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('A-006', chan_info)
            impedances(2) = EEG.IntanMetadata(7).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('A-009', chan_info)
            impedances(3) = EEG.IntanMetadata(10).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_L = 'A-005';
        elseif I == 2
            MX_buddy_L = 'A-006';
        elseif I == 3 
            MX_buddy_L = 'A-009';
        end
    end
        
    % okay, the Ag:MX pairs are done, the Ag:AG pairs are done, and the
    % MX:MX pairs are done, now all that's left are the corners - but they
    % either simply exist or don't, no need for all these loops finding
    % pairs, so these calcs can just go below with all the other metrics
    % calcs 

    
    %% Right side (subject's) Only - choose electrodes
    
    if ismember('P-002', chan_info) && ismember('P-005', chan_info)
        impedances = [];
        impedances(1) = EEG.IntanMetadata(34).electrode_impedance_magnitude;
        impedances(2) = EEG.IntanMetadata(37).electrode_impedance_magnitude;
        
        if impedances(1) < impedances(2)
            winning_AG_R = 'P-002';
            loosing_AG_R = 'P-005';
        else
            winning_AG_R = 'P-005';
            loosing_AG_R = 'P-002';
        end 
    elseif ismember('P-002', chan_info)
        winning_AG_R = 'P-002';
    elseif ismember('P-005', chan_info)
        winning_AG_R = 'P-005';
    end
        

    if ismember('P-002', chan_info) && ismember('P-005', chan_info) && convertCharsToStrings(winning_AG_R) == "P-002"
 
        if ismember('B-027', chan_info) && ismember('B-026', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(28).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(26).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                winning_MX_R = 'B-027';
            else
                winning_MX_R = 'B-026';
            end
            
        elseif ismember('B-027', chan_info)
            winning_MX_R = 'B-027';
        elseif ismember('B-026', chan_info)
            winning_MX_R = 'B-026';
        else

            impedances = [];
            if ismember('B-025', chan_info)
                impedances(1) = EEG.IntanMetadata(26).electrode_impedance_magnitude;
            else
                impedances(1) = 999999999999999999999;
            end
            if ismember('B-024', chan_info)
                impedances(2) = EEG.IntanMetadata(25).electrode_impedance_magnitude;
            else
                impedances(2) = 999999999999999999999;
            end
            if ismember('B-029', chan_info)
                impedances(3) = EEG.IntanMetadata(30).electrode_impedance_magnitude;
            else
                impedances(3) = 999999999999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                winning_MX_R = 'B-025';
            elseif I == 2 
                winning_MX_R = 'B-024';
            elseif I == 3
                winning_MX_R = 'B-029';
            end
        end
        
        if ismember('B-020', chan_info) && ismember('B-021', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(21).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(22).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_R = 'B-020';
            else
                furthest_MX_R = 'B-021';
            end   
        elseif ismember('B-020', chan_info)
            furthest_MX_R = 'B-020';
        elseif ismember('B-021', chan_info)
            furthest_MX_R = 'B-021';
        else
            impedances = [];
            if ismember('B-022', chan_info)
                impedances(1) = EEG.IntanMetadata(23).electrode_impedance_magnitude;
            else
                impedances(1) = 999999999999999999999;
            end
            
            if ismember('B-023', chan_info)
                impedances(2) = EEG.IntanMetadata(24).electrode_impedance_magnitude;
            else
                impedances(2) = 999999999999999999999;
            end
            
            if ismember('B-018', chan_info)
                impedances(3) = EEG.IntanMetadata(19).electrode_impedance_magnitude;
            else
                impedances(3) = 999999999999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                furthest_MX_R = 'B-022';
            elseif I == 2 
                furthest_MX_R = 'B-023';
            elseif I == 3
                furthest_MX_R = 'B-018';
            end
        end
        
    elseif ismember('P-002', chan_info) && ismember('P-005', chan_info) && convertCharsToStrings(winning_AG_R) == "P-005"
        if ismember('B-029', chan_info) && ismember('B-031', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(30).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(32).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                winning_MX_R = 'B-029';
            else
                winning_MX_R = 'B-031';
            end
        elseif ismember('B-029', chan_info)
            winning_MX_R = 'B-029';
        elseif ismember('B-031', chan_info)
            winning_MX_R = 'B-031';
        else
            impedances = [];
            if ismember('B-026', chan_info)
                impedances(1) = EEG.IntanMetadata(27).electrode_impedance_magnitude;
            else
                impedances(1) = 99999999999999;
            end
            if ismember('B-028', chan_info)
                impedances(2) = EEG.IntanMetadata(29).electrode_impedance_magnitude;
            else
                impedances(2) = 99999999999999;
            end
            if ismember('B-030', chan_info)
                impedances(3) = EEG.IntanMetadata(31).electrode_impedance_magnitude;
            else
                impedances(3) = 99999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                winning_MX_R = 'B-026';
            elseif I == 2
                winning_MX_R = 'B-028';
            elseif I == 3 
                winning_MX_R = 'B-030';
            end
        end
        if ismember('B-018', chan_info) && ismember('B-016', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(19).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(17).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_R = 'B-018';
            else
                furthest_MX_R = 'B-016';
            end
        elseif ismember('B-018', chan_info)
            furthest_MX_R = 'B-018';
        elseif ismember('B-016', chan_info)
            furthest_MX_R = 'B-016';
        else
            impedances = [];
            if ismember('B-020', chan_info)
                impedances(1) = EEG.IntanMetadata(21).electrode_impedance_magnitude;
            else
                impedances(1) = 99999999999999;
            end
            if ismember('B-019', chan_info)
                impedances(2) = EEG.IntanMetadata(20).electrode_impedance_magnitude;
            else
                impedances(2) = 99999999999999;
            end
            if ismember('B-017', chan_info)
                impedances(3) = EEG.IntanMetadata(18).electrode_impedance_magnitude;
            else
                impedances(3) = 99999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                furthest_MX_R = 'B-020';
            elseif I == 2
                furthest_MX_R = 'B-019';
            elseif I == 3 
                furthest_MX_R = 'B-017';
            end
        end
    
   
    elseif ismember('P-002', chan_info) && ismember('B-006', helper_p1)
        if ismember('B-026', chan_info) && ismember('B-027', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(27).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(28).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                winning_MX_R = 'B-026';
            else
                winning_MX_R = 'B-027';
            end  
        elseif ismember('B-026', chan_info)
            winning_MX_R = 'B-026';
        elseif ismember('B-027', chan_info)
            winning_MX_R = 'B-027';
        else
            impedances = [];
            if ismember('B-025', chan_info)
                impedances(1) = EEG.IntanMetadata(26).electrode_impedance_magnitude;
            else
                impedances(1) = 999999999999999999999;
            end
            if ismember('B-024', chan_info)
                impedances(2) = EEG.IntanMetadata(25).electrode_impedance_magnitude;
            else
                impedances(2) = 999999999999999999999;
            end
            if ismember('B-029', chan_info)
                impedances(3) = EEG.IntanMetadata(30).electrode_impedance_magnitude;
            else
                impedances(3) = 999999999999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                winning_MX_R = 'B-025';
            elseif I == 2 
                winning_MX_R = 'B-024';
            elseif I == 3
                winning_MX_R = 'B-029';
            end
        end
        if ismember('B-021', chan_info) && ismember('B-020', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(22).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(21).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_R = 'B-021';
            else
                furthest_MX_R = 'B-020';
            end   
        elseif ismember('B-021', chan_info)
            furthest_MX_R = 'B-021';
        elseif ismember('B-020', chan_info)
            furthest_MX_R = 'B-020';
        else
            impedances = [];
            if ismember('B-023', chan_info)
                impedances(1) = EEG.IntanMetadata(24).electrode_impedance_magnitude;
            else
                impedances(1) = 999999999999999999999;
            end
            if ismember('B-022', chan_info)
                impedances(2) = EEG.IntanMetadata(23).electrode_impedance_magnitude;
            else
                impedances(2) = 999999999999999999999;
            end
            if ismember('B-018', chan_info)
                impedances(3) = EEG.IntanMetadata(19).electrode_impedance_magnitude;
            else
                impedances(3) = 999999999999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                furthest_MX_R = 'B-023';
            elseif I == 2 
                furthest_MX_R = 'B-022';
            elseif I == 3
                furthest_MX_R = 'B-018';
            end
        end
    
    elseif ismember('P-002', chan_info)
        if ismember('B-026', chan_info) && ismember('B-029', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(27).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(30).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                winning_MX_R = 'B-026';
            else
                winning_MX_R = 'B-029';
            end
        elseif ismember('B-026', chan_info)
            winning_MX_R = 'B-026';
        elseif ismember('B-029', chan_info)
            winning_MX_R = 'B-029';
        else
            impedances = [];
            if ismember('B-031', chan_info)
                impedances(1) = EEG.IntanMetadata(32).electrode_impedance_magnitude;
            else
                impedances(1) = 999999999999999999999;
            end
            if ismember('B-028', chan_info)
                impedances(2) = EEG.IntanMetadata(29).electrode_impedance_magnitude;
            else
                impedances(2) = 999999999999999999999;
            end
            if ismember('B-024', chan_info)
                impedances(3) = EEG.IntanMetadata(25).electrode_impedance_magnitude;
            else
                impedances(3) = 999999999999999999999;
            end
            if ismember('B-027', chan_info)
                impedances(4) = EEG.IntanMetadata(28).electrode_impedance_magnitude;
            else 
                impedances(3) = 999999999999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                winning_MX_R = 'B-031';
            elseif I == 2
                winning_MX_R = 'B-028';
            elseif I == 3
                winning_MX_R = 'B-024';
            elseif I == 4
                winning_MX_R = 'B-027';
            end
        end
        if ismember('B-020', chan_info) && ismember('B-018', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(21).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(19).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_R = 'B-020';
            else
                furthest_MX_R = 'B-018';
            end
        elseif ismember('B-020', chan_info)
            furthest_MX_R = 'B-020';
        elseif ismember('B-018', chan_info)
            furthest_MX_R = 'B-018';
        end
        if ismember('B-021', chan_info) && ismember('B-016', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(22).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(17).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_R = 'B-021';
            else
                furthest_MX_R = 'B-016';
            end
        elseif ismember('B-021', chan_info)
            furthest_MX_R = 'B-021';
        elseif ismember('B-016', chan_info)
            furthest_MX_R = 'B-016';
        end

    elseif ismember('P-005', chan_info)
        if ismember('B-031', chan_info) && ismember('B-029', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(32).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(30).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                winning_MX_R = 'B-031';
            else
                winning_MX_R = 'B-029';
            end
        elseif ismember('B-031', chan_info)
            winning_MX_R = 'B-031';
        elseif ismember('B-029', chan_info)
            winning_MX_R = 'B-029';
        else
            impedances = [];
            if ismember('B-030', chan_info)
                impedances(1) = EEG.IntanMetadata(31).electrode_impedance_magnitude;
            else
                impedances(1) = 99999999999999;
            end
            if ismember('B-028', chan_info)
                impedances(2) = EEG.IntanMetadata(29).electrode_impedance_magnitude;
            else
                impedances(2) = 99999999999999;
            end
            if ismember('B-026', chan_info)
                impedances(3) = EEG.IntanMetadata(27).electrode_impedance_magnitude;
            else
                impedances(3) = 99999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                winning_MX_R = 'B-030';
            elseif I == 2
                winning_MX_R = 'B-028';
            elseif I == 3 
                winning_MX_R = 'B-026';
            end
        end
        if ismember('B-018', chan_info) && ismember('B-016', chan_info)
            impedances = [];
            impedances(1) = EEG.IntanMetadata(19).electrode_impedance_magnitude;
            impedances(2) = EEG.IntanMetadata(17).electrode_impedance_magnitude;
            if impedances(1) < impedances(2)
                furthest_MX_R = 'B-018';
            else
                furthest_MX_R = 'B-016';
            end
        elseif ismember('B-018', chan_info)
            furthest_MX_R = 'B-018';
        elseif ismember('B-016', chan_info)
            furthest_MX_R = 'B-016';
        else
            impedances = [];
            if ismember('B-020', chan_info)
                impedances(1) = EEG.IntanMetadata(21).electrode_impedance_magnitude;
            else
                impedances(1) = 99999999999999;
            end
            if ismember('B-019', chan_info)
                impedances(2) = EEG.IntanMetadata(20).electrode_impedance_magnitude;
            else
                impedances(2) = 99999999999999;
            end
            if ismember('B-017', chan_info)
                impedances(3) = EEG.IntanMetadata(18).electrode_impedance_magnitude;
            else
                impedances(3) = 99999999999999;
            end
            
            [M,I] = min(impedances);
            if I == 1
                furthest_MX_R = 'B-020';
            elseif I == 2
                furthest_MX_R = 'B-019';
            elseif I == 3 
                furthest_MX_R = 'B-017';
            end
        end
    end
        

    % here is a list of all potential winning MXtrodes
    % B-026, B-027, B-025, B-024, B-029, B-031, B-028, B-030
    
    %done  to match left side   
    if convertCharsToStrings(winning_MX_R) == "B-031"
        impedances = [];
        if ismember('B-030', chan_info)
            impedances(1) = EEG.IntanMetadata(31).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('B-028', chan_info)
            impedances(2) = EEG.IntanMetadata(29).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('B-029', chan_info)
            impedances(3) = EEG.IntanMetadata(30).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_R = 'B-030';
        elseif I == 2
            MX_buddy_R = 'B-028';
        elseif I == 3 
            MX_buddy_R = 'B-029';
        end
    elseif convertCharsToStrings(winning_MX_R) == "B-030"
        impedances = [];
        if ismember('B-031', chan_info)
            impedances(1) = EEG.IntanMetadata(32).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('B-028', chan_info)
            impedances(2) = EEG.IntanMetadata(29).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('B-017', chan_info)
            impedances(3) = EEG.IntanMetadata(18).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_R = 'B-031';
        elseif I == 2
            MX_buddy_R = 'B-028';
        elseif I == 3 
            MX_buddy_R = 'B-017';
        end
    elseif convertCharsToStrings(winning_MX_R) == "B-029"
        impedances = [];
        if ismember('B-031', chan_info)
            impedances(1) = EEG.IntanMetadata(32).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('B-026', chan_info)
            impedances(2) = EEG.IntanMetadata(27).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('B-028', chan_info)
            impedances(3) = EEG.IntanMetadata(29).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_R = 'B-031';
        elseif I == 2
            MX_buddy_R = 'B-026';
        elseif I == 3 
            MX_buddy_R = 'B-028';
        end
    elseif convertCharsToStrings(winning_MX_R) == "B-028"
        impedances = [];
        if ismember('B-030', chan_info)
            impedances(1) = EEG.IntanMetadata(31).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('B-029', chan_info)
            impedances(2) = EEG.IntanMetadata(30).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('B-024', chan_info)
            impedances(3) = EEG.IntanMetadata(25).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end
        if ismember('B-019', chan_info)
            impedances(4) = EEG.IntanMetadata(20).electrode_impedance_magnitude;
        else
            impedances(4) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_R = 'B-030';
        elseif I == 2
            MX_buddy_R = 'B-029';
        elseif I == 3 
            MX_buddy_R = 'B-024';
        elseif I == 4
            MX_buddy_R = 'B-019';
        end
    elseif convertCharsToStrings(winning_MX_R) == "B-026"
        impedances = [];
        if ismember('B-029', chan_info)
            impedances(1) = EEG.IntanMetadata(30).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('B-027', chan_info)
            impedances(2) = EEG.IntanMetadata(28).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('B-024', chan_info)
            impedances(3) = EEG.IntanMetadata(25).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_R = 'B-029';
        elseif I == 2
            MX_buddy_R = 'B-027';
        elseif I == 3 
            MX_buddy_R = 'B-024';
        end
    elseif convertCharsToStrings(winning_MX_R) == "B-027"
        impedances = [];
        if ismember('B-026', chan_info)
            impedances(1) = EEG.IntanMetadata(27).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('B-024', chan_info)
            impedances(2) = EEG.IntanMetadata(25).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('B-025', chan_info)
            impedances(3) = EEG.IntanMetadata(26).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_R = 'B-026';
        elseif I == 2
            MX_buddy_R = 'B-024';
        elseif I == 3 
            MX_buddy_R = 'B-025';
        end
    elseif convertCharsToStrings(winning_MX_R) == "B-024"
        impedances = [];
        if ismember('B-028', chan_info)
            impedances(1) = EEG.IntanMetadata(29).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('B-026', chan_info)
            impedances(2) = EEG.IntanMetadata(27).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('B-025', chan_info)
            impedances(3) = EEG.IntanMetadata(26).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end
        if ismember('B-022', chan_info)
            impedances(4) = EEG.IntanMetadata(23).electrode_impedance_magnitude;
        else
            impedances(4) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_R = 'B-028';
        elseif I == 2
            MX_buddy_R = 'B-026';
        elseif I == 3 
            MX_buddy_R = 'B-025';
        elseif I == 4 
            MX_buddy_R = 'B-022';
        end
    elseif convertCharsToStrings(winning_MX_R) == "B-025"
        impedances = [];
        if ismember('B-027', chan_info)
            impedances(1) = EEG.IntanMetadata(28).electrode_impedance_magnitude;
        else
            impedances(1) = 99999999999999;
        end
        if ismember('B-024', chan_info)
            impedances(2) = EEG.IntanMetadata(25).electrode_impedance_magnitude;
        else
            impedances(2) = 99999999999999;
        end
        if ismember('B-023', chan_info)
            impedances(3) = EEG.IntanMetadata(24).electrode_impedance_magnitude;
        else
            impedances(3) = 99999999999999;
        end

        [M,I] = min(impedances);
        if I == 1
            MX_buddy_R = 'B-027';
        elseif I == 2
            MX_buddy_R = 'B-024';
        elseif I == 3 
            MX_buddy_R = 'B-023';
        end
    end  
    
%% Pull data
    
    % okay - we have all the chosen electrodes/pairs, now we need to
    % actually pull their data to get metrics on
    
    AG_data_L = EEG.data(find(ismember(chan_info, winning_AG_L)),:);
    AG_data_R = EEG.data(find(ismember(chan_info, winning_AG_R)),:);
%----------------------------------------------------------------------------    
    AG_comp_helper_L = exist('loosing_AG_L', 'var');
    if AG_comp_helper_L == 1
        AG_comp_data_L = EEG.data(find(ismember(chan_info, loosing_AG_L)),:);
    end
    AG_comp_helper_R = exist('loosing_AG_R', 'var');
    if AG_comp_helper_R == 1
        AG_comp_data_R = EEG.data(find(ismember(chan_info, loosing_AG_R)),:);
    end 
%----------------------------------------------------------------------------     
    MX_data_L = EEG.data(find(ismember(chan_info, winning_MX_L)),:);
    MX_data_R = EEG.data(find(ismember(chan_info, winning_MX_R)),:);
%----------------------------------------------------------------------------     
    MX_bud_helper_L = exist('MX_buddy_L', 'var');
    if MX_bud_helper_L == 1
        MX_buddy_data_L = EEG.data(find(ismember(chan_info, MX_buddy_L)),:);
    end
    MX_bud_helper_R = exist('MX_buddy_R', 'var');
    if MX_bud_helper_R == 1
        MX_buddy_data_R = EEG.data(find(ismember(chan_info, MX_buddy_R)),:);
    end
 %----------------------------------------------------------------------------        
    if ismember('A-005', chan_info) && ismember('A-015', chan_info)
        Q1_data_L = EEG.data(find(ismember(chan_info, 'A-005')),:);
        Q3_data_L = EEG.data(find(ismember(chan_info, 'A-015')),:);
    end
    if ismember('B-027', chan_info) && ismember('B-016', chan_info)
        Q1_data_R = EEG.data(find(ismember(chan_info, 'B-027')),:);
        Q3_data_R = EEG.data(find(ismember(chan_info, 'B-016')),:);
    end
%----------------------------------------------------------------------------     
    if ismember('A-011', chan_info) && ismember('A-000', chan_info)
        Q2_data_L = EEG.data(find(ismember(chan_info, 'A-011')),:);
        Q4_data_L = EEG.data(find(ismember(chan_info, 'A-000')),:);
    end
    if ismember('B-021', chan_info) && ismember('B-031', chan_info)
        Q2_data_R = EEG.data(find(ismember(chan_info, 'B-021')),:);
        Q4_data_R = EEG.data(find(ismember(chan_info, 'B-031')),:);
    end
%----------------------------------------------------------------------------     
    furthest_helper_L = exist('furthest_MX_L', 'var');
    if furthest_helper_L == 1
        furthest_MX_data_L = EEG.data(find(ismember(chan_info, furthest_MX_L)),:);
    end
    furthest_helper_R = exist('furthest_MX_R', 'var');
    if furthest_helper_R == 1
        furthest_MX_data_R = EEG.data(find(ismember(chan_info, furthest_MX_R)),:);
    end
    
%% Pull Uninterupted 2sec epochs (no boundry -99 events)
    
    % DTW is computationally intensive and can't run on large timeseries,
    % it seems to max out at around 5sec worth of data - mscohere uses the
    % fft within it and discontinuities within the timeseries cause edge
    % artifacts and rippling in higher frequencies - so to solve both of
    % these problems, we made as many smaller continious chunks as possible
    % - we somewhat arbitrarily chose 2sec in an attempt to maximize amount
    % of usable data and be able to get metrics on the lowest frequencies
    % possible - but alas, we still have to min out at 2Hz because 2sec
    % isn't long enough to get coherence on 1Hz (or anything below 2Hz) -
    % boundry events are discontinuities, so we avoid them

    % I believe these will all be in miliseconds

    two_sec_epochs = []; %start time then end time in ms - to be used in metrics
    start_time = 500; %ms - used in loop only
    end_time = 2500; %ms - used in loop only
    end_data = length(EEG.data)/2; %divided by 2 to convert to ms instead of samples
    helper = 1;
    
    while end_data - end_time >= 2000
        % below is a magical function hidden in EEGlab help docs
        [~,all_bound_lat] = eeg_getepochevent(EEG, 'boundary',[start_time end_time]);
        empty = isempty(all_bound_lat{1,1});
        if empty == 1
            two_sec_epochs(helper,1) = start_time;
            two_sec_epochs(helper,2) = end_time;
            start_time = end_time;
            end_time = end_time + 2000;
            helper = helper+1;
        else
            % again, I arbitrarily chose to jump 200ms - it could be longer
            % or shorter
            start_time = start_time + 200;
            end_time = start_time + 2000;
        end
    end
    
    % I want to know how many "chunks" will be in my average
    report_card{2,33} = length(two_sec_epochs);
    report_card{3,33} = length(two_sec_epochs);
    
    
%% Run Metrics

    % and now we can run metrics and get them saved into our report card
    
    % the mscohere function is.... a lot... but I got it figured out - I
    % need to define a few things first which is why they are here
    
    % note, we start at 2Hz because of the 2sec epochs - if it turns out we
    % can make them longer we might be able to get down to 1Hz
    f = [2:35];
    string_f = string(f);
    fs = 2000;
    
%-------------------------------------------------------------------------------------------------------------------------    
    
    %MX:Ag - main comp
    
    % make sure to reset these for each comp 
    dtw_vector_L = [];
    dtw_vector_R = [];
    coherence_vector_L = [];
    coherence_vector_R = [];
    %spd metric - only on unfiltered
    AG_L_spd_vector = [];
    AG_R_spd_vector = [];
    MX_L_spd_vector = [];
    MX_R_spd_vector = [];
    % mean square root - only on bandpassed
    AG_L_msr_vector = [];
    AG_R_msr_vector = [];
    MX_L_msr_vector = [];
    MX_R_msr_vector = [];
    coef_column = 6;
    coherence_column = 7;
    dtw_column = 8;
    
    %first we do the easy part - the correlations
    [R,P] = corrcoef(AG_data_L, MX_data_L);    
        report_card{2,coef_column} = R(1,2);
        report_card{2,65} = P(1,2);
        
    [R,P] = corrcoef(AG_data_R, MX_data_R);    
        report_card{3,coef_column} = R(1,2);
        report_card{3,65} = P(1,2);
    
    % now we will do the DTW, spectral cohesion, and spectal power metrics - we will use
    % the boundry event "-99" free 2-second epochs created in the section
    % before and iterate through each epoch *** big note - the times are in
    % ms but these functions work in samples, so they need to be multiplied
    % by 2 ****
    for y = 1:length(two_sec_epochs)
        
        epochstart = two_sec_epochs(y,1)*2+1;
        epochend = two_sec_epochs(y,2)*2;
        
        AG_L_two_sec_epoch_y = AG_data_L(epochstart:epochend);
        AG_R_two_sec_epoch_y = AG_data_R(epochstart:epochend);
        MX_L_two_sec_epoch_y = MX_data_L(epochstart:epochend);
        MX_R_two_sec_epoch_y = MX_data_R(epochstart:epochend);
        
        dtw_vector_L(y) = dtw(AG_L_two_sec_epoch_y, MX_L_two_sec_epoch_y);
        dtw_vector_R(y) = dtw(AG_R_two_sec_epoch_y, MX_R_two_sec_epoch_y);
        
        % we are using a standard hamming window and we set it to length 
        % 2000 samples to allow a low of 2hz at 2k sampling rate - 50% overlap is standard
        [cxy, f] = mscohere(AG_L_two_sec_epoch_y, MX_L_two_sec_epoch_y,hamming(2000),[],f,fs);
        coherence_vector_L(1:length(cxy),y) = cxy(1:length(cxy));
        
        [cxy, f] = mscohere(AG_R_two_sec_epoch_y, MX_R_two_sec_epoch_y,hamming(2000),[],f,fs);
        coherence_vector_R(1:length(cxy),y) = cxy(1:length(cxy));
        
        % the parameters here were set to mimic the coherence calculations
        [spectra, freqs] = spectopo(AG_L_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
        AG_L_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
        
        [spectra, freqs] = spectopo(AG_R_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
        AG_R_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
        
        [spectra, freqs] = spectopo(MX_L_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
        MX_L_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
        
        [spectra, freqs] = spectopo(MX_R_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
        MX_R_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
        
        squared_AG_L_two_sec_epoch_y = AG_L_two_sec_epoch_y.^2;
        AG_L_msr_vector(y, 1:length(squared_AG_L_two_sec_epoch_y)) = squared_AG_L_two_sec_epoch_y;
        
        squared_AG_R_two_sec_epoch_y = AG_R_two_sec_epoch_y.^2;
        AG_R_msr_vector(y, 1:length(squared_AG_R_two_sec_epoch_y)) = squared_AG_R_two_sec_epoch_y;
        
        squared_MX_L_two_sec_epoch_y = MX_L_two_sec_epoch_y.^2;
        MX_L_msr_vector(y, 1:length(squared_MX_L_two_sec_epoch_y)) = squared_MX_L_two_sec_epoch_y;
        
        squared_MX_R_two_sec_epoch_y = MX_R_two_sec_epoch_y.^2;
        MX_R_msr_vector(y, 1:length(squared_MX_R_two_sec_epoch_y)) = squared_MX_R_two_sec_epoch_y;

    end
 
    % because of some silliness with data types and lables/data we had to
    % pull the numbers before we named the columns (as in fill the
    % frequency column)
    report_card{2,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));
    report_card{3,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));
    % each frequency will get metrics, so we must iterate
    for b = 1:length(report_card{2,7})-1
        report_card{2,coherence_column}(b+1,2) = mean(coherence_vector_L(b,:));
        report_card{2,coherence_column}(b+1,3) = median(coherence_vector_L(b,:));
        report_card{2,coherence_column}(b+1,4) = std(coherence_vector_L(b,:));
        
        report_card{3,coherence_column}(b+1,2) = mean(coherence_vector_R(b,:));
        report_card{3,coherence_column}(b+1,3) = median(coherence_vector_R(b,:));
        report_card{3,coherence_column}(b+1,4) = std(coherence_vector_R(b,:));
    end
    
    % now we can name
    report_card{2,coherence_column} = string(report_card{2,coherence_column});
    report_card{3,coherence_column} = string(report_card{3,coherence_column});
    
    report_card{2,coherence_column}(1,1) = "Frequency in Hz";
    report_card{2,coherence_column}(1,2) = "mean coherence";
    report_card{2,coherence_column}(1,3) = "median coherence";
    report_card{2,coherence_column}(1,4) = "std coherence";
    
    report_card{3,coherence_column}(1,1) = "Frequency in Hz";
    report_card{3,coherence_column}(1,2) = "mean coherence";
    report_card{3,coherence_column}(1,3) = "median coherence";
    report_card{3,coherence_column}(1,4) = "std coherence";
    
    %DTW is easier, because it's 1 value per subject
    report_card{2,dtw_column}(1,1) = "mean";
    report_card{2,dtw_column}(2,1) = mean(dtw_vector_L);
    report_card{2,dtw_column}(1,2) = "median";
    report_card{2,dtw_column}(2,2) = median(dtw_vector_L);
    report_card{2,dtw_column}(1,3) = "std";
    report_card{2,dtw_column}(2,3) = std(dtw_vector_L);
    
    report_card{3,dtw_column}(1,1) = "mean";
    report_card{3,dtw_column}(2,1) = mean(dtw_vector_R);
    report_card{3,dtw_column}(1,2) = "median";
    report_card{3,dtw_column}(2,2) = median(dtw_vector_R);
    report_card{3,dtw_column}(1,3) = "std";
    report_card{3,dtw_column}(2,3) = std(dtw_vector_R);
    
    %PSD - same process as mscohere - first put in the frequencies, then
    %fill in only the data for the frequencies of interest - we want 2-35Hz
    %so it will be index 3-36
    
    % so first we fill in the frequency column to prevent future confusion
    sub_freques = freqs(3:36);
    string_freques = string(sub_freques);

    report_card{2,51}(2:35,1) = string_freques(1:length(sub_freques));
    report_card{3,51}(2:35,1) = string_freques(1:length(sub_freques));
    report_card{2,52}(2:35,1) = string_freques(1:length(sub_freques));
    report_card{3,52}(2:35,1) = string_freques(1:length(sub_freques));
    
    % each frequency will get metrics, so we must iterate
    for b = 1:length(report_card{2,51})-1
        report_card{2,51}(b+1,2) = mean(AG_L_spd_vector(b+2,:));
        report_card{2,51}(b+1,3) = median(AG_L_spd_vector(b+2,:));
        report_card{2,51}(b+1,4) = std(AG_L_spd_vector(b+2,:));
        
        report_card{3,51}(b+1,2) = mean(AG_R_spd_vector(b+2,:));
        report_card{3,51}(b+1,3) = median(AG_R_spd_vector(b+2,:));
        report_card{3,51}(b+1,4) = std(AG_R_spd_vector(b+2,:));
        
        
        report_card{2,52}(b+1,2) = mean(MX_L_spd_vector(b+2,:));
        report_card{2,52}(b+1,3) = median(MX_L_spd_vector(b+2,:));
        report_card{2,52}(b+1,4) = std(MX_L_spd_vector(b+2,:));
        
        report_card{3,52}(b+1,2) = mean(MX_R_spd_vector(b+2,:));
        report_card{3,52}(b+1,3) = median(MX_R_spd_vector(b+2,:));
        report_card{3,52}(b+1,4) = std(MX_R_spd_vector(b+2,:));
    end
    
    report_card{2,51}(1,1) = "Frequency in Hz";
    report_card{2,51}(1,2) = "mean spd";
    report_card{2,51}(1,3) = "median spd";
    report_card{2,51}(1,4) = "std coherence";
    
    report_card{3,51}(1,1) = "Frequency in Hz";
    report_card{3,51}(1,2) = "mean spd";
    report_card{3,51}(1,3) = "median spd";
    report_card{3,51}(1,4) = "std spd";
    
    report_card{2,52}(1,1) = "Frequency in Hz";
    report_card{2,52}(1,2) = "mean spd";
    report_card{2,52}(1,3) = "median spd";
    report_card{2,52}(1,4) = "std coherence";
    
    report_card{3,52}(1,1) = "Frequency in Hz";
    report_card{3,52}(1,2) = "mean spd";
    report_card{3,52}(1,3) = "median spd";
    report_card{3,52}(1,4) = "std spd";
    
    %now onto msr - only to be looked at for bandpassed data
    
    report_card{2,40} = mean(AG_L_msr_vector, 'all');
    report_card{2,40} = sqrt(report_card{2,40});
    
    report_card{3,40} = mean(AG_R_msr_vector, 'all');
    report_card{3,40} = sqrt(report_card{3,40});
    
    report_card{2,41} = mean(MX_L_msr_vector, 'all');
    report_card{2,41} = sqrt(report_card{2,41});
    
    report_card{3,41} = mean(MX_R_msr_vector, 'all');
    report_card{3,41} = sqrt(report_card{3,41});
    
%-------------------------------------------------------------------------------------------------------------------------      

    %Ag:Ag     
    dtw_vector_L = [];          % note - I already have the main AG - only need the comp one for R and L 
    coherence_vector_L = [];
    %spd metric - only on unfiltered
    AG_comp_L_spd_vector = [];
    % mean square root power - only on bandpassed
    AG_comp_L_msr_vector = [];
    coef_column = 9;
    coherence_column = 10;
    dtw_column = 11;
    
    if AG_comp_helper_L == 1
        
        [R,P] = corrcoef(AG_data_L, AG_comp_data_L);    
            report_card{2,coef_column} = R(1,2);
            report_card{2,66} = P(1,2);
        
        for y = 1:length(two_sec_epochs)
            
            epochstart = two_sec_epochs(y,1)*2+1;
            epochend = two_sec_epochs(y,2)*2;

            AG_L_two_sec_epoch_y = AG_data_L(epochstart:epochend);
            AG_comp_L_two_sec_epoch_y = AG_comp_data_L(epochstart:epochend);
        
            dtw_vector_L(y) = dtw(AG_L_two_sec_epoch_y, AG_comp_L_two_sec_epoch_y);
            
            [cxy, f] = mscohere(AG_L_two_sec_epoch_y, AG_comp_L_two_sec_epoch_y,hamming(2000),[],f,fs);
            coherence_vector_L(1:length(cxy),y) = cxy(1:length(cxy));
            
            [spectra, freqs] = spectopo(AG_comp_L_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            AG_comp_L_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            squared_AG_comp_L_two_sec_epoch_y = AG_comp_L_two_sec_epoch_y.^2;
            AG_comp_L_msr_vector(y, 1:length(squared_AG_comp_L_two_sec_epoch_y)) = squared_AG_comp_L_two_sec_epoch_y;
        end
        
        report_card{2,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));

        for b = 1:length(report_card{2,7})-1
            report_card{2,coherence_column}(b+1,2) = mean(coherence_vector_L(b,:));
            report_card{2,coherence_column}(b+1,3) = median(coherence_vector_L(b,:));
            report_card{2,coherence_column}(b+1,4) = std(coherence_vector_L(b,:));
        end

        report_card{2,coherence_column} = string(report_card{2,coherence_column});

        report_card{2,coherence_column}(1,1) = "Frequency in Hz";
        report_card{2,coherence_column}(1,2) = "mean coherence";
        report_card{2,coherence_column}(1,3) = "median coherence";
        report_card{2,coherence_column}(1,4) = "std coherence";

        report_card{2,dtw_column}(1,1) = "mean";
        report_card{2,dtw_column}(2,1) = mean(dtw_vector_L);
        report_card{2,dtw_column}(1,2) = "median";
        report_card{2,dtw_column}(2,2) = median(dtw_vector_L);
        report_card{2,dtw_column}(1,3) = "std";
        report_card{2,dtw_column}(2,3) = std(dtw_vector_L);
        
        report_card{2,53}(2:35,1) = string_freques(1:length(sub_freques));
        
        for b = 1:length(report_card{2,53})-1
            report_card{2,53}(b+1,2) = mean(AG_comp_L_spd_vector(b+2,:));
            report_card{2,53}(b+1,3) = median(AG_comp_L_spd_vector(b+2,:));
            report_card{2,53}(b+1,4) = std(AG_comp_L_spd_vector(b+2,:));
        end
        
        report_card{2,53}(1,1) = "Frequency in Hz";
        report_card{2,53}(1,2) = "mean spd";
        report_card{2,53}(1,3) = "median spd";
        report_card{2,53}(1,4) = "std coherence";
        
        report_card{2,42} = mean(AG_comp_L_msr_vector, 'all');
        report_card{2,42} = sqrt(report_card{2,42});

        
    end
    
%--------------------------------------------------------------------------
    dtw_vector_R = [];
    coherence_vector_R = [];
    %spd metric - only on unfiltered
    AG_comp_R_spd_vector = [];
    % mean square root power - only on bandpassed
    AG_comp_R_msr_vector = [];

    
    if AG_comp_helper_R == 1
        
        [R,P] = corrcoef(AG_data_R, AG_comp_data_R);    
            report_card{3,coef_column} = R(1,2);
            report_card{3,66} = P(1,2);

        for y = 1:length(two_sec_epochs)
            
            epochstart = two_sec_epochs(y,1)*2+1;
            epochend = two_sec_epochs(y,2)*2;

            AG_R_two_sec_epoch_y = AG_data_R(epochstart:epochend);
            AG_comp_R_two_sec_epoch_y = AG_comp_data_R(epochstart:epochend);
            
            dtw_vector_R(y) = dtw(AG_R_two_sec_epoch_y, AG_comp_R_two_sec_epoch_y);
            
            [cxy, f] = mscohere(AG_R_two_sec_epoch_y, AG_comp_R_two_sec_epoch_y,hamming(2000),[],f,fs);
            coherence_vector_R(1:length(cxy),y) = cxy(1:length(cxy));
            
            [spectra, freqs] = spectopo(AG_comp_R_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            AG_comp_R_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            squared_AG_comp_R_two_sec_epoch_y = AG_comp_R_two_sec_epoch_y.^2;
            AG_comp_R_msr_vector(y, 1:length(squared_AG_comp_R_two_sec_epoch_y)) = squared_AG_comp_R_two_sec_epoch_y;
        end
        
        report_card{3,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));
        
        for b = 1:length(report_card{2,7})-1
            report_card{3,coherence_column}(b+1,2) = mean(coherence_vector_R(b,:));
            report_card{3,coherence_column}(b+1,3) = median(coherence_vector_R(b,:));
            report_card{3,coherence_column}(b+1,4) = std(coherence_vector_R(b,:));
        end

        report_card{3,coherence_column} = string(report_card{3,coherence_column});

        report_card{3,coherence_column}(1,1) = "Frequency in Hz";
        report_card{3,coherence_column}(1,2) = "mean coherence";
        report_card{3,coherence_column}(1,3) = "median coherence";
        report_card{3,coherence_column}(1,4) = "std coherence";

        report_card{3,dtw_column}(1,1) = "mean";
        report_card{3,dtw_column}(2,1) = mean(dtw_vector_R);
        report_card{3,dtw_column}(1,2) = "median";
        report_card{3,dtw_column}(2,2) = median(dtw_vector_R);
        report_card{3,dtw_column}(1,3) = "std";
        report_card{3,dtw_column}(2,3) = std(dtw_vector_R);
        
        report_card{3,53}(2:35,1) = string_freques(1:length(sub_freques));
        
        for b = 1:length(report_card{3,53})-1
            report_card{3,53}(b+1,2) = mean(AG_comp_R_spd_vector(b+2,:));
            report_card{3,53}(b+1,3) = median(AG_comp_R_spd_vector(b+2,:));
            report_card{3,53}(b+1,4) = std(AG_comp_R_spd_vector(b+2,:));
        end
        
        report_card{3,53}(1,1) = "Frequency in Hz";
        report_card{3,53}(1,2) = "mean spd";
        report_card{3,53}(1,3) = "median spd";
        report_card{3,53}(1,4) = "std coherence";
        
        report_card{3,42} = mean(AG_comp_R_msr_vector, 'all');
        report_card{3,42} = sqrt(report_card{3,42});
        
    end
%------------------------------------------------------------------------------------------------------------------------- 
   
    %MX:MX
    dtw_vector_L = [];
    coherence_vector_L = [];
    %spd metric - only on unfiltered
    MX_comp_L_spd_vector = [];
    % mean square root power - only on bandpassed
    MX_comp_L_msr_vector = [];
    coef_column = 12;
    coherence_column = 13;
    dtw_column = 14;

    if MX_bud_helper_L == 1
        
        [R,P] = corrcoef(MX_data_L, MX_buddy_data_L);    
            report_card{2,coef_column} = R(1,2);
            report_card{2,67} = P(1,2);
        
        for y = 1:length(two_sec_epochs)
            
            epochstart = two_sec_epochs(y,1)*2+1;
            epochend = two_sec_epochs(y,2)*2;

            MX_L_two_sec_epoch_y = MX_data_L(epochstart:epochend);
            MX_buddy_L_two_sec_epoch_y = MX_buddy_data_L(epochstart:epochend);
            
            dtw_vector_L(y) = dtw(MX_L_two_sec_epoch_y, MX_buddy_L_two_sec_epoch_y);
            
            [cxy, f] = mscohere(MX_L_two_sec_epoch_y, MX_buddy_L_two_sec_epoch_y,hamming(2000),[],f,fs);
            coherence_vector_L(1:length(cxy),y) = cxy(1:length(cxy));
            
            [spectra, freqs] = spectopo(MX_buddy_L_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            MX_comp_L_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            squared_MX_comp_L_two_sec_epoch_y = MX_buddy_L_two_sec_epoch_y.^2;
            MX_comp_L_msr_vector(y, 1:length(squared_MX_comp_L_two_sec_epoch_y)) = squared_MX_comp_L_two_sec_epoch_y;
        end
        
        report_card{2,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));

        for b = 1:length(report_card{2,7})-1
            report_card{2,coherence_column}(b+1,2) = mean(coherence_vector_L(b,:));
            report_card{2,coherence_column}(b+1,3) = median(coherence_vector_L(b,:));
            report_card{2,coherence_column}(b+1,4) = std(coherence_vector_L(b,:));
        end

        report_card{2,coherence_column} = string(report_card{2,coherence_column});

        report_card{2,coherence_column}(1,1) = "Frequency in Hz";
        report_card{2,coherence_column}(1,2) = "mean coherence";
        report_card{2,coherence_column}(1,3) = "median coherence";
        report_card{2,coherence_column}(1,4) = "std coherence";

        report_card{2,dtw_column}(1,1) = "mean";
        report_card{2,dtw_column}(2,1) = mean(dtw_vector_L);
        report_card{2,dtw_column}(1,2) = "median";
        report_card{2,dtw_column}(2,2) = median(dtw_vector_L);
        report_card{2,dtw_column}(1,3) = "std";
        report_card{2,dtw_column}(2,3) = std(dtw_vector_L);
        
        report_card{2,54}(2:35,1) = string_freques(1:length(sub_freques));
        
        for b = 1:length(report_card{2,54})-1
            report_card{2,54}(b+1,2) = mean(MX_comp_L_spd_vector(b+2,:));
            report_card{2,54}(b+1,3) = median(MX_comp_L_spd_vector(b+2,:));
            report_card{2,54}(b+1,4) = std(MX_comp_L_spd_vector(b+2,:));
        end
        
        report_card{2,54}(1,1) = "Frequency in Hz";
        report_card{2,54}(1,2) = "mean spd";
        report_card{2,54}(1,3) = "median spd";
        report_card{2,54}(1,4) = "std coherence";
        
        report_card{2,43} = mean(MX_comp_L_msr_vector, 'all');
        report_card{2,43} = sqrt(report_card{2,43});
        
    end
    
%--------------------------------------------------------------------------
    dtw_vector_R = [];
    coherence_vector_R = [];
    %spd metric - only on unfiltered
    MX_comp_R_spd_vector = [];
    % mean square root power - only on bandpassed
    MX_comp_R_msr_vector = [];


    if MX_bud_helper_R == 1
        
        [R,P] = corrcoef(MX_data_R, MX_buddy_data_R);    
            report_card{3,coef_column} = R(1,2);
            report_card{3,67} = P(1,2);
        
        for y = 1:length(two_sec_epochs)
            
            epochstart = two_sec_epochs(y,1)*2+1;
            epochend = two_sec_epochs(y,2)*2;

            MX_R_two_sec_epoch_y = MX_data_R(epochstart:epochend);
            MX_buddy_R_two_sec_epoch_y = MX_buddy_data_R(epochstart:epochend);
            
            dtw_vector_R(y) = dtw(MX_R_two_sec_epoch_y, MX_buddy_R_two_sec_epoch_y);
            
            [cxy, f] = mscohere(MX_R_two_sec_epoch_y, MX_buddy_R_two_sec_epoch_y,hamming(2000),[],f,fs);
            coherence_vector_R(1:length(cxy),y) = cxy(1:length(cxy));
            
            [spectra, freqs] = spectopo(MX_buddy_R_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            MX_comp_R_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            squared_MX_comp_R_two_sec_epoch_y = MX_buddy_R_two_sec_epoch_y.^2;
            MX_comp_R_msr_vector(y, 1:length(squared_MX_comp_R_two_sec_epoch_y)) = squared_MX_comp_R_two_sec_epoch_y;
        end
        
        report_card{3,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));
        
        for b = 1:length(report_card{2,7})-1
            report_card{3,coherence_column}(b+1,2) = mean(coherence_vector_R(b,:));
            report_card{3,coherence_column}(b+1,3) = median(coherence_vector_R(b,:));
            report_card{3,coherence_column}(b+1,4) = std(coherence_vector_R(b,:));
        end

        report_card{3,coherence_column} = string(report_card{3,coherence_column});

        report_card{3,coherence_column}(1,1) = "Frequency in Hz";
        report_card{3,coherence_column}(1,2) = "mean coherence";
        report_card{3,coherence_column}(1,3) = "median coherence";
        report_card{3,coherence_column}(1,4) = "std coherence";

        report_card{3,dtw_column}(1,1) = "mean";
        report_card{3,dtw_column}(2,1) = mean(dtw_vector_R);
        report_card{3,dtw_column}(1,2) = "median";
        report_card{3,dtw_column}(2,2) = median(dtw_vector_R);
        report_card{3,dtw_column}(1,3) = "std";
        report_card{3,dtw_column}(2,3) = std(dtw_vector_R);
        
        report_card{3,54}(2:35,1) = string_freques(1:length(sub_freques));
        
        for b = 1:length(report_card{3,54})-1
            report_card{3,54}(b+1,2) = mean(MX_comp_R_spd_vector(b+2,:));
            report_card{3,54}(b+1,3) = median(MX_comp_R_spd_vector(b+2,:));
            report_card{3,54}(b+1,4) = std(MX_comp_R_spd_vector(b+2,:));
        end
        
        report_card{3,54}(1,1) = "Frequency in Hz";
        report_card{3,54}(1,2) = "mean spd";
        report_card{3,54}(1,3) = "median spd";
        report_card{3,54}(1,4) = "std coherence";
        
        report_card{3,43} = mean(MX_comp_R_msr_vector, 'all');
        report_card{3,43} = sqrt(report_card{3,43});
        
    end
    
%------------------------------------------------------------------------------------------------------------------------- 
    % for the corners, they are different electrodes depending on array
    % side, so they need different loops
    
    %Q1:Q3
    dtw_vector_L = [];
    coherence_vector_L = [];
    %spd metric - only on unfiltered
    Q1_L_spd_vector = [];
    Q3_L_spd_vector = [];
    % mean square root power - only on bandpassed
    Q1_L_msr_vector = [];
    Q3_L_msr_vector = [];
    coef_column = 15;
    coherence_column = 16;
    dtw_column = 17;

    if ismember('A-005', chan_info) && ismember('A-015', chan_info)
        
        [R,P] = corrcoef(Q1_data_L, Q3_data_L);    
            report_card{2,coef_column} = R(1,2);
            report_card{2,68} = P(1,2);
        
        for y = 1:length(two_sec_epochs)
            
            epochstart = two_sec_epochs(y,1)*2+1;
            epochend = two_sec_epochs(y,2)*2;

            Q1_L_two_sec_epoch_y = Q1_data_L(epochstart:epochend);
            Q3_L_two_sec_epoch_y = Q3_data_L(epochstart:epochend);
            
            dtw_vector_L(y) = dtw(Q1_L_two_sec_epoch_y, Q3_L_two_sec_epoch_y);
            
            [cxy, f] = mscohere(Q1_L_two_sec_epoch_y, Q3_L_two_sec_epoch_y,hamming(2000),[],f,fs);
            coherence_vector_L(1:length(cxy),y) = cxy(1:length(cxy));   
            
            [spectra, freqs] = spectopo(Q1_L_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            Q1_L_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            [spectra, freqs] = spectopo(Q3_L_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            Q3_L_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            
            squared_Q1_L_two_sec_epoch_y = Q1_L_two_sec_epoch_y.^2;
            Q1_L_msr_vector(y, 1:length(squared_Q1_L_two_sec_epoch_y)) = squared_Q1_L_two_sec_epoch_y;
            
            squared_Q3_L_two_sec_epoch_y = Q3_L_two_sec_epoch_y.^2;
            Q3_L_msr_vector(y, 1:length(squared_Q3_L_two_sec_epoch_y)) = squared_Q3_L_two_sec_epoch_y;
        end
        
        report_card{2,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));
        
        for b = 1:length(report_card{2,7})-1
            report_card{2,coherence_column}(b+1,2) = mean(coherence_vector_L(b,:));
            report_card{2,coherence_column}(b+1,3) = median(coherence_vector_L(b,:));
            report_card{2,coherence_column}(b+1,4) = std(coherence_vector_L(b,:));
        end

        report_card{2,coherence_column} = string(report_card{2,coherence_column});

        report_card{2,coherence_column}(1,1) = "Frequency in Hz";
        report_card{2,coherence_column}(1,2) = "mean coherence";
        report_card{2,coherence_column}(1,3) = "median coherence";
        report_card{2,coherence_column}(1,4) = "std coherence";

        report_card{2,dtw_column}(1,1) = "mean";
        report_card{2,dtw_column}(2,1) = mean(dtw_vector_L);
        report_card{2,dtw_column}(1,2) = "median";
        report_card{2,dtw_column}(2,2) = median(dtw_vector_L);
        report_card{2,dtw_column}(1,3) = "std";
        report_card{2,dtw_column}(2,3) = std(dtw_vector_L);
        
        report_card{2,55}(2:35,1) = string_freques(1:length(sub_freques));
        report_card{2,56}(2:35,1) = string_freques(1:length(sub_freques));
        
        for b = 1:length(report_card{2,55})-1
            report_card{2,55}(b+1,2) = mean(Q1_L_spd_vector(b+2,:));
            report_card{2,55}(b+1,3) = median(Q1_L_spd_vector(b+2,:));
            report_card{2,55}(b+1,4) = std(Q1_L_spd_vector(b+2,:));
            
            report_card{2,56}(b+1,2) = mean(Q3_L_spd_vector(b+2,:));
            report_card{2,56}(b+1,3) = median(Q3_L_spd_vector(b+2,:));
            report_card{2,56}(b+1,4) = std(Q3_L_spd_vector(b+2,:));
        end
        
        report_card{2,55}(1,1) = "Frequency in Hz";
        report_card{2,55}(1,2) = "mean spd";
        report_card{2,55}(1,3) = "median spd";
        report_card{2,55}(1,4) = "std coherence";
        
        report_card{2,56}(1,1) = "Frequency in Hz";
        report_card{2,56}(1,2) = "mean spd";
        report_card{2,56}(1,3) = "median spd";
        report_card{2,56}(1,4) = "std coherence";
        
        report_card{2,44} = mean(Q1_L_msr_vector, 'all');
        report_card{2,44} = sqrt(report_card{2,44});
        
        report_card{2,45} = mean(Q3_L_msr_vector, 'all');
        report_card{2,45} = sqrt(report_card{2,45});

    end
    
 %-------------------------------------------------------------------------
 % right side same corners    
    
    dtw_vector_R = [];
    coherence_vector_R = [];
    %spd metric - only on unfiltered
    Q1_R_spd_vector = [];
    Q3_R_spd_vector = [];
    % mean square root power - only on bandpassed
    Q1_R_msr_vector = [];
    Q3_R_msr_vector = [];

    if ismember('B-027', chan_info) && ismember('B-016', chan_info)
        
        [R,P] = corrcoef(Q1_data_R, Q3_data_R);    
            report_card{3,coef_column} = R(1,2);
            report_card{3,68} = P(1,2);
        
        for y = 1:length(two_sec_epochs)
            
            epochstart = two_sec_epochs(y,1)*2+1;
            epochend = two_sec_epochs(y,2)*2;

            Q1_R_two_sec_epoch_y = Q1_data_R(epochstart:epochend);
            Q3_R_two_sec_epoch_y = Q3_data_R(epochstart:epochend);
            
            dtw_vector_R(y) = dtw(Q1_R_two_sec_epoch_y, Q3_R_two_sec_epoch_y);
            
            [cxy, f] = mscohere(Q1_R_two_sec_epoch_y, Q3_R_two_sec_epoch_y,hamming(2000),[],f,fs);
            coherence_vector_R(1:length(cxy),y) = cxy(1:length(cxy));
            
            [spectra, freqs] = spectopo(Q1_R_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            Q1_R_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            [spectra, freqs] = spectopo(Q3_R_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            Q3_R_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            
            squared_Q1_R_two_sec_epoch_y = Q1_R_two_sec_epoch_y.^2;
            Q1_R_msr_vector(y, 1:length(squared_Q1_R_two_sec_epoch_y)) = squared_Q1_R_two_sec_epoch_y;
            
            squared_Q3_R_two_sec_epoch_y = Q3_R_two_sec_epoch_y.^2;
            Q3_R_msr_vector(y, 1:length(squared_Q3_R_two_sec_epoch_y)) = squared_Q3_R_two_sec_epoch_y;
        end
        
        report_card{3,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));
        
        for b = 1:length(report_card{2,7})-1
            report_card{3,coherence_column}(b+1,2) = mean(coherence_vector_R(b,:));
            report_card{3,coherence_column}(b+1,3) = median(coherence_vector_R(b,:));
            report_card{3,coherence_column}(b+1,4) = std(coherence_vector_R(b,:));
        end

        report_card{3,coherence_column} = string(report_card{3,coherence_column});

        report_card{3,coherence_column}(1,1) = "Frequency in Hz";
        report_card{3,coherence_column}(1,2) = "mean coherence";
        report_card{3,coherence_column}(1,3) = "median coherence";
        report_card{3,coherence_column}(1,4) = "std coherence";

        report_card{3,dtw_column}(1,1) = "mean";
        report_card{3,dtw_column}(2,1) = mean(dtw_vector_R);
        report_card{3,dtw_column}(1,2) = "median";
        report_card{3,dtw_column}(2,2) = median(dtw_vector_R);
        report_card{3,dtw_column}(1,3) = "std";
        report_card{3,dtw_column}(2,3) = std(dtw_vector_R);
        
        report_card{3,55}(2:35,1) = string_freques(1:length(sub_freques));
        report_card{3,56}(2:35,1) = string_freques(1:length(sub_freques));
        
        for b = 1:length(report_card{2,55})-1
            report_card{3,55}(b+1,2) = mean(Q1_R_spd_vector(b+2,:));
            report_card{3,55}(b+1,3) = median(Q1_R_spd_vector(b+2,:));
            report_card{3,55}(b+1,4) = std(Q1_R_spd_vector(b+2,:));
            
            report_card{3,56}(b+1,2) = mean(Q3_R_spd_vector(b+2,:));
            report_card{3,56}(b+1,3) = median(Q3_R_spd_vector(b+2,:));
            report_card{3,56}(b+1,4) = std(Q3_R_spd_vector(b+2,:));
        end
        
        report_card{3,55}(1,1) = "Frequency in Hz";
        report_card{3,55}(1,2) = "mean spd";
        report_card{3,55}(1,3) = "median spd";
        report_card{3,55}(1,4) = "std coherence";
        
        report_card{3,56}(1,1) = "Frequency in Hz";
        report_card{3,56}(1,2) = "mean spd";
        report_card{3,56}(1,3) = "median spd";
        report_card{3,56}(1,4) = "std coherence";
        
        report_card{3,44} = mean(Q1_R_msr_vector, 'all');
        report_card{3,44} = sqrt(report_card{3,44});
        
        report_card{3,45} = mean(Q3_R_msr_vector, 'all');
        report_card{3,45} = sqrt(report_card{3,45});

    end
%------------------------------------------------------------------------------------------------------------------------- 
    % for the corners, they are different electrodes depending on array
    % side, so they need different loops

    %Q2:Q4
    dtw_vector_L = [];
    coherence_vector_L = [];
    %spd metric - only on unfiltered
    Q2_L_spd_vector = [];
    Q4_L_spd_vector = [];
    % mean square root power - only on bandpassed
    Q2_L_msr_vector = [];
    Q4_L_msr_vector = [];
    coef_column = 18;
    coherence_column = 19;
    dtw_column = 20;
    

    if ismember('A-011', chan_info) && ismember('A-000', chan_info)
        
        [R,P] = corrcoef(Q2_data_L, Q4_data_L);    
            report_card{2,coef_column} = R(1,2);
            report_card{2,69} = P(1,2);

        for y = 1:length(two_sec_epochs)
            
            epochstart = two_sec_epochs(y,1)*2+1;
            epochend = two_sec_epochs(y,2)*2;

            Q2_L_two_sec_epoch_y = Q2_data_L(epochstart:epochend);
            Q4_L_two_sec_epoch_y = Q4_data_L(epochstart:epochend);
            
            dtw_vector_L(y) = dtw(Q2_L_two_sec_epoch_y, Q4_L_two_sec_epoch_y);
            
            [cxy, f] = mscohere(Q2_L_two_sec_epoch_y, Q4_L_two_sec_epoch_y,hamming(2000),[],f,fs);
            coherence_vector_L(1:length(cxy),y) = cxy(1:length(cxy));
            
            [spectra, freqs] = spectopo(Q2_L_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            Q2_L_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            [spectra, freqs] = spectopo(Q4_L_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            Q4_L_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));

            
            squared_Q2_L_two_sec_epoch_y = Q2_L_two_sec_epoch_y.^2;
            Q2_L_msr_vector(y, 1:length(squared_Q2_L_two_sec_epoch_y)) = squared_Q2_L_two_sec_epoch_y;
            
            squared_Q4_L_two_sec_epoch_y = Q4_L_two_sec_epoch_y.^2;
            Q4_L_msr_vector(y, 1:length(squared_Q4_L_two_sec_epoch_y)) = squared_Q4_L_two_sec_epoch_y;
        end
        
        report_card{2,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));
        
        for b = 1:length(report_card{2,7})-1
            report_card{2,coherence_column}(b+1,2) = mean(coherence_vector_L(b,:));
            report_card{2,coherence_column}(b+1,3) = median(coherence_vector_L(b,:));
            report_card{2,coherence_column}(b+1,4) = std(coherence_vector_L(b,:));
        end

        report_card{2,coherence_column} = string(report_card{2,coherence_column});

        report_card{2,coherence_column}(1,1) = "Frequency in Hz";
        report_card{2,coherence_column}(1,2) = "mean coherence";
        report_card{2,coherence_column}(1,3) = "median coherence";
        report_card{2,coherence_column}(1,4) = "std coherence";

        report_card{2,dtw_column}(1,1) = "mean";
        report_card{2,dtw_column}(2,1) = mean(dtw_vector_L);
        report_card{2,dtw_column}(1,2) = "median";
        report_card{2,dtw_column}(2,2) = median(dtw_vector_L);
        report_card{2,dtw_column}(1,3) = "std";
        report_card{2,dtw_column}(2,3) = std(dtw_vector_L);
        
        report_card{2,57}(2:35,1) = string_freques(1:length(sub_freques));
        report_card{2,58}(2:35,1) = string_freques(1:length(sub_freques));
        
        for b = 1:length(report_card{2,57})-1
            report_card{2,57}(b+1,2) = mean(Q2_L_spd_vector(b+2,:));
            report_card{2,57}(b+1,3) = median(Q2_L_spd_vector(b+2,:));
            report_card{2,57}(b+1,4) = std(Q2_L_spd_vector(b+2,:));
            
            report_card{2,58}(b+1,2) = mean(Q4_L_spd_vector(b+2,:));
            report_card{2,58}(b+1,3) = median(Q4_L_spd_vector(b+2,:));
            report_card{2,58}(b+1,4) = std(Q4_L_spd_vector(b+2,:));
        end
        
        report_card{2,57}(1,1) = "Frequency in Hz";
        report_card{2,57}(1,2) = "mean spd";
        report_card{2,57}(1,3) = "median spd";
        report_card{2,57}(1,4) = "std coherence";
        
        report_card{2,58}(1,1) = "Frequency in Hz";
        report_card{2,58}(1,2) = "mean spd";
        report_card{2,58}(1,3) = "median spd";
        report_card{2,58}(1,4) = "std coherence";
        
        report_card{2,46} = mean(Q2_L_msr_vector, 'all');
        report_card{2,46} = sqrt(report_card{2,46});
        
        report_card{2,47} = mean(Q4_L_msr_vector, 'all');
        report_card{2,47} = sqrt(report_card{2,47});

    end

 %-------------------------------------------------------------------------
 % right side same corners
 
    dtw_vector_R = [];
    coherence_vector_R = [];
    %spd metric - only on unfiltered
    Q2_R_spd_vector = [];
    Q4_R_spd_vector = [];
    % mean square root power - only on bandpassed
    Q2_R_msr_vector = [];
    Q4_R_msr_vector = [];
    
    
    if ismember('B-021', chan_info) && ismember('B-031', chan_info)
        
        [R,P] = corrcoef(Q2_data_R, Q4_data_R);    
            report_card{3,coef_column} = R(1,2);
            report_card{3,69} = P(1,2);
        
        for y = 1:length(two_sec_epochs)
            
            epochstart = two_sec_epochs(y,1)*2+1;
            epochend = two_sec_epochs(y,2)*2;

            Q2_R_two_sec_epoch_y = Q2_data_R(epochstart:epochend);
            Q4_R_two_sec_epoch_y = Q4_data_R(epochstart:epochend);
            
            dtw_vector_R(y) = dtw(Q2_R_two_sec_epoch_y, Q4_R_two_sec_epoch_y);
            
            [cxy, f] = mscohere(Q2_R_two_sec_epoch_y, Q4_R_two_sec_epoch_y,hamming(2000),[],f,fs);
            coherence_vector_R(1:length(cxy),y) = cxy(1:length(cxy));
            
            [spectra, freqs] = spectopo(Q2_R_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            Q2_R_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            [spectra, freqs] = spectopo(Q4_R_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            Q4_R_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            
            squared_Q2_R_two_sec_epoch_y = Q2_R_two_sec_epoch_y.^2;
            Q2_R_msr_vector(y, 1:length(squared_Q2_R_two_sec_epoch_y)) = squared_Q2_R_two_sec_epoch_y;
            
            squared_Q4_R_two_sec_epoch_y = Q4_R_two_sec_epoch_y.^2;
            Q4_R_msr_vector(y, 1:length(squared_Q4_R_two_sec_epoch_y)) = squared_Q4_R_two_sec_epoch_y;
        end
        
        report_card{3,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));
        
        for b = 1:length(report_card{2,7})-1
            report_card{3,coherence_column}(b+1,2) = mean(coherence_vector_R(b,:));
            report_card{3,coherence_column}(b+1,3) = median(coherence_vector_R(b,:));
            report_card{3,coherence_column}(b+1,4) = std(coherence_vector_R(b,:));
        end
        
        report_card{3,coherence_column} = string(report_card{3,coherence_column});
        
        report_card{3,coherence_column}(1,1) = "Frequency in Hz";
        report_card{3,coherence_column}(1,2) = "mean coherence";
        report_card{3,coherence_column}(1,3) = "median coherence";
        report_card{3,coherence_column}(1,4) = "std coherence";
        
        report_card{3,dtw_column}(1,1) = "mean";
        report_card{3,dtw_column}(2,1) = mean(dtw_vector_R);
        report_card{3,dtw_column}(1,2) = "median";
        report_card{3,dtw_column}(2,2) = median(dtw_vector_R);
        report_card{3,dtw_column}(1,3) = "std";
        report_card{3,dtw_column}(2,3) = std(dtw_vector_R);
        
        report_card{3,57}(2:35,1) = string_freques(1:length(sub_freques));
        report_card{3,58}(2:35,1) = string_freques(1:length(sub_freques));
        
        for b = 1:length(report_card{2,57})-1
            report_card{3,57}(b+1,2) = mean(Q2_R_spd_vector(b+2,:));
            report_card{3,57}(b+1,3) = median(Q2_R_spd_vector(b+2,:));
            report_card{3,57}(b+1,4) = std(Q2_R_spd_vector(b+2,:));
            
            report_card{3,58}(b+1,2) = mean(Q4_R_spd_vector(b+2,:));
            report_card{3,58}(b+1,3) = median(Q4_R_spd_vector(b+2,:));
            report_card{3,58}(b+1,4) = std(Q4_R_spd_vector(b+2,:));
        end
        
        report_card{3,57}(1,1) = "Frequency in Hz";
        report_card{3,57}(1,2) = "mean spd";
        report_card{3,57}(1,3) = "median spd";
        report_card{3,57}(1,4) = "std coherence";
        
        report_card{3,58}(1,1) = "Frequency in Hz";
        report_card{3,58}(1,2) = "mean spd";
        report_card{3,58}(1,3) = "median spd";
        report_card{3,58}(1,4) = "std coherence";
        
        report_card{3,46} = mean(Q2_R_msr_vector, 'all');
        report_card{3,46} = sqrt(report_card{3,46});
        
        report_card{3,47} = mean(Q4_R_msr_vector, 'all');
        report_card{3,47} = sqrt(report_card{3,47});
        
    end
    
        
%-------------------------------------------------------------------------------------------------------------------------    

    %AG:Furthest MXtrode
    dtw_vector_L = [];
    coherence_vector_L = [];
    %spd metric - only on unfiltered
    furthest_MX_L_spd_vector = [];
    % mean square root power - only on bandpassed
    furthest_MX_L_msr_vector = [];
    coef_column = 21;
    coherence_column = 22;
    dtw_column = 23;
    
    if furthest_helper_L == 1
        
        [R,P] = corrcoef(furthest_MX_data_L, AG_data_L);    
            report_card{2,coef_column} = R(1,2);
            report_card{2,70} = P(1,2);
        
        for y = 1:length(two_sec_epochs)
            
            epochstart = two_sec_epochs(y,1)*2+1;
            epochend = two_sec_epochs(y,2)*2;

            furthest_MX_L_two_sec_epoch_y = furthest_MX_data_L(epochstart:epochend);
            AG_L_two_sec_epoch_y = AG_data_L(epochstart:epochend);
            
            dtw_vector_L(y) = dtw(furthest_MX_L_two_sec_epoch_y, AG_L_two_sec_epoch_y);
            
            [cxy, f] = mscohere(furthest_MX_L_two_sec_epoch_y, AG_L_two_sec_epoch_y,hamming(2000),[],f,fs);
            coherence_vector_L(1:length(cxy),y) = cxy(1:length(cxy));
            
            [spectra, freqs] = spectopo(furthest_MX_L_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            furthest_MX_L_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            squared_furthest_MX_L_two_sec_epoch_y = furthest_MX_L_two_sec_epoch_y.^2;
            furthest_MX_L_msr_vector(y, 1:length(squared_furthest_MX_L_two_sec_epoch_y)) = squared_furthest_MX_L_two_sec_epoch_y;
        end
        
        report_card{2,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));
        
        for b = 1:length(report_card{2,7})-1
            report_card{2,coherence_column}(b+1,2) = mean(coherence_vector_L(b,:));
            report_card{2,coherence_column}(b+1,3) = median(coherence_vector_L(b,:));
            report_card{2,coherence_column}(b+1,4) = std(coherence_vector_L(b,:));
        end

        report_card{2,coherence_column} = string(report_card{2,coherence_column});

        report_card{2,coherence_column}(1,1) = "Frequency in Hz";
        report_card{2,coherence_column}(1,2) = "mean coherence";
        report_card{2,coherence_column}(1,3) = "median coherence";
        report_card{2,coherence_column}(1,4) = "std coherence";

        report_card{2,dtw_column}(1,1) = "mean";
        report_card{2,dtw_column}(2,1) = mean(dtw_vector_L);
        report_card{2,dtw_column}(1,2) = "median";
        report_card{2,dtw_column}(2,2) = median(dtw_vector_L);
        report_card{2,dtw_column}(1,3) = "std";
        report_card{2,dtw_column}(2,3) = std(dtw_vector_L);
        
        report_card{2,59}(2:35,1) = string_freques(1:length(sub_freques));
        
        for b = 1:length(report_card{2,59})-1
            report_card{2,59}(b+1,2) = mean(furthest_MX_L_spd_vector(b+2,:));
            report_card{2,59}(b+1,3) = median(furthest_MX_L_spd_vector(b+2,:));
            report_card{2,59}(b+1,4) = std(furthest_MX_L_spd_vector(b+2,:));
        end
        
        report_card{2,59}(1,1) = "Frequency in Hz";
        report_card{2,59}(1,2) = "mean spd";
        report_card{2,59}(1,3) = "median spd";
        report_card{2,59}(1,4) = "std coherence";
        
        report_card{2,48} = mean(furthest_MX_L_msr_vector, 'all');
        report_card{2,48} = sqrt(report_card{2,48});

    end
        
%-------------------------------------------------------------------------
    
    dtw_vector_R = [];
    coherence_vector_R = [];
    %spd metric - only on unfiltered
    furthest_MX_R_spd_vector = [];
    % mean square root power - only on bandpassed
    furthest_MX_R_msr_vector = [];

    
    if furthest_helper_R == 1
        
        [R,P] = corrcoef(furthest_MX_data_R, AG_data_R);    
            report_card{3,coef_column} = R(1,2);
            report_card{3,70} = P(1,2);
        
        for y = 1:length(two_sec_epochs)
            
            epochstart = two_sec_epochs(y,1)*2+1;
            epochend = two_sec_epochs(y,2)*2;

            furthest_MX_R_two_sec_epoch_y = furthest_MX_data_R(epochstart:epochend);
            AG_R_two_sec_epochs_y = AG_data_R(epochstart:epochend);
            
            dtw_vector_R(y) = dtw(furthest_MX_R_two_sec_epoch_y, AG_R_two_sec_epochs_y);
            
            [cxy, f] = mscohere(furthest_MX_R_two_sec_epoch_y, AG_R_two_sec_epochs_y,hamming(2000),[],f,fs);
            coherence_vector_R(1:length(cxy),y) = cxy(1:length(cxy));
            
            [spectra, freqs] = spectopo(furthest_MX_R_two_sec_epoch_y, 4000, 2000, 'winsize', [2000], 'overlap', [1000], 'freqrange', [2 35], 'plot', 'off', 'verbose', 'off');
            furthest_MX_R_spd_vector(1:length(spectra),y) = spectra(1:length(spectra));
            
            squared_furthest_MX_R_two_sec_epoch_y = furthest_MX_R_two_sec_epoch_y.^2;
            furthest_MX_R_msr_vector(y, 1:length(squared_furthest_MX_R_two_sec_epoch_y)) = squared_furthest_MX_R_two_sec_epoch_y;
        end
        
        report_card{3,coherence_column}(2:length(f)+1,1) = string_f(1:length(f));
        
        for b = 1:length(report_card{2,7})-1
            report_card{3,coherence_column}(b+1,2) = mean(coherence_vector_R(b,:));
            report_card{3,coherence_column}(b+1,3) = median(coherence_vector_R(b,:));
            report_card{3,coherence_column}(b+1,4) = std(coherence_vector_R(b,:));
        end

        report_card{3,coherence_column} = string(report_card{3,coherence_column});

        report_card{3,coherence_column}(1,1) = "Frequency in Hz";
        report_card{3,coherence_column}(1,2) = "mean coherence";
        report_card{3,coherence_column}(1,3) = "median coherence";
        report_card{3,coherence_column}(1,4) = "std coherence";

        report_card{3,dtw_column}(1,1) = "mean";
        report_card{3,dtw_column}(2,1) = mean(dtw_vector_R);
        report_card{3,dtw_column}(1,2) = "median";
        report_card{3,dtw_column}(2,2) = median(dtw_vector_R);
        report_card{3,dtw_column}(1,3) = "std";
        report_card{3,dtw_column}(2,3) = std(dtw_vector_R);
        
        report_card{3,59}(2:35,1) = string_freques(1:length(sub_freques));
        
        for b = 1:length(report_card{2,59})-1
            report_card{3,59}(b+1,2) = mean(furthest_MX_R_spd_vector(b+2,:));
            report_card{3,59}(b+1,3) = median(furthest_MX_R_spd_vector(b+2,:));
            report_card{3,59}(b+1,4) = std(furthest_MX_R_spd_vector(b+2,:));
        end
        
        report_card{3,59}(1,1) = "Frequency in Hz";
        report_card{3,59}(1,2) = "mean spd";
        report_card{3,59}(1,3) = "median spd";
        report_card{3,59}(1,4) = "std coherence";
        
        report_card{3,48} = mean(furthest_MX_R_msr_vector, 'all');
        report_card{3,48} = sqrt(report_card{3,48});

    end
%-------------------------------------------------------------------------------------------------------------------------     

%% Clear things up to save space for perm tests (and confusion)
    
   clear AG_data_L AG_data_R all_bound_lat b coef_column coherence_column coherence_vector_L coherence_vector_R cxy d  dtw_column dtw_vector_L dtw_vector_R end_data end_time furthest_MX_data_L furthest_MX_data_R furthest_helper_L furthest_helper_R helper helper_p1 l impedances j M MX_bud_helper_L MX_bud_helper_R MX_buddy_data_L MX_buddy_data_R MX_data_L MX_data_R Q1_data_L Q1_data_R Q2_data_L Q2_data_R
   clear Q3_data_L Q3_data_R Q4_data_L Q4_data_R two_sec_epochs y I start_time
   clear AG_comp_data_L AG_comp_data_R AG_comp_helper_L AG_comp_helper_R
   clear AG_L_spd_vector AG_R_spd_vector AG_L_two_sec_epoch_y AG_L_two_sec_epochs_y AG_R_two_sec_epoch_y AG_R_two_sec_epochs_y furthest_MX_L_two_sec_epoch_y furthest_MX_R_two_sec_epoch_y MX_buddy_L_two_sec_epochs_y MX_buddy_R_two_sec_epochs_y MX_L_spd_vector MX_R_spd_vector MX_L_two_sec_epoch_y MX_R_two_sec_epoch_y Q1_L_two_sec_epoch_y Q1_R_two_sec_epoch_y Q2_L_two_sec_epoch_y Q2_R_two_sec_epoch_y
   clear Q3_L_two_sec_epochs_y Q3_R_two_sec_epochs_y Q4_L_two_sec_epochs_y Q4_R_two_sec_epochs_y spectra string_freques sub_freques string_f AG_L_msrp_vector AG_R_msrp_vector MX_L_msrp_vector MX_R_msrp_vector squared_AG_L_two_sec_epoch_y squared_AG_R_two_sec_epoch_y squared_MX_L_two_sec_epoch_y squared_MX_R_two_sec_epoch_y
   clear AG_comp_L_msr_vector AG_comp_L_spd_vector AG_comp_R_msr_vector AG_comp_R_spd_vector AG_L_msr_vector AG_R_msr_vector furthest_MX_L furthest_MX_L_msr_vector furthest_MX_L_spd_vector furthest_MX_R furthest_MX_R_msr_vector furthest_MX_R_spd_vector MX_buddy_L MX_buddy_L_two_sec_epoch_y MX_buddy_R MX_buddy_R_two_sec_epoch_y MX_comp_L_msr_vector MX_comp_L_spd_vector MX_comp_R_msr_vector MX_comp_R_spd_vector
   clear MX_L_msr_vector MX_R_msr_vector Q1_L_msr_vector Q1_L_spd_vector Q1_R_msr_vector Q1_R_spd_vector Q2_L_msr_vector Q2_L_spd_vector Q2_R_msr_vector Q2_R_spd_vector Q3_L_msr_vector Q3_L_spd_vector Q3_R_msr_vector Q3_R_spd_vector Q4_L_msr_vector Q4_L_spd_vector Q4_R_msr_vector Q4_R_spd_vector Q3_L_two_sec_epoch_y Q3_R_two_sec_epoch_y Q4_L_two_sec_epoch_y Q4_R_two_sec_epoch_y squared_furthest_MX_L_two_sec_epoch_y
   clear squared_furthest_MX_R_two_sec_epoch_y squared_MX_comp_L_two_sec_epoch_y squared_MX_comp_R_two_sec_epoch_y squared_Q1_L_two_sec_epoch_y squared_Q1_R_two_sec_epoch_y squared_Q2_L_two_sec_epoch_y squared_Q2_R_two_sec_epoch_y squared_Q3_L_two_sec_epoch_y squared_Q3_R_two_sec_epoch_y squared_Q4_L_two_sec_epoch_y squared_Q4_R_two_sec_epoch_y
   clear R P
   
   disp('length of everything in loop up to the permutation tests in mins')
   toc(loop_start)/60
%% Permutation Tests - it looks like with 10,000 perms, this will take over 3.5hrs/array to run on Ryan's iMac without parallelization
    
    %I decided to do the permutation stats at the end instead of within each
    %pair type group because they blend together MX:Ag and Ag:Ag comps and can
    %always be rearanged in the group level/summary stats sheet - it also made
    %it easier with report card index numbering
    
    %okay, since we are time-locking all the perm chunks to the probe event,
    %the easiest way to do that is by using the built-in epoching tools - so
    %the first step is to epoch - but do not baseline correct yet, that will
    %mess up the spectral/frequency measures - the post-probe epoch must be
    %2sec as calculated for coherence metrics down to 2Hz
    
    warning = 0;
    pre_warning = 0;
    
    %had to make the pre_warning and if loop because DGAR doesn't have any epochs for
    %perm tests but did have data for non-perm tests
    
    helper = report_card{2,1}(1:4) == 'DGAR';
    
    if sum(helper) ~= 4
        EEG = pop_epoch( EEG, {  'Probe'  }, [-0.2    2], 'epochinfo', 'yes');

    %---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
        %Pull out data before baseline correcting   

        %now that things are epoched, we can pull the data we actually want and
        %format it so that it's easier to work with and shuffle - note, it is not a
        %continious timeseries at this point, it's discontinious epoches that are
        %seperated - the "F" stands for Frequency-Domain 
        AG_F_Perm_epochs_L = EEG.data(find(ismember(chan_info, winning_AG_L)),401:4400,1:size(EEG.data,3));
        AG_F_Perm_epochs_L = squeeze(AG_F_Perm_epochs_L);
        AG_F_Perm_epochs_L = AG_F_Perm_epochs_L.';

        AG_F_Perm_epochs_R = EEG.data(find(ismember(chan_info, winning_AG_R)),401:4400,1:size(EEG.data,3));
        AG_F_Perm_epochs_R = squeeze(AG_F_Perm_epochs_R);
        AG_F_Perm_epochs_R = AG_F_Perm_epochs_R.';

        MX_F_Perm_epochs_L = EEG.data(find(ismember(chan_info, winning_MX_L)),401:4400,1:size(EEG.data,3));
        MX_F_Perm_epochs_L = squeeze(MX_F_Perm_epochs_L);
        MX_F_Perm_epochs_L = MX_F_Perm_epochs_L.';

        MX_F_Perm_epochs_R = EEG.data(find(ismember(chan_info, winning_MX_R)),401:4400,1:size(EEG.data,3));
        MX_F_Perm_epochs_R = squeeze(MX_F_Perm_epochs_R);
        MX_F_Perm_epochs_R = MX_F_Perm_epochs_R.';

        % we have to use 2sec epochs to get as much of the low frequency info as
        % possible using mscohere - we already start at 2Hz instead of 1Hz -
        % however, if thereare less than 8 2-sec Probe-locked epochs we will never
        % generate 10,000 unique perms and the script will iterate forever without
        % making progress and we won't know (8! = 40,320 and 7! = 5,40)

        if size(AG_F_Perm_epochs_L,1) < 8 || size(AG_F_Perm_epochs_L,1) > 100 %if it can't epoch, the dimensions are reversed - aka. epoching cahnges the order of the dimensions 
            disp('there are not enough epochs to create 10,000 unique permutations and all permutation statistics were skipped')
            warning = 1;
        end
        
        % keep track of how many epochs contributed
        report_card{2,38} = size(AG_F_Perm_epochs_L,1);
        report_card{3,38} = size(AG_F_Perm_epochs_L,1);
        
        % if there are no epochs, it becomes every sample and will break
        % the mean, so I set it to empty - I also don't want those that
        % had less than 8 and weren't run to influence things
        if report_card{2,38} > 100 || report_card{2,38} < 8
            report_card{2,38} = [];
            report_card{3,38} = [];
        end
        
    elseif report_card{2,1}(1:4) == 'DGAR'
        pre_warning = 1;
        disp('this subject had zero epochs and had to be skipped for perm stats')
    end
    
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
    %Pull out baseline-corrected data

    % had to make this the if loop and warning varriable because we don't
    % want to not run subjects who have less than 8 epochs through the
    % non-perm tests
    if warning == 0 && pre_warning == 0 
    
        %now that we have pulled the non-baseline-corrected data out for the
        %spectral analyses, we can baseline-correct it for the timeseries data
        EEG = pop_rmbase( EEG, [-200 0] ,[]);

        %This is the same process as before but the "T" stands for Time-Domain -
        %again, these are discrete epochs not a continious timeseries
        AG_T_Perm_epochs_L = EEG.data(find(ismember(chan_info, winning_AG_L)),401:4400,1:size(EEG.data,3));
        AG_T_Perm_epochs_L = squeeze(AG_T_Perm_epochs_L);
        AG_T_Perm_epochs_L = AG_T_Perm_epochs_L.';

        AG_T_Perm_epochs_R = EEG.data(find(ismember(chan_info, winning_AG_R)),401:4400,1:size(EEG.data,3));
        AG_T_Perm_epochs_R = squeeze(AG_T_Perm_epochs_R);
        AG_T_Perm_epochs_R = AG_T_Perm_epochs_R.';

        MX_T_Perm_epochs_L = EEG.data(find(ismember(chan_info, winning_MX_L)),401:4400,1:size(EEG.data,3));
        MX_T_Perm_epochs_L = squeeze(MX_T_Perm_epochs_L);
        MX_T_Perm_epochs_L = MX_T_Perm_epochs_L.';

        MX_T_Perm_epochs_R = EEG.data(find(ismember(chan_info, winning_MX_R)),401:4400,1:size(EEG.data,3));
        MX_T_Perm_epochs_R = squeeze(MX_T_Perm_epochs_R);
        MX_T_Perm_epochs_R = MX_T_Perm_epochs_R.';

    %---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        %now we make our stable, non-changing, non-shuffled timeseries that we will
        %compare to the shuffled ones iterativley made later - we actually only
        %need continious timeseries for the correlation metric - DTW
        %can't run on chunks that large and we pre-defined them to run on 2-sec
        %chunks (for mscohere, the edge artifacts from running the fft on the
        % discontinious epochs stitched together would introduce ringing and other
        % noise), so we will make it easier on ourselves and compare normal order
        %epochs to shuffled epochs (so same thing, just no gluing together into
        %continious timeseries)
        AG_T_Perm_L_timeseries = [];
        AG_T_Perm_R_timeseries = [];
        MX_T_Perm_L_timeseries = [];
        MX_T_Perm_R_timeseries = [];
        start_sample = 1;

        for d = 1:size(EEG.data,3)
            AG_T_Perm_L_timeseries(start_sample:start_sample + 3999) = AG_T_Perm_epochs_L(d,:);
            AG_T_Perm_R_timeseries(start_sample:start_sample + 3999) = AG_T_Perm_epochs_R(d,:);

            MX_T_Perm_L_timeseries(start_sample:start_sample + 3999) = MX_T_Perm_epochs_L(d,:);
            MX_T_Perm_R_timeseries(start_sample:start_sample + 3999) = MX_T_Perm_epochs_R(d,:);

            start_sample = start_sample + 4000;
        end
    %---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        %now we need to actually make the permutations, MATLAB has a function to go
        %through every single permutation, but that's way more than the 10,000 we
        %want (usually) and also too much for the computer - so I had to hand-craft 10,000
        %individual, random permutations then check to make sure they aren't
        %duplicates - it takes about 30sec to run and always includes all avaiable
        %epochs (that number varries by dataset) - after running, it was clear that
        %there were a decent number of perms where the same single epoch was being
        %compared to itself even though the perm as a whole was not a copy - for the MX:sMX
        %and Ag:sAG comps only - so we need to prevent that as well - however, it's
        %not possible to know how many instances that will show up so it's hard to
        %know if x epochs in the dataset will be enough - if they aren't it will
        %run forever - so since 8! gives us 40,320 perms and the script usually
        %took about 30secs to get 10,000 unique ones - I will multiply that by 4 -
        %so 2mins and if the script is still going, I will assume it's not possible
        %and error out (it might be easier to just insist on 9 epochs, but I don't
        %wanna do that unless I need to because we might loose arrays) (this is a
        %heuristic that can be updated if we find we need to) - it seems to take
        %around 107 seconds to run for 10,000 perms with the 2 limitations imposed
        %- it also seems to be 2 single epoch duplicates for every 1 acceptable
        %perm - so we shouldn't blow past the 40,000 avaiable for 8 trials and
        %won't need to increase the trial count min

        timer_start = tic; %record start time
        repeat_count = 0; %just used as a check
        single_epoch_overlap_count = 0; %again, as a check
        OG_epoch = [1:size(EEG.data,3)]; % just the order of epochs to match size of all epochs i.e 1,2,3,4,5,6,7,8
        perms = [];            
        while size(perms,1) <1 %set to number of perms you want
            perm = randperm(size(EEG.data,3));

            TF = perm == OG_epoch; % check to see if any epochs will be compared to themselves
            cases = sum(TF); %if the sum is greater than 0 - at least 1 was compared to itself
            helper2 = 0;
            if cases ~= 0 
                helper2 = 1; %if any of them are compared to themselves, reject
                single_epoch_overlap_count = single_epoch_overlap_count+1; % just a tool to see frequency
            end   

            helper = 0;
            for y = 1:size(perms,1)
                TF = perm == perms(y,:); %TF meaning true/false 1/0
                cases = sum(TF);
                if cases == size(EEG.data,3) %if they are all 1 it is a duplicate
                helper = 1; %if duplicate, do nothing
                repeat_count = repeat_count + 1;
                end
            end

            if helper == 0 && helper2 == 0 %if not duplicate and no single epoch overlap, record in perms
                perms(size(perms,1)+1,1:size(EEG.data,3)) = perm;
            end

            elapsedTime = toc(timer_start); %check how long you've been iterating in seconds
            assert(elapsedTime < 200, 'there are not enough epochs to run 10,000 iterations (or you need to set the timer higher) - same epoch comparisons are driving this')
        end
    %---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        % we want the 3 metrics for the singular unshuffled Ag:MX - so we
        % will do that here/now before we do the permutations and averages
        coherence_vector_L = [];
        dtw_vector_L = [];
        coherence_vector_R = [];
        dtw_vector_R = [];
        
        
        ushuffled_AG_MX_perm_correlation_L = corrcoef(AG_T_Perm_L_timeseries, MX_T_Perm_L_timeseries);
        ushuffled_AG_MX_perm_correlation_R = corrcoef(AG_T_Perm_R_timeseries, MX_T_Perm_R_timeseries);
        
        
        for d = 1:size(EEG.data,3)
            [cxy, f] = mscohere(AG_F_Perm_epochs_L(d,:),MX_F_Perm_epochs_L(d,:),hamming(2000),[],f,fs);
            coherence_vector_L(1:34,d) = cxy(1:34);
            
            [cxy, f] = mscohere(AG_F_Perm_epochs_R(d,:),MX_F_Perm_epochs_R(d,:),hamming(2000),[],f,fs);
            coherence_vector_R(1:34,d) = cxy(1:34);
            
            dtw_vector_L(d) = dtw(AG_F_Perm_epochs_L(d,:),MX_F_Perm_epochs_L(d,:));
            
            dtw_vector_R(d) = dtw(AG_F_Perm_epochs_R(d,:),MX_F_Perm_epochs_R(d,:));
        end
        
%         for d = 1:size(EEG.data,3)
%             AG_F_Perm_L_timeseries(start_sample:start_sample + 3999) = AG_F_Perm_epochs_L(d,:);
%             AG_F_Perm_R_timeseries(start_sample:start_sample + 3999) = AG_F_Perm_epochs_R(d,:);
%             
%             MX_F_Perm_L_timeseries(start_sample:start_sample + 3999) = MX_F_Perm_epochs_L(d,:);
%             MX_F_Perm_R_timeseries(start_sample:start_sample + 3999) = MX_F_Perm_epochs_R(d,:);
% 
%             start_sample = start_sample + 4000;
%         end
        
%         
%         for y = 1:length(two_sec_epochs)
%             
%             epochstart = two_sec_epochs(y,1)*2+1;
%             epochend = two_sec_epochs(y,2)*2;
% 
%             AG_F_Perm_L_timeseries_y = AG_F_Perm_L_timeseries(epochstart:epochend);
%             AG_R_two_sec_epochs_y = AG_data_R(epochstart:epochend);
%             
%             dtw_vector_R(y) = dtw(furthest_MX_R_two_sec_epoch_y, AG_R_two_sec_epochs_y);
%             
%             [cxy, f] = mscohere(furthest_MX_R_two_sec_epoch_y, AG_R_two_sec_epochs_y,hamming(2000),[],f,fs);
%             coherence_vector_R(1:length(cxy),y) = cxy(1:length(cxy));
%             
%         end
    
        report_card{2,61} = ushuffled_AG_MX_perm_correlation_L(1,2);
        report_card{3,61} = ushuffled_AG_MX_perm_correlation_R(1,2);
        
        for b = 1:34
            report_card{2,63}(b+1,1) = b+1;
            report_card{2,63}(b+1,2) = mean(coherence_vector_L(b,:));
            report_card{2,63}(b+1,3) = median(coherence_vector_L(b,:));
            report_card{2,63}(b+1,4) = std(coherence_vector_L(b,:));
            
            report_card{3,63}(b+1,1) = b+1;
            report_card{3,63}(b+1,2) = mean(coherence_vector_R(b,:));
            report_card{3,63}(b+1,3) = median(coherence_vector_R(b,:));
            report_card{3,63}(b+1,4) = std(coherence_vector_R(b,:));
        end
        
        report_card{2,62}(1,1) = "mean";
        report_card{2,62}(2,1) = mean(dtw_vector_L);
        report_card{2,62}(1,2) = "median";
        report_card{2,62}(2,2) = median(dtw_vector_L);
        report_card{2,62}(1,3) = "std";
        report_card{2,62}(2,3) = std(dtw_vector_L);
        
        report_card{3,62}(1,1) = "mean";
        report_card{3,62}(2,1) = mean(dtw_vector_R);
        report_card{3,62}(1,2) = "median";
        report_card{3,62}(2,2) = median(dtw_vector_R);
        report_card{3,62}(1,3) = "std";
        report_card{3,62}(2,3) = std(dtw_vector_R);

        
        report_card{2,63}(1,1) = "frequencies";
        report_card{2,63}(1,2) = "mean";
        report_card{2,63}(1,3) = "median";
        report_card{2,63}(1,4) = "std";
        
        report_card{3,63}(1,1) = "frequencies";
        report_card{3,63}(1,2) = "mean";
        report_card{3,63}(1,3) = "median";
        report_card{3,63}(1,4) = "std";
        

%         
%         report_card{3,61} = ushuffled_AG_MX_perm_correlation_R(1,2);
%         report_card{3,62} = unshuffled_AG_MX_perm_coherence_R;
%         report_card{3,63}(2,35) = unshuffled_AG_MX_Perm_dtw_R;

    %---------------------------------------------------------------------------------------------------------------------------------------------
        %onto the permutation metrics
        
        %now make the varriables that will hold all 10,000 output values, go
        %through the iterations, and then average them and throw them into report
        %card 
    %--------------------------------------------------
        MX_sAG_L_corr_holder = []; %vector, 10,000 enteries - row for easy averaging - 1 value per perm makes it easy
        MX_sAG_R_corr_holder = [];

        MX_sAG_L_DTW_holder = []; % in this case, there are multiple values per perm - one for each epoch and it's varriable - but they all get equal weight, so give each epoch 1 column (every column will have equal rows of values) and just average every value in the vector - the varriable rows based on subject doesn't matter
        MX_sAG_R_DTW_holder = [];

        MX_sAG_L_coh_holder = []; % so same situation as DTW but deeper - each perm will have 1 entry per epoch and each epoch's entery is 34 seperate values - but again, just give each epoch 1 column (always 34 rows) and iterate - we don't actually care which epoch the value is from - the length of the final vector will varry by subject but that's fine - just average each row
        MX_sAG_R_coh_holder = [];
    %--------------------------------------------------   
        AG_sAG_L_corr_holder = [];
        AG_sAG_R_corr_holder = [];

        AG_sAG_L_DTW_holder = [];
        AG_sAG_R_DTW_holder = [];

        AG_sAG_L_coh_holder = [];
        AG_sAG_R_coh_holder = [];
    %--------------------------------------------------    
        MX_sMX_L_corr_holder = [];
        MX_sMX_R_corr_holder = [];

        MX_sMX_L_DTW_holder = [];
        MX_sMX_R_DTW_holder = [];

        MX_sMX_L_coh_holder = [];
        MX_sMX_R_coh_holder = [];
    %--------------------------------------------------
    %---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    

        % we use the same process to iterativley shuffle and stitch together 
        % shuffled continious timeseries (still don't need to do so for the
        % frequency-based ones

        for r = 1:size(perms,1)

            sAG_T_Perm_L_timeseries = [];
            sAG_T_Perm_R_timeseries = [];

            sMX_T_Perm_L_timeseries = [];
            sMX_T_Perm_R_timeseries = [];

            start_sample = 1;

            for e = 1:size(EEG.data,3)
                sAG_T_Perm_L_timeseries(start_sample:start_sample + 3999) = AG_T_Perm_epochs_L(perms(r,e),:);
                sAG_T_Perm_R_timeseries(start_sample:start_sample + 3999) = AG_T_Perm_epochs_R(perms(r,e),:);

                sMX_T_Perm_L_timeseries(start_sample:start_sample + 3999) = MX_T_Perm_epochs_L(perms(r,e),:);
                sMX_T_Perm_R_timeseries(start_sample:start_sample + 3999) = MX_T_Perm_epochs_R(perms(r,e),:);

                start_sample = start_sample + 4000;
            end

            %now we start our analysis - corr is the simplest one, just a single
            %function with both continious timeseries as inputs - but it does the
            %2x2 output, so we do 1 more line and just pull out the correlation
            %value
            helper = corrcoef(MX_T_Perm_L_timeseries, sAG_T_Perm_L_timeseries);
            MX_sAG_L_corr_holder(1,r) = helper(1,2);

            helper = corrcoef(MX_T_Perm_R_timeseries, sAG_T_Perm_R_timeseries);
            MX_sAG_R_corr_holder(1,r) = helper(1,2);

            %------------------------------------------------------------------

            helper = corrcoef(AG_T_Perm_L_timeseries, sAG_T_Perm_L_timeseries);
            AG_sAG_L_corr_holder(1,r) = helper(1,2);

            helper = corrcoef(AG_T_Perm_R_timeseries, sAG_T_Perm_R_timeseries);
            AG_sAG_R_corr_holder(1,r) = helper(1,2);

            %------------------------------------------------------------------

            helper = corrcoef(MX_T_Perm_L_timeseries, sMX_T_Perm_L_timeseries);
            MX_sMX_L_corr_holder(1,r) = helper(1,2);

            helper = corrcoef(MX_T_Perm_R_timeseries, sMX_T_Perm_R_timeseries);
            MX_sMX_R_corr_holder(1,r) = helper(1,2);

            %------------------------------------------------------------------

            %even though DTW is based on the "T" data and spectral coherence is
            %based on the "F" data - they both work the same, iterating through our
            %2sec epochs - comparing one 2sec epoch to another - so they are in the
            %same loop - they use the same permutations - just different data
            %inputs and different output structures
            for k = 1:size(EEG.data,3)
                MX_sAG_L_DTW_holder(k,r) = dtw(MX_T_Perm_epochs_L(k,:),AG_T_Perm_epochs_L(perms(r,k),:));
                MX_sAG_R_DTW_holder(k,r) = dtw(MX_T_Perm_epochs_R(k,:),AG_T_Perm_epochs_R(perms(r,k),:));

                [cxy, f] = mscohere(MX_F_Perm_epochs_L(k,:),AG_F_Perm_epochs_L(perms(r,k),:), hamming(2000),[],f,fs);
                MX_sAG_L_coh_holder(1:length(cxy),size(MX_sAG_L_coh_holder,2)+1) = cxy(1:length(cxy));
                [cxy, f] = mscohere(MX_F_Perm_epochs_R(k,:),AG_F_Perm_epochs_R(perms(r,k),:), hamming(2000),[],f,fs);
                MX_sAG_R_coh_holder(1:length(cxy),size(MX_sAG_R_coh_holder,2)+1) = cxy(1:length(cxy));

                %------------------------------------------------------------------------------------------------------

                AG_sAG_L_DTW_holder(k,r) = dtw(AG_T_Perm_epochs_L(k,:),AG_T_Perm_epochs_L(perms(r,k),:));
                AG_sAG_R_DTW_holder(k,r) = dtw(AG_T_Perm_epochs_R(k,:),AG_T_Perm_epochs_R(perms(r,k),:));

                [cxy, f] = mscohere(AG_F_Perm_epochs_L(k,:),AG_F_Perm_epochs_L(perms(r,k),:), hamming(2000),[],f,fs);
                AG_sAG_L_coh_holder(1:length(cxy),size(AG_sAG_L_coh_holder,2)+1) = cxy(1:length(cxy));
                [cxy, f] = mscohere(AG_F_Perm_epochs_R(k,:),AG_F_Perm_epochs_R(perms(r,k),:), hamming(2000),[],f,fs);
                AG_sAG_R_coh_holder(1:length(cxy),size(AG_sAG_R_coh_holder,2)+1) = cxy(1:length(cxy));

                %------------------------------------------------------------------------------------------------------

                MX_sMX_L_DTW_holder(k,r) = dtw(MX_T_Perm_epochs_L(k,:),MX_T_Perm_epochs_L(perms(r,k),:));
                MX_sMX_R_DTW_holder(k,r) = dtw(MX_T_Perm_epochs_R(k,:),MX_T_Perm_epochs_R(perms(r,k),:));

                [cxy, f] = mscohere(MX_F_Perm_epochs_L(k,:),MX_F_Perm_epochs_L(perms(r,k),:), hamming(2000),[],f,fs);
                MX_sMX_L_coh_holder(1:length(cxy),size(MX_sMX_L_coh_holder,2)+1) = cxy(1:length(cxy));
                [cxy, f] = mscohere(MX_F_Perm_epochs_R(k,:),MX_F_Perm_epochs_R(perms(r,k),:), hamming(2000),[],f,fs);
                MX_sMX_R_coh_holder(1:length(cxy),size(MX_sMX_R_coh_holder,2)+1) = cxy(1:length(cxy));

            end

        end

        %getting our final correlations are easy - I could build medians and SD in
        %just as easily - there is just 1 output value per perm so a simple
        %mean(row)
        report_card{2,24} = mean(MX_sAG_L_corr_holder);
        report_card{2,25} = mean(AG_sAG_L_corr_holder);
        report_card{2,30} = mean(MX_sMX_L_corr_holder);

        report_card{3,24} = mean(MX_sAG_R_corr_holder);
        report_card{3,25} = mean(AG_sAG_R_corr_holder);
        report_card{3,30} = mean(MX_sMX_R_corr_holder);

        %***********check that this does what you think it does******************

        %**********below - check that the function does what you think***********


        % I was going to make this a 2-step process: step 1 - take the mean of each
        % iteration - step 2 - take the mean of each mean - this would work because
        % per subject or per array - each iteration would have the same number of
        % values so averaging the average means all individual epoch values get an
        % equal weighting - but since they get equal weighting it is a linear
        % operation - all this to say, it's the same as taking 1 average of every
        % single value with equal weighting - in theory, this would work with
        % medians and SDs - but we might want the two step process there as
        % outliers will be calculated for each step and therefore more removed and
        % the SD less - is that P-hacking? maybe - not my choice and I'm not doing
        % it right now so whateves 
        report_card{2,28} = mean(MX_sAG_L_DTW_holder, 'all');
        report_card{2,29} = mean(AG_sAG_L_DTW_holder, 'all');
        report_card{2,32} = mean(MX_sMX_L_DTW_holder, 'all');

        report_card{3,28} = mean(MX_sAG_R_DTW_holder, 'all');
        report_card{3,29} = mean(AG_sAG_R_DTW_holder, 'all');
        report_card{3,32} = mean(MX_sMX_R_DTW_holder, 'all');


        % so again, because the weight on all values is equal - we can take the
        % average of all values or the average of the average - and if it's the
        % avearge of all values, they don't need to be locked neatly away in
        % sub-cells for each epoch - you can just tack them onto the next column
        % and then average row-wise for each frequency - these will be huge
        % structures though 34x(10,000*#epochs) so something like 34x150,000 - so
        % average by row

        for v = 1:length(cxy)
            report_card{2,26}(v,1) = f(v);
            report_card{2,27}(v,1) = f(v);
            report_card{2,31}(v,1) = f(v);
            report_card{2,26}(v,2) = mean(MX_sAG_L_coh_holder(v,:));
            report_card{2,27}(v,2) = mean(AG_sAG_L_coh_holder(v,:));
            report_card{2,31}(v,2) = mean(MX_sMX_L_coh_holder(v,:));

            report_card{3,26}(v,1) = f(v);
            report_card{3,27}(v,1) = f(v);
            report_card{3,31}(v,1) = f(v);
            report_card{3,26}(v,2) = mean(MX_sAG_R_coh_holder(v,:));
            report_card{3,27}(v,2) = mean(AG_sAG_R_coh_holder(v,:));
            report_card{3,31}(v,2) = mean(MX_sMX_R_coh_holder(v,:));
        end

        disp('length in min of single loop iteration at conclusion of permutation tests')
        toc(loop_start)/60
    end

%% etc. for now

    % we love flags/warnings/checks/failsafes/etc - here they are

    report_card{1,35} = "Array Possibley Plugged in Backwards";

    if report_card{2,6} < report_card{2,21}
        report_card{2,35} = "FLAG";
    else
        report_card{2,35} = "p";
    end
    
    if report_card{3,6} < report_card{3,21}
        report_card{3,35} = "FLAG";
    else
        report_card{3,35} = "p";
    end

%--------------------------------------------------------------------------
    %build these later - I can't think anymore tonight 
    report_card{1,36} = "Left and Right Arrays Possibley Flipped Ag:MX";
    report_card{1,37} = "Left and Right Arrays Possibley Flipped Ag:Ag";
    
    
    class_report_left(i+1,:) = report_card(2,:);
    class_report_right(i+1,:) = report_card(3,:);

%% Clear things up to save space to run again (and confusion)
    
    clear AG_F_Perm_epochs_L AG_F_Perm_epochs_R AG_sAG_L_coh_holder AG_sAG_R_coh_holder AG_sAG_L_corr_holder AG_sAG_R_corr_holder AG_sAG_L_DTW_holder AG_sAG_R_DTW_holder AG_T_Perm_epochs_L AG_T_Perm_epochs_R AG_T_Perm_L_timeseries AG_T_Perm_R_timeseries cases cxy d e furthest_MX_data_L furthest_MX_R helper helper2 MX_buddy_L MX_buddy_R MX_F_Perm_epochs_L MX_F_Perm_epochs_R 
    clear MX_sAG_L_coh_holder MX_sAG_R_coh_holder MX_sAG_L_corr_holder MX_sAG_R_corr_holder MX_sAG_L_DTW_holder MX_sAG_R_DTW_holder MX_sMX_L_coh_holder MX_sMX_R_coh_holder MX_sMX_L_corr_holder MX_sMX_R_corr_holder MX_sMX_L_DTW_holder MX_sMX_R_DTW_holder MX_T_Perm_epochs_L MX_T_Perm_epochs_R MX_T_Perm_L_timeseries MX_T_Perm_R_timeseries OG_epoch perm perms r repeat_count 
    clear sAG_T_Perm_L_timeseries sAG_T_Perm_R_timeseries single_epoch_overlap_count sMX_T_Perm_L_timeseries sMX_T_Perm_R_timeseries start_sample TF v winning_AG_L winning_AG_R winning_MX_L winning_MX_R y furthest_MX_L k loosing_AG_L loosing_AG_R pre_warning warning 
    clear dtw_vector_L dtw_vector_R coherence_vector_L coherence_vector_R unshuffled_AG_MX_perm_corelation_L unshuffled_AG_MX_perm_corelation_R
    
    %then remember to clear all things so we don't get problems like before
    report_card(3,:) = [];        
    report_card(2,:) = [];
    
    disp('length of 1 full iteration in mins (1 sub or 2 arrays (usually)')
    toc(loop_start)/60
    
end


%time to save the class report - after combining left and right
% but save with different ordering to make things neater/make more sense



%%
% sample sizes are important to know - especially when auto-cleaning -
% these will be for final metrics sheet where things are averaged, not for
% the class report
% class_report_left{1,20} = "MX:AG n";
% class_report_left{1,21} = "AG:AG n";
% class_report_left{1,22} = "MX:MX n";
% class_report_left{1,23} = "Q1:Q3 n";
% class_report_left{1,24} = "Q2:Q4 n";



disp('total runtime for script in mins')
toc/60
