function [fit1data,baseline,contrast,gamma,baseline_err,contrast_err,gamma_err,resnorm]=fit1singleexp(varargin)
    %fit1singleexp(delay,g2,g2Err,FIT1_Start,FIT1_Flag,FIT1_lb,FIT1_ub)
                    

delay   = varargin{1};
g2      = varargin{2};
g2Err   = varargin{3};
                    
xdata=double(delay);
ydata=double(g2);
edata=double(g2Err);

if (nargin == 7) 
    %%flexible fitting routine where parameters can be kept fixed or
    %%varied and limits can be set and so on
    FIT1_Start  = varargin{4};
    FIT1_Flag   = varargin{5};
    FIT1_lb     = varargin{6};
    FIT1_ub     = varargin{7};
    
%     FIT1_vary are the params to be fitted
    FIT1_vary = FIT1_Start(find(FIT1_Flag==1));
%     FIT1_fix are the params to be kept fixed
    FIT1_fix = FIT1_Start(find(FIT1_Flag==0));
    
    FIT1_lb1 = FIT1_lb(find(FIT1_Flag==1));
    FIT1_ub1 = FIT1_ub(find(FIT1_Flag==1));
    
    
    options=optimset('disp','off','larges','on','jacobi','off',...
        'diagn','off','tolx',1e-15,'tolf',1e-15,'MaxFunEvals',1500,'maxit',500);
    [fit1,resnorm,residual,exitflag,output,lambda,jacobian]= ...
        lsqcurvefit(@singleExponent,FIT1_vary,xdata,ydata,FIT1_lb1,FIT1_ub1,options, ...
        FIT1_fix,FIT1_Flag);
    
    fit1data = ydata+residual;
    
    FIT1_final=zeros(1,length(FIT1_Flag));
    FIT1_final(find(FIT1_Flag==1)) = fit1;
    FIT1_final(find(FIT1_Flag==0)) = FIT1_fix;
    
    %calculate error bars for the fits
    s2=resnorm/(length(residual) - 3);
    [Q,R]=qr(jacobian,0);
    Rinv=inv(R);
    sigmaest=(Rinv*Rinv')*s2;
    stderrors=sqrt(diag(sigmaest));
    
    FIT1_err=zeros(1,length(FIT1_Flag));
    FIT1_err(find(FIT1_Flag==1)) = stderrors;
    FIT1_err(find(FIT1_Flag==0)) = NaN;
    
    
    % --- store some results (parameters,resnorm,...)
    baseline = FIT1_final(1)                              ;
    contrast = FIT1_final(2)                              ;
    gamma = FIT1_final(3)                              ;
    baseline_err = FIT1_err(1); 
    contrast_err = FIT1_err(2);
    gamma_err = FIT1_err(3); 
    

elseif (nargin == 3)
    %%standard fitting routine that is used in xpcsgui

    % --- parameters % limits for single exponential fit
    if (numel(xdata) > 5)
        
        % kludge to avoid NaN at last y point in calc'ed data
        fooEnd=ydata(end-2:end);
        TF = isnan(fooEnd);
        fooEnd(TF)=[];
        if isempty(fooEnd)
            baseline = 1;
        else
            baseline = sum(fooEnd)                    ...
                / numel(fooEnd)                     ; % take the average of some data points as baseline
        end
        %baseline = sum(ydata(end-2:end))                    ...
        %    / numel(ydata(end-2:end))                     ; % take the average of some data points as baseline
        
        contrast = sum(ydata(1:3)) / numel(ydata(1:3))      ...
            - baseline                                    ; % take the average of some data points minus baseline as contrast
        contrast = max(0.01, contrast)                         ; % make sure the contrast is positive
        gamma    = 1 / xdata(floor(numel(xdata)/2))            ; % put the starting gamma value into the middle of the time axis
        if ( contrast > 0.01 )                                  % standard correlation function (some decay)
            corrcase = 0                                       ;
        end
        if ( contrast == 0.01 && baseline >= 1.05 )              % no decay; only static specles
            baseline = 1.0                                     ; % fix the baseline at 1
            contrast = sum(ydata(1:4))/numel(ydata(1:4)) - 1.0 ; % take the average of some data points minus 1 as contrast
            gamma    = 1 / (1000 * xdata(end))                 ; % shift the relaxation rate gamma to very small values
            corrcase = 1                                       ;
        end
        if (  contrast == 0.01 && baseline < 1.05 )              % already fully decayed
            gamma    = 1 / (xdata(1)/1000)                     ; % shift the relaxation rate gamma to very large values
            corrcase = 2                                       ;
        end
    else
        baseline = 1.0                                         ; % emergency default baseline start parameter
        contrast = 0.3                                         ; % emergency default contrast start parameter
        gamma    = 1.0                                         ; % emergency default gamma start parameter
    end
    
    start1 = [baseline contrast gamma]                         ; % baseline, contrast & gamma
    if ( corrcase == 0 )
        low1   = [baseline/2 contrast/5 gamma/1e03]            ; % define lower limits
        high1  = [baseline*2 contrast*5 gamma*1e03]            ; % define higher limits
    end
    if ( corrcase == 1 )
        low1   = [0.995 contrast/5 gamma/1e03]                 ; % define lower limits
        high1  = [1.005 contrast*5 gamma*1e02]                 ; % define higher limits
    end
    if ( corrcase == 2 )
        low1   = [baseline/2 contrast/5 gamma/1e02]            ; % define lower limits
        high1  = [baseline*2 contrast*5 gamma*1e03]            ; % define higher limits
    end
    clear baseline contrast gamma corrcase                     ;

    
    % --- perform fit & calculated best fit at data points
    opt = optimset ('Display','off','MaxIter',500,          ...
        'MaxFunEvals',1500,'TolX',1.0e-15)         ;
    
    [fit1,sig1,fit1_resnorm,fit1_flag,fit1data] =           ...
        myeasyfit(@singleExponent1,xdata,ydata,edata       ...
        ,start1,low1,high1,opt)                     ;
    
% --- store some results (parameters,resnorm,...)
    baseline = fit1(1)                              ;
    contrast = fit1(2)                              ;
    gamma = fit1(3)                              ;
    baseline_err = sig1(1)                              ;
    contrast_err = sig1(2)                              ;
    gamma_err = sig1(3);
    

end

    return
    
    % =========================================================================
% --- function for single exponential fit
% =========================================================================
function F = singleExponent(x0,xdata,FIT1_fix,FIT1_Flag)
%%%used with the flexible fitting routine
% ---
% --- x(1) : Baseline
% --- x(2) : Contrast
% --- x(3) : Gamma = 1/tau
% ---
    x=zeros(1,length(FIT1_Flag));
    x(find(FIT1_Flag==1)) = x0;
    x(find(FIT1_Flag==0)) = FIT1_fix;

F = x(1) + x(2) * exp(- 2 * x(3) * xdata)                                  ; % this assumes a homodyne detection scheme
return

    % =========================================================================
% --- function for single exponential fit
% =========================================================================
function F = singleExponent1(x,xdata)
%%%used with the standard xpcsgui fitting routine
% ---
% --- x(1) : Baseline
% --- x(2) : Contrast
% --- x(3) : Gamma = 1/tau
% ---
F = x(1) + x(2) * exp(- 2 * x(3) * xdata)                                  ; % this assumes a homodyne detection scheme
return

