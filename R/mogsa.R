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
                 "output_file", "R", 1, "character", "ZIP file"
                 
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
library(gplots) # used for visulizing heatmap
library(openxlsx) #for load the xlsx file
library(rmarkdown) #r@2.6 for output html
#library(knitr) 
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
if ("colcode" %in% colnames(design)){colcode <- design$colcode}else{colcode = NULL}


# geneSet
load(opt$geneSet_file)
sup_data <- prepSupMoa(mogsa_data, geneSets=geneSet, minMatch = 1)


##########################################################
# mogsaBasicRun
##########################################################
mgsa1 <- mogsa(x = mogsa_data, sup=sup_data, nf=PC_number,
               proc.row = proc_row, w.data = w_data, statis = TRUE, 
               ks.B = ks_B, p.adjust.method = p_adjust_method)

wd = getwd()
# create directory and set it as working directory-----------------------------
dir.create("mogsa")
setwd("mogsa")
##########################################################
# PC 的方差 和 PC的百分比
##########################################################

pdf(width = 12.19, file = "Variance_PCs.pdf")
layout(matrix(1:2, 1, 2)) 
plot(mgsa1@moa, value="eig", type = 2, 
     # n=20, 
     main="variance of PCs") # use '?"moa-class"' to check the help manu
plot(mgsa1@moa, value="tau", type = 2,  main="Scaled variance of PCs")
dev.off()

##########################################################
# gene Set Score (GSS) Matrix 基因集打分矩阵  每个值表示该基因集在该样本的总体活性水平
##########################################################
# get the score matrix
scores <- getmgsa(mgsa1, "score")
write.csv(scores, file = "geneSetScoreMatrix.csv")

pdf(width = 17.72, file = "GeneSetScore.pdf")
if (is.null(colcode)){
  heatmap.2(scores, trace = "n", scale = "r", Colv = NULL, dendrogram = "row",
            margins = c(10, 40))
}else{
  heatmap.2(scores, trace = "n", scale = "r", Colv = NULL, dendrogram = "row",
            margins = c(10, 40), ColSideColors=colcode
  )
}

dev.off()


##########################################################
# P value Matrix 
##########################################################
# 获取p值矩阵，行是基因集/pathway名称,列为样本名称
p.mat <- getmgsa(mgsa1, "p.val") # get p value matrix
write.csv(p.mat, file = "p_value_matrix.csv")

# select gene sets with most signficant GSS scores.
if (nrow(p.mat) > 20){n = 20}else{n=nrow(p.mat)}
top.gs <- sort(rowSums(p.mat < 0.01), decreasing = TRUE)[1:n] #选择在所有样本中的p值小于0.01的基因集并排序，然后取前20个
top.gs.name <- names(top.gs)
#top.gs.name
# 对显著基因集/pathway的打分矩阵作热图
pdf(width = 17.72, file = "top_gs_GeneSetScore.pdf")
if (is.null(colcode)){
  heatmap.2(scores[top.gs.name, ], trace = "n", scale = "r", Colv = NULL, dendrogram = "row",
            margins = c(10, 40))
}else{
  heatmap.2(scores[top.gs.name, ], trace = "n", scale = "r", Colv = NULL, dendrogram = "row",
            margins = c(10, 40), ColSideColors=colcode
  )
}

dev.off()

##########################################################
# decompose.gs.group
##########################################################
pdf(width = 10.58, file = "decompose_gs_group.pdf")
for (gs in row.names(p.mat)){ #top.gs.name
  decompose.gs.group(mgsa1, gs, group = groups, nf = PC_number) 
  title(main = gs)
}
dev.off()
##########################################################
# The gene influential score (GIS) plot
##########################################################
gis_list <- vector(mode = "list", length = nrow(p.mat))
names(gis_list) = row.names(p.mat)
for (gs in row.names(p.mat)){
  gis_list[[gs]] <- GIS(mgsa1, gs, barcol = gray.colors(length(mogsa_data)), plot = FALSE)
  gis_list[[gs]]$geneSet <- gs
}
gis <- do.call(rbind, gis_list)
gis <- na.omit(gis)
rownames(gis) <- NULL
write.csv(gis, file = "geneInfluentialScore.csv")

