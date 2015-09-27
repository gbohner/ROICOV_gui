function main(task, varargin)
% % Main function

timestamp = datestr(now,30);

tmp = load([ fileparts(mfilename('fullpath')) '/tmp/tmp.mat']); %contains selected files and their directory


%Create options based on the latest edited options file or load saved one
%if specified
if nargin < 2
  opt = set_opt; %Create the opt structure based on current "set_opt.m".
else
  opt = load(varargin{1}); %Load past option file
end

switch task
  case 'preprocess'
    if ~isdir([tmp.workdir 'Preprocessed']), mkdir(tmp.workdir, 'Preprocessed'); end;
    
    %Save the current timestamp for further processing
    tmp.timestamp = timestamp; 
    save([fileparts(mfilename('fullpath')) '/tmp/tmp.mat'], '-struct', 'tmp');
    
    % Extract data with the current options file from all currently chosen
    % files
    for i1 = 1:numel(tmp.ToLoad)
      extractDataFromTif([tmp.workdir tmp.ToLoad{i1}], [tmp.workdir 'Preprocessed' filesep tmp.ToLoad{i1}(1:end-4) timestamp '.mat'],opt);
    end
    
  case 'learn'
    %% Try learning with preprocessed files with the current timestamp, if
    %they don't exist then ask the user to choose a set of files sharing
    %the same timestamp.
    clear tmp
    tmp = load([ fileparts(mfilename('fullpath')) '/tmp/tmp.mat']);
    answer = 'No';
    if ~isempty(dir([tmp.workdir 'Preprocessed/*' tmp.timestamp '*']))
      %Use the current set of preprocessed files?
      answer = questdlg('Use the current set of files?', 'Choose files','Yes','No','No');
    end
    
    %Choose timestamp for files to be learned from manually and save in
    %tmp.timestamp
    if strcmp(answer,'No') 
      l = dir([tmp.workdir 'Preprocessed/*T*.mat']); %find all timestamps
      for i1 = 1:numel(l);
        A(i1,:) = l(i1).name(end-18:end-4);
      end
      A = unique(A,'rows');
      A = sortrows(A);
%       A = mat2cell(A,ones(size(A,1)));
      h_popup = figure('MenuBar','none','Toolbar','none','Visible','on','Name','Choose timestamp',...
      'Position',[600 600 200 150]);
      h_timechoice = uicontrol('Parent', h_popup,'Style','popupmenu','String',A,...
      'Units', 'pixels', 'Position', [0 100 200 30],'Visible','on');
    
      %TODO Possibly implement an other window, which loads the options
      %from the relevant timestamp and displays most important settings (like window
      %size and number of cells in learning)
      
      h_timeok = uicontrol('Parent', h_popup,'Style','pushbutton','String','Ok',...
      'Units', 'pixels', 'Position', [50 20 100 50],'Visible','on','Callback',@track_callback);
      uiwait(h_popup); %During the callback tmp.timestamp is set correctly.
      
      l = dir([tmp.workdir 'Preprocessed/*' tmp.timestamp '*.mat']);
      tmp.ToLoad = cell(numel(l),1);
      for i1 = 1:numel(l);
        tmp.ToLoad{i1} = [l(i1).name(1:end-19) '.tif'];
      end
    end
    
    %% Now that we made sure there are definitely preprocessed files to learn
    %from, move on to learning
    Model_learn(tmp);
    
    
  case 'infer'
    clear tmp
    tmp = load([ fileparts(mfilename('fullpath')) '/tmp/tmp.mat']);
    
    %% Choose the files used for inference (should be same type of recording
    %we learned from)
    answer = 'No';
    if ~isempty(dir([tmp.workdir 'Preprocessed/*' tmp.timestamp '*']))
      %Use the current set of preprocessed files?
      answer = questdlg('Use the latest set of files?', 'Choose files','Yes','No','No');
    end
    
    %Choose timestamp for files to be learned from manually and save in
    %tmp.timestamp
    if strcmp(answer,'No') 
      l = dir([tmp.workdir 'Preprocessed/*T*.mat']); %find all timestamps
      for i1 = 1:numel(l);
        A(i1,:) = l(i1).name(end-18:end-4);
      end
      A = unique(A,'rows');
      A = sortrows(A);
