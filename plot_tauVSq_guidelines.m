function plot_tauVSq_guidelines
%will plot 1/q and 1/q^2 to the tau vs q plot
%

h=findall(0,'Tag','viewresult_Fig_Fitting');
havg=findall(0,'Tag','viewresult_Fig_Fitting_Avg');

if (isempty(h) && isempty(havg))
    disp('No fit plots are open, Exiting...');
    return;
end

viewresult_debug;

if ~verLessThan('Matlab','8.4')
   h = get(h,'Number');
   havg = get(havg,'Number');
   if iscell(h)
       h = cell2mat(h);
   end
   if iscell(havg)
       havg = cell2mat(havg);
   end
end



for figure_num=1:numel(h)
    figure(h(figure_num));
    subplot(2,2,4);hold on;
    
    qval=udata.result.dynamicQs{1};
    
    which_q=floor(median(1:numel(qval)));
    
    tau_val = udata.result.tauFIT2{1};
    % tauval = udata.result.tauBatchavgFIT2;       
    plot(qval,(tau_val(which_q)*qval(which_q))./qval,'k','linewidth',3);    
    plot(qval,(tau_val(which_q)*qval(which_q).^2)./qval.^2,'g--','linewidth',3);
end
fprintf('Plotting a 1/q and 1/q^2 guide to the eye to the Tau vs q plots:%i\n',h);


for figure_num=1:numel(havg)
    figure(havg(figure_num));
    subplot(2,2,4);hold on;
    
    qval=udata.result.dynamicQs{1};
    
    which_q=floor(median(1:numel(qval)));
    
    tau_val = udata.result.tauBatchavgFIT2;       
    plot(qval,(tau_val(which_q)*qval(which_q))./qval,'k','linewidth',3);    
    plot(qval,(tau_val(which_q)*qval(which_q).^2)./qval.^2,'g','linewidth',3);
end
fprintf('Plotting a 1/q and 1/q^2 guide to the eye to the _Averaged_ Tau vs q plots:%i\n',havg);

end
