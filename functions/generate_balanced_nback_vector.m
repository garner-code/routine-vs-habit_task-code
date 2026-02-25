function x = generate_balanced_nback_vector(N, n, pTarget, K)
%GENERATE_BALANCED_NBACK_VECTOR
% Build a length-N vector over {1..8} with:
%   * Balanced label counts (as equal as possible)
%   * Exactly round(pTarget*N) N-back matches (t>n with x(t)==x(t-n))
%   * No other lag-n matches (for non-target t>n, x(t)~=x(t-n))
%
% Usage:
%   x = generate_balanced_nback_vector(40, 2, 0.33);
%
% Inputs:
%   N        - total length
%   n        - N-back lag (positive integer)
%   pTarget  - proportion of targets (e.g., 0.33)
%   K         - number of items e.g. 1..8
%
% Output:
%   x        - 1xN vector of integers in 1..8

    if nargin < 3, pTarget = 0.33; end
    if ~isscalar(N) || ~isscalar(n) || N<=0 || n<=0 || n~=floor(n)
        error('N and n must be positive integers.');
    end
%    K = 8; % labels 1..8
    
    % Desired counts per label (balanced)
    base = floor(N / K);
    rem  = mod(N, K);
    desiredCounts = base * ones(1, K);
    if rem > 0
        desiredCounts(1:rem) = desiredCounts(1:rem) + 1; % distribute extras
    end
    if sum(desiredCounts) ~= N
        error('Internal count allocation error.');
    end
    
    % Number of target positions (clip to feasible)
    targetCount = round(pTarget * N);
    maxTargets  = max(0, N - n); % only positions n+1..N can be targets
    targetCount = min(targetCount, maxTargets);
    
    maxRestarts = 200; % very conservative; usually 1 attempt succeeds
    for attempt = 1:maxRestarts
        % Pick target indices
        if targetCount > 0
            targetIdx = sort(randsample(n+1:N, targetCount));
        else
            targetIdx = [];
        end
        isTarget = false(1, N);
        isTarget(targetIdx) = true;

        % Marks positions that are a "base" for a future target (i.e., t s.t. t+n is target)
        willBeTargetLater = false(1, N);
        willBeTargetLater(targetIdx - n) = true; % safe because targetIdx>n

        x = zeros(1, N);
        remaining = desiredCounts; % remaining quota per label 1..K
        feasible = true;

        for t = 1:N
            if isTarget(t)
                % Target: must equal x(t-n), and we also must have quota remaining
                l = x(t-n);
                if l == 0 || remaining(l) <= 0
                    feasible = false; break;
                end
                x(t) = l;
                remaining(l) = remaining(l) - 1;
            else
                % Non-target: choose a label that:
                %  (1) still has quota,
                %  (2) if t>n, is NOT equal to x(t-n) (no accidental N-back match),
                %  (3) if t+n is a target, we must be able to use the SAME label again at t+n,
                %      so require remaining(label) >= 2 for reservation.
                candidates = find(remaining > 0);
                if t > n
                    candidates(candidates == x(t-n)) = []; % avoid accidental N-back match
                end
                if t+n <= N && isTarget(t+n)
                    % need to reserve one extra for the future target
                    candidates = candidates(remaining(candidates) >= 2);
                end
                if isempty(candidates)
                    feasible = false; break;
                end
                % Choose label among candidates:
                %  - prefer the most underused (largest remaining)
                %  - break ties randomly
                remVals = remaining(candidates);
                best = candidates(remVals == max(remVals));
                l = best(randi(numel(best)));
                x(t) = l;
                remaining(l) = remaining(l) - 1;
            end
        end

        % Validate all constraints
        if feasible && validate_all(x, n, desiredCounts, isTarget)
            return
        end
        % Otherwise, restart
    end

    error('Failed to generate a valid sequence after %d attempts. Consider relaxing constraints.', maxRestarts);
end

function ok = validate_all(x, n, desiredCounts, isTarget)
    K = numel(desiredCounts);
    % 1) Balance
    cts = histcounts(x, 0.5:(K+0.5));
    if any(cts ~= desiredCounts), ok = false; return; end

    % 2) Exact N-back matches only at the declared targets
    N = numel(x);
    lagMatch = false(1, N);
    for t = (n+1):N
        lagMatch(t) = (x(t) == x(t-n));
    end
    if any(lagMatch ~= isTarget)
        ok = false; return;
    end

    ok = true;
end