############################################################
# markdown file
############################################################
content_text <- "

---
title: 'mogsa: Gene Set Analysis on multiple omics data'
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## 1. MOGSA overview

Modern 'omics' technologies enable quantitative monitoring of the abundance of various biological molecules in a high-throughput manner, accumulating an unprecedented amount of quantitative information on a genomic scale.  Gene set analysis is a particularly useful
method in high throughput data analysis since it can summarize single gene level information into the biological informative gene set levels.The mogsa provide a method doing gene set analysis based on multiple omics data that describes the same set of observations/samples.

MOGSA algorithm consists of three steps. In the first step, multiple omics data are integrated using multi-table multivariate analysis, such as multiple factorial analysis (MFA). MFA projects the observations and variables (genes) from each dataset onto a lower dimensional space, resulting in sample scores (or PCs) and variables loadings respectively. Next, gene set annotations are projected as additional information onto the same space, generating a set of scores for each gene set across samples. In the final step, MOGSA generates a gene set score (GSS) matrix by reconstructing the sample scores and gene set scores. A high GSS indicates that gene set and the variables in that gene set have measurement in one or more dataset that explain a large proportion of the correlated information across data tables. Variables (genes) unique to individual datasets or common among matrices may contribute to a high GSS. For example, in a gene set, a few genes may have high levels of gene expression, others may have increased protein levels and a few may have amplifications in copy number.


## 2. Variance of PC 

To determine how many PCs should be retained in the step of reconstructing gene set score matrix,
We plot scree plot of the eigenvalues, which result from the multivariate analysis.

```{r echo = FALSE}
layout(matrix(1:2, 1, 2)) 
plot(mgsa1@moa, value='eig', type = 2, 
     # n=20, 
     main='variance of PCs') # use '?'moa-class'' to check the help manu
plot(mgsa1@moa, value='tau', type = 2,  main='Scaled variance of PCs')
```



## 3. Gene Set Score (GSS) Matrix

The main result returned by `mogsa` is the gene set score matrix. The value in the matirx indicates the overall active level of a gene set in a sample.  The heatmap of this matrix and the top 20 significant gene sets can be visualized in [GeneSetScore.pdf](GeneSetScore.pdf) and [top_gs_GeneSetScore.pdf](top_gs_GeneSetScore.pdf). This table can be download from [geneSetScoreMatrix.csv](geneSetScoreMatrix.csv). 

```{r echo = FALSE}
library(DT)
datatable(scores, fillContainer = TRUE, filter = 'top')
```


## 4. P-value for each gene set score

The corresponding p-value for each gene set score can be download from [p_value_matrix.csv](p_value_matrix.csv).

## 5. Data-wise or PC-wise decomposition of gene set scores for all observations

Which dataset(s) contribute most to the high or low gene set score of a gene set? We used `decompose.gs.group()` function for 
gene set score decomposion. Here explore the gene set that have most significant gene set scores：

```{r echo=FALSE}
gs = top.gs.name[1]
decompose.gs.group(mgsa1, gs, group = groups, nf = PC_number) 
```

All gene set score decomposition can be viewed with [decompose_gs_group.pdf](decompose_gs_group.pdf).

## 6. Gene influential scores

Which genes are most important in defining the gene set score for a gene set? We can use `GIS()` function to calculate
gene influential scores of genes in a gene set. In this table show you all gene influential scores in all gene set. This 
table can be downloaded in [geneInfluentialScore.csv](geneInfluentialScore.csv).

```{r echo=FALSE}
library(DT) #version=r@0.17
datatable(gis, filter = 'top', fillContainer = TRUE)
```


"
cat(content_text, file = "mogsa.Rmd")

# OUTPUT AS HTML FILE
suppressMessages(render("mogsa.Rmd", "html_document"))


file.remove("mogsa.Rmd")
################################################################################
setwd(wd)
#system(paste0("zip -q -r ", opt$output_file, " mogsa"))
zip(zipfile = "mogsa_results.zip", files = "mogsa/")

file.rename(from = 'mogsa_results.zip', to=opt$output_file)