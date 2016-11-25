function viewresult(varargin)
% VIEWRESULT Choose options to display previously analyzed XPCSGUI results
%   VIEWRESULT opens GUI interface.
%
%   VIEWRESULT('FILE') open GUI interface and load FILE with default settings.
%
%   VIEWRESULT('FILE',SETTINGS) open GUI interface and load FILE and SETTINGS.
%       See readme_viewresult.m for setting instructions.
%
%   Note: needs varycolor.m, supertitle.m, findjobj.m, errorbarlogy.m,
%   errorbarlogx.m

% $Revision: 1.0 $  $Date: 2006/01/12 $ by Michael Sprung
% $Revision: 2.0 $  $Date: 2010/09/10 $ by Zhang Jiang
%       Interactive display
% $Revision: 2.1 $  $Date: 2011/03/31 $ by Zhang Jiang 
%       1) Update overlay plot to display result of different q/phi lists
%       2) Rearrange GUI layout
%       3) Use general plot function for dynamic plot
%
% $Revision: 2.2 $ $Date: 2012/09/18 $ by Suresh
%       1) New Hadoop cluster saves results into a HDF5 file
%       2) Added a simple switch and functionlity to read mat or hdf files
%       3) Current hdf file does not contain the fits to results, so this
%          is added using a function and the results are saved back to the
%          hdf5 file so that the next time, the fit is not done again.
%
% $Revision: 2.3 $ $Date: 2014/07/07 $  by Zhang
%       1) Add more plot options such as G2 error bar, none G2 fitting
%           display etc.
%       2) Plotting settings are kept when loading new result.
%
% $Revision: 2.4 $ $Date: 2014/12/16 $  by Zhang
%       1) Fix PlotSelection bug.
%       2) New GUI to load files
%
% $Revision: 2.5 $ $Date: 2015/03/2 $  by Zhang
%       1) Fix Compatibility problems with Matlab 2014b and later
%
% $Revision: 2.6 $ $Date: 2016/04/07 $  by Zhang
%       1) Added a field to pick the number of G2 panels so the screen is
%       not cluttered with noisy g2 plots


%% warning messages off
warning('off','MATLAB:Axes:NegativeDataInLogAxis');

%% determine input and load results if input is nonzero
if nargin > 2, error('Incorrect input argument'); end

if nargin ~= 0
    if ~isstruct(varargin{1}) %%regular file name
        file = varargin{1};
        [udata,viewresultinfo] = read_mat_or_hdf_resultfile(file);
    else %input is already a viewresultinfo kind of struct with the results
        viewresultinfo=varargin{1};%%could pass viewresultinfo
        file='null';
        udata.filepath='';
        udata.filename=file;
        udata.fileext='';
        udata.file=file;
        udata.result=viewresultinfo.result;
    end
end

if nargin == 2, udata.settings = varargin{2}; end

%% determin if figure exists
hFigViewresult = findall(0,'Tag','viewresult_Fig');
if ~isempty(hFigViewresult)
    if nargin == 0
        figure(hFigViewresult);
    else
        if nargin == 1
            udata0 = get(hFigViewresult,'UserData');        
            udata.settings = udata0.settings;            
        end
        set(hFigViewresult,'UserData',udata);
        setappdata(hFigViewresult,'viewresultinfo',viewresultinfo);
        viewresult_initialize(hFigViewresult);
        figure(hFigViewresult);
    end
    return;
end

%% main figure properites
backgroundcolor = [1 1 0.85];
facecolor = [1 1 0.9];
textcolor = [0.4 0.3 0];
subtextcolor = 'b';
figureSize = [800 540];
screenSize = get(0,'ScreenSize');
figurePos  = [screenSize(3)-figureSize(1)-5 50 figureSize];
hFigViewresult = figure(...
    'BackingStore','on',...
    'Units','pixels',...
    'Position',figurePos,...
    'DockControls','off',...
    'Resize','off',...
    'PaperOrient','portrait',...
    'PaperPositionMode','auto',...
    'IntegerHandle','off',...
    'NumberTitle','off',...
    'MenuBar','none',...
    'Toolbar','none',...
    'CloseRequestFcn',@viewresult_CloseRequestFcn,...
    'Name','XPCS - Plot XPCS Result',...
    'WindowStyle','normal',...
    'HandleVisibility','callback',...
    'Tag','viewresult_Fig','UserData',[]);
hAxes = axes('Parent',hFigViewresult,...
    'Units','pixels',...
    'Position',[0 0 figureSize],...
    'Tag','viewresult_Axes');
hPatchMain = patch('Parent',hAxes,'XData',[0 1 1 0],'YData',[0 0 1 1],'FaceColor',backgroundcolor,'EdgeColor',backgroundcolor);
text('Parent',hAxes,'Position',[0.5 0.965],'HorizontalAlignment','center','String','Plot XPCS Result','FontSize',12,'FontWeight','demi','color',[0.4 0.3 0]);
hGroupPatch = hggroup('Parent',hAxes);
hGroupSubPatch = hggroup('Parent',hAxes);
hGroupPatchTitleText    = hggroup('Parent',hAxes);
hGroupText   = hggroup('Parent',hAxes);
hGroupTextCenter   = hggroup('Parent',hAxes);
hPatchLoad = patch('Parent',hGroupPatch,'XData',[0.02 0.98 0.98 0.02],'YData',[0.8 0.8 0.925 0.925]);
hPatchSelectBatch = patch('Parent',hGroupPatch,'XData',[0.02 0.12 0.12 0.02],'YData',[0.09 0.09 0.7375 0.7375]);
hPatchImg = patch('Parent',hGroupPatch,'XData',[0.14 0.55 0.55 0.14],'YData',[0.6375 0.6375 0.7375 0.7375]);
hPatchStatic = patch('Parent',hGroupPatch,'XData',[0.14 0.55 0.55 0.14],'YData',[0.09 0.09 0.615 0.615]);
hPatchDynamic = patch('Parent',hGroupPatch,'XData',[0.57 0.98 0.98 0.57],'YData',[0.09 0.09 0.7775 0.7775]);
set(get(hGroupPatch,'Children'),'FaceColor',backgroundcolor+[0 0 0.05],'EdgeColor',[0.7 0.7 0.7]);

%% load panel
text('Parent',hGroupPatchTitleText,...
    'Position',[0.04 0.925],...
    'String','Load Results');
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Load ...',...
    'Position',[0.025 0.855 0.08 0.04],...
    'Tag','viewresult_PushbuttonLoad',...
    'TooltipString','Load *.mat/*.hdf result file',...
    'callback',@viewresult_PushbuttonLoadCallbackFcn);
uicontrol('Parent',hFigViewresult,...
    'style','Edit',...
    'Units','normalized',...
    'backgroundcolor','w',...
    'String','',...
    'HorizontalAlignment','left',...
    'Enable','on',...
    'Position',[0.12 0.86 0.85 0.035],...
    'Tag','viewresult_EditFile',...
    'callback',@viewresult_EditFileFcn);
%%
%Seems like was disabled for a long time, legacy feature, commenting now
%(August 2016). Will remove it at a later date
%
% % text('Parent',hGroupText,'Position',[0.03 0.835],'String','Plot Mode');
% % uicontrol('Parent',hFigViewresult,...
% %     'Style','Popupmenu',...
% %     'Units','normalized',...
% %     'Position',[0.12 0.8175 0.2 0.035],...
% %     'HorizontalAlignment',...
% %     'right','backgroundcolor','w',...
% %     'Enable','off',...
% %     'String',{'Individual batch','Average batches (dynamic)'},...
% %     'callback',@viewresult_savesettings,...
% %     'Tag','viewresult_PopupmenuPlotMode');

%% Panel for select batches
text('Parent',hGroupPatchTitleText,...
    'Position',[0.04 0.7375],...
    'String','Batches');
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Select All',...
    'Position',[0.03 0.68 0.08 0.04],...
    'Tag','viewresult_PushbuttonSelectAllBatches',...
    'TooltipString','Select all batches',...
    'callback',@viewresult_PushbuttonSelectAllBatchesFcn);
uicontrol('Parent',hFigViewresult,...
    'Style','listbox',...
    'Units','normalized',...
    'Position',[0.02 0.0875 0.1 0.585],...
    'backgroundcolor','w',...
    'Min',1,'Max',10,...
    'String',1,'Enable','on',...
    'value',[],...
    'Tag','viewresult_ListboxBatch',...
    'callback',@viewresult_ListboxBatchFcn);


%% Panel for averaged image and average intensity
text('Parent',hGroupPatchTitleText,...
    'Position',[0.16 0.7375],...
    'String','Image');
text('Parent',hGroupText,'Position',[0.15 0.7075],'String','Averaged Image');
uicontrol('Parent',hFigViewresult,...
    'Style','Popupmenu',...
    'Units','normalized',...
    'Position',[0.37 0.69 0.08 0.035],...
    'HorizontalAlignment','right',...
    'backgroundcolor','w',...
    'String',{'Linear','Log10'},...
    'value',1,...
    'Enable','on',...
    'callback',@viewresult_savesettings,...
    'Tag','viewresult_PopupmenuImageScale');
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Plot',...
    'Position',[0.46 0.685 0.08 0.04],...
    'Tag','viewresult_PushbuttonPlotAvgImage',...
    'TooltipString','Plot averaged image',...
    'callback',@viewresult_PushbuttonPlotAvgImageFcn);
text('Parent',hGroupText,'Position',[0.15 0.6675],'String','Total Intensity');
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Plot',...
    'Position',[0.46 0.645 0.08 0.04],...
    'Tag','viewresult_PushbuttonPlotTotalInt',...
    'TooltipString','Plot total intensity vs. time',...
    'callback',@viewresult_PushbuttonPlotTotalIntFcn);


%% Panel for static
text('Parent',hGroupPatchTitleText,...
    'Position',[0.16 0.615],...
    'String','Static');
text('Parent',hGroupText,'Position',[0.15 0.585],'String','Partition');
uicontrol('Parent',hFigViewresult,...
    'Style','Popupmenu',...
    'Units','normalized',...
    'Position',[0.26 0.5675 0.08 0.035],...
    'HorizontalAlignment','right',...
    'backgroundcolor','w',...
    'String',{'Q (col)','Phi (row)'},...
    'value',1,...
    'Enable','on',...
    'callback',@viewresult_PopupmenuStaticSelectFcn,...
    'Tag','viewresult_PopupmenuStaticSelect');
