function [fit2data,baseline,contrast,gamma,exponent,baseline_err,contrast_err,gamma_err,exponent_err,resnorm]= ...
                fit2stretchedexp(varargin)
%                     fit2stretchedexp(delay,g2,g2Err)

delay   = varargin{1};
g2      = varargin{2};
g2Err   = varargin{3};

xdata=double(delay);
ydata=double(g2);
edata=double(g2Err);

if (nargin == 7)
    %%flexible fitting routine where parameters can be kept fixed or
    %%varied and limits can be set and so on
    
    FIT2_Start  = varargin{4};
    FIT2_Flag   = varargin{5};
    FIT2_lb     = varargin{6};
    FIT2_ub     = varargin{7};
    
%     FIT2_vary are the params to be fitted
    FIT2_vary = FIT2_Start(find(FIT2_Flag==1));
%     FIT2_fix are the params to be kept fixed
    FIT2_fix = FIT2_Start(find(FIT2_Flag==0));
    
    FIT2_lb1 = FIT2_lb(find(FIT2_Flag==1));
    FIT2_ub1 = FIT2_ub(find(FIT2_Flag==1));
    
    
    options=optimset('disp','off','larges','on','jacobi','off',...
        'diagn','off','tolx',1e-15,'tolf',1e-15,'MaxFunEvals',1500,'maxit',500);
    [fit2,resnorm,residual,exitflag,output,lambda,jacobian]= ...
        lsqcurvefit(@stretchedExponent,FIT2_vary,xdata,ydata,FIT2_lb1,FIT2_ub1,options, ...
        FIT2_fix,FIT2_Flag);
    
    fit2data = ydata+residual;
    
    FIT2_final=zeros(1,length(FIT2_Flag));
    FIT2_final(find(FIT2_Flag==1)) = fit2;
    FIT2_final(find(FIT2_Flag==0)) = FIT2_fix;
    
    %calculate error bars for the fits
    s2=resnorm/(length(residual) - 3);
    [Q,R]=qr(jacobian,0);
    Rinv=inv(R);
    sigmaest=(Rinv*Rinv')*s2;
    stderrors=sqrt(diag(sigmaest));
    
    FIT2_err=zeros(1,length(FIT2_Flag));
    FIT2_err(find(FIT2_Flag==1)) = stderrors;
    FIT2_err(find(FIT2_Flag==0)) = NaN;
    
    
    % --- store some results (parameters,resnorm,...)
    baseline = FIT2_final(1)                              ;
    contrast = FIT2_final(2)                              ;
    gamma = FIT2_final(3)                              ;
    exponent = FIT2_final(4)                              ;
    baseline_err = FIT2_err(1); 
    contrast_err = FIT2_err(2);
    gamma_err = FIT2_err(3); 
    exponent_err = FIT2_err(4);
    
elseif (nargin == 3)
    %%standard fitting routine that is used in xpcsgui
    
    % --- parameters % limits for stretched exponential fit
    if (numel(xdata) > 5)
        
        % kludge to avoid NaN at last y point in calc'ed data
        fooEnd=ydata(end-4:end);
        TF = isnan(fooEnd);
        fooEnd(TF)=[];
        if isempty(fooEnd)
            baseline = 1;
        else
            baseline = sum(fooEnd)                    ...
                / numel(fooEnd)                     ; % take the average of some data points as baseline
        end
        %baseline = sum(ydata(end-4:end))                    ...
        %    / numel(ydata(end-4:end))                     ; % take the average of some data points as baseline
        
        contrast = sum(ydata(1:4)) / numel(ydata(1:4))      ...
            - baseline                                    ; % take the average of some data points minus baseline as contrast
        contrast = max(0.01, contrast)                         ; % make sure the contrast is positive
        gamma    = 1 / xdata(floor(numel(xdata)/2))            ; % put the starting gamma value into the middle of the time axis
        if ( contrast > 0.01 )                                  % standard correlation function (some decay)
            corrcase = 0                                       ;
        end
        if ( contrast == 0.01 && baseline > 1.05 )               % no decay; only static specles
            baseline = 1.0                                     ; % fix the baseline at 1
            contrast = sum(ydata(1:4))/numel(ydata(1:4)) - 1.0 ; % take the average of some data points minus 1 as contrast
            gamma    = 1 / (1000 * xdata(end))                 ; % shift the relaxation rate gamma to very small values
            corrcase = 1                                       ;
        end
        if (  contrast == 0.01 && baseline <= 1.05 )             % already fully decayed
            gamma    = 1 / (xdata(1)/1000)                     ; % shift the relaxation rate gamma to very large values
            corrcase = 2                                       ;
        end
    else
        baseline = 1.0                                         ; % emergency default baseline start parameter
        contrast = 0.3                                         ; % emergency default contrast start parameter
        gamma    = 1.0                                         ; % emergency default gamma start parameter
        corrcase = 0                                           ;
    end
    exponent = 1.0                                             ;
    
    
    start2 = [baseline contrast gamma exponent]                ;
    if ( corrcase == 0 )
        low2   = [baseline/2 contrast/5 gamma/1e03 exponent/3] ;
        high2  = [baseline*2 contrast*5 gamma*1e03 exponent*3] ;
    end
    if ( corrcase == 1 )
        low2   = [0.995 contrast/5 gamma/1e03 exponent/3]      ;
        high2  = [1.005 contrast*5 gamma*1e03 exponent*3]      ;
    end
    if ( corrcase == 2 )
        low2   = [baseline/2 contrast/5 gamma/1e03 exponent/3] ;
        high2  = [baseline*2 contrast*5 gamma*1e03 exponent*3] ;
    end
    clear baseline contrast gamma exponent corrcase            ;
    
    % --- perform fit & calculated best fit at data points
    opt = optimset ('Display','off','MaxIter',500,          ...
        'MaxFunEvals',2000,'TolX',1.0e-15)         ;
    [fit2,sig2,fit2_resnorm,fit2_flag,fit2data] =           ...
        myeasyfit(@stretchedExponent1,xdata,ydata,edata    ...
        ,start2,low2,high2,opt)                     ;
    %                 [fit2,fit2_resnorm,fit2_residual,fit2_flag,fit2_info] = ...
    %                     lsqcurvefit (@stretchedExponent,start2,xdata,ydata, ...
    %                                  low2,high2,opt)                           ;
    %                 fit2data = stretchedExponent(fit2,xdata)                   ;
    %                 sig2 = errorsigma(xdata,ydata,edata,fit2,0.01*fit2      ...
    %                                  ,ones(size(fit2)),@stretchedExponent,fit2data) ; % calculate sigmas of fitting parameter
    
    % --- store some results (parameters,resnorm,...)
    baseline = fit2(1)                              ;
    contrast = fit2(2)                              ;
    gamma = fit2(3)                              ;
    exponent = fit2(4);
    baseline_err = sig2(1)                              ;
    contrast_err = sig2(2)                              ;
    gamma_err = sig2(3);
    exponent_err = sig2(4);
    
end
    
    return
    
    % =========================================================================
% --- function for stretched exponential fit
% =========================================================================
function F = stretchedExponent(x0,xdata,FIT2_fix,FIT2_Flag)
%%%used with the flexible fitting routine
% ---
% --- x(1) : Baseline
% --- x(2) : Contrast
% --- x(3) : Gamma = 1/tau
% --- x(4) : Stretching Exponent
% ---
    x=zeros(1,length(FIT2_Flag));
    x(find(FIT2_Flag==1)) = x0;
    x(find(FIT2_Flag==0)) = FIT2_fix;

F = x(1) + x(2) * exp( - 2 * (x(3) * xdata).^x(4) )                        ; % this assumes a homodyne detection scheme
return
% =========================================================================

function F = stretchedExponent1(x,xdata)
%%%used with the standard xpcsgui fitting routine
% ---
% --- x(1) : Baseline
% --- x(2) : Contrast
% --- x(3) : Gamma = 1/tau
% --- x(4) : Stretching Exponent
% ---
F = x(1) + x(2) * exp( - 2 * (x(3) * xdata).^x(4) )                        ; % this assumes a homodyne detection scheme
return

