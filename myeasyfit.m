function [pbest,psigma,resnorm,flag,fbest,residual,out] =               ...
                        myeasyfit(fhandle,x,y,e,pinit,LB,UB,options)
%==========================================================================
%==========================================================================
% --- [PBEST,PSIGMA,RESNORM,FLAG,FBEST,RESIDUAL,OUT] = ...
% ---               MYEASYFIT(fhandle,x,y,e,pinit,LB,UB,options)
%==========================================================================
%==========================================================================
% --- Input parameters:
%==========================================================================
% --- 
% --- FHANDLE   the function handle defining the model-function, e.g.: 
% ---           fhandle=@myfunction
% ---
% --- X     the input of the model-function which parameters P has to be 
% ---       fitted. X has to be column(s) wise vector or matrix
% ---
% --- Y     the experimental data which is modeled by the model-function
% ---
% --- E     the error of the experimental data ( can be '[]')
% --- 
% --- PINIT   Vector of starting parameters
% ---
% --- LB - lower bound vector or array, must be the same size as PINIT
% ---      If no lower bounds exist for one of the variables, then
% ---      supply -inf for that variable
% ---      If no lower bounds at all, then LB may be left empty
% ---
% --- UB - upper bound vector or array, must be the same size as PINIT
% ---      If no upper bounds exist for one of the variables, then
% ---      supply +inf for that variable
% ---      If no upper bounds at all, then UB may be left empty.
% ---
% --- OPTIONS   are to be set when for instance, function values are
% ---           typically lower than 10^-4. 
% ---           See OPTIMSET in the MATLAB help.
% ---           The argument OPTIONS is ... optional
%==========================================================================
% --- Output parameters:
%==========================================================================
% --- PBEST     "best" parameters resulting from the fit process
% --- 
% --- PSIGMA    error of best parameters calculated by errorsigma
% --- 
% --- RESNORM   the squared 2-norm of the residuals using PBEST
% --- 
% --- FLAG      flag describing the exit condition of the fit
% ---           1  Coordinate difference is less than or equal to TolX
% ---              and difference in function values is less than or 
% ---              equal to TolFun. --- Fit converged ---
% ---           0  Maximum number of function evaluations or iterations
% ---              exceeded
% ---          -1  Algorithm terminated by the output function.
% --- 
% --- FBEST     Best fit through the data  [ fhandle(pbest,x) ]
% --- 
% --- RESIDUAL  Residual between fit and data  [ fhandle(pbest,x) - y ]
% ---
% --- OUT       parts of the output structure from fminsearch
% --- 
% --- 
% --- See fminsearch for all other arguments.
%==========================================================================
% --- April 2006
% --- jean-luc.dellis@u-picardie.fr
% --- May 2006
% --- Special thanks to John D'Errico who created FMINSEARCHBND which
% --- allows to set bounds to the parameters values:
% --- (see at : http://www.mathworks.com/matlabcentral/fileexchange)
%==========================================================================

    %======================================================================
    % ---- input variable check
    %======================================================================
    if ( nargin < 5 )
        disp('Warning MYEASYFIT: Not enough input variables!')
        disp('Provide atleast function handle, x, y, e & start parameter!')
        return
    end
    if ( nargin < 8 )
        options = []                                                       ;
    end
    if ( nargin < 7 || numel(pinit) ~= numel(UB) )
        UB = inf * ones(size(pinit))                                       ;
    end
    if ( nargin < 6 || numel(pinit) ~= numel(LB) )
        LB = -inf * ones(size(pinit))                                      ;
    end
    
    %======================================================================
    % ---- check vector/matrix sizes and calculate weights
    %======================================================================
    % --- check if x & y are not empty
    if ( isempty(x) == 1 || isempty(y) == 1 )
        pbest    = pinit                                                   ; % return start values as best parameter
        psigma   = 0 * pinit + Inf                                         ; % set the error on best parameter to infinite 
        resnorm  = Inf                                                     ; % set the residual norm to infinite
        flag     = -1                                                      ; % set the flag to -1 (not converged)
        fbest    = y                                                       ; % set fbest to the data
        residual = 0 * y + Inf                                             ; % set the residual to infinite
        out      = []                                                      ; % return empty matrix as out
        return 
    end
    % --- check if weights should be used
    useweights = 1                                                         ;
    if ( isempty(e) == 1 )
        e          = ones(size(y))                                         ; % create a constant weight
        useweights = 0                                                     ;
    end
    % --- check if x, y (& e) have the same number of elements
    if ( numel(x)~=numel(y) || numel(x)~=numel(e) || numel(y)~=numel(e) )
        disp('Warning MYEASYFIT: x, y (and e) are not of the same length!')
        nelements = min([numel(x),numel(y),numel(e)])                      ;
        x = x(1:nelements)                                                 ;
        y = y(1:nelements)                                                 ;
        e = e(1:nelements)                                                 ;
        clear nelements                                                    ;
    end
    % --- check for valid points (exclude NaN's and infinite values)
    valid = find( isfinite(x) & isfinite(y) & isfinite(e) )                ;
    x = x(valid)                                                           ;
    y = y(valid)                                                           ;
    e = e(valid)                                                           ;
    % --- create weight vector / matrix
    if ( useweights == 1 )
        w       = zeros(size(y))                                           ; % initialize weight vector
        w(e~=0) = 1 ./ e(e~=0)                                             ; % create a weight which inversely proportional to the error
        w(e==0) = 1; %(fix later)10 * max(w(e~=0))                                        ; % for create a strong weight for data with NO error
    end
    
    %======================================================================
    % ---- call to fminsearchbnd
    %======================================================================
    if ( useweights == 1 )
        [pbest,fval,flag,out]=fminsearchbnd(@wdistance,pinit,LB,UB,options);
    else
        [pbest,fval,flag,out]=fminsearchbnd(@distance,pinit,LB,UB,options) ;        
    end
    pbest = pbest(:)                                                       ; % transform pbest to a column vector

    %======================================================================
    % ---- assign the residual norm & calculate best fit + residuals
    %======================================================================
    resnorm  = fval                                                        ; % Squared 2-norm of the residuals: sum(sum((fhandle(pbest,x)-y).^2))
    if ( nargout > 4 )
        fbest    = fhandle(pbest,x)                                        ; % best fit throught the data
    end
    if ( nargout > 5 )
        residual = fbest - y                                               ; % Residual: fhandle(pbest,x) - y 
    end

    %======================================================================
    % ---- call to errorsigma
    %======================================================================
    psigma = errorsigma(x,y,e,pbest,0.05*pbest                          ...
                       ,ones(size(pbest)),fhandle,fhandle(pbest,x))        ; % calculate sigmas of fitting parameter

    %======================================================================
    % ---- Nested subfunctions DISTANCE & WDISTANCE
    % --- (i.e. they "know" x, y (& w) and fhandle)
    %======================================================================
    function dist = distance(pinit)                                            
        ymod = fhandle(pinit,x)                                            ;
        dist = sum(sum((ymod-y).^2))                                       ; % general form
    end
    function dist = wdistance(pinit)                                            
        ymod = fhandle(pinit,x)                                            ;
        dist = sum(sum(w.*(ymod-y).^2))                                    ; % general form
    end

end


%==========================================================================
% --- Here is the FMINSEARCHBND function created by John D'Errico
% --- Sub-functions have been nested. This may cause crashes when
% --- used with old versions of MATLAB.
%==========================================================================
function [x,fval,flag,output]=fminsearchbnd(fun,x0,LB,UB,options,varargin)
% --- fminsearchbnd: fminsearch with bound constraints by transformation
% ---
% --- Usage: fminsearchbnd(fun,x0,LB,UB,options,p1,p2,...)
% ---
% --- Arguments:
% --- LB - lower bound vector or array, must be the same size as x0
% ---
% --- If no lower bounds exist for one of the parameters, then
% --- supply '-inf' for that one.
% ---
% --- If no lower bounds at all, then LB may be left empty ('[]').
% ---
% --- UB - upper bound vector or array, must be the same size as x0
% ---
% --- If no upper bounds exist for one of the parameters, then
% --- supply '+inf' for that one.
% ---
% --- If no upper bounds at all, then UB may be left empty ('[]').
% ---
% --- See fminsearch for all other arguments and options.
% --- Note that TolX will apply to the transformed variables. All other
% --- fminsearch parameters are unaffected.
% ---
% --- Notes:
% ---
% --- Variables which are constrained by both a lower and an upper
% --- bound will use a sin transformation. Those constrained by
% --- only a lower or an upper bound will use a quadratic
% --- transformation, and unconstrained variables will be left alone.
% ---
% --- Variables may be fixed by setting their respective bounds equal.
% --- In this case, the problem will be reduced in size for fminsearch.
% ---
% --- The bounds are inclusive inequalities, which admit the
% --- boundary values themselves, but will not permit ANY function
% --- evaluations outside the bounds.
% ---
% ---
% ---
% --- FMINSEARCH Multidimensional unconstrained nonlinear minimization
% ---
% --- X = FMINSEARCH(FUN,X0) starts at X0 and attempts to find a local
% --- minimizer  X of the function FUN. FUN is a function handle.  
% --- FUN accepts input X and returns a scalar function value F evaluated 
% --- at X. X0 can be a scalar, vector or matrix.
% --- 
% --- X = FMINSEARCH(FUN,X0,OPTIONS) minimizes with default optimization
% --- parameters replaced by values in the structure OPTIONS, created
% --- with the OPTIMSET function. See OPTIMSET for details. FMINSEARCH
% --- uses these options: Display, TolX, TolFun, MaxFunEvals, MaxIter, 
% --- FunValCheck, PlotFcns, and OutputFcn.
% --- 
% --- X = FMINSEARCH(PROBLEM) finds the minimum for PROBLEM. PROBLEM is a
% --- structure with the function FUN in PROBLEM.objective, the start point
% --- in PROBLEM.x0, the options structure in PROBLEM.options, and solver
% --- name 'fminsearch' in PROBLEM.solver. The PROBLEM structure must have
% --- all the fields.
% --- 
% --- [X,FVAL]= FMINSEARCH(...) returns the value of the objective 
% --- function, described in FUN, at X.
% ---
% --- [X,FVAL,EXITFLAG] = FMINSEARCH(...) returns an EXITFLAG that
% --- describes the exit condition of FMINSEARCH. Possible values of 
% --- EXITFLAG and the  corresponding exit conditions are:
% --- 
% ---  1  Maximum coordinate difference between current best point and
% ---     other points in simplex is less than or equal to TolX, and 
% ---     corresponding  difference in function values is less than or 
% ---     equal to TolFun. --- Fit converged ---
% ---  0  Maximum number of function evaluations or iterations reached.
% --- -1  Algorithm terminated by the output function.
% ---
% --- [X,FVAL,EXITFLAG,OUTPUT] = FMINSEARCH(...) returns a structure
% --- OUTPUT with the number of iterations taken in OUTPUT.iterations, the
% --- number of function evaluations in OUTPUT.funcCount, the algorithm
% --- name in OUTPUT.algorithm, and the exit message in OUTPUT.message.
% ---
%==========================================================================

    % --- size checks
    xsize = size(x0)                                                       ;
    x0    = x0(:)                                                          ;
    n     =length(x0)                                                      ;

    if ( nargin<3) || isempty(LB )
        LB = repmat(-inf,n,1)                                              ;
    else
        LB = LB(:)                                                         ;
    end
    if ( nargin<4) || isempty(UB )
        UB = repmat(inf,n,1)                                               ;
    else
        UB = UB(:)                                                         ;
    end

    if ( n~=length(LB) || n~=length(UB) )
        error 'x0 is incompatible in size with either LB or UB.'
    end

    % --- set default options if necessary
    if ( nargin < 5 || isempty(options) )
        options = optimset('fminsearch')                                   ;
    end

    % --- stuff into a struct to pass around
    params.args = varargin                                                 ;
    params.LB   = LB                                                       ;
    params.UB   = UB                                                       ;
    params.fun  = fun                                                      ;
    params.n    = n                                                        ;

    % --- 0 --> unconstrained variable
    % --- 1 --> lower bound only
    % --- 2 --> upper bound only
    % --- 3 --> dual finite bounds
    % --- 4 --> fixed variable
    params.BoundClass = zeros(n,1)                                         ;
    for i = 1 : n
        k = isfinite(LB(i)) + 2*isfinite(UB(i))                            ;
        params.BoundClass(i) = k                                           ;
        if ( k==3 && LB(i) == UB(i) )
            params.BoundClass(i) = 4                                       ;
        end
    end

    % --- transform starting values into their unconstrained
    % --- surrogates. Check for infeasible starting guesses.
    x0u = x0                                                               ;
    k=1                                                                    ;
    for i = 1:n
        switch params.BoundClass(i)
            case 1 % lower bound only
                if x0(i)<=LB(i)
                    x0u(k) = 0                                             ; % infeasible starting value. Use bound.
                else
                    x0u(k) = sqrt(x0(i) - LB(i))                           ;
                end
                k=k+1                                                      ; % increment k
            case 2 % upper bound only
                if x0(i)>=UB(i)
                    x0u(k) = 0                                             ; % infeasible starting value. Use bound.
                else
                    x0u(k) = sqrt(UB(i) - x0(i))                           ;
                end
                k=k+1                                                      ; % increment k
            case 3 % lower and upper bounds
                if x0(i)<=LB(i)
                    x0u(k) = -pi/2                                         ; % infeasible starting value
                elseif x0(i)>=UB(i)
                    x0u(k) = pi/2                                          ; % infeasible starting value
                else
                    x0u(k) = 2*(x0(i) - LB(i))/(UB(i)-LB(i)) - 1           ;
                    % --- shift by 2*pi to avoid problems at zero
                    % --- otherwise, the initial simplex is very small
                    x0u(k) = 2*pi+asin(max(-1,min(1,x0u(i))))              ;
                end
                k=k+1; % increment k
            case 0 % unconstrained variable. x0u(i) is set.
                x0u(k) = x0(i)                                             ;
                k=k+1                                                      ; % increment k
            case 4 % Fixed variable. Drop it before fminsearch sees it.
                  % k is not incremented for this variable.
        end
    end

    % --- if any of the unknowns were fixed, then we need to shorten x0u
    if ( k <= n )
        x0u(k:n) = []                                                      ;
    end

    % --- were all the variables fixed?
    if ( isempty(x0u) )
        % --- All variables were fixed. quit immediately, setting the
        % --- appropriate parameters, then return.
  
        % --- undo the variable transformations into the original space
        x = xtransform(x0u,params)                                         ;
  
        % --- final reshape
        x = reshape(x,xsize)                                               ;
  
        % --- stuff fval with the final value
        fval = feval(params.fun,x,params.args{:})                          ;
  
        % --- fminsearchbnd was not called
        flag = 0                                                           ;
        output.iterations = 0                                              ;
        output.funcount   = 1                                              ;
        output.algorithm  = 'fminsearch'                                   ;
        output.message    = 'All variables were fixed by applied bounds'   ;
  
        % --- return with no call at all to fminsearch
        return
    end

    % --- call fminsearch, but with own intra-objective function.
    [xu,fval,flag,output] = fminsearch(@intrafun,x0u,options,params)       ;

    % --- undo the variable transformations into the original space
    x = xtransform(xu,params)                                              ;

    % --- final reshape
    x = reshape(x,xsize)                                                   ;

    % =====================================================================
    % --- begin of subfunctions 
    % =====================================================================
    function fval = intrafun(x,params)
        xtrans = xtransform(x,params)                                      ; % transform variables
        fval   = feval(params.fun,xtrans,params.args{:})                   ; % and call fun
    end
    % =====================================================================
    function xtrans = xtransform(x,params)
        % --- converts unconstrained variables into their original domains
        xtrans = zeros(1,params.n)                                         ;
        % --- k allows some variables to be fixed, thus dropped from the optimization.
        k=1                                                                ;
        for j = 1:params.n
            switch params.BoundClass(j)
                case 1 % lower bound only
                    xtrans(j) = params.LB(j) + x(k).^2                     ;
                    k=k+1;
                case 2 % upper bound only
                    xtrans(j) = params.UB(j) - x(k).^2                     ;
                    k=k+1;
                case 3 % lower and upper bounds
                    xtrans(j) = (sin(x(k))+1)/2                            ;
                    xtrans(j) = xtrans(j)                               ...
                              *(params.UB(j) - params.LB(j)) + params.LB(j);
                    xtrans(j) = max(params.LB(j)                        ...
                                   ,min(params.UB(j),xtrans(j)))           ; % just in case of any floating point problems
                    k=k+1                                                  ;
                case 4 % fixed variable, bounds are equal
                    xtrans(j) = params.LB(j)                               ;
                case 0 % unconstrained variable.
                    xtrans(j) = x(k)                                       ;
                    k=k+1                                                  ;
            end
        end
    end
    % =====================================================================
    % --- end of subfunctions 
    % =====================================================================

end
%==========================================================================
% --- End of FMINSEARCHBND function created by John D'Errico
%==========================================================================


% =========================================================================
% --- Begin of function errorsigma
% =========================================================================
function [psigma,covp,corp,r2,rv] = errorsigma(x,y,e,p,dp,free,func,f)
% =========================================================================
% --- ERRORSIGMA computes the sigma for each fitting parameter value
% --- call this function after a fit is performed
% --- [psigma,covp,corp,r2,rv] = errorsigma(x,y,e,p,dp,free,func,f)
% --- free should be 0 for fixed parameters, 1 for variable parameters
% --- a good choice for dp = 0.05 * p
% =========================================================================

    % =====================================================================
    % --- input preparation
    % =====================================================================
    x            = x(:)                                                    ; % x data
    y            = y(:)                                                    ; % y data
    if ( isempty(e) == 1 )
        e = ones(size(y))                                                  ;
    end
    e            = e(:)                                                    ; % error of data
    % ---
    wt           = zeros(size(y))                                          ; % initialize weight vector
    valid        = find( isfinite(e) & e~=0 )                              ; % find data with some finite error 
    wt(valid)    = 1 ./ e(valid)                                           ; % create a weight which inversely proportional to the error
    wt(e==0)     = 1; %(fix later)10 * max(wt(e~=0))                                      ; % create a strong weight for data with NO error
    wt           = wt(:)                                                   ;
    clear valid                                                            ;
    % ---
    m            = length(x)                                               ; % number of data points
    p            = p(:)                                                    ; % parameters of final fit
    dp           = dp(:)                                                   ; % a vector telling how much to vary the parameter
    free         = free(:)                                                 ; % vector showing which parameters are varying

    % =====================================================================
    % --- check if best fit is supplied
    % =====================================================================
    if ( nargin <= 8 ) 
        f = []                                                             ;
    end
    if ( isempty(f) || (length(f) ~= m) )
        f = feval(func,p,x)                                                ;
    end
    f = f(:)                                                               ;

    % =====================================================================
    % --- check if all points are valid and use only valid points
    % =====================================================================
    index = find(isfinite(x)&isfinite(y)&isfinite(wt)&isfinite(f)&wt~=0)   ; 
    x  = x(index)                                                          ;
    y  = y(index)                                                          ;
    wt = wt(index)                                                         ;
    f  = f(index)                                                          ;
    m  = length(y)                                                         ;
    dp = dp .* free                                                        ;
    
    % =====================================================================
    % --- create dummy output parameter if early extit
    % =====================================================================
    psigma = []                                                            ;
    covp   = []                                                            ;
    corp   = []                                                            ;
    r2     = []                                                            ;
    rv     = []                                                            ;
    if ( isempty(p) == 1 )
        return
    end

    % =====================================================================
    % --- data reduction for data sets above 1000 points
    % =====================================================================
    nreduce = 1000                                                         ;
    if ( m > nreduce )                                                       % try to avoid crash if too many points
        ysav = y                                                           ;
        fsav = f                                                           ;
        msav = m                                                           ; % store the number of good data points
        wsav = wt                                                          ;
        % ---
        k    = m/nreduce                                                   ;
        k    = floor(k*(1:nreduce))                                        ;
        k    = k(k >= 1 & k <= m)                                          ;
        % ---
        x    = x(k)                                                        ;
        y    = y(k)                                                        ;
        f    = f(k)                                                        ;
        wt   = wt(k)                                                       ;
        m    = nreduce                                                     ;
    end

    % =====================================================================
    % --- calculate variance COV matrix & correlation matrix of parameters
    % --- & reevaluate the Jacobian at optimal values
    % --- The following section is Ray Muzic's estimate for covariance 
    % --- and correlation.
    % --- Covariance matrix of data estimate is from 
    % --- Bard Equation 7-5-13 and Row 1 of Table 5.1.
    % =====================================================================

    % =====================================================================
    % --- calculate Jacobian
    % =====================================================================
    jac = partialderivatives(x,f,p,dp,func)                                ;
    msk = find(dp ~= 0)                                                    ; % use only 'free' parameter
    n   = length(msk)                                                      ; % reduce n to equal number of free parameters
    jac = jac(:, msk)                                                      ; % use only fitted parameters

    % =====================================================================
    % --- calculate squared inverse Jacobian
    % =====================================================================
    resid   = y-f                                                          ; %unweighted residuals
    Qinv    = diag(wt.*wt)                                                 ;
    jtgjinv = pinv(jac'*Qinv*jac)                                          ;
    if ( ~isempty(jtgjinv) && m > n )
        covp  = resid' * Qinv * resid / (m-n) * jtgjinv                    ;
        stdp  = sqrt(abs(diag(covp)))                                      ;
        stdp2 = stdp*stdp'                                                 ;
        % ---
        corp           = ones(n,n)                                         ;
        corp(stdp2~=0) = covp(stdp2~=0) ./ stdp2(stdp2~=0)                 ;
        corp(stdp2==0) = Inf                                               ;
    else
        disp('Warning : Could not compute squared inverse Jacobian!')      ;
        disp('Warning : Neither covariance nor correlation matrix!!')      ;
        covp = zeros(n,n)                                                  ;
        stdp = sqrt(abs(diag(covp)))                                       ;
        corp = ones(n,n)                                                   ;
    end

    % =====================================================================
    % --- calculate the error on the fitting parameter
    % =====================================================================
    j   = 1                                                                ;
    psigma = zeros(size(p))                                                ;
    for i = 1 : length(stdp)
        while free(j)==0
            j=j+1                                                          ;
        end
        psigma(j) = stdp(i)                                                ;
        j = j + 1                                                          ;
    end

    % =====================================================================
    % --- restore the data & calculate correlation coefficients ...
    % =====================================================================
    if ( nargout > 3 )
        if ( msav > nreduce )                                                      
            y  = ysav                                                      ;
            f  = fsav                                                      ;
            wt = wsav                                                      ;
        end
        r  = corrcoef(y.*wt,f.*wt)                                         ;
        r2 = r.*r'                                                         ;
        rv = sum(((f-y).*wt).^2/length(y))                                 ;
        clear r ysav fsav msav wsav                                        ;
    end
    clear nreduce                                                          ;

    % =====================================================================
    % --- Begin of subfunction partialderivatives
    % =====================================================================
    function df_dp = partialderivatives(x,f,p,dp,func)
    % =====================================================================
    % --- y = partialderivatives(x,y,p,dp,func)
    % --- Returns the partial derivatives of function 'func'.
    % --- 'x'(vect) is x axis values, 'y' is y values,
    % --- 'p' and 'dp' are parameters and their variation.
    % --- 'func' is the function concerned [y=func(x,p)]
    % --- Output 'df_dp' is a vector or matrix of partials varying of 'dp'
    % =====================================================================
        [nr,nc] = size(x)                                                  ;
        if ( nr < nc )
            x = x'                                                         ; 
        end
        p0    = p                                                          ; % save init params
        df_dp = zeros(length(x), length(p))                                ;
        i0 = find((abs(dp) <= 1e-12) | ~isfinite(dp) )                     ; % these parameters should not vary
        if ( ~isempty(i0) )
            dp(i0) = 0                                                     ;
        end
        for ii = 1 : length(p)
            if ( dp(ii) ~= 0 )
                p(ii) = p(ii) + dp(ii)                                     ;
                t = feval(func,p,x)                                        ;
                if ( length(t) ~= length(f) )
                    t = t(1:length(x))                                     ;
                end
                df_dp(:,ii) = (t(:)-f(:)) / dp(ii)                         ;
                p = p0                                                     ;
            end
        end
        if (nr < nc)
            df_dp = df_dp'                                                 ;
        end
    end
    % =====================================================================
    % --- End of subfunction partialderivatives
    % =====================================================================
    
end
% =========================================================================
% --- End of function errorsigma
% =========================================================================




% ---
% EOF
