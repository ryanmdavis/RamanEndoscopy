function d=getParentDir(varargin)

d=mfilename('fullpath');
slash_loc=strfind(d,mkslash);
d=d(1:slash_loc(end));

if nargin>0
    switch varargin{1}
        case 'quartz background'
            d=strcat(d,'standards and background spectra',mkslash,'quartz background',mkslash);
        case 'tissue background'
            d=strcat(d,'standards and background spectra',mkslash,'tissue background',mkslash);
        case 'standard spectra'
            d=strcat(d,'standards and background spectra',mkslash,'define A gui',mkslash);
    end
end
