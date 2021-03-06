function DEV_ImageSelection()
% Rate all images in 3 person-specific craved categories + 1 not craved 
% Create output file (csv + mat) including all ratings, tiers (0,1,2,3) and pic names

global wRect w XCENTER rects mids COLORS KEYS ImgRatings inputDir

testing = 0; % set this to testing=1 if you have no dropbox
studyDir = '~/Desktop/DEV/ImageSelection/';

prompt={'SUBJECT ID (3 DIGITS)'};
defAns={'999'};
% minCravedImages = 10; % for testing; will be 64
minCravedImages = 64;

answer=inputdlg(prompt,'Please input subject info',1,defAns);

ID=str2double(answer{1});

if ID<10
    placeholder = '00';
elseif ID<100
    placeholder = '0';
else placeholder = '';
end

stimSet = questdlg('Which stimulus set would you like to use?','Stimuli',1,2,1);

if testing
     studyDir_inout = '~/Desktop/ImageSelection/';
else
    studyDir_inout = '~/Dropbox (University of Oregon)/UO-SAN Lab/Berkman Lab/Devaluation/Tasks/ImageSelection/';
end

inputDir = [studyDir_inout filesep 'input/'];

if stimSet == 1
    
    outputDir = [studyDir_inout filesep 'output/Categorized/'];
    imgDir = [studyDir filesep 'Stimuli/CategorizedImages/Unhealthy/'];
    
    convertRedCap2input(ID,placeholder);
    
    %Input categories.
    subCats = dlmread([inputDir filesep 'categories_DEV' placeholder num2str(ID) '.txt'],'\t');
    catTable = readtable([inputDir filesep 'categories_masterList.txt'],'ReadVariableNames',false);
    FOODCATS = table2array(catTable);
    
elseif stimSet == 2
    
    outputDir = [studyDir_inout filesep 'output/WTP/'];
    imgDir = [studyDir filesep 'Stimuli/WTPImages/'];
    FOODCATS = {'unhealthy' 'healthy' };
    subCats = [1; 2];

end

addpath(genpath(imgDir))

COLORS = struct;
COLORS.BLACK = [0 0 0];
COLORS.GREY = [180 180 180];
COLORS.WHITE = [255 255 255];
COLORS.RED = [255 0 0];
COLORS.BLUE = [130 130 255];
COLORS.GREEN = [0 255 0];
COLORS.YELLOW = [255 255 0];
COLORS.rect = COLORS.GREEN;

KbName('UnifyKeyNames');

KEYS = struct;
KEYS.ONE= KbName('1!');
KEYS.TWO= KbName('2@');
KEYS.THREE= KbName('3#');
KEYS.FOUR= KbName('4$');
KEYS.FIVE= KbName('5%');
KEYS.SIX= KbName('6^');
KEYS.SEVEN= KbName('7&');
KEYS.EIGHT= KbName('8*');
KEYS.NINE= KbName('9(');
KEYS.TEN= KbName('0)');
KEYS.all = [KEYS.ONE:KEYS.FOUR KEYS.TEN]; % 1-4 and 0

try
    cd(imgDir)
catch
    error('Failed to open or find the image directory as: %s.',imgdir);
end

% Set up output filename
outputFile = [outputDir filesep sprintf('ImgRatings_DEV%s%d.mat',placeholder,ID)];

if exist(outputFile,'file') == 2;
    commandwindow;
    warning('THIS FILE ALREADY EXISTS ARE YOU SURE YOU WANT TO CONTINUE?')
    overwrite = input('Type 1 to over-write file or 0 to cancel and enter in new info: ');
    if overwrite == 0;
        error('File already exists. Please double-check and/or re-enter participant number and session information.');
    end
end

% Figure out which unhealthy photos to use:

if stimSet == 1
    extens = '.jpg';
elseif stimSet == 2
    extens = '.bmp';
end

for ccc = 1:length(subCats);
    %open each category folder
    catFolder = FOODCATS{subCats(ccc)};
    try
        cd([imgDir filesep catFolder]);
    catch
        error('Tried to open the folder for %s category but failed. Ensure it is saved as %s',catFolder,catFolder)
    end
    
    catPics = dir(['*' extens]);
    catCodes=repmat({ccc-1},length(catPics),1);
    [catPics(:).catCode] = deal(catCodes{:});
    if exist('subPics')==1
        subPics = [subPics; catPics];    
    else subPics = catPics;
    end
