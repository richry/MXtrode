clear
clc

myDir = '/Users/byronbiney/Documents/MXene_Project/all_CogNeW_data/MXAttn_a_raw';
myFiles = dir(fullfile(myDir));
cd (myDir)

ant = '_ANT_';
nback = '_Nback_';
pvt_post = '_PVT_post_';
pvt_pre = '_PVT_pre_';
EO1 = '_RS_EO1_';
EO2 = '_RS_EO2_';
EC1 = '_RS_EC1_';
EC2 = '_RS_EC2_';

%%
big_data = {};

big_data{1,1} = 'SubID';
big_data{2,1} = 'Total_Files';
big_data{3,1} = 'ReadMe';
big_data{4,1} = 'Surveys';
big_data{5,1} = 'Session_Notes';
big_data{8,1} = 'PVT_pre';
big_data{9,1} = 'ANT';
big_data{10,1} = 'NBack';
big_data{11,1} = 'PVT_post';
big_data{14,1} = 'EO1';
big_data{15,1} = 'EC1';
big_data{16,1} = 'EO2';
big_data{17,1} = 'EC2';
big_data{20,1} = 'PVT_pre_behavioral';
big_data{21,1} = 'ANT_behavioral';
big_data{22,1} = 'NBack_behavioral';
big_data{23,1} = 'PVT_post_behavioral';

%% 
helper = 1;

for i = 4%:length(myFiles)
    helper = helper+1;
    temp_data = big_data;
    subDir = myFiles(i).name;
    cd (subDir)
    current_dir = pwd;
    subFiles = dir(fullfile(current_dir));
    subid = subDir(8:11);
    
    temp_data{1,helper} = subid;
    temp_data{2,helper} = length(subFiles);
end
    

% Things to check for: 1 is everything there? 2 is everythging named
% correctly? 3. Are any RHD files split? 4. Are any behavioral data files
% split? Are the EO and EC correct (part of naming) 5 are they the right
% subject's data (part of naming)


%Later things to check - is the session notes complete/correct (and not a
%weird split one) - is the session notes the right subject? - are the
%behavioral files in the correct format? How many varriations are there?
%Which varriation is it? 





