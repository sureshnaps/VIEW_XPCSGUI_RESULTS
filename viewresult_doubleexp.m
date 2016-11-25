function viewresult_doubleexp(varargin)
tmp = varargin{1};

if (nargin >=2)
    batchlist = varargin{2};
else
    batchlist = 1;
end

if isempty(batchlist) 
    viewresultinfo = tmp;
    viewresultinfo.result.g2avgFIT3 = {};
    viewresultinfo.result.baselineFIT3={};
    viewresultinfo.result.contrastFIT3={};
    viewresultinfo.result.ratioFIT3={};
    viewresultinfo.result.tau1FIT3={};
    viewresultinfo.result.tau2FIT3={};
    viewresultinfo.result.baselineErrFIT3={};
    viewresultinfo.result.contrastErrFIT3={};
    viewresultinfo.result.ratioErrFIT3={};
    viewresultinfo.result.tau1ErrFIT3={};
    viewresultinfo.result.tau2ErrFIT3={};
    
    viewresultinfo.result.g2avgFIT3{1}  = viewresultinfo.result.g2BatchavgFIT3;
    viewresultinfo.result.baselineFIT3{1}      = viewresultinfo.result.baselineBatchavgFIT3;
    viewresultinfo.result.contrastFIT3{1}      = viewresultinfo.result.contrastBatchavgFIT3;
    viewresultinfo.result.ratioFIT3{1}         = viewresultinfo.result.ratioBatchavgFIT3;
    viewresultinfo.result.tau1FIT3{1}          = viewresultinfo.result.tau1BatchavgFIT3;
    viewresultinfo.result.tau2FIT3{1}          = viewresultinfo.result.tau2BatchavgFIT3;
    viewresultinfo.result.baselineErrFIT3{1}   = viewresultinfo.result.baselineErrBatchavgFIT3;
    viewresultinfo.result.contrastErrFIT3{1}   = viewresultinfo.result.contrastErrBatchavgFIT3;
    viewresultinfo.result.ratioErrFIT3{1}      = viewresultinfo.result.ratioErrBatchavgFIT3;
    viewresultinfo.result.tau1ErrFIT3{1}       = viewresultinfo.result.tau1ErrBatchavgFIT3;
    viewresultinfo.result.tau2ErrFIT3{1}       = viewresultinfo.result.tau2ErrBatchavgFIT3;
    batchlist = 1;
    udata.avgFlag = 1;
else
    viewresultinfo = tmp;
    udata.avgFlag = 0;
end

if nargin == 3
    filename = varargin{3};
else
    filename = '';
end
udata.settings.G2Panel = 9;
udata.settings.G2PanelRow = 3;
udata.settings.G2PanelCol = 3;
udata.settings.DynamicFigPos = [100,50,960,720];
udata.settings.DynamicSelect = 1;
udata.settings.DynamicSelectQ = 1;
udata.settings.DynamicSelectPHI = 1;
udata.settings.DynamicXScale = 2;
udata.settings.DynamicFitting = 3;
udata.settings.Batch = batchlist;
udata.filename = filename;
udata.result = viewresultinfo.result;

% --- get data
[dt,x,g2avg,g2avgErr,g2avgFIT3,baselineFIT3,baselineErrFIT3,...
    contrastFIT3,contrastErrFIT3,ratioFIT3,ratioErrFIT3,...
    tau1FIT3,tau1ErrFIT3,tau2FIT3,tau2ErrFIT3] = get_dynamic_data_fit3(udata);
% --- settings
if udata.settings.DynamicSelect == 1
    title_label_str0 = 'q=';
    xlabel_str = 'q (A^{-1})';
elseif udata.settings.DynamicSelect == 2
    title_label_str0 = 'phi=';
    xlabel_str = 'phi';
end

% --- plot 
plot_dynamics_g2(dt,x,g2avg,g2avgErr,g2avgFIT3,tau1FIT3,tau2FIT3,udata,title_label_str0);
plot_dynamics_tau(x,...
    tau1FIT3,tau2FIT3,tau1ErrFIT3,tau2ErrFIT3,...
    baselineFIT3,baselineErrFIT3,...
    contrastFIT3,contrastErrFIT3,...
    ratioFIT3,ratioErrFIT3,...
    udata,xlabel_str);


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