end

numPics = size(subPics,1);
rng('default')
rng('shuffle')
perm = randperm(numPics);
subPics_shuf = subPics(perm);
subPicsCell_shuf = struct2cell(subPics_shuf)';
picnames_shuf = subPicsCell_shuf(:,1);
catcodes_shuf = subPicsCell_shuf(:,7);

save([outputDir filesep 'imagePrezOrder_DEV' placeholder num2str(ID)],'picnames_shuf')

% ImgRatings used to be called PicRatings_CC
ImgRatings = struct('Rate_App',0,'Tier',catcodes_shuf,'Filename',picnames_shuf);

commandwindow;

%%
%change this to 0 to fill whole screen
DEBUG=0;

%set up the screen and dimensions

%list all the screens, then just pick the last one in the list (if you have
%only 1 monitor, then it just chooses that one)
Screen('Preference', 'SkipSyncTests', 1);

screenNumber=max(Screen('Screens'));

if DEBUG==1;
    %create a rect for the screen
    winRect=[0 0 640 480];
    %establish the center points
    XCENTER=320;
    YCENTER=240;
else
    %change screen resolution
    %     Screen('Resolution',0,1024,768,[],32);
    
    %this gives the x and y dimensions of our screen, in pixels.
    [swidth, sheight] = Screen('WindowSize', screenNumber);
    XCENTER=fix(swidth/2);
    YCENTER=fix(sheight/2);
    %when you leave winRect blank, it just fills the whole screen
    winRect=[];
end

%open a window on that monitor. 32 refers to 32 bit color depth (millions of
%colors), winRect will either be a 1024x768 box, or the whole screen. The
%function returns a window "w", and a rect that represents the whole
%screen.
[w, wRect]=Screen('OpenWindow', screenNumber, 0,winRect,32,2);

%%
%you can set the font sizes and styles here
Screen('TextFont', w, 'Arial');
%Screen('TextStyle', w, 1);
Screen('TextSize',w,35);

%% Dat Grid
[rects,mids] = DrawRectsGrid();
verbage = 'How appetizing is this food?';

%% Intro
DrawFormattedText(w,'We are going to show you some pictures of food and have you rate how appetizing each food is.\n\n You will use a scale from 1 to 4, where 1 is "Not at all appetizing" and 4 is "Extremely appetizing."\n\nIf you have a strong negative reaction to the food, press 0.\n\n\n\nPress any key to continue.','center','center',COLORS.WHITE,70,[],[],1.5);
Screen('Flip',w);
KbWait([],3);

DrawFormattedText(w,'Please use the numbers along the top of the keyboard to select your rating.\n\nThe rating task will now begin.\n\n\n\nPress any key to continue.','center','center',COLORS.WHITE,70,[],[],1.5);
Screen('Flip',w);
KbWait([],3);

for x = 1:20:length(ImgRatings);
    for y = 1:20;
        xy = x+(y-1);
        if xy > length(ImgRatings)
            break
        end
        
        DrawFormattedText(w,'+','center','center',COLORS.WHITE);
        Screen('Flip',w);
        WaitSecs(.25);
        
        tp = imread(getfield(ImgRatings,{xy},'Filename'));
        tpx = Screen('MakeTexture',w,tp);
        Screen('DrawTexture',w,tpx);
        drawRatings();
        DrawFormattedText(w,verbage,'center',(wRect(4)*.15),COLORS.GREY);
        Screen('Flip',w);
        
        FlushEvents();
        while 1
            [keyisdown, ~, keycode] = KbCheck();
            if (keyisdown==1 && any(keycode(KEYS.all)))
                                
                if iscell(KbName(keycode)) && numel(KbName(keycode))>1  %You have mashed 2 keys; shame on you.
                    rating = KbName(find(keycode,1));
                    rating = str2double(rating(1));
                    while isnan(rating);        %This key selection is not a number!
                        newrating = KbName(keycode);
                        for kk = 2:numel(newrating)
                            rating = str2double(newrating(kk));
                            if ~isnan(rating)
                                break
                            elseif kk == length(KbName(keycode)) && isnan(rating);
                                %something has gone horrible awry;
                                warning('Trial #%d rating is NaN for some reason',xy);
                                rating = NaN;
                            end
                        end
                    end
                else
                    rating = KbName(find(keycode));
                    rating = str2double(rating(1));
                    
                end
                Screen('DrawTexture',w,tpx);
                drawRatings(keycode);
                DrawFormattedText(w,verbage,'center',(wRect(4)*.15),COLORS.GREY);
                Screen('Flip',w);
                WaitSecs(.25);
                break;
            end
        end
        %Record response here.
        ImgRatings(xy).Rate_App = rating;
        Screen('Flip',w);
        FlushEvents();
        %            WaitSecs(.25);
        
    end
    %Take a break every 20 pics.
    Screen('Flip',w);
    DrawFormattedText(w,'Press any key when you are ready to continue','center','center',COLORS.WHITE);
    Screen('Flip',w);
    KbWait([],3);
    
    if xy > length(ImgRatings)
        break
    end
