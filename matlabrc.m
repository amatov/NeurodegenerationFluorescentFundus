%MATLABRC Master startup M-file.
%   MATLABRC is automatically executed by MATLAB during startup.
%   It establishes the MATLAB path, sets the default figure size,
%   and sets a few uicontrol defaults.
%
%	On multi-user or networked systems, the system manager can put
%	any messages, definitions, etc. that apply to all users here.
%
%   MATLABRC also invokes a STARTUP command if the file 'startup.m'
%   exists on the MATLAB path.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.154 $  $Date: 2002/06/07 20:08:31 $

% Set up path.
if exist('pathdef','file')
  matlabpath(pathdef);
end

% Display helpful hints.
% If the MATLAB Desktop is not running, then use the old message, since
% the Help menu will be unavailable.
cname = computer;
if usejava('Desktop')
    disp(' ')
    disp('  To get started, select "MATLAB Help" from the Help menu.')
    disp(' ')
else
    disp(' ')
    disp('  To get started, type one of these: helpwin, helpdesk, or demo.')
    disp('  For product information, visit www.mathworks.com.')
    disp(' ')
end

% Set default warning level to WARNING BACKTRACE.  See help warning.
warning backtrace

% The RecursionLimit forces MATLAB to throw an error when the specified
% function call depth is hit.  This protects you from blowing your stack
% frame (which can cause MATLAB and/or your computer to crash).  Set the
% value to inf if you don't want this protection.
cname = computer;
if strncmp(cname,'GLNX',4)
  set(0,'RecursionLimit',100)
elseif strncmp(cname,'ALPHA',5)
  set(0,'RecursionLimit',200)
else
  set(0,'RecursionLimit',500)
end

% Set the default figure position, in pixels.
% On small screens, make figure smaller, with same aspect ratio.
screen = get(0, 'ScreenSize');
width = screen(3);
height = screen(4);
if any(screen(3:4) ~= 1)  % don't change default if screensize == [1 1]
  if all(cname(1:2) == 'PC')
    if height >= 500
      mwwidth = 560; mwheight = 420;
      if(get(0,'screenpixelsperinch') == 116) % large fonts
        mwwidth = mwwidth * 1.2;
        mwheight = mwheight * 1.2;
      end
    else
      mwwidth = 560; mwheight = 375;
    end
    left = (width - mwwidth)/2;
    bottom = height - mwheight -90;
  else
    if height > 768
      mwwidth = 560; mwheight = 420;
      left = (width-mwwidth)/2;
      bottom = height-mwheight-90;
    else  % for screens that aren't so high
      mwwidth = 512; mwheight = 384;
      left = (width-mwwidth)/2;
      bottom = height-mwheight-76;
    end
  end
  rect = [ left bottom mwwidth mwheight ];
  set(0, 'defaultfigureposition',rect);
end

colordef(0,'white') % Set up for white defaults

%% Uncomment the next group of lines to make uicontrols, uimenus
%% and lines look better on monochrome displays.
%if get(0,'ScreenDepth')==1,
%   set(0,'DefaultUIControlBackgroundColor','white');
%   set(0,'DefaultAxesLineStyleOrder','-|--|:|-.');
%   set(0,'DefaultAxesColorOrder',[0 0 0]);
%   set(0,'DefaultFigureColor',[1 1 1]);
%end

%% Uncomment the next line to use Letter paper and inches
%defaultpaper = 'usletter'; defaultunits = 'inches';

%% Uncomment the next line to use A4 paper and centimeters
%defaultpaper = 'A4'; defaultunits = 'centimeters';

%% If neither of the above lines are uncommented then guess
%% which papertype and paperunits to use based on ISO 3166 country code.
if usejava('jvm') & ~exist('defaultpaper','var')
  if any(strncmpi(char(java.util.Locale.getDefault.getCountry), ...
		  {'gb', 'uk', 'fr', 'de', 'es', 'ch', 'nl', 'it', 'ru',...
		   'jp', 'kr', 'tw', 'cn', 'cz', 'sk', 'au', 'dk', 'fi',...
           'gr', 'hu', 'ie', 'il', 'in', 'no', 'pl', 'pt',...
           'ru', 'se', 'tr', 'za'},2))
    defaultpaper = 'A4';
    defaultunits = 'centimeters';
  end
