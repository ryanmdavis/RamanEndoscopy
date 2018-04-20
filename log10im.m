function i_out = log10im(i_in)

min_positive=min(i_in(i_in>0));
i_in(i_in<0)=min_positive;
i_out=log10(i_in);