text('Parent',hGroupText,'Position',[0.15 0.545],'String','X Axis Scale');
uicontrol('Parent',hFigViewresult,...
    'Style','Popupmenu',...
    'Units','normalized',...
    'Position',[0.26 0.525 0.08 0.035],...
    'HorizontalAlignment','right',...
    'backgroundcolor','w',...
    'String',{'Linear','Log10'},...
    'Enable','on',...
    'value',1,...
    'callback',@viewresult_savesettings,...
    'Tag','viewresult_PopupmenuStaticXScale');
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Stability Plot',...
    'Position',[0.38 0.5625 0.16 0.04],...
    'Tag','viewresult_PushbuttonPlotStability',...
    'TooltipString','Stability plot',...
    'callback',@viewresult_PushbuttonPlotStabilityFcn);
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Plot',...
    'Position',[0.46 0.5225 0.08 0.04],...
    'Tag','viewresult_PushbuttonPlotStatic',...
    'TooltipString','Plot static result',...
    'callback',@viewresult_PushbuttonPlotStaticFcn);
uitable('Parent',hFigViewresult,...
    'Units','normalized',...
    'Tag','viewresult_tableStatic',...
    'CellSelectionCallback',@viewresult_TableStaticCellSelectionCallback,...
    'Interruptible','off',...
    'Position',[0.14,0.0875,0.41,0.42]);

%% panel for dynamic
text('Parent',hGroupPatchTitleText,...
    'Position',[0.59 0.7775],...
    'String','Dynamic');
text('Parent',hGroupText,'Position',[0.58 0.7475],'String','Partition');
uicontrol('Parent',hFigViewresult,...
    'Style','Popupmenu',...
    'Units','normalized',...
    'Position',[0.69 0.73 0.08 0.035],...
    'HorizontalAlignment','right',...
    'backgroundcolor','w',...
    'String',{'Q (col)','Phi (row)'},...
    'value',1,...
    'Enable','on',...
    'callback',@viewresult_PopupmenuDynamicSelectFcn,...
    'Tag','viewresult_PopupmenuDynamicSelect');
text('Parent',hGroupText,'Position',[0.58 0.7075],'String','G2 X Axis');
uicontrol('Parent',hFigViewresult,...
    'Style','Popupmenu',...
    'Units','normalized',...
    'Position',[0.69 0.6875 0.08 0.035],...
    'HorizontalAlignment','right',...
    'backgroundcolor','w',...
    'String',{'Linear','Log10'},...
    'value',2,...
    'Enable','on',...
    'callback',@viewresult_savesettings,...
    'Tag','viewresult_PopupmenuDynamicG2XScale');
text('Parent',hGroupText,'Position',[0.79 0.7475],'String','Fit Display');
uicontrol('Parent',hFigViewresult,...
    'Style','Popupmenu',...
    'Units','normalized',...
    'Position',[0.89 0.73 0.08 0.035],...
    'HorizontalAlignment','right',...
    'backgroundcolor','w',...
    'String',{'Simple Exp','Stretched Exp','Both','None'},...
    'value',3,...
    'Enable','on',...
    'callback',@viewresult_savesettings,...
    'Tag','viewresult_PopupmenuDynamicFitting');
text('Parent',hGroupText,'Position',[0.79 0.7075],'String','G2 Errorbars');
uicontrol('Parent',hFigViewresult,...
    'Style','Popupmenu',...
    'Units','normalized',...
    'Position',[0.89 0.6875 0.08 0.035],...
    'HorizontalAlignment','right',...
    'backgroundcolor','w',...
    'String',{'Yes','No'},...
    'value',1,...
    'Enable','on',...
    'callback',@viewresult_savesettings,...
    'Tag','viewresult_PopupmenuDynamicG2PlotErrorbars');
text('Parent',hGroupText,'Position',[0.58 0.66],'String','Q/Phi Axis');
uicontrol('Parent',hFigViewresult,...
    'Style','Popupmenu',...
    'Units','normalized',...
    'Position',[0.69 0.6425 0.08 0.035],...
    'HorizontalAlignment','right',...
    'backgroundcolor','w',...
    'String',{'Linear','Log10'},...
    'value',2,...
    'Enable','on',...
    'callback',@viewresult_savesettings,...
    'Tag','viewresult_PopupmenuDynamicXScale');
% --- option to limit # of figures
text('Parent',hGroupText,'Position',[0.79 0.66],'String','# of G2 Figs');
uicontrol('Parent',hFigViewresult,...
    'style','Edit',...
    'Units','normalized',...
    'backgroundcolor','w',...
    'String','Inf',...
    'HorizontalAlignment','left',...
    'Enable','on',...
    'Position',[0.89 0.6425 0.08 0.035],...
    'Tag','viewresult_EditNumberOfG2Figures',...
    'callback',@viewresult_EditNumberOfG2FiguresFcn);
% --- for individual plot
text('Parent',hGroupText,'Position',[0.58 0.62],'String','Individual Batches'); % 0.6675
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Overlay Plot',...
    'Position',[0.77 0.595 0.11 0.04],...
    'Tag','viewresult_PushbuttonOverlayPlotDynamic',...
    'TooltipString','Overlay plot dynamic result',...
    'callback',@viewresult_PushbuttonOverlayPlotDynamicFcn);        % 0.6425
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Plot',...
    'Position',[0.89 0.595 0.08 0.04],...
    'Tag','viewresult_PushbuttonPlotDynamic',...
    'TooltipString','Plot dynamic result',...
    'callback',@viewresult_PushbuttonPlotDynamicFcn);   % 0.6425
% --- for average
text('Parent',hGroupText,'Position',[0.58 0.58],'String','Averaged Batches');  %0.6275
uicontrol('Parent',hFigViewresult,...
    'style','Edit',...
    'Units','normalized',...
    'backgroundcolor','w',...
    'String','',...
    'HorizontalAlignment','right',...
    'Enable','inactive',...
    'Position',[0.59 0.5175 0.2 0.035],...
    'Tag','viewresult_EditBatches2average'); % 0.565
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Average',...
    'Position',[0.8 0.5145 0.08 0.04],...
    'Tag','viewresult_PushbuttonAvgDynamic',...
    'TooltipString','Average dynamic result',...
    'callback',@viewresult_PushbuttonAvgDynamicFcn);    % 0.5625
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Plot',...
    'Position',[0.89 0.5145 0.08 0.04],...
    'Tag','viewresult_PushbuttonPlotAvgDynamic',...
    'TooltipString','Plot averaged dynamic result',...
    'callback',@viewresult_PushbuttonPlotAvgDynamicFcn); % 0.5625
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Average & Plot',...
    'Position',[0.8 0.4745 0.17 0.04],...
    'Tag','viewresult_PushbuttonAvgAndPlotDynamic',...
    'TooltipString','Average & plot dynamic result',...
    'callback',@viewresult_PushbuttonAvgAndPlotDynamicFcn); %0.5225
uicontrol('Parent',hFigViewresult,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Export ...',...
    'Position',[0.59 0.4745 0.1 0.04],...
    'Tag','viewresult_PushbuttonExportAvgDynamic',...
    'TooltipString','Export averaged dynamic result',...
    'callback',@viewresult_PushbuttonExportAvgDynamicFcn); %0.5225

uitable('Parent',hFigViewresult,...
    'Units','normalized',...
    'Tag','viewresult_tableDynamic',...
    'CellSelectionCallback',@viewresult_TableDynamicCellSelectionCallback,...
    'Interruptible','off',...
    'Position',[0.5675,0.0875,0.4125,0.372]);

%% layout of close and plot buttons for all
uicontrol(hFigViewresult,'Style','pushbutton',...
    'Units','normalized',...
    'String','Restore Default',...
    'position',[0.02 0.02 0.125 0.05],...
    'Tag','viewresult_PushbuttonRestoreDefault',...
    'TooltipString','Restore default settings',...
    'callback',@viewresult_PushbuttonRestoreDefaultFcn);
uicontrol(hFigViewresult,'Style','pushbutton',...
    'Units','normalized',...
    'String','Plot All',...
    'position',[0.155 0.02 0.125 0.05],...
    'Tag','viewresult_PushbuttonPlotAll',...
    'TooltipString','Plot all figures',...
    'callback',@viewresult_PushbuttonPlotAllFcn);
uicontrol(hFigViewresult,'Style','pushbutton',...
    'Units','normalized',...
    'String','Close All',...
    'position',[0.29 0.02 0.125 0.05],...
    'Tag','viewresult_PushbuttonCloseAll',...
    'TooltipString','Close all displayed results',...
    'callback',@viewresult_PushbuttonCloseAllFcn);
uicontrol(hFigViewresult,'Style','pushbutton',...
    'Units','normalized','String','Close',...
    'position',[0.85 0.02 0.125 0.05],...
    'Tag','viewresult_PushbuttonClose',...
    'TooltipString','Close window',...
    'callback',@viewresult_CloseRequestFcn);

%% set group properties
set(get(hGroupPatchTitleText,'Children'),...
    'Units','normalized',...
    'Fontsize',9,...
    'HorizontalAlignment','left',...
    'BackgroundColor',backgroundcolor,...
    'Color',[0.4 0.3 0]);
set(get(hGroupText,'Children'),...
    'Units','normalized',...
    'Fontsize',10,...
    'HorizontalAlignment','left',...
    'Color','b');
set(get(hGroupTextCenter,'Children'),...
    'Units','normalized',...
    'Fontsize',10,...
    'HorizontalAlignment','center',...
    'Color','b');

%% initialize figure
if nargin == 1 || nargin == 2
    set(hFigViewresult,'UserData',udata);
    setappdata(hFigViewresult,'viewresultinfo',viewresultinfo);
    viewresult_initialize(hFigViewresult);
else
    viewresult_PushbuttonLoadCallbackFcn;
    udata = get(hFigViewresult,'UserData');
    if ~isfield(udata,'file'),viewresult_CloseRequestFcn; return; end
end
figure(hFigViewresult);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function viewresult_initialize(hFigViewresult)
udata = get(hFigViewresult,'UserData');
set(findobj(hFigViewresult,'tag','viewresult_EditFile'),'String',udata.file);
batchlist = [];
for ii=1:length(udata.result.aIt)
    if ~isempty(udata.result.aIt{ii})
        batchlist = [batchlist,ii]; %#ok<AGROW>
    end
end
if isfield(udata,'settings') == 0
%     udata.settings.PlotMode           = 1;
    udata.settings.PlotImageScale     = 1;
    udata.settings.Batch              = batchlist(1);
    udata.settings.StaticSelect       = 1;
    udata.settings.StaticSelectQ      = 1;
    udata.settings.StaticSelectPHI    = 1;
    udata.settings.StaticXScale       = 1;
    if isfield(udata.result,'dynamicQs')
        udata.settings.G2Panel = 9;
        udata.settings.G2PanelRow = 3;
        udata.settings.G2PanelCol = 3;
        udata.settings.DynamicFigPos = [100,50,960,720];
        udata.settings.DynamicSelect = 1;
        udata.settings.DynamicSelectQ = 1;
        udata.settings.DynamicSelectPHI = 1;
        udata.settings.DynamicXScale = 2;
        udata.settings.DynamicG2XScale = 2;
        udata.settings.DynamicFitting = 3;
        udata.settings.DynamicG2PlotErrorbars = 1;
        udata.settings.DynamicNumberOfG2Figures = Inf;
    end
