title = getTitle();
//SET DICIONARY FOR STACKS IMAGES
dic = "/Volumes/WD_BLACK/Image_Analysis_Cai/Halo-YAP/U2OS"
path= dic + "/processed/"
foci = "H3K9me3"
setForegroundColor(255, 255, 255);
setBackgroundColor(255, 255, 255);
roicount = roiManager("count");
if (roicount!= 0){
	roiManager("delete");
}
// TEAD4 based localization analysis, this cannel will reset
run("Duplicate...", "duplicate channels=1");
resetMinAndMax;
run("Duplicate...", "duplicate channels=1");
resetMinAndMax;
run("Gaussian Blur...", "sigma=1");
setAutoThreshold("MaxEntropy dark no-reset");
//run("Threshold...")；
run("Analyze Particles...", "size=0.03-Infinity display exclude clear summarize overlay add composite");
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
    	makeRectangle(x*15.14-22.5,y*15.14-22.5,45,45);
    	//x*15.14-22.5,y*15.14-22.5,45,45
    	//x*28.33-42.5, y*28.33-42.5, 85, 85
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
//start another channel
selectWindow(title);
run("Duplicate...", "duplicate channels=2");
resetMinAndMax;
run("Duplicate...", "duplicate channels=2");
resetMinAndMax;
run("Gaussian Blur...", "sigma=1");
//try Shanbhag if not work
setAutoThreshold("MaxEntropy dark no-reset");
run("Analyze Particles...", "size=0.03-Infinity display exclude clear summarize overlay add composite");
run("Convert to Mask");
run("RGB Color");

//if no result
n = roiManager("count");
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


//if result, sort, and start with largest foci
if (n!=0){
	print("enter results (redchannel)",n);
	selectWindow("Results");
	Table.sort("Area");
	i= 0;
	n = roiManager("count");
//	print(n);
	while (i<n) {
		x = getResult("X", n-i-1);
   		y = getResult("Y",n-i-1);
    	print(x,y,"debug2");
    	makeRectangle(x*15.14-22.5,y*15.14-22.5,45,45);
    	//x*15.14-22.5,y*15.14-22.5,45,45
    	//x*28.33-42.5, y*28.33-42.5, 85, 85
    	roiManager("Add");
		i=i+1;
	}
}


//draw
roiManager("show all");

roiManager("Draw");
//roiManager("reset");
for (i = 0; i < roiManager("count"); i++) {
//	print(i);
	roiManager("Select", i);
	roiManager("rename", i+1);
}

roicount = (roiManager("count")/2);
for (i = 0; i < roicount ; i++) {
roiManager("select", 0);
roiManager("delete");
}


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


selectWindow(title);
resetMinAndMax;
//roiManager("show all with labels");


roiManager("deselect");
//change ROI position name
for (i = 0; i < roiManager("count"); i++) {
//	print(i);
	roiManager("Select", i);
	roiManager("rename", i+1);
}
//waitForUser
//save ROI position as tiff image
roiManager("Show All");
//roiManager("Draw");
selectWindow(title);
saveAs("Tiff", path + "/" +title + "_ROI.tiff");
tiff = getTitle();
run("Undo");

//optional import previous results
//open("/Users/jeffrey.liang.mac/Desktop/Image Analysis for JIL 20230207/test_save_folder/Results.csv");
//waitForUser
//run plugin


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

//
////#IJ_IsoData
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=IJ_IsoData threshold_for_channel_b=IJ_IsoData manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "IJ_Isodata_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
//
////#Li
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=Li threshold_for_channel_b=Li manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "Li_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#MaxEntropy
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=MaxEntropy threshold_for_channel_b=MaxEntropy manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "MaxEntropy_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#Mean
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=Mean threshold_for_channel_b=Mean manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "Mean_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#MinError
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=MinError threshold_for_channel_b=MinError manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "MinError_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#Minimum
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=Minimum threshold_for_channel_b=Minimum manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "Minimum_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#Moments
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=Moments threshold_for_channel_b=Moments manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "Moments_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#Otsu
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=Otsu threshold_for_channel_b=Otsu manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "Otsu_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#Percentile
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=Percentile threshold_for_channel_b=Percentile manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "Percentile_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#RenyiEntropy
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=RenyiEntropy threshold_for_channel_b=RenyiEntropy manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "RenyiEntropy_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#Shanbhag
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=Shanbhag threshold_for_channel_b=Shanbhag manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "Shanbhag_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#Triangle
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=Triangle threshold_for_channel_b=Triangle manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "Triangle_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//
////#Yen
//run("BIOP JACoP", "channel_a=1 channel_b=2 threshold_for_channel_a=Yen threshold_for_channel_b=Yen manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap costes_block_size=5 costes_number_of_shuffling=100");
//for (i = 0; i < roiManager("count"); i++) {
//	selectWindow(tiff + " (" + i+1 + ") " + "Report");
//	saveAs("Tiff", path+tiff + " (" + i+1 + ") " + "Yen_Report.tiff");
//	run("Close");	
//}
//selectWindow("Results");
//Table.setColumn("Foci", newArray(foci,foci));
//run("Read and Write Excel", "file=["+path+"biopresult.xlsx] stack_results" );
//selectWindow("Results");
//run("Close");
//selectWindow("Log");
//saveAs("txt", path+tiff+"_log.txt");
//run("Close");
//close("*");
//
