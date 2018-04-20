function out=readModelSpectra

this_file=mfilename('fullpath');
slash_loc=strfind(this_file,mkslash);
this_path=this_file(1:slash_loc(end));
mat_loc=strcat(this_path,'forward_model.mat');
xls_loc=strcat(this_path,'forward_model.xlsx');

if ~(exist(mat_loc,'file')==2)
    out = getAndSave(mat_loc);
else
    d_xls=dir(xls_loc);
    load(mat_loc);
    time_multiplier=86400; %seconds per day
    if round(d_xls.datenum*time_multiplier-out.datenum*time_multiplier)>=1 %if timestamp of xls file is more than 1 second later than the internal time of matfile, re-save the standard spectra
        out = getAndSave(mat_loc);
    end
end


function out = getAndSave(mat_loc)
    disp('loading new forward model from hard drive, please wait');
    out=struct('defaults',readModelSpectraXls('defaults'),'endoscope_sers',readModelSpectraXls('endoscope_sers'),'microscope_sers',readModelSpectraXls('microscope_sers'),'endoscope_background',readModelSpectraXls('endoscope_background'),'microscope_background',readModelSpectraXls('microscope_background'),'datenum',now);
    save(mat_loc,'out');
    disp('done');