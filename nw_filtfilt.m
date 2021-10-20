function fct = nw_filtfilt(b,a,ct)

fct=filter(b,a,ct);
fct=filter(b,a,fct(end:-1:1));
fct=fct(end:-1:1);