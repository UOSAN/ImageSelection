currentSub=28;
test=1;

if test == 0
    studyDir = '/Users/Shared/Dropbox/Devaluation/ImageSelection';
elseif test == 1
    studyDir = '~/Desktop/ImageSelection/';
end

imgDir = [studyDir filesep 'Stimuli/CategorizedImages/Unhealthy/'];
inputDir = [studyDir filesep 'input/'];

%Find most recent redcap LABELS file
redcapFiles = dir('Devaluation_DATA_LABELS*');
[~,idx] = sort([redcapFiles.datenum]);
currentRedcapFile = redcapFiles(idx(end)).name;

redcapTable=readtable([inputDir filesep currentRedcapFile]);

subRows = redcapTable.RecordID==currentSub;
sessionRows = strcmp(redcapTable.EventName,'Session 0');
catRow = subRows & sessionRows;

if ~(sum(catRow)==1)
    error('More than one Session 0 entry for sub %d in the RedCap raw file',currentSub)
else
   food0 = redcapTable{catRow,'FoodCategory_LeastCravedFood'}{1};
   food1 = redcapTable{catRow,'FoodCategoryRank_1'}{1};
   food2 = redcapTable{catRow,'FoodCategoryRank_2'}{1};
   food3 = redcapTable{catRow,'FoodCategoryRank_3'}{1};
end

cd(inputDir)
catTable = readtable('categories_masterList.txt','ReadVariableNames',false);

vars = {'food0','food1','food2','food3'};
idxList = zeros(4,1);
for v = 1:length(vars)
    % Get rid of spaces in food strings ("despacify")
    currentVar = vars{v};
    despacifyStr = [currentVar ' = ' currentVar '(~isspace(' currentVar '));'];
    eval(despacifyStr)
    
    % Find & save index of each cat
    saveIdxStr = ['idxList(v) = find(strcmp(catTable.Var1,' currentVar '));'];
    eval(saveIdxStr)
end

dlmwrite(['categories_DEV' num2str(currentSub) '.txt'],idxList,'delimiter','\t')
