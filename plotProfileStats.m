function plotProfileStats(profiles,um_per_pixel,varargin)

invar = struct('x_lim',[]);
argin = varargin;
invar = generateArgin(invar,argin);

means=mean(profiles,1);
sems=std(profiles,[],1)/sqrt(size(profiles,1));

x_labels=um_per_pixel*((1:size(means,2))-size(means,2)/2);
if isempty(invar.x_lim)
    invar.x_lim=[min(x_labels) max(x_labels)];
end

plot(x_labels,means,'linewidth',3,'color','k');
hold on
plot(x_labels,means-sems,'linewidth',1,'color','b');
plot(x_labels,means+sems,'linewidth',1,'color','b');
xlim([invar.x_lim]);
axis square
legend('mean','\pmSEM');