#the XML package should already come with R
require(XML)
#make path and wd go to wherever your data is
path = "~/pascal-voc-python/VOCdevkit/VOC2012/Annotations"
setwd("~/pascal-voc-python/VOCdevkit/VOC2012/Annotations")

#get a list of all annotation files in the directory
filenames = dir(path,pattern=".xml")

#list of VOC2012 classes in alphabetical order
classes = c("aeroplane", "bicycle", "bird", "boat",
            "bottle", "bus", "car", "cat", "chair",
            "cow", "diningtable", "dog", "horse",
            "motorbike", "person", "pottedplant",
            "sheep", "sofa", "train",
            "tvmonitor")

#loop through XML files and convert them to correct annotation format
for(fname in filenames){
  xmlfile = xmlParse(file=fname)
  root = xmlRoot(xmlfile)
  len = length(xmlChildren(root))
  df = data.frame(matrix(nrow=4,ncol=0))
  v = vector()
  for(i in 1:len){
    attr = trimws(toString.XMLNode(root[[i]][[1]][[1]]),"both")
    
    #check to see if the node corresponds to an object in the image
    if(attr %in% classes){
      for(j in 1:length(xmlChildren(root[[i]]))){
        #hacky solution, but only bbox nodes have 4 children
        if(xmlSize(root[[i]][[j]])==4){
          column = xmlToDataFrame(root[[i]][[j]])
          if(!((grepl("2007_",fname)) | (grepl("2008_",fname)))){
            column = column[c(2,4,1,3),]
          }
          df = cbind(df,column)
        }
      }
      #v is a vector that stores the class to which the object in each bbox belongs
      v = c(v,match(attr,classes))
    }
  }
  df = t(df)
  #below is a data frame whose rows correspond to each bbox followed by the class of the object
  df = cbind(df,v)
  rownames(df) = NULL
  colnames(df) = NULL
  
  #save the data frame as a CSV file whose rows correspond to each bbox (coordinates followed by class)
  write.table(df,file=paste("/Users/rohithkuditipudi/updatedannotations/",gsub(".xml","",fname),".txt",sep=""),quote=FALSE,row.names=FALSE,col.names = FALSE,sep=",")
}