end
%% Set the default if requested
if exist('defaultpaper','var') & exist('defaultunits','var')
  % Handle Graphics defaults
  set(0,'DefaultFigurePaperType',defaultpaper);
  set(0,'DefaultFigurePaperUnits',defaultunits);
  % Simulink defaults
  set_param(0,'PaperType',defaultpaper);
  set_param(0,'PaperUnits',defaultunits);
end

%% For Japan, set default fonts
lang = lower(get(0,'language'));
if strncmp(lang, 'ja', 2)
   if strncmp(cname,'PC',2)
      set(0,'defaultuicontrolfontname',get(0,'factoryuicontrolfontname'));
      set(0,'defaultuicontrolfontsize',get(0,'factoryuicontrolfontsize'));
      set(0,'defaultaxesfontname',get(0,'factoryuicontrolfontname'));
      set(0,'defaultaxesfontsize',get(0,'factoryuicontrolfontsize'));
      set(0,'defaulttextfontname',get(0,'factoryuicontrolfontname'));
      set(0,'defaulttextfontsize',get(0,'factoryuicontrolfontsize'));

      %% You can control the fixed-width font
      %% with the following command
      % set(0,'fixedwidthfontname','MS Gothic');
   end
end

%% For the 'edit' command, to use an editor defined in the $EDITOR
%% environment variable, the following line should be uncommented
%% (UNIX only)
%system_dependent('builtinEditor','off')

%% CONTROL OVER FIGURE TOOLBARS:
%% The new figure toolbars are visible when appropriate,
%% by default, but that behavior is controllable
%% by users.  By default, they're visible in figures
%% whose MenuBar property is 'figure', when there are
%% no uicontrols present in the figure.  This behavior
%% is selected by the figure ToolBar property being
%% set to its default value of 'auto'.

%% to have toolbars always on, uncomment this:
%set(0,'defaultfiguretoolbar','figure')

%% to have toolbars always off, uncomment this:
%set(0,'defaultfiguretoolbar','none')

%% init java prefs system if java is present
if usejava('mwt')
  initprefs
end

%% Text-based preferences
NumericFormat = system_dependent('getpref','GeneralNumFormat');
if ~isempty(NumericFormat)
  eval(['format ' NumericFormat(2:end)]);
end
NumericDisplay = system_dependent('getpref','GeneralNumDisplay');
if ~isempty(NumericDisplay)
  format(NumericDisplay(2:end));
end
MaxTab = system_dependent('getpref','CommandWindowMaxCompletions');
if ~isempty(MaxTab) & MaxTab(1) == 'I'
  EnableTab = system_dependent('getpref','CommandWindowTabCompletion');
  TabSetting = strcmpi(EnableTab,'BTrue') * str2num(MaxTab(2:end));
  system_dependent('TabCompletion', TabSetting);
end
if (strcmpi(system_dependent('getpref','GeneralEightyColumns'),'BTrue'))
  feature('EightyColumns',1);
end

% Clean up workspace.
clear

% Enable/Disable selected warnings by default
warning off MATLAB:nonScalarConditional
warning on  MATLAB:namelengthmaxExceeded

%necessary for our system. see help change_notification for details
system_dependent RemotePathPolicy TimecheckDirFile;
system_dependent RemoteCWDPolicy  TimecheckDirFile;

% Turn UsingLongNames warning to detect aliasing problems with legacy
% MATLAB code.  It will warn when any name longer than 31 characters
% is used.
%
warning off MATLAB:UsingLongNames  

% Execute startup M-file, if it exists.
if (exist('startup','file') == 2)
  startup
end

% Defer echo until startup is complete
if strcmpi(system_dependent('getpref','GeneralEchoOn'),'BTrue')
  echo on
end
