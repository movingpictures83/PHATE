library(ggplot2)
library(ggrepel)
library(cowplot)
library(plspm)
library(phateR)

dyn.load(paste("RPluMA", .Platform$dynlib.ext, sep=""))
source("RPluMA.R")

input <- function(inputfile) {
  parameters <<- read.table(inputfile, as.is=T);
  rownames(parameters) <<- parameters[,1];
    pfix = prefix()
  if (length(pfix) != 0) {
     pfix <- paste(pfix, "/", sep="")
  }

mydata <- read.csv(paste(pfix, parameters["csvfile", 2], sep="/"), check.names=FALSE)
mydata <- as.data.frame(mydata)
numeric_vars <- readLines(paste(pfix, parameters["features", 2], sep="/"))

mydata_num <<- mydata[, numeric_vars]
mydata_num$classification <<- "normal"

parameters_cats <<- read.table(paste(pfix, parameters["categories", 2], sep="/"), as.is=T);
cats <- c()
for (i in 1:nrow(parameters_cats)) {
   cat_samples <- readLines(paste(pfix, parameters_cats[i,2], sep="/"))
   cats <- c(cats, cat_samples)
   mydata_num$classification[match(cat_samples, rownames(mydata_num))] <<- parameters_cats[i,1]
}

mydata_num_sub <<- match(
  cats,
  rownames(mydata_num)
)

mydata_num$label <<- ""
mydata_num$label[mydata_num_sub] <<- rownames(mydata_num)[mydata_num_sub]

#thecols <<- readLines(paste(pfix, parameters["columns", 2], sep="/"))
}

run <- function() {}

output <- function(outputfile) {
x <- as.matrix(mydata_num[, 1:as.integer(parameters["variables", 2])])
print("A")
phate_data_num <- phate(scale(x))
print("B")
phate_data_num <- data.frame(
  PHATE1 = phate_data_num$embedding[, 1],
  PHATE2 = phate_data_num$embedding[, 2],
  label = mydata_num$label,
  classification = mydata_num$classification
)

yy <<- ggplot(phate_data_num, aes(x = PHATE1, y = PHATE2, 
       label = label, col = classification)) +
  geom_point()
	

	write.csv(yy$label, paste(outputfile, "csv", sep="."))
ggsave(outputfile)
}
