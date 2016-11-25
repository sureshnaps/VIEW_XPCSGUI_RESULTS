function settings = settings_viewresult(nBatch)
% --- plot settings
% general settings
settings.PlotMode           = 1;    % 1/2: individual batch / averaged batches for dynamics. Default:1
settings.PlotImageScale     = 2;    % 1/2: linear/log10 for plotting averaged images. Default:1
settings.Batch              = [nBatch];% Batch numbers to plot. Call be multiple batches. Default: 1
% for static 
settings.StaticSelect       = 1;    % 1/2: plot I vs q/phi. Default: 1
settings.StaticSelectQ      = 1;    % PHI column where q will be plotted. Valid when StaticSelect=1. Default: 1
settings.StaticSelectPHI    = 1;    % Q row where phi will be plotted. Valid when StaticSelect=2. Default: 1
settings.StaticXScale       = 1;    % 1/2: linear/log10 for x-axis scale. Default: 1
% for dynmaic (can be left void for static plots only)
settings.G2Panel = 9;               % Total subplots in one g2 figures. G2Panel=G2PanelRow*G2PanelCol. Default: 9
settings.G2PanelRow = 3;            % Number of subplot rows in one g2 figure. Default: 3
settings.G2PanelCol = 3;            % Number of subplot coumns in one g2 figure. Default: 3
settings.DynamicFigPos = [100,50,960,720];      % Position and size for dynamic figures
settings.DynamicSelect = 1;         % 1/2: plot vs q/phi. Default: 1
settings.DynamicSelectQ = 1;        % PHI column where q will be plotted. Valid when DynamicSelect=1. Default: 1
settings.DynamicSelectPHI = 1;      % Q row where phi will be plotted. Valid when DynamicSelect=2. Default: 1
settings.DynamicG2XScale = 2;         % 1/2: linear/log10 for x-axis (g2 plots). Default: 2
settings.DynamicXScale = 1;         % 1/2: linear/log10 for x-axis (not for g2 plots). Default: 2
settings.DynamicG2PlotErrorbars = 1;    % 1/2 Yes/No for plotting g2 errorbars?. Default: 1
settings.DynamicNumberOfG2Figures = Inf;
settings.DynamicFitting = 3;        % 1/2/3/4: display single/stretched/both/none fittings. Default: 3
return;

% --- load data, set settings and open GUI
%viewresult('z_test_PS454nmPDMS_70C_1_result.mat',settings);
%viewresult('z_test_PS454nmPDMS_70C_1_result.mat');


% % % % viewresult('PSe127nm_110C_1_20100728T142352_result_mrg.mat',settings);

%viewresult('PSe127nm_110C_1_20100728T142352_result.mat');
%return;

% % % % hFigViewresult = findall(0,'Tag','viewresult_Fig');     % GUI handle

%set(findall(0,'Tag','viewresult_Fig'),'visible','off'); % set GUI invisible
%set(findall(0,'Tag','viewresult_Fig'),'visible','on'); % set GUI visible
%return;
% --- plot
 %feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonPlotAll'),'callback'));      % all against current settings
% feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonPlotAvgImage'),'callback'));   % averaged images
% feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonPlotTotalInt'),'callback'));   % total intensity
% feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonPlotStability'),'callback'));   % stability
% feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonPlotStatic'),'callback'));     % static
% feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonPlotDynamic'),'callback'));     % plot Dynamic

%feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonOverlayPlotDynamic'),'callback'));     % Overlay plot Dynamic
%feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonAvgDynamic'),'callback'));     % batch average dynamic result
%feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonPlotAvgDynamic'),'callback'));     % plot batch average dynamic result
%feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonAvgAndPlotDynamic'),'callback'));     % average and plot 
% feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonExportAvgDynamic'),'callback'),...
%     '','','zzzz.mat');     % export averaged dynamic result. Last input argument is the file name (including path) to be saved; the input arguments can be left none and the default file name will be used with '_avg' added to the end of the file name.

% --- close all the plot figure
%feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonCloseAll'),'callback'));


%delete(findall(0,'Tag','viewresult_Fig'));              % delete GUI