end

Screen('Flip',w);
WaitSecs(.5);

%% Sort & Save List of Foods.
% Sort by top appetizing ratings.

savefilename = sprintf('DEV%s%d_ratings',placeholder,ID); %can use for csv or mat

fields = {'Rate_App' 'Tier' 'Filename'};

presort = struct2cell(ImgRatings)';
ImgRatings_sorted = sortrows(presort,-1);    %Sort descending by column 3

%Turn back into structure
ImgRatings_sorted_struct = cell2struct(ImgRatings_sorted,fields,2);

%% Save dat data
try
    save([outputDir filesep savefilename '.mat'],'ImgRatings_sorted');
catch
    warning('Something is amiss with this save. Retrying to save in a more general location (i.e., in same folder as Dev_ImageSelection.m)...\n');
    try
        save([imgDir filesep savefilename '.mat'],'ImgRatings_sorted');
        warning('Save location:  %s\n',[imgDir filesep savefilename '.mat']);
    catch
        warning('STILL problems saving....Look for "ImgRatings_sorted.mat" somewhere on the computer and rename it DEV%s%d_ratings.mat\n',placeholder,ID);
        warning('File might be found in: %s\n',pwd);
        save([savefilename '.mat'],'ImgRatings_sorted')
    end
end

%Save to .csv too.
ImgRatings_table = struct2table(ImgRatings_sorted_struct);
writetable(ImgRatings_table,[outputDir filesep savefilename '.csv'],'WriteVariableNames',false);

%save website CSV
makeWebsiteCSV(ID, placeholder, studyDir, studyDir_inout);

DrawFormattedText(w,'That concludes this task. The assessor will be with you shortly.','center','center',COLORS.WHITE);
Screen('Flip',w);
WaitSecs(5);
sca
%% Check if enough trials

tiers = cell2mat(ImgRatings_sorted(:,2));
ratings = cell2mat(ImgRatings_sorted(:,1));
cravedIdx = (tiers > 0) & (ratings > 0); % only select images from craved categories

if sum(cravedIdx) < minCravedImages
    warning('Only %d usable images!',sum(cravedIdx))
end

end

%%
function [] = convertRedCap2input(currentSub,placeholder)

global inputDir

%Find most recent redcap LABELS file
% redcapFiles = dir([inputDir filesep 'Devaluation_DATA_LABELS*']);
redcapFiles = dir([inputDir filesep '*DATA_LABELS*']);
[~,idx] = sort([redcapFiles.datenum]);
currentRedcapFile = redcapFiles(idx(end)).name;

redcapTable=readtable([inputDir filesep currentRedcapFile],'ReadVariableNames',1); %Lauren added this

subCode = ['DEV' placeholder num2str(currentSub)];
subRows = strcmp(redcapTable.DEVID,subCode);
sessionRows = strcmp(redcapTable.EventName,'Session 0');
catRow = subRows & sessionRows;

food0 = redcapTable{catRow,'FoodCategory_LeastCravedFood'}{1};
food1 = redcapTable{catRow,'FoodCategoryRank_1'}{1};
food2 = redcapTable{catRow,'FoodCategoryRank_2'}{1};
food3 = redcapTable{catRow,'FoodCategoryRank_3'}{1};

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

dlmwrite(['categories_DEV' placeholder num2str(currentSub) '.txt'],idxList,'delimiter','\t')

end

%%
function [ rects,mids ] = DrawRectsGrid()
%DrawRectGrid:  Builds a grid of squares with gaps in between.

global wRect XCENTER