function plot_dynamics_g2(dt,x,g2avg,g2avgErr,g2avgFIT3,tau1FIT3,tau2FIT3,udata,title_label_str0)
for ii=1:length(udata.settings.Batch)
    for jj=1:length(x{ii})
        if mod(jj-1,udata.settings.G2Panel) == 0
            set(figure(figure_handle_check(8000)),...
                'position',udata.settings.DynamicFigPos,...
                'Tag','viewresult_Fig_G2',...
                'PaperOrientation','landscape',...
                'PaperPositionMode','manual',...
                'PaperSize',[11 8.5],...
                'PaperType','usletter',...
                'PaperPosition',[0.25 0.25 10.5 7.75]);
            if udata.avgFlag == 0
                set(gcf,'Name',['G2 - ',udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))]);
                supertitle([udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))]);
            elseif udata.avgFlag == 1
                batches2average_str = batches2average_str_fcn(udata.result.batches2average);
                set(gcf,'Name',['G2 (Average) - ',udata.filename,' - Batch #',batches2average_str]);
                supertitle([udata.filename,' - Batch #',batches2average_str]);
            end
        end
        subplot(udata.settings.G2PanelRow,udata.settings.G2PanelCol,mod(jj-1,udata.settings.G2Panel)+1);
        hold on;
        herr = errorbar(dt{ii},g2avg{ii}(jj,:),g2avgErr{ii}(jj,:),'o','color','k');
        %errorbarlogx;
        set(gca,'xscale','log');
        tag_g2errorbars(herr,1);%udata.settings.DynamicG2PlotErrorbars);
        
        title_label_str = [title_label_str0,num2str(x{ii}(jj))];
        title_label_str = [title_label_str,' (',num2str(tau1FIT3{ii}(jj),'%.2f'),'s)'];
        title_label_str = [title_label_str,' (',num2str(tau2FIT3{ii}(jj),'%.2f'),'s)'];
        plot(dt{ii},g2avgFIT3{ii}(jj,:),'r-');
        hold off; box on;
        set(gca,'xminortick','on');
        xlims = (get(gca,'xlim'));
        set(gca,'xtick',10.^(floor(log10(xlims(1))):floor(log10(xlims(2)))));
        title(title_label_str);
        xlabel('dt (s)');
        ylabel('g_2');
    end
    
end

function plot_dynamics_tau(x,tau1FIT3,tau2FIT3,tau1ErrFIT3,tau2ErrFIT3,...
    baselineFIT3,baselineErrFIT3,contrastFIT3,contrastErrFIT3,...
    ratioFIT3,ratioErrFIT3,udata,xlabel_str)
for ii=1:length(udata.settings.Batch)
    set(figure(figure_handle_check(8000)),...
        'position',udata.settings.DynamicFigPos,...
        'Tag','viewresult_Fig_Fitting',...
        'PaperOrientation','landscape',...
        'PaperPositionMode','manual',...
        'PaperSize',[11 8.5],...
        'PaperType','usletter',...
        'PaperPosition',[0.25 0.25 10.5 7.75]);
    if udata.avgFlag == 0
        set(gcf,'Name',['Fitting - ',udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))]);
        supertitle([udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))]);        
    elseif udata.avgFlag == 1
        batches2average_str = batches2average_str_fcn(udata.result.batches2average);
        set(gcf,'Name',['Fitting (Average) - ',udata.filename,' - Batch #',batches2average_str]);
        supertitle([udata.filename,' - Batch #',batches2average_str]);                
    end
    subplot(6,2,[1,3]); % contrast plot
    plot_dynamics_tau_subplot(x{ii},contrastFIT3{ii},contrastErrFIT3{ii},udata,xlabel_str,'Constrast');
    set(gca,'ylim',[0,max(contrastFIT3{ii})]);
    subplot(6,2,[5,7]); % baseline plot
    set(gca,'ylim',[min(baselineFIT3{ii})-eps,max(baselineFIT3{ii})+eps]);
    plot_dynamics_tau_subplot(x{ii},baselineFIT3{ii},baselineErrFIT3{ii},udata,xlabel_str,'Baseline');
    subplot(6,2,[9,11]); % ratio plot
    plot_dynamics_tau_subplot(x{ii},ratioFIT3{ii},ratioErrFIT3{ii},udata,xlabel_str,'Ratio (for tau1)');    
    set(gca,'ylim',[0,1]);
    subplot(6,2,[2,4,6]); % tau1 q plot
    plot_dynamics_tau_subplot(x{ii},tau1FIT3{ii},tau1ErrFIT3{ii},udata,xlabel_str,'Tau1 (sec)');    
    errorbarlogy;
    subplot(6,2,[8,10,12]); % tau2 q plot
    plot_dynamics_tau_subplot(x{ii},tau2FIT3{ii},tau2ErrFIT3{ii},udata,xlabel_str,'Tau2 (sec)');    
    errorbarlogy;
end

function plot_dynamics_tau_subplot(x,y,yErr,udata,xlabel_str,ylabel_str)
hold on;
legend_str = {};
errorbar(x,y,yErr,'bo');
legend_str = [legend_str,'Double Exp'];
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


function [dt,x,g2avg,g2avgErr,g2avgFIT3,baselineFIT3,baselineErrFIT3,...
    contrastFIT3,contrastErrFIT3,ratioFIT3,ratioErrFIT3,...
    tau1FIT3,tau1ErrFIT3,tau2FIT3,tau2ErrFIT3] = get_dynamic_data_fit3(udata)
% --- get all dt, q, phi
dt  =  cell(size(udata.settings.Batch));
q   = cell(size(udata.settings.Batch));
phi = cell(size(udata.settings.Batch));
for ii=1:length(udata.settings.Batch)
    dt{ii} = udata.result.delay{udata.settings.Batch(ii)};
    q{ii} = udata.result.dynamicQs{udata.settings.Batch(ii)}(:,udata.settings.DynamicSelectQ);
    q{ii}(q{ii}==0) = NaN;
    phi{ii} = udata.result.dynamicPHIs{udata.settings.Batch(ii)}(udata.settings.DynamicSelectPHI,:);
    phi{ii}(phi{ii}==0) = NaN;
