function out=fromAgetBwithCequalsD(a,b,c,d)
matching_indicies=strcmp({a.(c)},d);
if sum(matching_indicies)
    out=a(matching_indicies).(b);
else
    error(char(strcat({'no "'},{c},{'" that equals '},{d})));
end