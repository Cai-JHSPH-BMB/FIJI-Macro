//Open czi stack image using FIJI(installed with Bioformat) 
//When the window pop-up, open all images
//run the code. With one click of run, one image will be saved

dic = getDirectory("image");
title = getTitle();
print(dic);
saveAs("Tiff", dic+title)
close();
