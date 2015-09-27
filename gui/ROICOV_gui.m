function varargout = ROICOV_gui()
%ROICOV_GUI Create simple gui to easily access functionality

  

  % Load temp files
  cur_dir = mfilename('fullpath'); %file's directory
  bla = strfind(cur_dir,'/'); 
  cur_dir = cur_dir(1:(bla(end-1))); % Get path to main folder
  addpath(genpath(cur_dir)); %Add whole folder to matlab path
  if exist([ cur_dir 'tmp/tmp.mat'],'file')
    tmp = load([ cur_dir 'tmp/tmp.mat']); %Load previous run settings to initialize
  else %Create fresh tmp folder and file
    mkdir(cur_dir, 'tmp');
    tmp.workdir = cur_dir;
    save([cur_dir 'tmp/tmp.mat'],'-struct','tmp');
  end

  %Create gui window
  h_figure = figure('MenuBar','none','Toolbar','none','Visible','on','Name','ROICOV',...
   'Position',[300 400 200 500], 'CloseRequestFcn', @close_callback,'Color',[0.7608, 0.8392, 0.8549]);

  %Button for selecting a new set of files
  h_selectfiles = uicontrol('Parent', h_figure,'Style','pushbutton','String','Select files',...
   'Units', 'pixels', 'Position', [0 400 200 100],'Callback',@selectfiles_callback,...
   'Visible','on');
 
  %Button for selecting a new set of files
  h_setsettings = uicontrol('Parent', h_figure,'Style','pushbutton','String','Set settings',...
   'Units', 'pixels', 'Position', [0 300 200 100],'Callback',@setsettings_callback,...
   'Visible','on'); 
 
  %Preprocess the set of files with the selected options
  h_preprocess = uicontrol('Parent', h_figure,'Style','pushbutton','String','Preprocess',...
   'Units', 'pixels', 'Position', [0 200 200 100],'Callback',@preprocess_callback,...
   'Visible','on'); 
 
  %Button for selecting a new set of files
  h_learnmodel = uicontrol('Parent', h_figure,'Style','pushbutton','String','Learn Model',...
   'Units', 'pixels', 'Position', [0 100 200 100],'Callback',@learnmodel_callback,...
   'Visible','on');
 
 
  %Button for selecting a new set of files
  h_infer = uicontrol('Parent', h_figure,'Style','pushbutton','String','Infer cell positions',...
   'Units', 'pixels', 'Position', [0 0 200 100],'Callback',@infer_callback,...
   'Visible','on');
 
 %% Callbacks
   %On close
   function close_callback(varargin)
      if numel(varargin)>0 && strcmp(varargin{1},'Reset')
         clear global
         clear
         closereq
      else        
%          answer = questdlg('Are you sure you want to quit?', 'Quit','Yes','No','No');
%          if strcmp(answer,'Yes')
%             clear global
%             clear
%             closereq
%          end
         clear
         closereq
      end
   end
 
  % Select files
  function selectfiles_callback(varargin)
    [FileName,PathName,FilterIndex] = uigetfile('*.tif','Load TIF files',tmp.workdir,'MultiSelect','on');
      if PathName == 0
        warndlg('No file was chosen, stopping function.');
        return;
      end
      ToLoad = {};
      if iscell(FileName)
         for r1 = 1:numel(FileName)
            ToLoad(r1) = FileName(r1);
         end
      else
         ToLoad{1} = FileName;
      end
      
      tmp.workdir = PathName;
      tmp.ToLoad = ToLoad;
      save([cur_dir '/tmp/tmp.mat'],'-struct','tmp')
  end

  % Set processing settings
  function setsettings_callback(varargin)
    edit([cur_dir '/set_opt.m']); %Make sure to manually save the file
  end

  function preprocess_callback(varargin)
    main('preprocess');
  end


  % Select files
  function learnmodel_callback(varargin)
    main('learn');
  end

  % Select files
  function infer_callback(varargin)
    main('infer');
  end

  
 
end

