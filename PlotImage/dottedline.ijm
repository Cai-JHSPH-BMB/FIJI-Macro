imgtitle = getTitle();
run("Duplicate...", "duplicate channels=3");
run("Gaussian Blur...", "sigma=15");
setAutoThreshold("Huang dark no-reset");
setForegroundColor(255, 255, 255);
setBackgroundColor(255, 255, 255);
//run("Threshold...");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "size=0.20-Infinity display add");
selectImage(imgtitle);
run("Duplicate...", "duplicate channels=1");

count = roiManager("count")
for (i=0; i<count; i++){
   roiManager("select", i);
   run("Dotted Line", "line=1 dash=6,6");
}
