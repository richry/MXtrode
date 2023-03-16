
% gotta remember to do this then delete row 10
combined_report = {};
combined_report = [class_report_left; class_report_right];

%% spectral coherence plotting - non-permutations - only do for unfiltered
indicies = [7, 10, 13, 16, 19, 22]; 
%names = ['MX:Ag Close n=16', 'Ag:Ag n=9', 'MX:MX Close n=16', 'MX:MX:Q1:Q3 n=13', 'MX:MX Q2:Q4 n=13', 'MX:Ag Far n=16'];
line_widths = [7, 6, 6, 5, 5, 5];
line_colors = {'#318F62', '#2A6FDB', '#FF0023', '#F5A914', '#FC6509', '#8CE648'};
%line_colors = {'#7E2F8E', 'b', 'r', '#EDB120', '#D95319', 'm'};

figure
hold on
title('Spectral Coherence Comparisons "not time-locked"', 'FontSize', 25)
xlabel('Frequency in Hz', 'FontSize', 20)
ylabel('Spectral Coherence', 'FontSize', 20)


for r = 1:6
    holder = [];
    
    for p = 1:16

        empty = 0;
        empty = isempty(combined_report{p+1,indicies(r)});
            if empty == 0
                holder(1:size(f,2),size(holder,2)+1) = combined_report{p+1,indicies(r)}(2:size(f,2)+1,2);
            end
    end
    

    for p = 1:size(f,2)
        averages(p,1) = mean(holder(p,1:size(holder,2)));
    end
    
    plot(f(1:34), averages(1:34), 'LineWidth', line_widths(r), 'Color', line_colors{r})
    
    clear('holder','empty','averages')
    
    
end

legend('MX:AG n=16', 'AG:AG n=9', 'MX:MX-Near n=16', 'MX:MX Q1:Q3 n=13', 'MX:MX Q2:Q4 n=13', 'MX:Ag-Far n=16', 'FontSize', 20)


%% Spectral coherence of permutations - unfiltered only

indicies = [26, 27, 31, 63];
line_widths = [7, 6, 6, 8];
line_colors = {	'#10F53D', 'b', 'r', 'k'};

figure
hold on
title('Spectral Coherence Comparisons Permutations "Time-Locked"', 'FontSize', 25)
xlabel('Frequency in Hz', 'FontSize', 20)
ylabel('Spectral Coherence', 'FontSize', 20)

for r = 1:4
    holder = [];
    
    if r < 4
        for p = 1:16
            empty = 0;
            empty = isempty(combined_report{p+1,indicies(r)});
        
            if empty == 0
                holder(1:size(f,2),size(holder,2)+1) = combined_report{p+1,indicies(r)}(1:size(f,2),2);
            end
        end 
    elseif r == 4
        for p = 1:16 
            empty = 0;
            empty = isempty(combined_report{p+1,indicies(r)});

            if empty == 0
                holder(1:size(f,2),size(holder,2)+1) = combined_report{p+1,indicies(r)}(2:size(f,2)+1,2);
            end
        end
    end
    
         
    for p = 1:size(f,2)
        averages(p,1) = mean(holder(p,1:size(holder,2)));
    end
    
    plot(f(1:34), averages(1:34), 'LineWidth', line_widths(r), 'Color', line_colors{r})
    
    clear('holder','empty','averages')

end

legend('MX:AG -Perm', 'AG:AG -Perm', 'MX:MX -Perm', 'MX:AG -Unshuffled', 'FontSize', 20)

%% Data formatting for correlation and MScohere - broadband and frequency bands

prep_for_excel_correlations = [];


indicies = [6, 9, 12, 15, 18, 21];% these are perms and not directly comprable, 24, 25, 30];

for r = 1:size(indicies,2)
    
    holder = [];
    for p = 2:17
        
        empty = 0;
        empty = isempty(combined_report{p, indicies(r)});
            if empty == 0
                holder(size(holder,1)+1,1) = combined_report{p, indicies(r)};
            end
    end
    
    prep_for_excel_correlations(1,r) = mean(holder);
    prep_for_excel_correlations(2,r) = median(holder);
    prep_for_excel_correlations(3,r) = std(holder);
    
    clear holder 
end
    
prep_for_excel_dtw = [];

indicies = [8, 11, 14, 17, 20, 23];% these are perms and not directly comprable, 28, 29, 32];

for r = 1:size(indicies,2)
    
    holder = [];
    for p = 2:17
        
        empty = 0;
        empty = isempty(combined_report{p, indicies(r)});
            if empty == 0 && r < 7 && p ~=1
                holder(size(holder,1)+1,1) = combined_report{p, indicies(r)}(2,1);
            elseif empty == 0
                holder(size(holder,1)+1,1) = combined_report{p, indicies(r)};
            end
    end
    
    prep_for_excel_dtw(1,r) = mean(holder);
    prep_for_excel_dtw(2,r) = median(holder);
    prep_for_excel_dtw(3,r) = std(holder);
    
    clear holder
end
    
%% PSD - power spectral density - unfiltered data only

