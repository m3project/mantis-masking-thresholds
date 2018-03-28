function plotResults

mantids = {'F10', 'F11', 'F21', 'F23', 'F32', 'F7'};

n = length(mantids);

thresholds = nan(6, 3, n);

sigmas = nan(6, 3, n);

for i=1:n
    
    [thresholds(:, :, i), sigmas(:, :, i)] = getMantisThresholds(mantids{i});    
    
end

ord = [1 3 5 2 4 6];

thresholds = thresholds(ord, :, :); % re-arrange

sigmas = sigmas(ord, :, :); % re-arrange

thresholds(:, 3, :) = (thresholds(:, 3, :));

tab = getThresholdsTab(thresholds); doStats(tab);

m = mean(thresholds, 3);

s = std(thresholds, [], 3) / sqrt(n);

sfigure(1);

% dimension 1 of mr is noise mode: no noise, 0.04 cpd then 0.2 cpd
% dimension 2 of mr is signal freq: 0.04 cpd then 0.2 cpd

mr = reshape(m(:, 3), [3 2]);

sr = reshape(s(:, 3), [3 2]);

barwitherr(sr, mr);

hold off;

legend('0.04 cpd signal', '0.2 cpd signal', 'Location', 'NorthWest');

ylabel('Threshold');

set(gca, 'XTick', 1:6);

set(gca, 'XTickLabel', ...
    {'none', '0.04 cpd', '0.2 cpd'});

xlabel('Noise');

grid on;

colormap(lines(2))

ylim([0 0.1]);

% set(gca, 'pos', [1068 648 431 287]);

set(gcf, 'pos', [1068 686 354 336]);

return

%% figure 2

x1 = thresholds(1:3, 3, :);
y1 = sigmas(1:3, 3, :);

x2 = thresholds(4:6, 3, :);
y2 = sigmas(4:6, 3, :);

x1 = x1(:); y1 = y1(:);
x2 = x2(:); y2 = y2(:);

sfigure(2); clf; hold on;

plot(x1, y1, 'o');

plot(x2, y2, 'ro');

set(gca, 'xscale', 'log')

ylim([0 3])

xlim([1e-2 2e-1])

xlabel('Contrast Threshold');

ylabel('\sigma');

grid on;

legend('0.04 cpd', '0.2 cpd');

corr(x1, y1)

corr(x2, y2)

n1 = length(x1)

n2 = length(x2)

end

function tab = getThresholdsTab(thresholds)

% this function produces a tabular representation of thresholds
% each row is:
% fnoise, fsig, thresh1, thresh2, ..., threshN

n = size(thresholds, 3);

conds = thresholds(1:6, 1:2, 1);

k1 = thresholds(:, 3, :);

k2 = reshape(k1, [6 n]);

conds(conds == 1) = 0;
conds(conds == 2) = 0.2;
conds(conds == 3) = 0.04;

tab = [conds k2];

end

function doStats(tab)

lowFreq = tab(1:3, 3:end);

highFreq = tab(4:6, 3:end);

conds = tab(1:6, 3:end);

labels = {
    '0.04 sig (-no- noise)' % 1
    '0.04 sig (0.04 noise)' % 2
    '0.04 sig (0.20 noise)' % 3
    '0.20 sig (-no- noise)' % 4
    '0.20 sig (0.04 noise)' % 5
    '0.20 sig (0.20 noise)' % 6
    };

labels = {
    'L' % 1
    'L+L' % 2
    'L+H' % 3
    'H' % 4
    'H+L' % 5
    'H+H' % 6
    };

results = {'', ' (*)', '(**)'};

testConds(1, 4);

testConds(1, 2);
testConds(1, 3);

testConds(4, 5);
testConds(4, 6);

testConds(3, 2);
testConds(6, 5);

testConds(2, 5);

mThresh = mean(conds, 2);

highNoiseRelSens1 = mThresh(4)/mThresh(6) % effect of high noise on low freq

highNoiseRelSens2 = mThresh(1)/mThresh(3) % effect of high noise on high freq

    function testConds(c1, c2)
        
        [h,p,ci,stats] = ttest(conds(c1, :), conds(c2,:));
        
        sig = (p<=0.05)*1 + 1 + (p<=0.01)*1;
        
%         fprintf('%-25s | %-25s | p = %1.3f%s\n', labels{c1}, labels{c2}, p, results{sig});
        
        fprintf('%-25s | %-25s | t(%d) = %1.1f, p = %1.3f%s\n', labels{c1}, labels{c2}, stats.df, stats.tstat, p, results{sig});
        
    end

end