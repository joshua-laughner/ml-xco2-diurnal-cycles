function [array,PC1_grid,PC2_grid] = grid_and_take_percentiles(PC1,PC2,drawdown,divides,percentile)
%input: vector of PC1 values, vector of PC2 values, vector of drawdowns,
%how fine we want to make the grid, and either a percentile number from 0
%-100 or 'mean'

spacing_1 = (max(PC1)-min(PC1))/divides;
PC1_grid = min(PC1):spacing_1:max(PC1)+0.01;

spacing_2 = (max(PC2)-min(PC2))/divides;
PC2_grid = min(PC2):spacing_2:max(PC2)+0.01;

array = nan(divides);

for x = 1:divides
    for y = 1:divides
        concatenated = [PC1>=PC1_grid(x), PC1< PC1_grid(x+1), PC2>= PC2_grid(y), PC2 < PC2_grid(y+1)];
        index = find(all(concatenated,2));
        if isempty(index)
            continue
        end
        if strcmp(percentile,'mean')
            array(y,x) = mean(drawdown(index));
        elseif strcmp(percentile,'std')
            array(y,x) = std(drawdown(index));
        elseif strcmp(percentile,'count')
             array(y,x) = length(index);
        else
        array(y,x) = prctile(drawdown(index),percentile);
        end
    end
end
end