function CombinationMatrix = generate_Duples(NumVector)

D = length(NumVector);
PartialMatrix = (0:(NumVector(D)-1))';
if D>1
    for idxParam = (D-1):-1:1
        NewPartialMatrix = repmat(PartialMatrix,[NumVector(idxParam),1]);
        CurrentNumLines = size(NewPartialMatrix,1);
        a = round(CurrentNumLines / NumVector(idxParam));
        AdditionalColumn = floor((0:(CurrentNumLines-1))'/a);
        PartialMatrix = [AdditionalColumn,NewPartialMatrix];
    end
end
CombinationMatrix = PartialMatrix;