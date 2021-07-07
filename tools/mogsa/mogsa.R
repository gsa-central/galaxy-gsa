###############################################################################
# title: mogsa
# author: Xiaowei
# time: Mar.31 2021
###############################################################################
#=================================================================
#how to pass parameters
#=================================================================
spec <- matrix(c("data_file", "D",1, "character", "mogsa data file, xlsx file",
                 "geneSet_file", "G",1, "character", "gene set /pathway, rdata file, geneSet object",
                 "design_file", "S",1, "character", "CSV file, colcode, label, sample",
                 
                 "PC_number", "P",1, "integer", "numbers for PCs",
                 "w_data","W",1, "character", "uniform, lambdal, inertia",
                 "proc_row", "O", 1, "character", "cnetre, center_ssq1, center_ssqN, center_ssqNm1",
                 "ks_B","B",1, "character", "An integer to indicate the number of bootstrapping samples to calculated the p-value of KS statistic.",
                 "p_adjust_method", "M", 1, "character", "p values adjust method",
                 "output_file1", "R", 1, "character", "genesetScoreMatrix CSV file",
                 "output_file2", "R2", 1, "character", "P value Matrix CSV file"
                 
),
byrow = TRUE, ncol = 5)


if (!requireNamespace("getopt", quietly = TRUE))
  install.packages("getopt")

opt <- getopt::getopt(spec)

if (is.null(opt$PC_number)){PC_number = 3}else{PC_number = opt$PC_number}
if (is.null(opt$w_data)){w_data = "inertia"}else{w_data = opt$w_data}
if (is.null(opt$proc_row)){proc_row = "center_ssq1"}else{proc_row = opt$proc_row}
if (is.null(opt$ks_B)){ks_B = 1000}else{ks_B = opt$ks_B}
if (is.null(opt$p_adjust_method)){p_adjust_method = "fdr"}else{p_adjust_method = opt$p_adjust_method}

##########################################################
# load packages
##########################################################
library(mogsa)
library(openxlsx) #for load the xlsx file
##########################################################
# Parameters
##########################################################

sheets <- getSheetNames(opt$data_file)
mogsa_data <- vector(mode = "list", length = length(sheets))
names(mogsa_data) = sheets
for (sht in sheets){
  mogsa_data[[sht]] <- read.xlsx(opt$data_file, sheet = sht, colNames = T, rowNames = T)
}



# design
design <- read.csv(opt$design_file, header = T, stringsAsFactors = F) #分类别、分组别
groups <- as.factor(design$label) 
#if ("colcode" %in% colnames(design)){colcode <- design$colcode}else{colcode = NULL}


# geneSet
load(opt$geneSet_file)
sup_data <- prepSupMoa(mogsa_data, geneSets=geneSet, minMatch = 1)


##########################################################
# mogsaBasicRun
##########################################################
mgsa1 <- mogsa(x = mogsa_data, sup=sup_data, nf=PC_number,
               proc.row = proc_row, w.data = w_data, statis = TRUE, 
               ks.B = ks_B, p.adjust.method = p_adjust_method)



##########################################################
# gene Set Score (GSS) Matrix 基因集打分矩阵  每个值表示该基因集在该样本的总体活性水平
##########################################################
# get the score matrix
scores <- getmgsa(mgsa1, "score")
write.csv(scores, file = opt$output_file1)


##########################################################
# P value Matrix 
##########################################################
# 获取p值矩阵，行是基因集/pathway名称,列为样本名称
p.mat <- getmgsa(mgsa1, "p.val") # get p value matrix
write.csv(p.mat, file = opt$output_file2)