else
    udata.settings.StaticSelectQ      = 1;
    udata.settings.StaticSelectPHI    = 1; 
    if isfield(udata.result,'dynamicQs')
        udata.settings.DynamicSelectQ = 1;
        udata.settings.DynamicSelectPHI = 1;        
    end
end
udata.settings.Batch              = batchlist(1);
set(hFigViewresult,'UserData',udata);    
% set(findobj(hFigViewresult,'tag','viewresult_PopupmenuPlotMode'),'value',udata.settings.PlotMode);
set(findobj(hFigViewresult,'tag','viewresult_ListboxBatch'),'String',batchlist);
set(findobj(hFigViewresult,'tag','viewresult_ListboxBatch'),'value',udata.settings.Batch);
set(findobj(hFigViewresult,'tag','viewresult_PopupmenuImageScale'),'value',udata.settings.PlotImageScale);
% --- for static
set(findobj(hFigViewresult,'tag','viewresult_PopupmenuStaticSelect'),'value',udata.settings.StaticSelect);
set(findobj(hFigViewresult,'tag','viewresult_PopupmenuStaticXScale'),'value',udata.settings.StaticXScale);
viewresult_PopupmenuStaticSelectFcn;
% --- for dynamics
if isfield(udata.result,'dynamicQs')
    set(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicSelect'),'value',udata.settings.DynamicSelect,'enable','on');
    set(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicXScale'),'value',udata.settings.DynamicXScale,'enable','on');
    set(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicG2XScale'),'value',udata.settings.DynamicG2XScale,'enable','on');
    set(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicG2PlotErrorbars'),'value',udata.settings.DynamicG2PlotErrorbars,'enable','on');
    set(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicFitting'),'value',udata.settings.DynamicFitting,'enable','on');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonOverlayPlotDynamic'),'enable','on');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonPlotDynamic'),'enable','on');
    set(findobj(hFigViewresult,'tag','viewresult_EditBatches2average'),'enable','inactive');
    viewresult_EditBatches2average_initialize(hFigViewresult,udata)
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonAvgDynamic'),'enable','on');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonPlotAvgDynamic'),'enable','on');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonAvgAndPlotDynamic'),'enable','on');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonExportAvgDynamic'),'enable','on');
    set(findobj(hFigViewresult,'Tag','viewresult_tableDynamic'),'enable','on');
    viewresult_PopupmenuDynamicSelectFcn;
else
    set(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicSelect'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicXScale'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicG2XScale'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicG2PlotErrorbars'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicFitting'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonOverlayPlotDynamic'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonPlotDynamic'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_EditBatches2average'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonAvgDynamic'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonPlotAvgDynamic'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonAvgAndPlotDynamic'),'enable','off');
    set(findobj(hFigViewresult,'tag','viewresult_PushbuttonExportAvgDynamic'),'enable','off');
    set(findobj(hFigViewresult,'Tag','viewresult_tableDynamic'),'enable','off');
end
viewresult_savesettings;

function viewresult_EditBatches2average_initialize(hFigViewresult,udata)
hEditBatches2average = findobj(hFigViewresult,'tag','viewresult_EditBatches2average');
if isfield(udata.result,'batches2average') && ~isempty(udata.result.batches2average)
    set(hEditBatches2average,'string',batches2average_str_fcn(udata.result.batches2average));
else
    set(hEditBatches2average,'string','');
end

function str=batches2average_str_fcn(batches2average)
b={};
b{1,1} = batches2average(1);
for ii=2:length(batches2average)
    if batches2average(ii)-batches2average(ii-1) == 1
        b{end,1} = [b{end,1},batches2average(ii)];
    else
        b{end+1,1} = batches2average(ii);
    end
end
str = '';
for ii=1:length(b)
    if length(b{ii})>1
        tmp_str = [num2str(b{ii}(1)),'-',num2str(b{ii}(end))];
    else
        tmp_str = num2str(b{ii});
    end
    str = [str,',',tmp_str];
end
str(1) = '';

function viewresult_PushbuttonLoadCallbackFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
[filename, filepath] = uigetfile(...
    {'*.hdf', 'Result Files (*.hdf)';'*.mat', 'Result Files (*result.mat)';'*.*', 'All Files'},...
    'Select Result File','MultiSelect', 'on');
if ( isequal([filename,filepath],[0,0]) ), return; end;
file = fullfile(filepath,filename);
update_file(hFigViewresult,file,findall(hFigViewresult,'tag','viewresult_PushbuttonLoad'));


function [udata,viewresultinfo] = read_mat_or_hdf_resultfile(varargin)
file=varargin{1};

if ~iscellstr(file) %%single .mat or .hdf file
    
    %Check if the file ext is .mat or .hdf
    [udata.filepath,udata.filename,udata.fileext]=fileparts(file);
    if strcmpi(cellstr(udata.fileext),'.mat') %%if .mat, do as usual
        try
            tmp = load(file);
            
            try
                viewresultinfo = tmp.viewresultinfo; %new naming style
            catch
                viewresultinfo = tmp.ccdimginfo; %old naming style
            end
            
            if isfield(viewresultinfo,'cluster')            % determine for cluster result
                udata.result = viewresultinfo.cluster.result;
            else
                % If staticQs field exists in viewresultinfo.result, call
                % save_local_results to generate result fields
                %                 if ~isfield(viewresultinfo.result,'staticQs') %obsolete
                %                     viewresultinfo = creat_result_field(viewresultinfo);
                %                 end
                udata.result = viewresultinfo.result;
            end
            [udata.filepath,udata.filename,udata.fileext] = fileparts(file);
            if isempty(udata.filepath);
                udata.filepath = pwd;
            end
            if isempty(udata.fileext);
                udata.fileext = '.mat';
            end
            udata.file = fullfile(udata.filepath,[udata.filename,udata.fileext]);
        catch
            disp('Something wrong with the specified .mat or .hdf file');
            return;
        end %try-catch block ends here and is for .mat file
        %
    elseif strcmpi(cellstr(udata.fileext),'.hdf') %%if .hdf, use special functions
        
        try
            version_xpcs_code = h5read(file,'/xpcs/Version'); %field added in Aug 2016 with version of .jar=0.5%
        catch
            version_xpcs_code = num2str(0.4); %previous and the only older working version of .jar file
        end
        
        if strcmpi(version_xpcs_code,'0.5')
            xpcs_group_suffix = hdf5_find_group_suffix(file,'/xpcs');
            if (xpcs_group_suffix == 1) %only one group is present: /xpcs
                xpcs_group ='/xpcs';
            elseif (xpcs_group_suffix > 1) %more than one group is present
                xpcs_group = ['/xpcs_',num2str(xpcs_group_suffix -1)];
            else
                fprintf('No XPCS group/result seems to be there in the file: %s\n',file);
            end
        elseif strcmpi(version_xpcs_code,'0.4')
            xpcs_group = '/xpcs';
        end
        
        try
            udata.result = loadhdf5result(file,xpcs_group); %%results from hdf5 file to matlab structure
        catch
            %%not sure what to do here
        end %try-catch block ends here and is for .hdf file
        udata.file = fullfile(udata.filepath,[udata.filename,udata.fileext]);
        
        viewresultinfo.result=udata.result;
    else
        return;
    end
    
else %%cell array of multiple .mat or .hdf files or combo
    [viewresultinfo,file_out]=function_merge_xpcsgui_result_files(file);
    for ii=1:numel(file_out)
        if (ii==1)
            fprintf('\n');
            fprintf('%s\n','------------------------------');
            fprintf('%s,%s\n','File_Number','Result_FileName');
            fprintf('%s\n','------------------------------');
        end
        fprintf('%03i,%s\n',ii,file_out{ii});
        fprintf('%s\n','------------------------------');
    end
    file = 'null_1';
    udata.filepath='';
    udata.filename=file;
    udata.fileext='';
    udata.file=file;
    udata.result = viewresultinfo.result;
end
assignin('base','udata',udata);


function update_file(hFigViewresult,file,hobj)
try
    udata0 = get(hFigViewresult,'Userdata');
    [udata,viewresultinfo]=read_mat_or_hdf_resultfile(file);
    if isfield(udata0,'settings') ~= 0
        udata.settings = udata0.settings;
    end
catch
    hobj_tag = get(hobj,'tag');
    if strcmpi(hobj_tag,'viewresult_PushbuttonLoad')
        viewresult_PushbuttonLoadCallbackFcn;
    elseif strcmpi(hobj_tag,'viewresult_EditFile')
        udata = get(hFigViewresult,'Userdata');
        set(findall(hFigViewresult,'tag','viewresult_EditFile'),'string',udata.file);
    end
    return;
end
set(hFigViewresult,'UserData',udata);
setappdata(hFigViewresult,'viewresultinfo',viewresultinfo);
viewresult_initialize(hFigViewresult);


function viewresult_EditFileFcn(~,~)
hFigViewresult = gcbf;
hEditFile = findall(hFigViewresult,'tag','viewresult_EditFile');
file = get(hEditFile,'string');
update_file(hFigViewresult,file,hEditFile);


function viewresult_ListboxBatchFcn(~,~)
viewresult_savesettings;
viewresult_PopupmenuStaticSelectFcn;
viewresult_PopupmenuDynamicSelectFcn;

function viewresult_PushbuttonSelectAllBatchesFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
hListboxBatch = findall(hFigViewresult,'tag','viewresult_ListboxBatch');
batchlist = str2num(get(hListboxBatch,'string'));
set(hListboxBatch,'value',1:length(batchlist));
viewresult_savesettings;

function viewresult_PushbuttonPlotAvgImageFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
for ii=1:length(udata.settings.Batch)
    set(figure(figure_handle_check(1000)),...
        'Name',['Averaged Image - ',udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))],...
        'Tag','viewresult_Fig_Image',...
        'PaperOrientation','landscape',...
        'PaperPositionMode','manual',...
        'PaperSize',[11 8.5],...
        'PaperType','usletter',...
        'PaperPosition',[0.25 0.25 10.5 7.75]);
    img = udata.result.aIt{udata.settings.Batch(ii)};
    if udata.settings.PlotImageScale == 1
        imagesc(img,[min(img(:)), min(mean(img(:))*100,max(img(:)))]);
    else
        img(img<0)=0;
        imagesc(log10(img));
    end
    axis image;
    set(gca,'ydir','norm');
    supertitle([udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))]);
end

function viewresult_PushbuttonPlotTotalIntFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
set(figure(figure_handle_check(2000)),...
    'Name',['Total Intensity - ',udata.filename],...
    'Tag','viewresult_Fig_TotalInt',...
    'PaperOrientation','landscape',...
    'PaperPositionMode','manual',...
    'PaperSize',[11 8.5],...
    'PaperType','usletter',...
    'PaperPosition',[0.25 0.25 10.5 7.75]);
