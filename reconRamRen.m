function varargout = reconRamRen(path)

if strfind(path,'.txt');
    out=readRenishawSpectra(path);
    file_type='txt';
elseif strfind(path,'.spc')
    out=readRenishawSpc(path);
    file_type='spc';
else
    error('path not .txt or .spc');
end

% sub_path = reconstructHelperSubpath(path,'\Renishaw Data\');
file_name=reconstructHelperFilename(path);

if nargout==0
    figure
    if strcmp(file_type,'txt');
        plot(out.wavenumber,out.spectra);
        xlim([out.wavenumber(end) out.wavenumber(1)])
        ylabel('counts');
        axis square
    else
        plot2YAxes(out.wavenumber,out.spectra,out.normalization_divisor,'xlim',[out.wavenumber(end) out.wavenumber(1)],'ylabel1','counts/mW/s','ylabel2','raw counts');
    end

    xlabel('Raman Shift (cm^-^1)');
    if size(file_name,2)>30
        title(strcat(file_name(1:30),'...'));
    else
        title(file_name);
    end
    niceFigure(gcf);
end
if nargout == 1
    varargout{1}=struct('name',file_name,'out',out);
end