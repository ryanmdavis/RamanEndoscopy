function d = cellSetDifference(a,b)

if ~iscell(a) || ~iscell(b)
    error('both inputs must be cells');
end

if max(size(a)) < max(size(b))
    error('first input must be as long or longer than second input');
end

d=cell(1,size(a,2)-size(b,2));

d_ind=1;
for ai=1:max(size(a))
    if ~sum(~cellfun('isempty',strfind(b,a{ai}))) % if a(ai) not in b
        d{d_ind}=a{ai};
        d_ind=d_ind+1;
    end
end