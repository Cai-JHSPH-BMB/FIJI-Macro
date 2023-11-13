# Using BIOP-JACoP to do Co-localization in a certain ROI.

Here's the explanation for each chuck which can be further customized. 

### First step: Preparation

Prepare for the directory, path, and file names for later references:

```java
title = getTitle();
//SET DICIONARY FOR STACKS IMAGES
dic = getDirectory("image");
path= dic + "/processed/"
foci = "H3K9me3"
setForegroundColor(252, 252, 252);
setBackgroundColor(252, 252, 252);
//clear old saved roi positions
roicount = roiManager("count");
if (roicount!= 0){
	roiManager("delete");
}
```

note: make sure that you have a processed folder in your folder so that the output is not too messy. You can use `path = dic` if you don't want a subfolder. 

### Second Step: Look for your ROI of interested

The following code is an automatic process that looks for foci in the image. In one channel; you can specify which channel goes first, duplicate, Gaussian Blur, Analyze Particles, and count the ROI manager. As a quality control, if there's no output, have "0" as the output. ROI will be reset before another repeat

```java
//ROI-based localization analysis, this channel will reset
run("Duplicate...", "duplicate channels=2");
resetMinAndMax;
run("Duplicate...", "duplicate channels=2");
resetMinAndMax;
run("Gaussian Blur...", "sigma=1");
setAutoThreshold("MaxEntropy dark no-reset");
//run("Threshold...")；
run("Analyze Particles...", "size=0.20-Infinity display exclude clear summarize overlay add composite");
run("Convert to Mask") ;
run("RGB Color");
//selectWindow("Results");
//if no result
i=0;
n = roiManager("count");
//print(n)
if (n==0) {
	print("enter no result(green channel)",n);
	Table.create("Results");
	Table.setColumn("Label", newArray(title));
	Table.setColumn("Area", newArray("0"));
	Table.setColumn("Mean", newArray("0"));
	Table.setColumn("Min", newArray("0"));
	Table.setColumn("Max", newArray("0"));
	Table.setColumn("X", newArray("0"));
	Table.setColumn("Y", newArray("0"));
	Table.setColumn("IntDen", newArray("0"));
	Table.setColumn("RawIntDen", newArray("0"));
}
//if result
if (n!=0){
	print("enter results (green channel)",n);
	while (i<5 && i<n) {
		x = getResult("X", i);
    	y = getResult("Y",i);
//    	print(x,y,"debug1");
    	makeRectangle(x*15.13-42.5, y*15.13-42.5, 85, 85);
    	roiManager("Add");
		i=i+1;
	}
}
//draw square
roiManager("show all");
roiManager("Draw");
//reset  and start
roiManager("reset");


//save 
selectWindow("Results");
run("Read and Write Excel", "stack_results" );
run("Close");
selectWindow("Summary");
run("Close");
```

Here's the algorithm for ROI: 
![alt text](https://github.com/Cai-JHSPH-BMB/FIJI-Macro/blob/main/ROI-Coloc/ROI.png)
Note here is if you want to proceed to do colocalization of two channels, you first need to determine which ROI if interested you are looking at. For example, if the green channel is what I'm interested in, you first measure in the red channel, and reset, and then measure in green channel. THis would make sure that only the green channel ROI is there. If you want to have both, you can delete the reset ROImanager function. 


## Step Three: Rename ROI -- this is important if you want to output your data to excel: 

```java
//roiManager("reset");
for (i = 0; i < roiManager("count"); i++) {
//	print(i);
	roiManager("Select", i);
	roiManager("rename", i+1);
}
```

### Step Four: Visualization

As a quality control, you can see how your threshold and your foci calling algorithm is good enough for further analysis. This step simply output a montage image of the thresholding. 

```java
//stack and montage
selectWindow("Results");
run("Read and Write Excel", "stack_results" );
run("Close");
run("Images to Stack", "use");
run("Make Montage...", "columns=2 rows=2 scale=1 border=1 font=40 label use");
saveAs("Tiff", path + "/" +title + "_Montage.tiff");
run("Close");
selectWindow("Stack");
run("Close");
selectWindow("Summary");
run("Close");
```

### Step Five: Run BIOP-JACoP for analysis, and save output. 

```java

//default 
run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=Default threshold_for_channel_b=Default manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
for (i = 0; i < roiManager("count"); i++) {
	selectWindow(tiff + " (" + i+1 + ") " + "Report");
	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "default_Report.tiff");
	run("Close");	
}
selectWindow("Results");
Table.setColumn("Foci", newArray(foci,foci));
run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
selectWindow("Results");
run("Close");
selectWindow("Log");
saveAs("txt", path+tiff+"_log.txt");
run("Close");
```
