% solve inverse of b=Ax on a pixel-by-pixel basis

function out = pivUnmixing(b,A,Ai,wavenumber_b,wavenumber_A)
f_pb=figure;
% calculate pseudo-inverse
% Ai=pinv(A);

x=zeros(size(Ai,2),size(b,1),size(b,2));
b_est=zeros(size(b,1),size(b,2),max(size(wavenumber_A)));
for row=1:size(b,1)
    percentBar(100*row/size(b,1),f_pb,'% Unmixing completed');
    for col=1:size(b,2)
        this_spectrum=squeeze(b(row,col,:));
        
        % make sure measurement and standard have same x-axis.  This puts
        % the x axis on the same scale as the standard S440
        this_spectrum_interp=interp1(wavenumber_b,this_spectrum,wavenumber_A);
        this_spectrum_interp=this_spectrum_interp(~isnan(this_spectrum_interp));
        if size(this_spectrum_interp,2)<size(Ai,1)
            Ai = Ai(~isnan(this_spectrum_interp),:);
        end
        
        % solve the inverse problem
        x(:,row,col)=this_spectrum_interp*Ai;
        
        % show fit spectra
        b_est(row,col,1:size(A,2))=squeeze(x(:,row,col)).'*A;
    end
end
close(f_pb);
out=struct('x',x,'b_est',b_est,'b',b,'wavenumber_b',wavenumber_b,'wavenumber_b_est',wavenumber_A);