markerlist = varymarker(length(udata.settings.Batch));
colorlist = varycolor(length(udata.settings.Batch));
hold on;
for ii=1:length(udata.settings.Batch)
    I = sum(udata.result.totalIntensity{udata.settings.Batch(ii)},2);
    plot(udata.result.framespacing{udata.settings.Batch(ii)}*(1:length(I)),I,'marker',markerlist{ii},'color',colorlist(ii,:));
end
hold off; box on;
xlabel('Elasped Time (s)');
ylabel('Total Intensity (photons/sec)');
supertitle([udata.filename]);
legend(num2str(udata.settings.Batch));

function viewresult_PopupmenuStaticSelectFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
hPopupmenuStaticSelect = findall(hFigViewresult,'tag','viewresult_PopupmenuStaticSelect');
hTableStatic = findobj(hFigViewresult,'tag','viewresult_tableStatic');
if get(hPopupmenuStaticSelect,'value') == 1
    set(hTableStatic,'Data',udata.result.staticQs{udata.settings.Batch(1)});
else
    set(hTableStatic,'Data',udata.result.staticPHIs{udata.settings.Batch(1)});
end
viewresult_savesettings;
% udata = get(hFigViewresult,'UserData');
% viewresult_TableCellSelect(hTableStatic,...
%     udata.settings.StaticSelectQ,...
%     udata.settings.StaticSelectPHI,...
%     size(udata.result.staticQs{1},1),...
%     size(udata.result.staticQs{1},2),...
%     udata.settings.StaticSelect);

function viewresult_PushbuttonPlotStabilityFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
if udata.settings.StaticSelect == 1
    for ii=1:length(udata.settings.Batch)
        colorlist = varycolor(1+size(udata.result.Iqphit{udata.settings.Batch(ii)},3));
        markerlist = varymarker(size(udata.result.Iqphit{udata.settings.Batch(ii)},3));
        set(figure(figure_handle_check(3000)),...
            'Name',['Stability - ',udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))],...
            'Tag','viewresult_Fig_Stability',...
            'PaperOrientation','landscape',...
            'PaperPositionMode','manual',...
            'PaperSize',[11 8.5],...
            'PaperType','usletter',...
            'PaperPosition',[0.25 0.25 10.5 7.75]);
        hold on;
        q = udata.result.staticQs{udata.settings.Batch(ii)}(:,udata.settings.StaticSelectQ);
%        index = (q==0);
%        q(index) = [];
        legend_str = cell(1+size(udata.result.Iqphit{udata.settings.Batch(ii)},3),1);
        for jj=1:size(udata.result.Iqphit{udata.settings.Batch(ii)},3)
            I = udata.result.Iqphit{udata.settings.Batch(ii)}(:,udata.settings.StaticSelectQ,jj);
%            I(index) = [];
            plot(q,I,'-','marker',markerlist{jj},'color',colorlist(end-jj,:));
            legend_str{jj} = ['TS:',num2str(jj,'%.2d')];
        end
        I = udata.result.Iqphi{udata.settings.Batch(ii)}(:,udata.settings.StaticSelectQ);
%        I(index) = [];
        plot(q,I,'o-','color',colorlist(end,:),'markerfacecolor',colorlist(end,:));
        legend_str{end} = 'Static';
        hold off; box on;
        xlabel('q (A^{-1})');
        set(gca,'yscale','log');
        set(gca,'xminortick','on');
        ylabel('I/I_0 (a.u.)');
        legend(legend_str);
        supertitle([udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))]);
        % check xscale
        if udata.settings.StaticXScale == 2
            set(gca,'xscale','log');
            xlims = get(gca,'xlim');
            xticks = 10.^(floor(log10(xlims(1))):ceil(log10(xlims(2))));
            set(gca,'xtick',xticks);
        end
    end
else
    for ii=1:length(udata.settings.Batch)
        colorlist = varycolor(1+size(udata.result.Iqphit{udata.settings.Batch(ii)},3));
        markerlist = varymarker(size(udata.result.Iqphit{udata.settings.Batch(ii)},3));
        set(figure(figure_handle_check(3000)),...
            'Name',['Stability - ',udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))],...
            'Tag','viewresult_Fig_Stability',...
            'PaperOrientation','landscape',...
            'PaperPositionMode','manual',...
            'PaperSize',[11 8.5],...
            'PaperType','usletter',...
            'PaperPosition',[0.25 0.25 10.5 7.75]);
        hold on;
        phi = udata.result.staticPHIs{udata.settings.Batch(ii)}(udata.settings.StaticSelectPHI,:);
%        index = (phi==0);
%        phi(index) = [];
        legend_str = cell(1+size(udata.result.Iqphit{udata.settings.Batch(ii)},3),1);
        for jj=1:size(udata.result.Iqphit{udata.settings.Batch(ii)},3)
            I = udata.result.Iqphit{udata.settings.Batch(ii)}(udata.settings.StaticSelectPHI,:,jj);
 %           I(index) = [];
            plot(phi,I,'-','marker',markerlist{jj},'color',colorlist(end-jj,:));
            legend_str{jj} = ['TS:',num2str(jj,'%.2d')];
        end
        I = udata.result.Iqphi{udata.settings.Batch(ii)}(udata.settings.StaticSelectPHI,:);
%        I(index) = [];
        plot(phi,I,'o-','color',colorlist(end,:),'markerfacecolor',colorlist(end,:));
        legend_str{end} = 'Static';
        hold off; box on;
        xlabel('phi');
        set(gca,'yscale','log');
        ylabel('I/I_0 (a.u.)');
        legend(legend_str);
        supertitle([udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))]);
        if udata.settings.StaticXScale == 2
            set(gca,'xscale','log');
            xlims = get(gca,'xlim');
            xticks = 10.^(floor(log10(xlims(1))):ceil(log10(xlims(2))));
            set(gca,'xtick',xticks);
        end
    end
end

function viewresult_PushbuttonPlotStaticFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
set(figure(figure_handle_check(4000)),...
    'Name',['Static - ',udata.filename],...
    'Tag','viewresult_Fig_Static',...
    'PaperOrientation','landscape',...
    'PaperPositionMode','manual',...
    'PaperSize',[11 8.5],...
    'PaperType','usletter',...
    'PaperPosition',[0.25 0.25 10.5 7.75]);
colorlist = varycolor(length(udata.settings.Batch));
markerlist = varymarker(length(udata.settings.Batch));
hold on;
if udata.settings.StaticSelect == 1
    for ii=1:length(udata.settings.Batch)
        I = udata.result.Iqphi{udata.settings.Batch(ii)}(:,udata.settings.StaticSelectQ);
        q = udata.result.staticQs{udata.settings.Batch(ii)}(:,udata.settings.StaticSelectQ);
%        index = (q==0);
%        q(index) = [];
%        I(index) = [];
        plot(q,I,'marker',markerlist{ii},'color',colorlist(ii,:));
        xlabel('q (A^{-1})');
    end
else
    for ii=1:length(udata.settings.Batch)
        I = udata.result.Iqphi{udata.settings.Batch(ii)}(udata.settings.StaticSelectPHI,:);
        phi = udata.result.staticPHIs{udata.settings.Batch(ii)}(udata.settings.StaticSelectPHI,:);
%        index = (phi==0);
%        phi(index) = [];
%        I(index) = [];
        plot(phi,I,'marker',markerlist{ii},'color',colorlist(ii,:));
        xlabel('phi');
    end
end
hold off; box on;
set(gca,'yscale','log');
set(gca,'xminortick','on');
ylabel('I/I_0 (a.u.)');
supertitle([udata.filename]);
legend(num2str(udata.settings.Batch));
if udata.settings.StaticXScale == 2
    set(gca,'xscale','log');
    xlims = get(gca,'xlim');
    xticks = 10.^(floor(log10(xlims(1))):ceil(log10(xlims(2))));
    set(gca,'xtick',xticks);
end

% function viewresult_TableCellSelect(hTable,col,row,ncol,nrow,QPHIselect)
% jUIScrollPane  = findjobj(hTable);
% jUITable = jUIScrollPane.getViewport.getView;
% if QPHIselect == 1
%     jUITable.setRowSelectionAllowed(1);
%     jUITable.changeSelection(nrow-1,col-1, false,false);
%     jUITable.changeSelection(0,col-1, false,true);
% elseif QPHIselect == 2
%     jUITable.setColumnSelectionAllowed(1);
%     jUITable.changeSelection(row-1,ncol-1, false,false);
%     jUITable.changeSelection(row-1,0,false,true);
% end

function viewresult_TableStaticCellSelectionCallback(~,eventdata)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
if isempty(eventdata.Indices), return; end;
if udata.settings.StaticSelect == 1
    udata.settings.StaticSelectQ = eventdata.Indices(1,2);
elseif udata.settings.StaticSelect == 2
    udata.settings.StaticSelectPHI = eventdata.Indices(1,1);
end
set(hFigViewresult,'UserData',udata);

function viewresult_TableDynamicCellSelectionCallback(~,eventdata)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
if isempty(eventdata.Indices), return; end;
if udata.settings.DynamicSelect == 1
    udata.settings.DynamicSelectQ = eventdata.Indices(1,2);
elseif udata.settings.DynamicSelect == 2
    udata.settings.DynamicSelectPHI = eventdata.Indices(1,1);
end
set(hFigViewresult,'UserData',udata);

% function viewresult_TableStaticCellSelectionCallback(~,~)
% hFigViewresult = findall(0,'Tag','viewresult_Fig');
% udata = get(hFigViewresult,'UserData');
% hTableStatic = findobj(hFigViewresult,'tag','viewresult_tableStatic');
% data = get(hTableStatic,'Data');
% ncol = size(data,2);
% nrow = size(data,1);
% jUIScrollPane  = findjobj(hTableStatic);
% jUITable = jUIScrollPane.getViewport.getView;
% col = jUITable.getSelectedColumn + 1;
% row = jUITable.getSelectedRow + 1;
% if udata.settings.StaticSelect == 1 && jUITable.getSelectedRowCount == nrow
%     udata.settings.StaticSelectQ = col;
%     set(hFigViewresult,'UserData',udata);
%     return;
% elseif udata.settings.StaticSelect == 2 && jUITable.getSelectedColumnCount == ncol
%     udata.settings.StaticSelectPHI = row;
%     set(hFigViewresult,'UserData',udata);
%     return;
% end
% try
%     viewresult_TableCellSelect(hTableStatic,col,row,ncol,nrow,udata.settings.StaticSelect);
% catch
% end

