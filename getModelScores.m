% get scores for each data point using specified Classification model

function [scores,predictions]=getModelScores(Model,data)

[out1,out2]=predict(Model,data);
if isa(Model,'GeneralizedLinearModel')
    scores=out1;
    predictions=double(out1>=0.5);
else
    scores=out2(:,2);
    predictions=out1;
end