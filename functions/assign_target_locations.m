function [sub, ca_idxs, cb_idxs] = assign_target_locations(sub)

    %%%% ASSIGN_TARGET_LOACTIONS: for a given subject, assign randomly
    %%%% selected target loactions to doors, with the following constraints
    %%%% - 1 door in each quadrant, 2 are outer, 2 are inner
    
    
    % note that the below variables could be shifted to be inputs in future
    % iterations of the task
    quadrants = 4;
    n_outest = 1; % n tgts in outer corners per context
    n_outmid = 2; % n tgts in outer but not corners per context
    n_inner = 1; % n tgts in inner per context
    
    %%%%%%%%%% set the options for each type of door allocation
    outest = [1, 4, 13, 16]; % outer corners
    outmid = {[2, 5];... % outer but not a corner
              [3, 8];...
              [9, 14];...
              [12, 15]};
    inner = [6, 7, 10, 11]; % inner

    assign_outer_to_a = datasample(1:quadrants, n_outest, 'Replace', false);
    assign_outer_to_b = datasample(setdiff(1:quadrants, assign_outer_to_a), ...
        n_outest, 'Replace', false);
    assign_innest_to_a = datasample(setdiff(1:quadrants, assign_outer_to_a), ...
        n_inner, 'Replace', false);
    % now assign the inner for b, making sure it doesn't share a quadrant
    % with the outer for b, and it also can't be the same as the innest for
    % a
    assign_innest_to_b = datasample(setdiff(1:quadrants, [assign_outer_to_b, ...
        assign_innest_to_a]), n_inner, 'Replace', false);
    % now two quadrants have been taken for both a and b, so get the
    % remaining 2 for each context
    assign_outmid_to_a = setdiff(1:quadrants, [assign_innest_to_a, assign_outer_to_a]);
    assign_outmid_to_b = setdiff(1:quadrants, [assign_innest_to_b, assign_outer_to_b]);
    %%%%%%%%%%%%%%

    %%%%%%%%% now I have the assignments, I can start selecting target
    %%%%%%%%% locations for each context
    ca_idxs = zeros(1, quadrants);
    cb_idxs = ca_idxs;

    % now assign the tricky guys
    for imid = 1:n_outmid
        
        ca_idxs(imid) = datasample(outmid{assign_outmid_to_a(imid)}, 1, 'Replace',false);
        outmid{assign_outmid_to_a(imid)}(outmid{assign_outmid_to_a(imid)} == ca_idxs(imid)) = []; %now remove that guy because its not possible for other cfigs
        cb_idxs(imid) = datasample(outmid{assign_outmid_to_b(imid)}, 1, 'Replace',false);
        outmid{assign_outmid_to_b(imid)}(outmid{assign_outmid_to_b(imid)} == cb_idxs(imid)) = []; % now remove 
    end

    % hardcoded - warning!
    ca_idxs(3) = outest(assign_outer_to_a);
    cb_idxs(3) = outest(assign_outer_to_b);
    ca_idxs(4) = inner(assign_innest_to_a);
    cb_idxs(4) = inner(assign_innest_to_b);
end
