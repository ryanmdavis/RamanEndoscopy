function out=readModelSpectraXls(sheet)

% find names of sheets holding data
[~,sheets]=xlsfinfo('forward_model.xlsx');
readme_ind=cellfun('isempty',strfind(sheets,'ReadMe'));
sheets=sheets(readme_ind);

% find if desired sheet exists
sheet_ind=~cellfun('isempty',strfind(sheets,sheet));
if ~sum(sheet_ind)
    error(strcat('Specified sheet name must be: ',sheets));
end

% find location of forward_model.xls and read it in
p=mfilename('fullpath');
slash_loc=strfind(p,mkslash);
[num,txt,raw]=xlsread(strcat(p(1:slash_loc(end)),'\forward_model.xlsx'),sheet);

if ~strcmp(sheet,'defaults')
    % read output wavenumber
    output_wavenumber=num(:,1);
    output_wavenumber=output_wavenumber(~isnan(output_wavenumber));

    % determine number of model spectra
    num_model_spectra=(size(num,2)-1)/2;

    % allocate output memory
    model_spectra_struct(num_model_spectra)=struct('name','','wavenumber',[],'intensity',[]);
    for msn=1:num_model_spectra
        nan_ind=isnan(num(:,msn*2));
        model_spectra_struct(msn).wavenumber=num(~nan_ind,msn*2).';
        model_spectra_struct(msn).intensity=num(~nan_ind,msn*2+1).';
        model_spectra_struct(msn).name=txt{msn*2-1};
    end

%     % normalize to S440
%     [~,i_s440]=max(~cellfun('isempty',strfind({model_spectra_struct.name},'S440')));
%     n=norm(model_spectra_struct(i_s440).intensity);
%     for msn=1:num_model_spectra
%         model_spectra_struct(msn).intensity=model_spectra_struct(msn).intensity/n;
%     end
    
    out=struct('output_wavenumber',output_wavenumber.','spectra',model_spectra_struct);
else
    for d_num=1:size(raw,2)
        vals={raw{2:end,d_num}};
        vals={vals{~cellfun('isempty',vals)}};
        out.(raw{1,d_num})=vals;
%         keyboard;
    end
end