%       A = mat2cell(A,ones(size(A,1)));
      h_popup = figure('MenuBar','none','Toolbar','none','Visible','on','Name','Choose timestamp',...
      'Position',[600 600 200 150]);
      h_timechoice = uicontrol('Parent', h_popup,'Style','popupmenu','String',A,...
      'Units', 'pixels', 'Position', [0 100 200 30],'Visible','on');
    
      %TODO Possibly implement an other window, which loads the options
      %from the relevant timestamp and displays most important settings (like window
      %size and number of cells in learning)
      
      h_timeok = uicontrol('Parent', h_popup,'Style','pushbutton','String','Ok',...
      'Units', 'pixels', 'Position', [50 20 100 50],'Visible','on','Callback',@track_callback);
      uiwait(h_popup); %During the callback tmp.timestamp is set correctly.
      
      l = dir([tmp.workdir 'Preprocessed/*' tmp.timestamp '*.mat']);
      tmp.ToLoad = cell(numel(l),1);
      for i1 = 1:numel(l);
        tmp.ToLoad{i1} = [l(i1).name(1:end-19) '.tif'];
      end
    end
    
    %% Select the model to use (default choice is going to be the one with
    % current timestep and highest iteration number, just click select if
    % it's good)
    %Find all models, and select the appropriate one as default choice
    try
      l = dir([tmp.workdir 'Model/model*' tmp.timestamp '*.mat']);
      for i1 = 1:numel(l)
        k = findstr(l(i1).name,'iter');
        k = k(end);
        A(i1) = str2num(l(i1).name((k+4):(end-4)));
      end
      k = find(A==max(A),1); %highest iteration number   
      default_name = [tmp.workdir 'Model/' l(k).name];
    catch
      default_name = [tmp.workdir 'Model/'];
    end
      
    
    [FileName,PathName,FilterIndex] = uigetfile('model*.mat','Load TIF files',default_name,'MultiSelect','off');
    tmp.model = [PathName FileName];
    
    % Select number of cells to infer (make sure to overestimate)
    ans = inputdlg('Select number of cells to infer (make sure to overestimate)', 'Number of cells',1,{'100'});
    tmp.infer_num = str2num(ans{1});
    
    %Now that we made sure there are definitely preprocessed files to learn
    %from, move on to learning
    Inference(tmp);

end

%{


%% Step 3 - Inference using a learned model and preprocessed data
model_path = '/nfs/data3/gergo/Fhatarah/Results/m10039RhemA24b/inference_model.mat';
[ y, x_coord, y_coord, dLL ] = Inference(data_path, model_path,  output_folder, ...
  struct('cells_per_image',400) ...
  );

end

%% Step 4 - copy and collect all results into appropriate folder
input_folder = '/nfs/data3/gergo/Fhatarah';
allfiles = dir([input_folder '/*.tif']);
for i1 = 1:size(allfiles,1)
  input_path = [input_folder '/' allfiles(i1).name];
  nospacefname = allfiles(i1).name(~isspace(allfiles(i1).name));
  output_folder = [input_folder '/Results/' nospacefname(1:end-4)];
  res_files = dir([output_folder '/inference*T*.mat']);
  cur_result_file = [output_folder '/' res_files(1).name];
  load(cur_result_file, 'y_orig', 'x_coord', 'y_coord', 'dLL');
  plot(dLL, 'Color', [mod(i1,2),1-mod(i1,2),0])
  hold on;
  xlabel('Object number'); ylabel('delta Log Likelihood');
%   figure; imagesc(y_orig); colormap(gray);
%   hold on;
%   scatter(x_coord(1:150), y_coord(1:150), 55, 'r.');
%   scatter(x_coord(151:300), y_coord(151:300), 55, 'g.');
%   pause;
%   fileID = fopen([input_folder '/Results/' allfiles(i1).name(1:end-4) '.txt'],'w');
%   for i2 = 1:length(x_coord)
%     fprintf(fileID,'%d %d %5.3f\n', x_coord(i2), y_coord(i2), dLL(i2));
%   end
%   fclose(fileID);
%   
%   copyfile(cur_result_file, [input_folder '/Results/' allfiles(i1).name(1:end-4) '.mat']);
end

legend({allfiles.name}, 'Location', 'SouthEast')


%Visualize inference results
% figure; imagesc(y); colormap(gray);
% hold on;
% scatter(x_coord(1:150), y_coord(1:150), 55, 'r.');
% scatter(x_coord(151:300), y_coord(151:300), 55, 'g.');
% 
% figure; plot(dLL); xlabel('Object number'); ylabel('Delta Log Likelihood');
%}

%% Callbacks
  % Callback for timestamp chosen
  function track_callback(hObj, varargin)
    num = get(h_timechoice, 'Value');
    strlist = get(h_timechoice,'String');
    tmp.timestamp = strlist(num,:);
    closereq;
  end
end