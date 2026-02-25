function [] = run_n_back_instructions(window, screenYpixels)

Screen('TextStyle', window, 1);
Screen('TextSize', window, 20);
instruct_col = [49, 130, 189];

instructions = ...
    sprintf(['instructions go here\n'...
    'and here\n']);

DrawFormattedText(window, instructions,'Center', screenYpixels*.3, instruct_col);
Screen('Flip', window);