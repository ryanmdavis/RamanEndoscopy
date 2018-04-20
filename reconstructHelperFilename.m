function file_name=reconstructHelperFilename(path)

slash_loc=strfind(path,'\');
last_slash_loc=slash_loc(end);
file_name=path(last_slash_loc+1:end);