%Size of image will depend on screen size. First, an area approximately 80%
%of screen is determined. Then, images are 1/4th the side of that square
%(minus the 3 x the gap between images.

num_rects = 8;                 %How many rects?
% Really there are 5 (1,2,3,4,0) but we want 3 phantom rects between 4 and 0

xlen = wRect(3)*.9;           %Make area covering about 90% of vertical dimension of screen.
gap = 20;                       %Gap size between each rect
square_side = fix((xlen - (num_rects-1)*gap)/num_rects); %Size of rect depends on size of screen.

squart_x = XCENTER-(xlen/2);
squart_y = wRect(4)*.8;         %Rects start @~80% down screen.

rects = zeros(4,num_rects);

% for row = 1:DIMS.grid_row;
for col = 1:num_rects;
    %         currr = ((row-1)*DIMS.grid_col)+col;
    rects(1,col)= squart_x + (col-1)*(square_side+gap);
    rects(2,col)= squart_y;
    rects(3,col)= squart_x + (col-1)*(square_side+gap)+square_side;
    rects(4,col)= squart_y + square_side;
end
% end
mids = [rects(1,:)+square_side/2; rects(2,:)+square_side/2+5];

end

%%
function drawRatings(varargin)

global w KEYS COLORS rects mids

maxRating = 4;
num_rects = 8;
% Really there are 5 (1,2,3,4,0) but we want 2 phantom rects between 4 and 0

colors=repmat(COLORS.GREY',1,num_rects);
% rects=horzcat(allRects.rate1rect',allRects.rate2rect',allRects.rate3rect',allRects.rate4rect');

%Needs to feed in "code" from KbCheck, to show which key was chosen.
if nargin >= 1 && ~isempty(varargin{1})
    response=varargin{1};
    
    key=find(response);
    if length(key)>1
        key=key(1);
    end;
    
    switch key
        
        case {KEYS.ONE}
            choice=1;
        case {KEYS.TWO}
            choice=2;
        case {KEYS.THREE}
            choice=3;
        case {KEYS.FOUR}
            choice=4;
        case {KEYS.TEN}
            choice=num_rects;
    end
    
    if exist('choice','var')
        colors(:,choice)=COLORS.GREEN';
    end
end


window=w;


Screen('TextFont', window, 'Arial');
Screen('TextStyle', window, 1);
oldSize = Screen('TextSize',window,35);

% Screen('TextFont', w2, 'Arial');
% Screen('TextStyle', w2, 1)
% Screen('TextSize',w2,60);

rectsToDraw = [1:maxRating num_rects];

%draw all the squares
Screen('FrameRect',window,colors(:,rectsToDraw),rects(:,rectsToDraw),1);

%draw the text (1-4 and 0)
for n = 1:num_rects;
    if n == num_rects
        numnum = sprintf('%d',0);
    else
        numnum = sprintf('%d',n);
    end
    if n <= maxRating || n == num_rects
        CenterTextOnPoint(window,numnum,mids(1,n),mids(2,n),COLORS.GREY);
    end
end

Screen('TextSize',window,oldSize);

end

%%

function [nx, ny, textbounds] = CenterTextOnPoint(win, tstring, sx, sy,color)
% [nx, ny, textbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft])
%
%

numlines=1;

if nargin < 1 || isempty(win)
    error('CenterTextOnPoint: Windowhandle missing!');
end

if nargin < 2 || isempty(tstring)
    % Empty text string -> Nothing to do.
    return;
end

% Store data class of input string for later use in re-cast ops:
stringclass = class(tstring);

% Default x start position is left border of window:
if isempty(sx)
    sx=0;
end

% if ischar(sx) && strcmpi(sx, 'center')
%     xcenter=1;
%     sx=0;
% else
%     xcenter=0;
% end

xcenter=0;

% No text wrapping by default:
% if nargin < 6 || isempty(wrapat)
wrapat = 0;
% end

% No horizontal mirroring by default:
% if nargin < 7 || isempty(flipHorizontal)
flipHorizontal = 0;
% end

% No vertical mirroring by default:
% if nargin < 8 || isempty(flipVertical)
flipVertical = 0;
% end

% No vertical mirroring by default:
% if nargin < 9 || isempty(vSpacing)
vSpacing = 1.5;
% end

% if nargin < 10 || isempty(righttoleft)
righttoleft = 0;
% end

% Convert all conventional linefeeds into C-style newlines:
newlinepos = strfind(char(tstring), '\n');

% If '\n' is already encoded as a char(10) as in Octave, then
% there's no need for replacemet.
if char(10) == '\n' %#ok<STCMP>
    newlinepos = [];
end

% Need different encoding for repchar that matches class of input tstring:
if isa(tstring, 'double')
    repchar = 10;
elseif isa(tstring, 'uint8')
    repchar = uint8(10);
else
    repchar = char(10);
end

while ~isempty(newlinepos)
    % Replace first occurence of '\n' by ASCII or double code 10 aka 'repchar':
    tstring = [ tstring(1:min(newlinepos)-1) repchar tstring(min(newlinepos)+2:end)];
    % Search next occurence of linefeed (if any) in new expanded string:
    newlinepos = strfind(char(tstring), '\n');
end

% % Text wrapping requested?
% if wrapat > 0
%     % Call WrapString to create a broken up version of the input string
%     % that is wrapped around column 'wrapat'
%     tstring = WrapString(tstring, wrapat);
% end

% Query textsize for implementation of linefeeds:
theight = Screen('TextSize', win) * vSpacing;

% Default y start position is top of window:
if isempty(sy)
    sy=0;
end

winRect = Screen('Rect', win);
winHeight = RectHeight(winRect);

% if ischar(sy) && strcmpi(sy, 'center')
% Compute vertical centering:

% Compute height of text box:
%     numlines = length(strfind(char(tstring), char(10))) + 1;
%bbox = SetRect(0,0,1,numlines * theight);
bbox = SetRect(0,0,1,theight);


textRect=CenterRectOnPoint(bbox,sx,sy);
% Center box in window:
[rect,dh,dv] = CenterRect(bbox, textRect);

% Initialize vertical start position sy with vertical offset of
% centered text box:
sy = dv;
% end

% Keep current text color if noone provided:
if nargin < 5 || isempty(color)
    color = [];
end

% Init cursor position:
xp = sx;
yp = sy;

minx = inf;
miny = inf;
maxx = 0;
maxy = 0;

% Is the OpenGL userspace context for this 'windowPtr' active, as required?
[previouswin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');

% OpenGL rendering for this window active?
if IsOpenGLRendering
    % Yes. We need to disable OpenGL mode for that other window and
    % switch to our window:
    Screen('EndOpenGL', win);
end

% Disable culling/clipping if bounding box is requested as 3rd return
% % argument, or if forcefully disabled. Unless clipping is forcefully
% % enabled.
% disableClip = (ptb_drawformattedtext_disableClipping ~= -1) && ...
%               ((ptb_drawformattedtext_disableClipping > 0) || (nargout >= 3));
%

disableClip=1;

% Parse string, break it into substrings at line-feeds:
while ~isempty(tstring)
    % Find next substring to process:
    crpositions = strfind(char(tstring), char(10));
    if ~isempty(crpositions)
        curstring = tstring(1:min(crpositions)-1);
        tstring = tstring(min(crpositions)+1:end);
        dolinefeed = 1;
    else
        curstring = tstring;
        tstring =[];
        dolinefeed = 0;
    end
    
    if IsOSX
        % On OS/X, we enforce a line-break if the unwrapped/unbroken text
        % would exceed 250 characters. The ATSU text renderer of OS/X can't
        % handle more than 250 characters.
        if size(curstring, 2) > 250
            tstring = [curstring(251:end) tstring]; %#ok<AGROW>
            curstring = curstring(1:250);
            dolinefeed = 1;
        end
    end
    
    if IsWin
        % On Windows, a single ampersand & is translated into a control
        % character to enable underlined text. To avoid this and actually
        % draw & symbols in text as & symbols in text, we need to store
        % them as two && symbols. -> Replace all single & by &&.
        if isa(curstring, 'char')
            % Only works with char-acters, not doubles, so we can't do this
            % when string is represented as double-encoded Unicode:
            curstring = strrep(curstring, '&', '&&');
        end
    end
    
    % tstring contains the remainder of the input string to process in next
    % iteration, curstring is the string we need to draw now.
    
    % Perform crude clipping against upper and lower window borders for
    % this text snippet. If it is clearly outside the window and would get
    % clipped away by the renderer anyway, we can safe ourselves the
    % trouble of processing it:
    if disableClip || ((yp + theight >= 0) && (yp - theight <= winHeight))
        % Inside crude clipping area. Need to draw.
        noclip = 1;
    else
        % Skip this text line draw call, as it would be clipped away
        % anyway.
        noclip = 0;
        dolinefeed = 1;
    end
    
    % Any string to draw?
    if ~isempty(curstring) && noclip
        % Cast curstring back to the class of the original input string, to
        % make sure special unicode encoding (e.g., double()'s) does not
        % get lost for actual drawing:
        curstring = cast(curstring, stringclass);
        
        % Need bounding box?
        %         if xcenter || flipHorizontal || flipVertical
        % Compute text bounding box for this substring:
        bbox=Screen('TextBounds', win, curstring, [], [], [], righttoleft);
        %         end
        
        % Horizontally centered output required?
        %         if xcenter
        % Yes. Compute dh, dv position offsets to center it in the center of window.
        %             [rect,dh] = CenterRect(bbox, winRect);
        [rect,dh] = CenterRect(bbox, textRect);
        % Set drawing cursor to horizontal x offset:
        xp = dh;
        %         end
        
        %         if flipHorizontal || flipVertical
        %             textbox = OffsetRect(bbox, xp, yp);
        %             [xc, yc] = RectCenter(textbox);
        %
        %             % Make a backup copy of the current transformation matrix for later
        %             % use/restoration of default state:
        %             Screen('glPushMatrix', win);
        %
        %             % Translate origin into the geometric center of text:
        %             Screen('glTranslate', win, xc, yc, 0);
        %
        %             % Apple a scaling transform which flips the direction of x-Axis,
        %             % thereby mirroring the drawn text horizontally:
        %             if flipVertical
        %                 Screen('glScale', win, 1, -1, 1);
        %             end
        %
        %             if flipHorizontal
        %                 Screen('glScale', win, -1, 1, 1);
        %             end
        %
        %             % We need to undo the translations...
        %             Screen('glTranslate', win, -xc, -yc, 0);
        %             [nx ny] = Screen('DrawText', win, curstring, xp, yp, color, [], [], righttoleft);
        %             Screen('glPopMatrix', win);
        %         else
        [nx ny] = Screen('DrawText', win, curstring, xp, yp, color, [], [], righttoleft);
        %         end
    else
        % This is an empty substring (pure linefeed). Just update cursor
        % position:
        nx = xp;
        ny = yp;
    end
    
    % Update bounding box:
    minx = min([minx , xp, nx]);
    maxx = max([maxx , xp, nx]);
    miny = min([miny , yp, ny]);
    maxy = max([maxy , yp, ny]);
    
    % Linefeed to do?
    if dolinefeed
        % Update text drawing cursor to perform carriage return:
        if xcenter==0
            xp = sx;
        end
        yp = ny + theight;
    else
        % Keep drawing cursor where it is supposed to be:
        xp = nx;
        yp = ny;
    end
    % Done with substring, parse next substring.
end

% Add one line height:
maxy = maxy + theight;

% Create final bounding box:
textbounds = SetRect(minx, miny, maxx, maxy);

% Create new cursor position. The cursor is positioned to allow
% to continue to print text directly after the drawn text.
% Basically behaves like printf or fprintf formatting.
nx = xp;
ny = yp;

% Our work is done. If a different window than our target window was
% active, we'll switch back to that window and its state:
if previouswin > 0
    if previouswin ~= win
        % Different window was active before our invocation:
        
        % Was that window in 3D mode, i.e., OpenGL rendering for that window was active?
        if IsOpenGLRendering
            % Yes. We need to switch that window back into 3D OpenGL mode:
            Screen('BeginOpenGL', previouswin);
        else
            % No. We just perform a dummy call that will switch back to that
            % window:
            Screen('GetWindowInfo', previouswin);
        end
    else
        % Our window was active beforehand.
        if IsOpenGLRendering
            % Was in 3D mode. We need to switch back to 3D:
            Screen('BeginOpenGL', previouswin);
        end
    end
end

return;
end

function [] = makeWebsiteCSV(ID, placeholder, studyDir, studyDir_inout)

subject_code = ID;

% studyDir is Desktop Image Selection
% studyDir_inout is dropbox ImageSelection

DIR.task = studyDir;

DIR.img = [DIR.task filesep 'Stimuli/CategorizedImages/'];
DIR.output_dropbox = [studyDir_inout filesep 'output/Categorized/'];

trialsPerType = 60;
num_hStim = 82;

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
