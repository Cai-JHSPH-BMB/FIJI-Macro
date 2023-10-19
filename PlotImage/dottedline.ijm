imgtitle = getTitle();
dic = getDirectory("image");
roiManager("reset");
run("Duplicate...", "duplicate channels=3");
run("Gaussian Blur...", "sigma=5");
setAutoThreshold("Default dark no-reset");
setForegroundColor(255, 255, 0);
setBackgroundColor(255, 255, 255);
//run("Threshold...");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Analyze Particles...", "size=100-Infinity display add");
selectImage(imgtitle);
waitForUser;
run("Duplicate...", "duplicate channels=2");
count = roiManager("count")
for (i=0; i<count; i++){
   roiManager("select", i);
   run("Dotted Line", "line=2 dash=12,12");
}
print(dic)
print(imgtitle)
saveAs("Tiff", dic + imgtitle + "channel_one_dotline");
run("Close");
selectImage(imgtitle);
run("Duplicate...", "duplicate channels=1");
count = roiManager("count")
for (i=0; i<count; i++){
   roiManager("select", i);
   run("Dotted Line", "line=2 dash=12,12");
}
saveAs("Tiff", dic + imgtitle + "channel_two_dotline");
///////////////////////////////////creating composite image
selectImage(imgtitle);
run("Scale Bar...", "width=5 height=5 thickness=5 bold hide overlay");
//run("Channels Tool...");
Property.set("CompositeProjection", "Sum");
Stack.setDisplayMode("composite");
Stack.setActiveChannels("110");
saveAs("Jpeg", dic + imgtitle + "channel_three_scalebar");
print(imgtitle)
open(dic + imgtitle + "channel_three_scalebar.jpg");

for (i=0; i<count; i++){
   roiManager("select", i);
   run("Dotted Line", "line=2 dash=12,12");
}
/// automatically generate a rectengle that does that drawing, need to drag
makeRectangle(0, 0, 85, 85);
waitForUser("Select Custom Foci ROI");
roiManager("add");
setForegroundColor(255, 255, 255);
setBackgroundColor(255, 255, 255);
selectImage(imgtitle + "channel_three_scalebar.jpg");
run("Line Width...", "line=4");
roiManager("select", 1);
roiManager("Draw");
saveAs("Jpeg", dic + imgtitle + "channel_three_dotline");

selectImage(imgtitle);
roiManager("select", 1);
run("Duplicate...", "duplicate channels=1");
saveAs("Jpeg", dic + imgtitle + "channel_one_foci");
run("Close");


selectImage(imgtitle);
roiManager("select", 1);
run("Duplicate...", "duplicate channels=2");
saveAs("Jpeg", dic + imgtitle + "channel_two_foci");
run("Close");

open(dic + imgtitle + "channel_three_scalebar.jpg");
roiManager("select", 1);
run("Duplicate...");
saveAs("Jpeg", dic + imgtitle + "channel_three_foci");
run("Close");

