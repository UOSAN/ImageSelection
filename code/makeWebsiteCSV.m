function [] = makeWebsiteCSV()

testing = 0;
% testing = 1;
num_hStim = 82;

if testing
    DIR.study = '~/Desktop/';
else
    DIR.study = '~/Desktop/DEV/';
end

DIR.task = [DIR.study filesep 'ImageSelection/'];

DIR.img = [DIR.task '/Stimuli/CategorizedImages/'];
DIR.input = [DIR.task filesep 'input/'];
DIR.output_dropbox = '~/Dropbox (PfeiBer Lab)/Devaluation/Tasks/ImageSelection/output/Categorized';

trialsPerType = 60;
subject_code=input('Enter subject number (3 digits): ');

if subject_code<10
    placeholder = '00';
elseif subject_code<100
    placeholder = '0';
else placeholder = '';
end

% GET HEALTHY IMAGES
% hStimStruct = dir([DIR.img filesep 'Healthy' filesep 'healthy*.png']);
% hStimCell = struct2cell(hStimStruct)';
% hStim = hStimCell(:,1);
% hStim = Shuffle(hStim);
hStim = cell(num_hStim,1);
for i = 1:num_hStim
    if i<10
        imPlaceholder = '0';
    else
        imPlaceholder = '';
    end
    hStim{i} = {['healthy' imPlaceholder num2str(i) '.png']};
end

% pick top trialsPerType for unhealthy images
% if trialsPerType <= length(hStim)
%     hStim = hStim(1:trialsPerType);
% else
%     error('Not enough healthy stim! You''ve requested more healthy images than there are.')
% end

% GET UNHEALTHY images
% Load ratings .mat

load([DIR.output_dropbox filesep 'DEV' placeholder num2str(subject_code) '_ratings.mat'])
tiers = cell2mat(ImgRatings_sorted(:,2));
ratings = cell2mat(ImgRatings_sorted(:,1));
cravedIdx = (tiers > 0) & (ratings > 0); % only select images from craved categories
% cravedStim = [ImgRatings_sorted(cravedIdx,3) ImgRatings_sorted(cravedIdx,1)];

% shuffle within each rating
minRating = 1;
maxRating = 4;
for r=minRating:maxRating
    %Find stim of rating r & shuffle them
    rIdx = (ratings==r & tiers > 0);
    stimWithinRating = [ImgRatings_sorted(rIdx,3) ImgRatings_sorted(rIdx,1)];
    if ~isempty(stimWithinRating) 
        
        shuffInd = Shuffle(1:size(stimWithinRating,1));
        stimWithinRating = stimWithinRating(shuffInd,:);
        
        % Append to beginning of cravedStim list
        if exist('cravedStim_shufWithin')==1
            cravedStim_shufWithin = [stimWithinRating; cravedStim_shufWithin];
        else
            cravedStim_shufWithin = stimWithinRating;
        end
    end
end

[ImgRatings_sorted(cravedIdx,:) cravedStim_shufWithin];
checkShuffle = [ImgRatings_sorted(cravedIdx,:) cravedStim_shufWithin];
% can check to see that images were successfully shuffled within rating.

% pick top trialsPerType for unhealthy images
if trialsPerType <= length(cravedStim_shufWithin)
    uStim = cravedStim_shufWithin(1:trialsPerType,1);
    uStim_ratings = cravedStim_shufWithin(1:trialsPerType,2);
else
    warning('Not enough unhealthy stim!')
    numReps = ceil(trialsPerType/size(cravedStim_shufWithin,1));
    stimWReps = {};
    for r=1:numReps
        stimWReps = [stimWReps; cravedStim_shufWithin];
    end
    uStim = stimWReps(1:trialsPerType,1);
    uStim_ratings = stimWReps(1:trialsPerType,2);
end

% CHANGE FILE EXTENSION
for i=1:size(uStim,1)
    uStim{i} = [uStim{i}(1:end-3) 'png'];
end


% create website-formatted csv
uStim_website = cell(length(uStim),5);
hStim_website = cell(length(hStim),5);

% name
uStim_website(:,1) = uStim;
hStim_website(:,1) = hStim;

% pictype
uStim_website(:,2)={0};
hStim_website(:,2)={1};

%rating
uStim_website(:,3)=uStim_ratings;
hStim_website(:,3)={0}; % healthy images are not rated

%chosen
uStim_website(:,4)={1};
hStim_website(:,4)={1};

%value
uStim_website(:,5)={0};
hStim_website(:,5)={0};

stim_website = vertcat(uStim_website,hStim_website);
fields = {'name','pictype','rating','chosen','value'};
stim_website_struct = cell2struct(stim_website,fields,2);
% write csv

%Save to .csv too.
stim_website_table = struct2table(stim_website_struct);
savefilename = sprintf('DEV%s%d_ratings_forWebsite',placeholder,subject_code);
writetable(stim_website_table,[DIR.output_dropbox filesep savefilename '.csv'],'WriteVariableNames',true);

end
