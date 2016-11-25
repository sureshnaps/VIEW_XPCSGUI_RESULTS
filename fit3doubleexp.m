function [fitg2data,baseline,contrast,ratio,tau1,tau2,baseline_err,contrast_err,ratio_err,tau1_err,tau2_err] = fit3doubleexp(varargin)

dt      = varargin{1};
g2      = varargin{2};
g2Err   = varargin{3};

parInit = varargin{4};      % initial paramters (5x1)
fitFlag = varargin{5};      % parameters to fit (5x1)

dt      = double(dt(:));
g2      = double(g2(:));
g2Err   = double(g2Err(:));

%% construct fitting parameters and settings
baseline   = parInit(1);
contrast   = parInit(2);
ratio      = parInit(3);
tau1       = parInit(4);
tau2       = parInit(5);
fit_struct = [...
    baseline     -Inf     Inf     0
    contrast     eps      Inf     0
    ratio        0        1       0
    tau1         eps      Inf     0
    tau2         eps      Inf     0];
fit_struct(:,4) = fitFlag;
x       = fit_struct(:,1);
lb      = fit_struct(:,2);
ub      = fit_struct(:,3);
fitFlag = fit_struct(:,4);
x1 = x(fitFlag==1);
x2 = x(fitFlag==0);
lb1 = lb(fitFlag==1);
ub1 = ub(fitFlag==1);

%% --- start fitting
options = optimset (...
    'Display','off',...
    'TolX',1e-9,...
    'TolFun',1e-9,...
    'FunValCheck','on',...
    'MaxFunEvals',800,...
    'MaxIter',600);
[fittedX1,resnorm,residual,exitflag,output,lambda,jacobian] = ...
    lsqcurvefit(@fcn_fit_doubleexp,x1,dt,g2,lb1,ub1,options,x2,fitFlag);
% --- error estimation
s2=resnorm/(length(residual) - 3);
[Q,R]=qr(jacobian,0);
Rinv=inv(R);
sigmaest=(Rinv*Rinv')*s2;
stderrors=sqrt(diag(sigmaest));

%% reconstruct parameters
% --- get fitting g2 values
fitg2data = g2+residual;
% --- get fitting parameters
x=zeros(1,length(fitFlag));
x(fitFlag==1) = fittedX1;
x(fitFlag==0) = x2;

err = NaN*ones(1,length(fitFlag));
err(fitFlag == 1) = stderrors;

baseline   = x(1);
contrast   = x(2);
ratio      = x(3);
tau1       = x(4);
tau2       = x(5);

baseline_err = err(1);
contrast_err = err(2);
ratio_err = err(3);
tau1_err = err(4);
tau2_err = err(5);


function g2 = fcn_fit_doubleexp(x1,dt,x2,fitFlag)

% --- construct fitting parameters
x=zeros(1,length(fitFlag));
x(fitFlag==1) = x1;
x(fitFlag==0) = x2;

baseline   = x(1);
contrast   = x(2);
ratio      = x(3);
tau1       = x(4);
tau2       = x(5);

g2 = baseline+contrast*(ratio*exp(-dt/tau1)+(1-ratio)*exp(-dt/tau2)).^2;
