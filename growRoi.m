function roi_next = growRoi(roi_in,mask,varargin)

if nargin==2
    SE = strel('diamond',1);
elseif nargin==3
    SE=varargin{1};
end

roi_next = logical(imdilate(roi_in,SE)) & logical(mask);
if sum(sum(roi_next==roi_in)) ~= numel(roi_in)
    roi_next = growRoi(roi_next,mask,SE);
end