% function viewresult_TableDynamicCellSelectionCallback(~,~)
% hFigViewresult = findall(0,'Tag','viewresult_Fig');
% udata = get(hFigViewresult,'UserData');
% hTableDynamic = findobj(hFigViewresult,'tag','viewresult_tableDynamic');
% data = get(hTableDynamic,'Data');
% ncol = size(data,2);
% nrow = size(data,1);
% jUIScrollPane  = findjobj(hTableDynamic);
% jUITable = jUIScrollPane.getViewport.getView;
% col = jUITable.getSelectedColumn + 1;
% row = jUITable.getSelectedRow + 1;
% if udata.settings.DynamicSelect == 1 && jUITable.getSelectedRowCount == nrow
%     udata.settings.DynamicSelectQ = col;
%     set(hFigViewresult,'UserData',udata);
%     return;
% elseif udata.settings.DynamicSelect == 2 && jUITable.getSelectedColumnCount == ncol
%     udata.settings.DynamicSelectPHI = row;
%     set(hFigViewresult,'UserData',udata);
%     return;
% end
% try
%     viewresult_TableCellSelect(hTableDynamic,col,row,ncol,nrow,udata.settings.DynamicSelect);
% catch
% end

function viewresult_PopupmenuDynamicSelectFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
hPopupmenuDynamicSelect = findall(hFigViewresult,'tag','viewresult_PopupmenuDynamicSelect');
if strcmpi(get(hPopupmenuDynamicSelect,'Enable'),'off'), return; end
hTableDynamic = findobj(hFigViewresult,'tag','viewresult_tableDynamic');
if get(hPopupmenuDynamicSelect,'value') == 1
    set(hTableDynamic,'Data',udata.result.dynamicQs{udata.settings.Batch(1)});
else
    set(hTableDynamic,'Data',udata.result.dynamicPHIs{udata.settings.Batch(1)});
end
viewresult_savesettings;
% udata = get(hFigViewresult,'UserData');
% viewresult_TableCellSelect(hTableDynamic,...
%     udata.settings.DynamicSelectQ,...
%     udata.settings.DynamicSelectPHI,...
%     size(udata.result.dynamicQs{1},1),...
%     size(udata.result.dynamicQs{1},2),...
%     udata.settings.DynamicSelect);

function viewresult_EditNumberOfG2FiguresFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
hEditNumberOfG2Figures = findall(hFigViewresult,'tag','viewresult_EditNumberOfG2Figures');
string_noff = get(hEditNumberOfG2Figures,'String');
noff = floor(str2double(string_noff));
if ~isnan(noff) && noff>0
    set(hEditNumberOfG2Figures,'String',num2str(noff));    
else
    set(hEditNumberOfG2Figures,'String','Inf');    
end
viewresult_savesettings;
return;


function viewresult_PushbuttonOverlayPlotDynamicFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
[dt,x,g2avg,g2avgErr,g2avgFIT1,g2avgFIT2,...
    tauFIT1,tauFIT2,tauErrFIT1,tauErrFIT2,...
    baselineFIT1,baselineFIT2,baselineErrFIT1,baselineErrFIT2,...
    contrastFIT1,contrastFIT2,contrastErrFIT1,contrastErrFIT2,...
    exponentFIT2,exponentErrFIT2] = get_dynamic_data(udata);
if udata.settings.DynamicSelect == 1
    title_label_str0 = 'q=';
    xlabel_str = 'q (A^{-1})';
elseif udata.settings.DynamicSelect == 2
    title_label_str0 = 'phi=';
    xlabel_str = 'phi';
else
    return;
end
% --- check if q/phi are identical batch from batch
notisequal_sum = 0;
for ii = 1:(length(x)-1)
    if length(x{ii}) ~= length(x{ii+1}) || mean(abs((x{ii}-x{ii+1})./x{ii})) > 0.1
        notisequal_sum = notisequal_sum + 1;
    end
%    notisequal_sum = (~isequal(x{ii},x{ii+1})) + notisequal_sum;
end
% --- contruct color, makers, etc.
batches_str = batches2average_str_fcn(udata.settings.Batch);
colorlist = varycolor(length(x));
markerlist = varymarker(length(x));
% --- plot g2
if notisequal_sum ~= 0
    plot_dynamics_g2(dt,x,g2avg,g2avgErr,g2avgFIT1,g2avgFIT2,tauFIT1,tauFIT2,udata,title_label_str0);
else
    plot_dynamics_g2_overlay(dt,x,g2avg,g2avgErr,g2avgFIT1,g2avgFIT2,udata,batches_str,colorlist,markerlist,title_label_str0);
end
% --- plot tau
if udata.settings.DynamicFitting == 1 || udata.settings.DynamicFitting == 3     % single
    fig_name_str = ['Fitting (Simple Exponential) - ',udata.filename,' - Batch #',batches_str];
    plot_dynamics_tau_overlay(x,...
        tauFIT1,tauErrFIT1,...
        baselineFIT1,baselineErrFIT1,...
        contrastFIT1,contrastErrFIT1,...
        [],[],...
        udata,fig_name_str,batches_str,colorlist,markerlist,xlabel_str)
end
if udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3     % streched
    fig_name_str = ['Fitting (Stretched Exponential) - ',udata.filename,' - Batch #',batches_str];
    plot_dynamics_tau_overlay(x,...
        tauFIT2,tauErrFIT2,...
        baselineFIT2,baselineErrFIT2,...
        contrastFIT2,contrastErrFIT2,...
        exponentFIT2,exponentErrFIT2,...
        udata,fig_name_str,batches_str,colorlist,markerlist,xlabel_str)    
end


function plot_dynamics_g2_overlay(dt,x,...
    g2avg,g2avgErr,g2avgFIT1,g2avgFIT2,...
    udata,batches_str,colorlist,markerlist,title_label_str0)
for jj=1:min(udata.settings.G2Panel*udata.settings.DynamicNumberOfG2Figures,length(x{1}))
    if mod(jj-1,udata.settings.G2Panel) == 0
        set(figure(figure_handle_check(5000)),...
            'position',udata.settings.DynamicFigPos,...
            'Name',['G2 - ',udata.filename,' - Batch #',batches_str],'Tag','viewresult_Fig_G2',...
            'PaperOrientation','landscape',...
            'PaperPositionMode','manual',...
            'PaperSize',[11 8.5],...
            'PaperType','usletter',...
            'PaperPosition',[0.25 0.25 10.5 7.75]);
        supertitle([udata.filename,' - Batch #',batches_str]);
    end
    subplot(udata.settings.G2PanelRow,udata.settings.G2PanelCol,mod(jj-1,udata.settings.G2Panel)+1);
    hold on;
    for ii=1:length(x)       % plot data
        herr = errorbar(dt{ii},g2avg{ii}(jj,:),g2avgErr{ii}(jj,:),'marker',markerlist{ii},'color',colorlist(ii,:));
        if udata.settings.DynamicG2XScale == 2
            %errorbarlogx;
            set(gca,'xscale','log');            
        end
        tag_g2errorbars(herr,udata.settings.DynamicG2PlotErrorbars);
    end
    for ii=1:length(x)       % plot fitting
        if udata.settings.DynamicFitting == 1 || udata.settings.DynamicFitting == 3
            plot(dt{ii},g2avgFIT1{ii}(jj,:),'-','color',colorlist(ii,:));
        end
        if udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3
            plot(dt{ii},g2avgFIT2{ii}(jj,:),'--','color',colorlist(ii,:));
        end
    end
    hold off; box on;
    set(gca,'xminortick','on');
    xlims = (get(gca,'xlim'));
    if udata.settings.DynamicG2XScale == 2
        xlim_min = 10.^floor(log10(dt{ii}(1)));
        xlim_max = 10.^ceil(log10(dt{ii}(end)));
        set(gca,'xlim',[xlim_min,xlim_max]);
        set(gca,'xtick',10.^(floor(log10(xlims(1))):floor(log10(xlims(2)))));
    end
    title([title_label_str0,num2str(x{1}(jj))]);
    xlabel('dt (s)');
    ylabel('g_2');
    if jj==1
        legend(num2str(udata.settings.Batch));
    end
end

function plot_dynamics_tau_overlay(x,...
    tauFIT,tauErrFIT,...
    baselineFIT,baselineErrFIT,...
    contrastFIT,contrastErrFIT,...
    exponentFIT,exponentErrFIT,...
    udata,fig_name_str,batches_str,colorlist,markerlist,xlabel_str)
set(figure(figure_handle_check(5000)),...
    'position',udata.settings.DynamicFigPos,...
    'Name',fig_name_str,...
    'Tag','viewresult_Fig_Fitting',...
    'PaperOrientation','landscape',...
    'PaperPositionMode','manual',...
    'PaperSize',[11 8.5],...
    'PaperType','usletter',...
    'PaperPosition',[0.25 0.25 10.5 7.75]);
supertitle([udata.filename,' - Batch #',batches_str]);
subplot(2,2,1)  % contrast plot
plot_dynamics_tau_overlay_subplot(x,contrastFIT,contrastErrFIT,udata,markerlist,colorlist,xlabel_str,'Contrast');
ylim([-0.2 1.2]);
legend(num2str(udata.settings.Batch));
subplot(2,2,2)  % baseline plot
plot_dynamics_tau_overlay_subplot(x,baselineFIT,baselineErrFIT,udata,markerlist,colorlist,xlabel_str,'Baseline');
ylim([0.5 1.5]);
if ~isempty(exponentFIT) % exponent plot
    subplot(2,2,3)
    plot_dynamics_tau_overlay_subplot(x,exponentFIT,exponentErrFIT,udata,markerlist,colorlist,xlabel_str,'Stretching Exponent');
    ylim([-0.2 2.5]);
end
subplot(2,2,4)  % tau plot
plot_dynamics_tau_overlay_subplot(x,tauFIT,tauErrFIT,udata,markerlist,colorlist,xlabel_str,'Tau (sec)');
errorbarlogy;

function plot_dynamics_tau_overlay_subplot(x,y,yErr,udata,markerlist,colorlist,xlabel_str,ylabel_str)
hold on;
for ii=1:length(x)
    errorbar(x{ii},y{ii},yErr{ii},'marker',markerlist{ii},'color',colorlist(ii,:));
end
hold off; box on;
if udata.settings.DynamicXScale == 2
%     errorbarlogx;
    set(gca,'xscale','log');
%     xlims = get(gca,'xlim');
%     xticks = 10.^(floor(log10(xlims(1))):ceil(log10(xlims(2))));
%     set(gca,'xtick',xticks);
end
set(gca,'xminortick','on');
xlabel(xlabel_str);
ylabel(ylabel_str);

function viewresult_PushbuttonPlotDynamicFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
[dt,x,g2avg,g2avgErr,g2avgFIT1,g2avgFIT2,...
    tauFIT1,tauFIT2,tauErrFIT1,tauErrFIT2,...
    baselineFIT1,baselineFIT2,baselineErrFIT1,baselineErrFIT2,...
    contrastFIT1,contrastFIT2,contrastErrFIT1,contrastErrFIT2,...
    exponentFIT2,exponentErrFIT2] = get_dynamic_data(udata);