f = [2:35];
frequencies = [2:35];
indicies = [51:58];
% line_widths = [3, 3, 3, 3, 3, 3, 5, 5];
line_widths = [5, 5, 3, 3, 3, 3, 3, 3];
%line_colors = {'#A80DFB', '#E30B9D', '#FA1400', '#E35A0B', '#F2B433', '#39A2DB', '#E8BF31', '#095F8F'};
line_colors = {'#0FFF3C', '#E3C60B', '#FA4700', '#AD0BE3', '#008BFA','#FA8C52', '#C640E3', '#70ADFA'};%
% line_colors = {'r', 'g', 'b', 'c', 'm', 'y', '#EDB120', '#77AC30'};

figure
hold on
title('Power Spectral Density AG v MX Unfiltered', 'FontSize', 25)
xlabel('Frequency in Hz', 'FontSize', 20)
ylabel('Log Power Spectral Density 10*log_{10}(\muV^{2}/Hz)', 'FontSize', 20)


% ***** Big Note *****
% The "Qs" were not getting plotted because of an error where the 8th row
% with data in the PSD columns for the Qs was generated but empty, so the
% quick fix it to just go in and delete those 4 cells and run

% ** also the last 2 for Q2 and Q4





for r = [8,7,6,5,4,3,2,1] %1:size(indicies,2)
    
    holder = [];
    for p = 2:17
        empty = 0;
        empty = isempty(combined_report{p,indicies(r)});
        if empty == 0
            holder(1:size(f,2),size(holder,2)+1) = combined_report{p, indicies(r)}(2:size(f,2)+1,2);
        end
    end
    
    for k = 1:34
        averages(k,1) = mean(holder(k,1:size(holder,2)));
    end
    
    plot(frequencies(1:34), averages(1:34), 'LineWidth', line_widths(r), 'Color', line_colors{r})
    
    if r == 1
        AG_averages = averages;
    elseif r == 2
        MX_averages = averages;
    end
    
    clear('holder','empty','averages')
end

ag_minus_mx_dif = AG_averages - MX_averages;
plot(frequencies, ag_minus_mx_dif, 'LineWidth', 6, 'LineStyle', '--', 'Color', 'k')

%legend('AG', 'MX', 'AG2', 'MX2','MX:Q1', 'MX:Q3', 'MX:Q2', 'MX:Q4', 'Ag-MX', 'FontSize', 20)
legend('MX:Q4', 'MX:Q2', 'MX:Q3', 'MX:Q1', 'MX2', 'AG2', 'MX', 'AG', 'Ag-MX', 'FontSize', 20)
 
 %% mean root squred data curation - slightly automated - use bandpassed data only
 
 
mrs_chart(1:17,1) = combined_report(1:17,1);
mrs_chart(1:17,2) = combined_report(1:17,40);
mrs_chart(1:17,3) = combined_report(1:17,41);
mrs_chart(1:17,7) = combined_report(1:17,42);
mrs_chart(1:17,8) = combined_report(1:17,43);
mrs_chart(1:17,9) = combined_report(1:17,44);
mrs_chart(1:17,10) = combined_report(1:17,45);
mrs_chart(1:17,11) = combined_report(1:17,46);
mrs_chart(1:17,12) = combined_report(1:17,47);
mrs_chart(1:17,13) = combined_report(1:17,48);

mrs_chart{1,5} = "AG - MX";

for i = 2:17
mrs_chart{i,5} = mrs_chart{i,2}-mrs_chart{i,3};
end

mrs_chart{19,1} = "mean";
mrs_chart{20,1} = "median";
mrs_chart{21,1} = "std";

indicies = [2,3,5,7,8,9,10,11,12,13];


for i = 1:10
    helper = [];
    for j = 2:17
        empty = 0;
        empty = isempty(mrs_chart{j,indicies(i)});
        if empty == 0
            helper(size(helper,2)+1) = double(mrs_chart{j,indicies(i)});
        end
    end
    mrs_chart{19,indicies(i)} = mean(helper);
    mrs_chart{20,indicies(i)} = median(helper);
    mrs_chart{21,indicies(i)} = std(helper);
end


%% ----------------------------------------------------------------------------------------

%% Impedance Boxplot Maker

load('/Users/byronbiney/Documents/MXene_Project/All_things_Gamry/Area_Corrected_AG_values_10Hz_all.mat')
load('/Users/byronbiney/Documents/MXene_Project/All_things_Gamry/Area_Corrected_MX_Medians_10Hz_all_gamry.mat')

%% now make sure to delete the Ag outlier manually

%%

x = [area_corrected_mx_medians_10hz; Area_Corrected_AG_values_10Hz_All];
g = [];
g(1:16,1) = 1;
g(17:24,1) = 2;


figure
hold on
title('Area Corrected Impedance', 'FontSize', 25)
ylabel('Kohn*cm^2', 'FontSize', 20)
boxplot(x,g, 'Colors', 'k', 'Labels', {'MXtrode Array n = 16', 'Ag/AgCl Electrode n = 8'})







