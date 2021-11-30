function layers=freeze_layer(layers ...
    )
%this function is used for transfer learning.  It makes it so that all the
%layers that have weights are frozen and cannot change during subsequent
%training
for i = 1:numel(layers)
    if isprop(layers(i),'WeightLearnRateFactor')
        layers(i).WeightLearnRateFactor = 0;
    end
    if isprop(layers(i),'WeightL2Factor')
        layers(i).WeightL2Factor = 0;
    end
    if isprop(layers(i),'BiasLearnRateFactor')
        layers(i).BiasLearnRateFactor = 0;
    end
    if isprop(layers(i),'BiasL2Factor')
        layers(i).BiasL2Factor = 0;
    end
end