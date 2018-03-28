function [thresholds, sigmas] = getMantisThresholds(mantis)

if nargin == 0
    
    mantids = {'F10', 'F11', 'F21', 'F23', 'F32', 'F7', 'NS15F', 'NS21F', 'NS22F'};
    
    mantis = mantids{2};
    
    sfigure(1);
    
    clf;
    
    makePlot = 1;
    
else
    
    makePlot = 0;
    
end

dir1 = '../data';

[pSet, rSet] = loadDirData(dir1, {mantis}, {}, 0, 1);

A = [pSet rSet];

% structure of A:
% col 1 : noise mode (1 = no noise, 2 = 0.2 cpd, 3 = 0.04 cpd)
% col 2 : spatial frequency (0.04 or 0.2 cpd)
% col 3 : contrast (0.0625/4 0.0625/2 0.0625 0.125 0.25 or 0.5)
% col 4 : direction
% col 5 : observer judgment of mantis direction

B = fold(A, [1 2 3], @fun1);

% structure of B:
% col 1 : noise mode
% col 2 : spatial frequency
% col 3 : contrast
% col 4 : mean response rate
% col 5 : response rate lower-bound
% col 6 : response rate upper-bound
% col 7 : m (number of hits)
% col 8 : n (number of trials)

% plotting

clf; subPlotInd = 0;

B(B(:, 1)==2) = 4;

% calculate sigma

plotPsychometric_w1 = @(As) plotPsychometric_sigma(As, makePlot);

plotPsychometric_w2 = @(As) plotPsychometric(As, makePlot);

sigmas = fold(B, [1 2], plotPsychometric_w1);

thresholds = fold(B, [1 2], plotPsychometric_w2);

function threshold = plotPsychometric(As, makePlot)
    
    threshold = plotPsychometric_int(As, makePlot, subPlotInd);
    
    subPlotInd = subPlotInd + 1;
    
end

end

function y = fun1(As)

% calculates mean response rate (r) + 0.95 CI bounds

m = sum(As(:, 4) == As(:, 5));

n = size(As, 1);

r = m/n;

[L, U] = BinoConf_ScoreB(m, n);

y = [r L U m n];

end

function sigma = plotPsychometric_sigma(As, ~)

% fitting psychometric

[~, ~, sigma] = fitPsychometric(As(:, 3), As(:, 7), As(:, 8));

end

function threshold = plotPsychometric_int(As, makePlot, p)

lw = 1;

% fitting psychometric

[func, threshold, ~] = fitPsychometric(As(:, 3), As(:, 7), As(:, 8));

if makePlot
    
    % plotting
    
    plotOrder = [1 2 5 6 3 4];    
    
%     p0 = length(get(gcf, 'children'));
    
    subplot(3, 2, p + 1);
    
    hold on;    
    
    plot([1 1] * threshold, [0 0.5], 'r', 'LineWidth', lw);
    
    fineC = logspace2(1e-4, 1e2, 500);
    
    plot(fineC, func(fineC), 'r', 'LineWidth', lw);
    
    eb = @(x, y, l, u, varargin) errorbar(x, y, -l, u, varargin{:});
    
    eb(As(:, 3), As(:, 4), As(:, 5), As(:, 6), 'o', 'LineWidth', lw);
    
    errorbarlogx(0.035);
    
    hold off;
    
    set(gca, 'xscale', 'log');
    
   if p>3
    
        xlabel('Contrast');
        
    else
        
        set(gca, 'xticklabel', {});
        
    end
        
    if ismember(p, [0 2 4])
    
        ylabel('Response Rate');
    
    else
        
        set(gca, 'yticklabel', {});
        
    end 
    
    noiseLabels = {'none', 'ERROR', '0.04 cpd', '0.2 cpd'};
    
    strTitle = sprintf('Signal = %1.2f cpd, Noise = %s', As(1, 2), ...
        noiseLabels{As(1, 1)});
    
    title(strTitle);
    
    axis([1e-3 1e1 0 1]);
    
    set(gca, 'xtick', [1e-3 1e-1 1e1])
    
    grid on;
    
    box on
    
end

end