if udata.settings.DynamicSelect == 1
    title_label_str0 = 'q=';
    xlabel_str = 'q (A^{-1})';
elseif udata.settings.DynamicSelect == 2
    title_label_str0 = 'phi=';
    xlabel_str = 'phi';
else
    return;
end
% --- plot g2
plot_dynamics_g2(dt,x,g2avg,g2avgErr,g2avgFIT1,g2avgFIT2,tauFIT1,tauFIT2,udata,title_label_str0);
if udata.settings.DynamicFitting == 4
    return;
end
plot_dynamics_tau(x,...
    tauFIT1,tauFIT2,tauErrFIT1,tauErrFIT2,...
    baselineFIT1,baselineFIT2,baselineErrFIT1,baselineErrFIT2,...
    contrastFIT1,contrastFIT2,contrastErrFIT1,contrastErrFIT2,...
    exponentFIT2,exponentErrFIT2,...
    udata,xlabel_str);


function [dt,x,g2avg,g2avgErr,g2avgFIT1,g2avgFIT2,...
    tauFIT1,tauFIT2,tauErrFIT1,tauErrFIT2,...
    baselineFIT1,baselineFIT2,baselineErrFIT1,baselineErrFIT2,...
    contrastFIT1,contrastFIT2,contrastErrFIT1,contrastErrFIT2,...
    exponentFIT2,exponentErrFIT2] = get_avg_dynamic_data(udata)
% --- get all dt, q, phi (using the first selected batch)
batch1 = udata.result.batches2average(1);
dt = udata.result.delay{batch1};
q = udata.result.dynamicQs{batch1}(:,udata.settings.DynamicSelectQ);
phi = udata.result.dynamicPHIs{batch1}(udata.settings.DynamicSelectPHI,:);

% --- get all dynamic data
g2avg       = udata.result.g2Batchavg;
g2avgErr    = udata.result.g2BatchavgErr;
g2avgFIT1   = udata.result.g2BatchavgFIT1;
g2avgFIT2   = udata.result.g2BatchavgFIT2;
tauFIT1             = udata.result.tauBatchavgFIT1;
tauFIT2             = udata.result.tauBatchavgFIT2;
tauErrFIT1          = udata.result.tauErrBatchavgFIT1;
tauErrFIT2          = udata.result.tauErrBatchavgFIT2;
baselineFIT1        = udata.result.baselineBatchavgFIT1;
baselineFIT2        = udata.result.baselineBatchavgFIT2;
baselineErrFIT1     = udata.result.baselineErrBatchavgFIT1;
baselineErrFIT2     = udata.result.baselineErrBatchavgFIT2;
contrastFIT1        = udata.result.contrastBatchavgFIT1;
contrastFIT2        = udata.result.contrastBatchavgFIT2;
contrastErrFIT1     = udata.result.contrastErrBatchavgFIT1;
contrastErrFIT2     = udata.result.contrastErrBatchavgFIT2;
exponentFIT2        = udata.result.exponentBatchavgFIT2;
exponentErrFIT2     = udata.result.exponentErrBatchavgFIT2;
% --- determine q or phi to reduce dynamic data
if udata.settings.DynamicSelect == 1
    x = q;
    g2avg           = transpose(shiftdim(g2avg(:,udata.settings.DynamicSelectQ,:),2));
    g2avgErr        = transpose(shiftdim(g2avgErr(:,udata.settings.DynamicSelectQ,:),2));
    g2avgFIT1       = transpose(shiftdim(g2avgFIT1(:,udata.settings.DynamicSelectQ,:),2));
    g2avgFIT2       = transpose(shiftdim(g2avgFIT2(:,udata.settings.DynamicSelectQ,:),2));
    tauFIT1             = tauFIT1(:,udata.settings.DynamicSelectQ);
    tauFIT2             = tauFIT2(:,udata.settings.DynamicSelectQ);
    tauErrFIT1          = tauErrFIT1(:,udata.settings.DynamicSelectQ);
    tauErrFIT2          = tauErrFIT2(:,udata.settings.DynamicSelectQ);
    baselineFIT1        = baselineFIT1(:,udata.settings.DynamicSelectQ);
    baselineFIT2        = baselineFIT2(:,udata.settings.DynamicSelectQ);
    baselineErrFIT1     = baselineErrFIT1(:,udata.settings.DynamicSelectQ);
    baselineErrFIT2     = baselineErrFIT2(:,udata.settings.DynamicSelectQ);
    contrastFIT1        = contrastFIT1(:,udata.settings.DynamicSelectQ);
    contrastFIT2        = contrastFIT2(:,udata.settings.DynamicSelectQ);
    contrastErrFIT1     = contrastErrFIT1(:,udata.settings.DynamicSelectQ);
    contrastErrFIT2     = contrastErrFIT2(:,udata.settings.DynamicSelectQ);
    exponentFIT2        = exponentFIT2(:,udata.settings.DynamicSelectQ);
    exponentErrFIT2     = exponentErrFIT2(:,udata.settings.DynamicSelectQ);
elseif udata.settings.DynamicSelect == 2
    x = phi;
    g2avg       = shiftdim(g2avg(udata.settings.DynamicSelectPHI,:,:),1);
    g2avgErr    = shiftdim(g2avgErr(udata.settings.DynamicSelectPHI,:,:),1);
    g2avgFIT1   = shiftdim(g2avgFIT1(udata.settings.DynamicSelectPHI,:,:),1);
    g2avgFIT2   = shiftdim(g2avgFIT2(udata.settings.DynamicSelectPHI,:,:),1);
    tauFIT1             = tauFIT1(udata.settings.DynamicSelectPHI,:);
    tauFIT2             = tauFIT2(udata.settings.DynamicSelectPHI,:);
    tauErrFIT1          = tauErrFIT1(udata.settings.DynamicSelectPHI,:);
    tauErrFIT2          = tauErrFIT2(udata.settings.DynamicSelectPHI,:);
    baselineFIT1        = baselineFIT1(udata.settings.DynamicSelectPHI,:);
    baselineFIT2        = baselineFIT2(udata.settings.DynamicSelectPHI,:);
    baselineErrFIT1     = baselineErrFIT1(udata.settings.DynamicSelectPHI,:);
    baselineErrFIT2     = baselineErrFIT2(udata.settings.DynamicSelectPHI,:);
    contrastFIT1        = contrastFIT1(udata.settings.DynamicSelectPHI,:);
    contrastFIT2        = contrastFIT2(udata.settings.DynamicSelectPHI,:);
    contrastErrFIT1     = contrastErrFIT1(udata.settings.DynamicSelectPHI,:);
    contrastErrFIT2     = contrastErrFIT2(udata.settings.DynamicSelectPHI,:);
    exponentFIT2        = exponentFIT2(udata.settings.DynamicSelectPHI,:);
    exponentErrFIT2     = exponentErrFIT2(udata.settings.DynamicSelectPHI,:);
end


function [dt,x,g2avg,g2avgErr,g2avgFIT1,g2avgFIT2,...
    tauFIT1,tauFIT2,tauErrFIT1,tauErrFIT2,...
    baselineFIT1,baselineFIT2,baselineErrFIT1,baselineErrFIT2,...
    contrastFIT1,contrastFIT2,contrastErrFIT1,contrastErrFIT2,...
    exponentFIT2,exponentErrFIT2] = get_dynamic_data(udata)
% --- get all dt, q, phi
dt  =  cell(size(udata.settings.Batch));
q   = cell(size(udata.settings.Batch));
phi = cell(size(udata.settings.Batch));
for ii=1:length(udata.settings.Batch)
    dt{ii} = udata.result.delay{udata.settings.Batch(ii)};
    q{ii} = udata.result.dynamicQs{udata.settings.Batch(ii)}(:,udata.settings.DynamicSelectQ);
%    q{ii}(q{ii}==0) = NaN;
    phi{ii} = udata.result.dynamicPHIs{udata.settings.Batch(ii)}(udata.settings.DynamicSelectPHI,:);
%    phi{ii}(phi{ii}==0) = NaN;
end
% --- get all dynamic data
g2avg       = udata.result.g2avg(udata.settings.Batch);
g2avgErr    = udata.result.g2avgErr(udata.settings.Batch);
g2avgFIT1   = udata.result.g2avgFIT1(udata.settings.Batch);
g2avgFIT2   = udata.result.g2avgFIT2(udata.settings.Batch);
tauFIT1             = udata.result.tauFIT1(udata.settings.Batch);
tauFIT2             = udata.result.tauFIT2(udata.settings.Batch);
tauErrFIT1          = udata.result.tauErrFIT1(udata.settings.Batch);
tauErrFIT2          = udata.result.tauErrFIT2(udata.settings.Batch);
baselineFIT1        = udata.result.baselineFIT1(udata.settings.Batch);
baselineFIT2        = udata.result.baselineFIT2(udata.settings.Batch);
baselineErrFIT1     = udata.result.baselineErrFIT1(udata.settings.Batch);
baselineErrFIT2     = udata.result.baselineErrFIT2(udata.settings.Batch);
contrastFIT1        = udata.result.contrastFIT1(udata.settings.Batch);
contrastFIT2        = udata.result.contrastFIT2(udata.settings.Batch);
contrastErrFIT1     = udata.result.contrastErrFIT1(udata.settings.Batch);
contrastErrFIT2     = udata.result.contrastErrFIT2(udata.settings.Batch);
exponentFIT2        = udata.result.exponentFIT2(udata.settings.Batch);
exponentErrFIT2     = udata.result.exponentErrFIT2(udata.settings.Batch);
% --- determine q or phi to reduce dynamic data
if udata.settings.DynamicSelect == 1
    x = q;
    for ii=1:length(udata.settings.Batch)   
        g2avg{ii}       = transpose(shiftdim(g2avg{ii}(:,udata.settings.DynamicSelectQ,:),2));
        g2avgErr{ii}    = transpose(shiftdim(g2avgErr{ii}(:,udata.settings.DynamicSelectQ,:),2));
        g2avgFIT1{ii}   = transpose(shiftdim(g2avgFIT1{ii}(:,udata.settings.DynamicSelectQ,:),2));
        g2avgFIT2{ii}   = transpose(shiftdim(g2avgFIT2{ii}(:,udata.settings.DynamicSelectQ,:),2));       
        tauFIT1{ii}             = tauFIT1{ii}(:,udata.settings.DynamicSelectQ);
        tauFIT2{ii}             = tauFIT2{ii}(:,udata.settings.DynamicSelectQ);
        tauErrFIT1{ii}          = tauErrFIT1{ii}(:,udata.settings.DynamicSelectQ);     
        tauErrFIT2{ii}          = tauErrFIT2{ii}(:,udata.settings.DynamicSelectQ); 
        baselineFIT1{ii}        = baselineFIT1{ii}(:,udata.settings.DynamicSelectQ);        
        baselineFIT2{ii}        = baselineFIT2{ii}(:,udata.settings.DynamicSelectQ);        
        baselineErrFIT1{ii}     = baselineErrFIT1{ii}(:,udata.settings.DynamicSelectQ);        
        baselineErrFIT2{ii}     = baselineErrFIT2{ii}(:,udata.settings.DynamicSelectQ);                
        contrastFIT1{ii}        = contrastFIT1{ii}(:,udata.settings.DynamicSelectQ);        
        contrastFIT2{ii}        = contrastFIT2{ii}(:,udata.settings.DynamicSelectQ);        
        contrastErrFIT1{ii}     = contrastErrFIT1{ii}(:,udata.settings.DynamicSelectQ);        
        contrastErrFIT2{ii}     = contrastErrFIT2{ii}(:,udata.settings.DynamicSelectQ);        
        exponentFIT2{ii}        = exponentFIT2{ii}(:,udata.settings.DynamicSelectQ);        
        exponentErrFIT2{ii}     = exponentErrFIT2{ii}(:,udata.settings.DynamicSelectQ);                
    end
