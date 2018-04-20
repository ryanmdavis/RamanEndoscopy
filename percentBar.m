function percentBar(varargin)
if size(varargin,2) == 0
    error('At Input: Need to specify percent and/or figure handle')
elseif size(varargin,2) == 1
    f_h = gcf;
    percent = varargin{1};
    bar_title = [];
elseif size(varargin,2) == 2
    percent = varargin{1};
    f_h = varargin{2};
%     if strcmp(get(f_h,'Visible'),'on');
%         set(f_h,'Visible','off')
%     end
    figure(f_h);
    bar_title = [];
elseif size(varargin,2) == 3
    percent = varargin{1};
    f_h = varargin{2};
    if strcmp(get(f_h,'Visible'),'on');
        set(f_h,'Visible','off')
    end
    figure(f_h);
    bar_title = varargin{3};
end
% set figure position
position=get(gcf,'Position');
position(4)=100;
set(gcf,'Position',position);

bar = zeros(7,100);
bar(:,1:round(percent)) = 1;
imagesc(bar,[0 1]);
text(2,5,strcat(num2str(percent),'%'));
if ~isempty(bar_title)
    title(bar_title);
end
colormap summer
axis image off
drawnow;