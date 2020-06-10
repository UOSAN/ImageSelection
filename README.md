# ImageSelection

## Introduction

The ImageSelection task presents image stimuli of foods that are rated for how appetizing the food looks.

- Conditions: pictures of food, where the food is either in a category that the participant self-reports they crave, or in a category that the participant self-reports they do not crave.
- Trial structure: stimulus until participants rates from 1 to 4, or 0 to indicate a strong negative reaction to the picture.

## How to run the task

1. Launch the PsychoPy Builder.
2. Open the file `ImageSelection.psyexp`.
3. Start the experiment by selecting the Tools -> Run menu item or click the run icon:

![run icon](./run_icon.png)

4. Fill in the subject number, and the stimulus set. The stimulus set should be "1" for the categorized images, and "2" for WillingnessToPay. The task will start automatically after that.

## Task description

The task starts by displaying introduction text. The introduction text is displayed until the user presses any button. The introduction text is:
```
We are going to show you some pictures of food and have you rate how appetizing each food is.

You will use a scale from 1 to 4, where 1 is "Not at all appetizing" and 4 is "Extremely appetizing."

If you have a strong negative reaction to the food, press 0.


Press any key to continue.
```

Then instruction text is displayed. The instruction text is displayed until the user presses any button. The instruction text is:
```
Please use the numbers along the top of the keyboard to select your rating.

The rating task will now begin.


Press any key to continue.
```

A fixation cross is displayed for 0.25 seconds, then trials are displayed. Trials are repeated 120 times for categorized images, and 68 times for WillingnessToPay images.
After 20 trials, there is a pause text displayed, until the user presses any button. The pause text is:
```
Press any key when you are ready to continue
```

After all the trials are completed, end text is displayed for 5 seconds. The end text is:
```
That concludes this task. The assessor will be with you shortly.
```

Trials are repeated 40 times, in the behavioral version, or 20 times, in the scanner version.

### Trial structure

- On a black background:
- Display rating instructions, in grey text, at the top of the screen. The text is: `How appetizing is this food?`
- Display the image stimulus.
- Display the 4 squares evenly spaced in a row, from left to right, containing the text "1", "2", "3", "4". Display a fifth square in the same row, further spaced to the right, containing the text "0"
- When the participant selects a rating, provide visual feedback by changing the background color of the square, corresponding to the selected rating, to green.


Duration depends on participant behavior.

## Configuration

The task is configured by a file containing the categories of food, named `categories_DEV<participant_number>.txt`, i.e. `categories_DEV123.txt` for the participant number 123. The file must contain four lines. The first line is number indicating the category of non-craved food. The next three lines are numbers indicating the categories of craved food.

The location of the images is in the labwide Dropbox folder.

## Output
The task outputs the standard PsychoPy log, csv, and psydat files. It also outputs a file named `DEV<participant_number>_ratings_forWebsite.csv`, and `imagePrezOrder_DEV<participant_number>.txt`.


## Developer documentation

Developed with PsychoPy v2020.1.2
