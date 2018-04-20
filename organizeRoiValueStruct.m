% the input for this function is the variable poofed to the matlab
% workspace after clicking "Save ROI Vals." on the visualizeRaman GUI.

function out = organizeRoiValueStruct(roi_value_struct,varargin)
if nargin == 1
    group_names = {'Group1_normal','Group2_tumor','Group3_other','Group4_other','Group5_other'};
elseif nargin == 2
    group_names = varargin{1};
end

% initialize structure
for group_num=1:size(group_names,2)
    out.(group_names{group_num})=[];
end

%determine group numbers
group_numbers=zeros(size(roi_value_struct));
for struct_index=1:size(roi_value_struct,2)
    group_numbers(struct_index)=str2double(roi_value_struct(struct_index).group(1));
end

% find which group numbers exist here
groups=[1*double(~isempty(find(group_numbers==1,1))) 2*double(~isempty(find(group_numbers==2,1))) 3*double(~isempty(find(group_numbers==3,1))) 4*double(~isempty(find(group_numbers==4,1))) 5*double(~isempty(find(group_numbers==5,1)))];
groups=groups(groups>0);

% assign data to structure
for group_num=1:size(groups,2)
    out.(group_names{groups(group_num)})=vertcat(roi_value_struct(group_numbers==groups(group_num)).values);
end

% group1_values=vertcat(roi_value_struct(strcmp({roi_value_struct.group},'1 - normal')).values);
% group2_values=vertcat(roi_value_struct(strcmp({roi_value_struct.group},'2 - tumor')).values);
% group3_values=vertcat(roi_value_struct(strcmp({roi_value_struct.group},'3 - other')).values);
% group4_values=vertcat(roi_value_struct(strcmp({roi_value_struct.group},'4 - other')).values);
% group5_values=vertcat(roi_value_struct(strcmp({roi_value_struct.group},'5 - other')).values);
% 
% out=struct(group_names{1},group1_values,group_names{2},group2_values,group_names{3},group3_values,group_names{4},group4_values,group_names{5},group5_values);