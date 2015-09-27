Version 2015 09 27
By Gergo Bohner

Download the zip file and extract to a folder, let's call it CODEDIR.

The aim of this software is to locate cell bodies in a set of images.
The process is as follows:

Collect the set of images in a folder, which I will call WORKDIR from now on.
Make sure Matlab has write permission for WORKDIR and subfolders.

Start the software by running the function CODEDIR/gui/ROICOV_gui, this will also add all the required folders to the Matlab path.

The very simple gui consists of 5 buttons, which should be used from top to buttom during the first run.

1.) Select files
	Navigate to WORKDIR and select all (shift/control clicking) the TIFF images you want to use during the subsequent process.

2.) Set options
	Set a bunch of options for further processing of images.
	During initial testing it is recommended to scale down the original images to 0.5 or even 0.2 for much quicker processing. Adjust other settings accordingly. Make sure to save the file in matlab editor.
	
3.) Preprocess
	During this phase the data from the images will be converted into matlab files, as well as some basic image processing will be used.
	One crucial part is, if opt.mask = 1, then the user will be required to draw a polygon around the area to be considered. This goes as:
	Start left clicking around the area of interest, when it is done right click to join the first and the last nodes of the line. Then right click again and choose "create mask", then move on to the next image.
	The preprocessed files will be stored within the WORKDIR/Preprocessed folder, and files selected during step 1 together will share a time stamp that refers to the start of preprocessing.
	Sets of files with different timestamps can not be processed together further on, this ensures that they had been preprocessed during the same options.

4.) Learn Model
	The user is first asked whether to use the current set of files, if all the previous steps had been done in the current run, just click yes.
	If you want to go back to a previous set of files to learn from, you can click no, then you are given the option to choose the corresponding timestamp.
	Afterwards learning proceeds, this is somewhat slow, with 5 files of 1500x1500 and 19 pixel basis functions it is 5 minutes per iteration. Downscaling makes it dramatically faster.
	The output of this step is a model for each iteration in the folder WORKDIR/Model, with the corresponding timestamp. This model shall be used during the inference step.

5.) Inference
	Again, the user is promted to select a set of files based on their shared timestamp, just as in step 4.
	Afterwards you also need to select a model. The default option will give you the model with the correct timestamp and the highest iteration number, so normally just click select here.
	As a third step, you have to select the number of cells to infer, this shall be higher than the number of cells you have learned from, 
	as it does not influence quality anymore, and you can disregard bad cells in a post-processing step afterwards.

	The output of this step will appear in WORKDIR/Results, there will be 3 types of files.
		all_results_timestamp.mat is all the cells found in all the images, mainly for reproducability.
		There will be a matlab file for each of the original images, containing the inferred variables.
		There will be also a text file for each of the original images, containing 3 columns, the x coordinate the y coordinate and the "cell likeliness" (the lower the better, sorted accordingly), for each object.


DEBUGGING
- All intermediate step variables (for current set of files, current timestamp etc) are stored in the "CODEDIR/tmp" folder, I recommend deleting the folder in case something is acting weirdly, and trying a fresh start
- The subfolders within WORKDIR can get crowded with file sets of different timestamps (but this is required for reproduceability), so I recommend sometimes copying the original images to a different location (basically a new WORKDIR) for a fresh start yet again.
- If a certain setting (corresponding to a timestamp) seemed to have been a failure, then just search within WORKDIR and subdirectories for all files sharing that timestamp, and delete them.
