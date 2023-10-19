dic = getDirectory("image");
title = getTitle();
print(dic);
saveAs("Tiff", dic+title)
close();