elseif udata.settings.DynamicSelect == 2
    x = phi;
    for ii=1:length(udata.settings.Batch)   
        g2avg{ii}       = (shiftdim(g2avg{ii}(udata.settings.DynamicSelectPHI,:,:),1));
        g2avgErr{ii}    = (shiftdim(g2avgErr{ii}(udata.settings.DynamicSelectPHI,:,:),1));
        g2avgFIT1{ii}   = (shiftdim(g2avgFIT1{ii}(udata.settings.DynamicSelectPHI,:,:),1));
        g2avgFIT2{ii}   = (shiftdim(g2avgFIT2{ii}(udata.settings.DynamicSelectPHI,:,:),1));
        tauFIT1{ii}             = tauFIT1{ii}(udata.settings.DynamicSelectPHI,:);
        tauFIT2{ii}             = tauFIT2{ii}(udata.settings.DynamicSelectPHI,:);    
        tauErrFIT1{ii}          = tauErrFIT1{ii}(udata.settings.DynamicSelectPHI,:);
        tauErrFIT2{ii}          = tauErrFIT2{ii}(udata.settings.DynamicSelectPHI,:);
        baselineFIT1{ii}        = baselineFIT1{ii}(udata.settings.DynamicSelectPHI,:);
        baselineFIT2{ii}        = baselineFIT2{ii}(udata.settings.DynamicSelectPHI,:);
        baselineErrFIT1{ii}     = baselineErrFIT1{ii}(udata.settings.DynamicSelectPHI,:);
        baselineErrFIT2{ii}     = baselineErrFIT2{ii}(udata.settings.DynamicSelectPHI,:);         
        contrastFIT1{ii}        = contrastFIT1{ii}(udata.settings.DynamicSelectPHI,:);
        contrastFIT2{ii}        = contrastFIT2{ii}(udata.settings.DynamicSelectPHI,:);
        contrastErrFIT1{ii}     = contrastErrFIT1{ii}(udata.settings.DynamicSelectPHI,:);
        contrastErrFIT2{ii}     = contrastErrFIT2{ii}(udata.settings.DynamicSelectPHI,:); 
        exponentFIT2{ii}        = exponentFIT2{ii}(udata.settings.DynamicSelectPHI,:);    
        exponentErrFIT2{ii}     = exponentErrFIT2{ii}(udata.settings.DynamicSelectPHI,:); 
    end
end

function tag_g2errorbars(herr,flag)
%herrobars = findall(get(herr,'Children'),'Marker','none','LineStyle','-');
%set(herrobars,'tag','viewresult_g2errorbars');
%if flag == 2
%    set(herrobars,'visible','off');
%end
if flag==2
    n = size(get(herr,'LData'));
    set(herr,'LData',nan(n));
    set(herr,'UData',nan(n));
end

function plot_dynamics_g2(dt,x,g2avg,g2avgErr,g2avgFIT1,g2avgFIT2,tauFIT1,tauFIT2,udata,title_label_str0)
for ii=1:length(udata.settings.Batch)
    for jj=1:min(udata.settings.G2Panel*udata.settings.DynamicNumberOfG2Figures,length(x{ii}))
        if mod(jj-1,udata.settings.G2Panel) == 0
            set(figure(figure_handle_check(6000)),...
                'position',udata.settings.DynamicFigPos,...
                'Name',['G2 - ',udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))],...
                'Tag','viewresult_Fig_G2',...
                'PaperOrientation','landscape',...
                'PaperPositionMode','manual',...
                'PaperSize',[11 8.5],...
                'PaperType','usletter',...
                'PaperPosition',[0.25 0.25 10.5 7.75]);

            supertitle([udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))]);
        end
        subplot(udata.settings.G2PanelRow,udata.settings.G2PanelCol,mod(jj-1,udata.settings.G2Panel)+1);
        hold on;
        herr = errorbar(dt{ii},g2avg{ii}(jj,:),g2avgErr{ii}(jj,:),'o','color','k');
        if udata.settings.DynamicG2XScale == 2
            %errorbarlogx;
            set(gca,'xscale','log');
        end
        tag_g2errorbars(herr,udata.settings.DynamicG2PlotErrorbars);
        title_label_str = [title_label_str0,num2str(x{ii}(jj))];
        if udata.settings.DynamicFitting == 1 || udata.settings.DynamicFitting == 3
           title_label_str = [title_label_str,' (',num2str(tauFIT1{ii}(jj),'%.2f'),'s)'];
            plot(dt{ii},g2avgFIT1{ii}(jj,:),'b-');
        end
        if udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3
            title_label_str = [title_label_str,' (',num2str(tauFIT2{ii}(jj),'%.2f'),'s)'];
            plot(dt{ii},g2avgFIT2{ii}(jj,:),'r-');
        end

        hold off; box on;
        set(gca,'xminortick','on');
        xlims = (get(gca,'xlim'));
        if udata.settings.DynamicG2XScale == 2
            xlim_min = 10.^floor(log10(dt{ii}(1)));
            xlim_max = 10.^ceil(log10(dt{ii}(end)));
            set(gca,'xlim',[xlim_min,xlim_max]);
            set(gca,'xtick',10.^(floor(log10(xlims(1))):floor(log10(xlims(2)))));
        end
        title(title_label_str);
        xlabel('dt (s)');
        ylabel('g_2');
    end
end

function plot_dynamics_tau(x,...
    tauFIT1,tauFIT2,tauErrFIT1,tauErrFIT2,...
    baselineFIT1,baselineFIT2,baselineErrFIT1,baselineErrFIT2,...
    contrastFIT1,contrastFIT2,contrastErrFIT1,contrastErrFIT2,...
    exponentFIT2,exponentErrFIT2,...
    udata,xlabel_str)
for ii=1:length(udata.settings.Batch)
    set(figure(figure_handle_check(6000)),...
        'position',udata.settings.DynamicFigPos,...
        'Name',['Fitting - ',udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))],...
        'Tag','viewresult_Fig_Fitting',...
        'PaperOrientation','landscape',...
        'PaperPositionMode','manual',...
        'PaperSize',[11 8.5],...
        'PaperType','usletter',...
        'PaperPosition',[0.25 0.25 10.5 7.75]);
    supertitle([udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))]);
    subplot(2,2,1); % contrast plot
    plot_dynamics_tau_subplot(x{ii},contrastFIT1{ii},contrastErrFIT1{ii},contrastFIT2{ii},contrastErrFIT2{ii},udata,xlabel_str,'Contrast');
    ylim([-0.2 1.2]);
    subplot(2,2,2); % baseline plot
    plot_dynamics_tau_subplot(x{ii},baselineFIT1{ii},baselineErrFIT1{ii},baselineFIT2{ii},baselineErrFIT2{ii},udata,xlabel_str,'Baseline');
    ylim([0.5 1.5]);
    if udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3
        subplot(2,2,3); % exponent plot
        plot_dynamics_tau_subplot(x{ii},[],[],exponentFIT2{ii},exponentErrFIT2{ii},udata,xlabel_str,'Streching Exponent');        
        ylim([-0.2 2.5]);
    end
    subplot(2,2,4); % tauq plot
    plot_dynamics_tau_subplot(x{ii},tauFIT1{ii},tauErrFIT1{ii},tauFIT2{ii},tauErrFIT2{ii},udata,xlabel_str,'Tau (sec)');    
    errorbarlogy;
end

function plot_dynamics_tau_subplot(x,y1,yErr1,y2,yErr2,udata,xlabel_str,ylabel_str)
hold on;
legend_str = {};
if (udata.settings.DynamicFitting == 1 || udata.settings.DynamicFitting == 3) && ~isempty(y1)
    errorbar(x,y1,yErr1,'bo');
    legend_str = [legend_str,'Simple Exp'];
end
if (udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3) &&  ~isempty(y2)
    errorbar(x,y2,yErr2,'rs');
    legend_str = [legend_str,'Streched Exp'];
end
hold off; box on;
if udata.settings.DynamicXScale == 2
    %errorbarlogx;
    set(gca,'xscale','log');
 %   xlims = get(gca,'xlim');
%    xticks = 10.^(floor(log10(xlims(1))):ceil(log10(xlims(2))));
 %   set(gca,'xtick',xticks);
end
set(gca,'xminortick','on');
xlabel(xlabel_str);
ylabel(ylabel_str);
legend(legend_str);

function viewresult_PushbuttonAvgDynamicFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
udata = averageG2(udata,udata.settings.Batch(:)');
set(hFigViewresult,'UserData',udata);
viewresult_EditBatches2average_initialize(hFigViewresult,udata);

function viewresult_PushbuttonPlotAvgDynamicFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
if ~isfield(udata.result,'batches2average') || isempty(udata.result.batches2average)
    return;
end
batches2average_str = get(findobj(hFigViewresult,'tag','viewresult_EditBatches2average'),'string');
% get averaged data
[dt,x,g2avg,g2avgErr,g2avgFIT1,g2avgFIT2,...
    tauFIT1,tauFIT2,tauErrFIT1,tauErrFIT2,...
    baselineFIT1,baselineFIT2,baselineErrFIT1,baselineErrFIT2,...
    contrastFIT1,contrastFIT2,contrastErrFIT1,contrastErrFIT2,...
    exponentFIT2,exponentErrFIT2] = get_avg_dynamic_data(udata);
if udata.settings.DynamicSelect == 1            
    x_str = 'q';
elseif udata.settings.DynamicSelect == 2
    x_str = 'phi';
end
% --- plot g2
for jj=1:min(udata.settings.G2Panel*udata.settings.DynamicNumberOfG2Figures,length(x))
    if mod(jj-1,udata.settings.G2Panel) == 0
        set(figure(figure_handle_check(7000)),...
            'position',udata.settings.DynamicFigPos,...
            'Name',['G2 (Average) - ',udata.filename,' - Batches #',batches2average_str],'Tag','viewresult_Fig_G2Avg',...
            'PaperOrientation','landscape',...
            'PaperPositionMode','manual',...
            'PaperSize',[11 8.5],...
            'PaperType','usletter',...
            'PaperPosition',[0.25 0.25 10.5 7.75]);
        supertitle([udata.filename,' - Batch #',batches2average_str]);
    end
    subplot(udata.settings.G2PanelRow,udata.settings.G2PanelCol,mod(jj-1,udata.settings.G2Panel)+1);
    hold on;
    herr = errorbar(dt,g2avg(jj,:), g2avgErr(jj,:),'o','color','k');
    if udata.settings.DynamicG2XScale == 2
        %errorbarlogx;
        set(gca,'xscale','log');
    end
    tag_g2errorbars(herr,udata.settings.DynamicG2PlotErrorbars);
    title_label_str = [x_str,'=',num2str(x(jj))];
    if udata.settings.DynamicFitting == 1 || udata.settings.DynamicFitting == 3
        title_label_str = [title_label_str,' (',num2str(tauFIT1(jj),'%.2f'),'s)'];
        plot(dt,g2avgFIT1(jj,:),'b-');
    end
    if udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3
        title_label_str = [title_label_str,' (',num2str(tauFIT2(jj),'%.2f'),'s)'];
        plot(dt,g2avgFIT2(jj,:),'r-');
    end
    hold off; box on;
    set(gca,'xminortick','on');
    xlims = (get(gca,'xlim'));
    if udata.settings.DynamicG2XScale == 2
        xlim_min = 10.^floor(log10(dt(1)));
        xlim_max = 10.^ceil(log10(dt(end)));
        set(gca,'xlim',[xlim_min,xlim_max]);
        set(gca,'xtick',10.^(floor(log10(xlims(1))):floor(log10(xlims(2)))));
    end
    title(title_label_str);
    xlabel('dt (s)');
    ylabel('g_2');
end
% --- plot fitting result
if udata.settings.DynamicFitting == 4
    return;
end
set(figure(figure_handle_check(7000)),...
    'position',udata.settings.DynamicFigPos,...
    'Name',['Fitting (Average) - ',udata.filename,' - Batch #',batches2average_str],...
    'Tag','viewresult_Fig_Fitting_Avg',...
    'PaperOrientation','landscape',...
    'PaperPositionMode','manual',...
    'PaperSize',[11 8.5],...
    'PaperType','usletter',...
    'PaperPosition',[0.25 0.25 10.5 7.75]);
supertitle([udata.filename,' - Batch #',batches2average_str]);
% contrast plot
subplot(2,2,1);
hold on;
legend_str = {};
if udata.settings.DynamicFitting == 1 || udata.settings.DynamicFitting == 3
    errorbar(x,contrastFIT1,contrastErrFIT1,'bo');
    legend_str = [legend_str,'Simple Exp'];
end
if udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3
    errorbar(x,contrastFIT2,contrastErrFIT2,'rs');
    legend_str = [legend_str,'Streched Exp'];
end
hold off; box on;
if udata.settings.DynamicXScale == 2
    %errorbarlogx;
    set(gca,'xscale','log');    
    xlims = get(gca,'xlim');
    xticks = 10.^(floor(log10(xlims(1))):ceil(log10(xlims(2))));
    set(gca,'xtick',xticks);
end
set(gca,'xminortick','on');
xlabel(x_str);
ylabel('Contrast');
legend(legend_str);
% baseline plot
subplot(2,2,2);
hold on;
if udata.settings.DynamicFitting == 1 || udata.settings.DynamicFitting == 3
    errorbar(x,baselineFIT1,baselineErrFIT1,'bo');
end
if udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3
    errorbar(x,baselineFIT2,baselineErrFIT2,'rs');
end
hold off; box on;
if udata.settings.DynamicXScale == 2
    %errorbarlogx;
    set(gca,'xscale','log');    
    set(gca,'xtick',xticks);
end
set(gca,'xminortick','on');
xlabel(x_str);
ylabel('Baseline');
% stretching exponent plot
if udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3
    subplot(2,2,3);
    errorbar(x,exponentFIT2,exponentErrFIT2,'rs');
    box on;
    if udata.settings.DynamicXScale == 2
        %errorbarlogx;
        set(gca,'xscale','log');        
        set(gca,'xtick',xticks);
    end
    set(gca,'xminortick','on');
    xlabel(x_str);
    ylabel('Stretching Exponent');
end
% tau plot
subplot(2,2,4);
hold on;
if udata.settings.DynamicFitting == 1 || udata.settings.DynamicFitting == 3
    errorbar(x,tauFIT1,tauErrFIT1,'bo');
end
if udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3
    errorbar(x,tauFIT2,tauErrFIT2,'rs');
end
hold off; box on;
if udata.settings.DynamicXScale == 2
    %errorbarlogx;
    set(gca,'xscale','log');    
    set(gca,'xtick',xticks);
end
set(gca,'xminortick','on');
errorbarlogy;
xlabel(x_str);
ylabel('Tau (sec)');

function viewresult_PushbuttonAvgAndPlotDynamicFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonAvgDynamic'),'callback'));
feval(get(findall(hFigViewresult,'tag','viewresult_PushbuttonPlotAvgDynamic'),'callback'));

function viewresult_PushbuttonExportAvgDynamicFcn(varargin)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
% % if ~isfield(udata.result,'batches2average') || isempty(udata.result.batches2average)
% %     return;
% % end
viewresultinfo = getappdata(hFigViewresult,'viewresultinfo');
if isfield(viewresultinfo,'cluster')            % determine for cluster result
    viewresultinfo.cluster.result = udata.result;
else
    viewresultinfo.result = udata.result;
end    
if nargin == 3          % for command access: the third input is the .mat file name with path to be saved
    file2save = varargin{3};
else
    default_file = fullfile(udata.filepath,[udata.filename,'_avg.mat']);
    [filename, filepath] = uiputfile('*.mat','Save Averaged Result As',default_file);
    if ( isequal([filename,filepath],[0,0]) ), return; end;
    file2save = fullfile(filepath,filename);
end
save(file2save,'viewresultinfo');

function viewresult_savesettings(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
% udata.settings.PlotMode = get(findobj(hFigViewresult,'tag','viewresult_PopupmenuPlotMode'),'value');
hListboxBatch = findobj(hFigViewresult,'tag','viewresult_ListboxBatch');
batchlist = str2num(get(hListboxBatch,'string'));
udata.settings.Batch = batchlist(get(hListboxBatch,'value'));
udata.settings.PlotImageScale = get(findobj(hFigViewresult,'tag','viewresult_PopupmenuImageScale'),'value');
udata.settings.StaticSelect = get(findobj(hFigViewresult,'tag','viewresult_PopupmenuStaticSelect'),'value');
udata.settings.StaticXScale = get(findobj(hFigViewresult,'tag','viewresult_PopupmenuStaticXScale'),'value');
if isfield(udata.result,'dynamicQs')
    udata.settings.DynamicSelect = get(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicSelect'),'value');
    udata.settings.DynamicXScale = get(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicXScale'),'value');
    udata.settings.DynamicG2XScale = get(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicG2XScale'),'value');    
    udata.settings.DynamicFitting = get(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicFitting'),'value');
    udata.settings.DynamicG2PlotErrorbars = get(findobj(hFigViewresult,'tag','viewresult_PopupmenuDynamicG2PlotErrorbars'),'value');    
    udata.settings.DynamicNumberOfG2Figures = str2double(get(findobj(hFigViewresult,'tag','viewresult_EditNumberOfG2Figures'),'String'));
end
set(hFigViewresult,'UserData',udata);

function viewresult_PushbuttonRestoreDefaultFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
udata = rmfield(udata,'settings');
set(hFigViewresult,'UserData',udata);
viewresult_initialize(hFigViewresult);

function viewresult_PushbuttonPlotAllFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
udata = get(hFigViewresult,'UserData');
feval(get(findall(hFigViewresult,'Tag','viewresult_PushbuttonPlotAvgImage'),'Callback'));
feval(get(findall(hFigViewresult,'Tag','viewresult_PushbuttonPlotTotalInt'),'Callback'));
feval(get(findall(hFigViewresult,'Tag','viewresult_PushbuttonPlotStability'),'Callback'));
feval(get(findall(hFigViewresult,'Tag','viewresult_PushbuttonPlotStatic'),'Callback'));
if isfield(udata.result,'dynamicQs')
    feval(get(findall(hFigViewresult,'Tag','viewresult_PushbuttonPlotDynamic'),'Callback'));
end

function viewresult_PushbuttonCloseAllFcn(~,~)
hfigs = findall(0,'type','figure');
tags = get(hfigs,'tag');
if ~iscell(tags), tags = {tags}; end
for ii=1:length(hfigs)
    if ~isempty(strfind(tags{ii},'viewresult_Fig_')), delete(hfigs(ii)); end
end

function viewresult_CloseRequestFcn(~,~)
hFigViewresult = findall(0,'Tag','viewresult_Fig');
delete(hFigViewresult);

function viewresultinfo = creat_result_field(viewresultinfo)
pause(0.1);
hwarndlg = warndlg('Please wait while creating result fields ...','Old Result File','modal');
for ii=1:length(viewresultinfo.result.aIt)
    try
        viewresultinfo = save_local_results(viewresultinfo,ii);
    catch
        continue;
    end
end
delete(hwarndlg);

function hfig = figure_handle_check(fign)
intn = 10^floor(log10(fign));
startn = floor(fign/intn)*intn+1;
endn = startn-1+intn;
if verLessThan('Matlab','8.4')
    h = findall(0,'type','figure');
    h = h(h<=endn & h>=startn);
else
    h = get(findall(0,'type','figure'),'number');
    if ~isempty(h)      % extract figure numbers
        if iscell(h)
            h = cell2mat(h);
        end
        h = h(h<=endn & h>=startn);
    end
end
hfig = startn;
if isempty(h)
    return;
else
    while(~isempty(find(h==hfig)))
        hfig = hfig+1;
    end
    if hfig > endn
        error('Returned figure handle exceeds the range.');
    end
end


% function off_warning_msg(msg)
% msg = 'MATLAB:Axes:NegativeDataInLogAxis';
% s = warning('query',msg);
% warning('off',msg);
% warning(s.state,msg);
%
% function restore_warning_msg
% msg = 'MATLAB:Axes:NegativeDataInLogAxis';
% s = warning('query',msg);
% warning('off',msg);
% warning(s.state,msg);
% EOF
