
start_sample_list = [];
onset_list = [];
onset_bucket_counter = 1;
onset_list_counter =1;
onset_bucket = [zeros(1,length(response_ttls))];
onset_bucket(1) = 11;
for i = 1:length(onset_bucket)
    for t = onset_bucket(onset_bucket_counter)
        average_before = mean(response_ttls(t-10:t-1));
        average_after = mean(response_ttls(t+1:t+10));
        if response_ttls(t)> (average_before+.5) && average_before <= 2.5
            onset_list(onset_list_counter,1:20) = response_ttls(t-10:t+9);
            onset_list_counter = onset_list_counter+1;
            start_sample_list(onset_list_counter,1) = t;
            onset_bucket(onset_bucket_counter) = t+30;%420;
            %now jump ahead 420 samples
        else
            onset_bucket(onset_bucket_counter) = t+1;
        end
    end
end

%%

stop_sample_list = [];
offset_list = [];
offset_bucket_counter = 1;
offset_list_counter =1;
offset_bucket = [zeros(1,length(response_ttls))];
offset_bucket(1) = 11;
for i = 1:length(offset_bucket)
    for t = offset_bucket(offset_bucket_counter)
        average_before = mean(response_ttls(t-10:t-1));
        average_after = mean(response_ttls(t+1:t+10));
        if response_ttls(t)< (average_before-.5) && average_before >= 2.5 && average_after < 2
            offset_list(offset_list_counter,1:20) = response_ttls(t-10:t+9);
            offset_list_counter = offset_list_counter+1;
            stop_sample_list(offset_list_counter,1) = t;
           % offset_bucket(offset_bucket_counter) = t+30;%420;
           %don't think we can jump because idk how long b4 next onset
            %now jump ahead 420 samples
            offset_bucket(offset_bucket_counter) = t+11;
        else
            offset_bucket(offset_bucket_counter) = t+1;
        end
    end
end

%%

ttl_lengths_in_samples = stop_sample_list - start_sample_list;

Fixation_ttl_length = [];
Probe_ttl_length = [];
Response_ttl_length = [];

counter = 3;
helper = 1;

for i = 1:length(ttl_lengths_in_samples)/3
    Fixation_ttl_length(helper,1) = ttl_lengths_in_samples(counter,1);
    Probe_ttl_length(helper,1) = ttl_lengths_in_samples(counter+1,1);
    Response_ttl_length(helper,1) = ttl_lengths_in_samples(counter+2,1);
    counter = counter+3;
    helper = helper+1;
end

%%

Fixation_onsets = [];
Probe_onsets = [];
Response_onsets = [];

counter = 4; %4?? why is the other 3?
helper =1;

for i = 1:length(start_sample_list/3)
    Fixation_onsets(helper,1) = start_sample_list(counter,1);
    Probe_onsets(helper,1) = start_sample_list(counter+1,1);
    Response_onsets(helper,1) = start_sample_list(counter+2,1);
    counter = counter+3;
    helper = helper+1;
end
    
Fix_onset_to_Probe_onset = Probe_onsets - Fixation_onsets;
Probe_onset_to_response_onset = Response_onsets - Fixation_onsets(1:length(Response_onsets));

% almost every ttl has an onset of 1 sample - with a few exceptions where
% they take 2 samples

% every single ttl has an offset time of 1 sample with one case where it
% just barely made it

% Fixation ttl length in samples: Max:140 Min:131 Mode:133
% Probe ttl length in samples: Max:291 Min:35 Mode:38 ---- not sure what's up with the few large ones
% Response ttl length in samples: Max:280 Min:266 Mode:277

%Fixation to Probe: Max:2789 (really 791) Min:255 (really 536)
%Probe to Response: Max:5024 Min:1665 Difference: 3359 Mean: 1965

%we have a 31sample mystery if the jitter was 250ms+-125ms (how frequent is
%it?) - pull out the index of everything over 750samples (could be a 30sample or 15ms mystery
%because of ttl onset varriability) - there is only 1.......

% 2 more mysteries, why does that counter start at 4 and why are there 91
% of everything but 90 Responses - and 90 trials in the export
