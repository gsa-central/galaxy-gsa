###############################################################################
# title: SPIA
# author: Xiaowei
# time: Mar.31 2021
###############################################################################

#=================================================================
#input arguments
#=================================================================
#spiadata  An CSV file included columns ENTREZ, logFC, and adj.P.Val
#pvalue   Set a threshold value to define different expression genes
#organism A three letter character designating the organism. See a full list at ftp://ftp.genome.jp/pub/kegg/xml/organisms
#nB       Number of bootstrap iterations used to compute the P PERT value. Should be larger than 100. A recommended value is 2000.
#plot     If set to TRUE, the function plots the gene perturbation accumulation vs log2 fold change for every gene on each pathway. The null distribution of the total net accumulations from which PPERT is computed, is plotted as well. The figures are sent to the SPIAPerturbationPlots.pdf file in the current directory.
#combine  Method used to combine the two types of p-values. If set to "fisher" it will use Fisher's method. If set to "norminv" it will use the normal inversion method.
#pathid   A character vector with the names of the pathways to be analyzed. If left NULL all pathways available will be tested.
#=================================================================
#output arguments
#=================================================================
#result_of_SPIA     CSV file of SPIA
#perturbation_Plot  if plot argument set TRUE, the gene perturbation accumulation vs log2 fold change for every gene on each pathway

#=================================================================
#how to pass parameters
#=================================================================
spec <- matrix(c("spiadata", "D", 1, "character", "An CSV file included columns ENTREZ, logFC, and adj.P.Val",
                 "pvalue",   "P", 1, "numeric",   "Set a threshold value to define different expression genes",
                 "organism", "O", 1, "character", "A three letter character designating the organism. See a full list at ftp://ftp.genome.jp/pub/kegg/xml/organisms",
                 "nB",       "N", 1, "integer",   "Number of bootstrap iterations used to compute the P PERT value. Should be larger than 100. A recommended value is 2000.",
                 "combine",  "C", 1, "character", "Method used to combine the two types of p-values. If set to 'fisher' it will use Fisher's method. If set to 'norminv' it will use the normal inversion method.",
                 "pathid",   "I", 1, "character", "A character vector with the names of the pathways to be analyzed. If left NULL all pathways available will be tested.",
                 "result_of_SPIA", "R", 1, "character", "CSV file of SPIA",
                 "plot",     "W", 0, "logical", "if plot argument set TRUE, the gene perturbation accumulation vs log2 fold change for every gene on each pathway",
                 "perturbation_Plot", "L", 1, "character", "An pdf file for the gene perturbation accumulation vs log2 fold change for every gene on each pathway "),
               byrow = TRUE, ncol = 5)


if (!requireNamespace("getopt", quietly = TRUE))
  install.packages("getopt")

opt <- getopt::getopt(spec)

#----------------
#整理参数
#----------------

spiadata = opt$spiadata  

if (!is.null(opt$pvalue)){
  pvalue = opt$pvalue
}else{
  pvalue = 0.05
}

if (!is.null(opt$organism)){
  organism = opt$organism
}else{
  organism = "hsa"  
}

if (!is.null(opt$nB)){
  nB = opt$nB
}else{
  nB = 2000  
}

if (!is.null(opt$combine)){
  combine = opt$combine
}else{
  combine = "fisher" 
}

if (!is.null(opt$pathid)){
  opt$pathid = gsub(" ","", opt$pathid) #remove all blank in opt$pathid
  pathid = strsplit(opt$pathid,",")[[1]]
}else{
  pathid = NULL
}

if (!is.null(opt$result_of_SPIA)){
  result_of_SPIA = opt$result_of_SPIA  
}else{
  result_of_SPIA = "result_SPIA.csv"
}

if (!is.null(opt$plot)){
  plots = opt$plot  
}else{
  plots = FALSE
}


#================================================================
#run codes
#================================================================
suppressPackageStartupMessages(library(SPIA))
top<- read.csv(spiadata)

tg1 <- top[top$adj.P.Val < pvalue,] #chose DE genes
DE_Colorectal = tg1$logFC #chose logFC
names(DE_Colorectal) <- as.vector(tg1$ENTREZ) #set its name as ENTREZ
ALL_Colorectal = top$ENTREZ #Get the whole ENTREZ genes in the files input 
#run spia
# pathway analysis based on combined evidence; # use nB=2000 or more for more accurate results
res=spia(de=DE_Colorectal,  
         all=ALL_Colorectal, 
         organism=organism, 
         nB=nB, 
         plots=plots,
         pathids = pathid,
         beta=NULL, 
         combine=combine,
         verbose=FALSE) 
#================================================================
#result of SPIA
#================================================================
write.csv(res, file = result_of_SPIA )
if(!is.null(opt$perturbation_Plot)){
  file.rename(from = 'SPIAPerturbationPlots.pdf', to=opt$perturbation_Plot)
}