end
% --- get all dynamic data
g2avg       = udata.result.g2avg(udata.settings.Batch);
g2avgErr    = udata.result.g2avgErr(udata.settings.Batch);
g2avgFIT3   = udata.result.g2avgFIT3(udata.settings.Batch);
tau1FIT3             = udata.result.tau1FIT3(udata.settings.Batch);
tau2FIT3             = udata.result.tau2FIT3(udata.settings.Batch);
tau1ErrFIT3          = udata.result.tau1ErrFIT3(udata.settings.Batch);
tau2ErrFIT3          = udata.result.tau2ErrFIT3(udata.settings.Batch);
baselineFIT3        = udata.result.baselineFIT3(udata.settings.Batch);
baselineErrFIT3     = udata.result.baselineErrFIT3(udata.settings.Batch);
contrastFIT3        = udata.result.contrastFIT3(udata.settings.Batch);
contrastErrFIT3     = udata.result.contrastErrFIT3(udata.settings.Batch);
ratioFIT3           = udata.result.ratioFIT3(udata.settings.Batch);
ratioErrFIT3        = udata.result.ratioErrFIT3(udata.settings.Batch);
% --- determine q or phi to reduce dynamic data
if udata.settings.DynamicSelect == 1
    x = q;
    for ii=1:length(udata.settings.Batch)
        g2avg{ii}       = transpose(shiftdim(g2avg{ii}(:,udata.settings.DynamicSelectQ,:),2));
        g2avgErr{ii}    = transpose(shiftdim(g2avgErr{ii}(:,udata.settings.DynamicSelectQ,:),2));
        g2avgFIT3{ii}   = transpose(shiftdim(g2avgFIT3{ii}(:,udata.settings.DynamicSelectQ,:),2));
        tau1FIT3{ii}             = tau1FIT3{ii}(:,udata.settings.DynamicSelectQ);
        tau2FIT3{ii}             = tau2FIT3{ii}(:,udata.settings.DynamicSelectQ);
        tau1ErrFIT3{ii}          = tau1ErrFIT3{ii}(:,udata.settings.DynamicSelectQ);
        tau2ErrFIT3{ii}          = tau2ErrFIT3{ii}(:,udata.settings.DynamicSelectQ);
        baselineFIT3{ii}        = baselineFIT3{ii}(:,udata.settings.DynamicSelectQ);
        baselineErrFIT3{ii}     = baselineErrFIT3{ii}(:,udata.settings.DynamicSelectQ);
        contrastFIT3{ii}        = contrastFIT3{ii}(:,udata.settings.DynamicSelectQ);
        contrastErrFIT3{ii}     = contrastErrFIT3{ii}(:,udata.settings.DynamicSelectQ);
        ratioFIT3{ii}           = ratioFIT3{ii}(:,udata.settings.DynamicSelectQ);
        ratioErrFIT3{ii}        = ratioErrFIT3{ii}(:,udata.settings.DynamicSelectQ);
    end
elseif udata.settings.DynamicSelect == 2
    x = phi;
    for ii=1:length(udata.settings.Batch)
        g2avg{ii}       = (shiftdim(g2avg{ii}(udata.settings.DynamicSelectPHI,:,:),1));
        g2avgErr{ii}    = (shiftdim(g2avgErr{ii}(udata.settings.DynamicSelectPHI,:,:),1));
        g2avgFIT3{ii}   = (shiftdim(g2avgFIT3{ii}(udata.settings.DynamicSelectPHI,:,:),1));
        g2avgFIT3{ii}   = (shiftdim(g2avgFIT3{ii}(udata.settings.DynamicSelectPHI,:,:),1));
        tau1FIT3{ii}             = tau1FIT3{ii}(udata.settings.DynamicSelectPHI,:);
        tau2FIT3{ii}             = tau2FIT3{ii}(udata.settings.DynamicSelectPHI,:);
        tau1ErrFIT3{ii}          = tau1ErrFIT3{ii}(udata.settings.DynamicSelectPHI,:);
        tau2ErrFIT3{ii}          = tau2ErrFIT3{ii}(udata.settings.DynamicSelectPHI,:);
        baselineFIT3{ii}        = baselineFIT3{ii}(udata.settings.DynamicSelectPHI,:);
        baselineErrFIT3{ii}     = baselineErrFIT3{ii}(udata.settings.DynamicSelectPHI,:);
        contrastFIT3{ii}        = contrastFIT3{ii}(udata.settings.DynamicSelectPHI,:);
        contrastErrFIT3{ii}     = contrastErrFIT3{ii}(udata.settings.DynamicSelectPHI,:);
        ratioFIT3{ii}        = ratioFIT3{ii}(udata.settings.DynamicSelectPHI,:);
        ratioErrFIT3{ii}     = ratioErrFIT3{ii}(udata.settings.DynamicSelectPHI,:);
    end
end


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
