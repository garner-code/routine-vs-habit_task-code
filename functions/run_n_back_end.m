function [] = run_n_back_end(window, screenYpixels, scores, task)

Screen('TextStyle', window, 1);
Screen('TextSize', window, 20);
instruct_col = [49, 130, 189];

acc = sum(scores.hit_count)/sum(task.is_target);
fa = sum(scores.fa_count)/sum(task.is_target);

instructions = ...
    sprintf(['Good work!\n\n'...
             'Your accuracy rate was: %.0f%%\n' ...
             'and your false alarm rate was: %.0f%% \n\n'...
             'Please call the Experimenter. :)'
             ], acc*100, fa*100);

DrawFormattedText(window, instructions,'Center', screenYpixels*.3, instruct_col);
Screen('Flip', window);

