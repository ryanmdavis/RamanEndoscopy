% make slash character for file paths

function out = mkslash

if ismac
    out='/';
else
    out='\';
end