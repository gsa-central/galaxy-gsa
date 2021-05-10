###############################################################################
# title: Gene set variation analysis
# author: Xiaowei
# time: Mar.31 2021
###############################################################################
#=================================================================
#how to pass parameters
#=================================================================
spec <- matrix(c("expr", 'E', 1, 'character', 'Gene expression data which is an CSV file of expression values where rows correspond to genes and columns correspond to samples.',
                 "geneSet", 'G', 1, 'character', 'Gene set',
                 'gene_Identifier_class','C', 1, 'character', 'Gene Identifier class of GeneSet',
                 'method', "M", 1,'character', 'One of gsva, ssgsea, zscore, plage',
                 'img_file', 'I', 1,'character', 'img_file',
                 'img_type', 'T', 1,'character', 'PDF, PNG, JPEG',
                 'img_width', 'W', 1, 'integer', 'the img file width',
                 'img_height', 'H', 1, 'integer', 'the img file height',
                 'GSVA_result', 'R', 1, 'character', 'Result of GSVA, an CSV file.'
                 
                 ),
               byrow = TRUE, ncol = 5)


if (!requireNamespace("getopt", quietly = TRUE))
  install.packages("getopt")

opt <- getopt::getopt(spec)

#----------------
#整理参数
#----------------

if(is.null(opt$gene_Identifier_class)){gene_Identifier_class = 'Symbol'}else{gene_Identifier_class = opt$gene_Identifier_class }
if(is.null(opt$method)){opt$method = 'gsva'}
if(is.null(opt$img_type)){opt$img_type = 'PNG'}
if(is.null(opt$img_width)){img_width = 900}else{img_width = opt$img_width}
if(is.null(opt$img_height)){img_height = 900}else{img_height = opt$img_height}

#================================================================
#run codes
#================================================================
gsva_input_data <- read.csv(opt$expr, row.names = 1)

# if (gene_Identifier_class == 'Symbol'){
#   geneset <- GSEABase::getGmt(opt$geneSet, 
#                               geneIdType = GSEABase::SymbolIdentifier())
# }else{
#   geneset <- GSEABase::getGmt(opt$geneSet, 
#                               geneIdType = GSEABase::EntrezIdentifier())
# }

load(opt$geneSet)

result <- GSVA::gsva(as.matrix(gsva_input_data), geneSet, mx.diff=FALSE, 
               verbose=FALSE, parallel.sz=2, method = opt$method)
#================================================================
#output
#================================================================

write.csv(result, file = opt$GSVA_result)

if (opt$img_type == 'PNG'){
  png(filename = opt$img_file, width = img_width, height = img_height)
}else if(opt$img_type == 'JPG'){
  jpeg(filename = opt$img_file, width = img_width, height = img_height)
}else{
  pdf(file = opt$img_file, width = img_width, height = img_height)
}

pheatmap::pheatmap(result, scale = "row", main = "heatmap", show_colnames=T)
dev.off()






















#参考：
#https://nbviewer.jupyter.org/github/mora-lab/benchmarks/blob/master/single-sample/workflows/Tutorial%20of%20GSVA%20using%20data%20GSE10245.ipynb

#<requirement type="package" version="1.0.12">r-pheatmap</requirement>

# library(GSVA)
# 
# p <- 20000    ## number of genes
# n <- 30       ## number of samples
# nGS <- 100    ## number of gene sets
# min.sz <- 10  ## minimum gene set size
# max.sz <- 100 ## maximum gene set size
# X <- matrix(rnorm(p*n), nrow=p, dimnames=list(1:p, 1:n))
# dim(X)
# gs <- as.list(sample(min.sz:max.sz, size=nGS, replace=TRUE)) ## sample gene set sizes
# gs <- lapply(gs, function(n, p) sample(1:p, size=n, replace=FALSE), p) ## sample gene sets
# es.max <- gsva(X, gs, mx.diff=FALSE, verbose=FALSE, parallel.sz=1)
# es.dif <- gsva(X, gs, mx.diff=TRUE, verbose=FALSE, parallel.sz=1)

#boss说只需要输出行为pathway列为sample的矩阵和其heatmap就可以了

# 
# gsva(expr,  #基因表达数据，可以是SummarizedExperiment或ExpressionSet对象，也可以是行为基因列为样本的矩阵
#      gset.idx.list,  #基因集，list或GeneSetCollection 对象
#      annotation, #基因表达数据为SummarizedExperiment对象时，用来挑选矩阵中的分子数据； 当基因表达数据为matrix，基因集为GeneSetCollection对象时，annotation参数用来注释矩阵的注释信息。 当表达数据是ExpressionSet时，该参数忽略。
#      method=c("gsva", "ssgsea", "zscore", "plage"), #用于估计每个样本的基因集富集分数的方法
#      kcdf=c("Gaussian", "Poisson", "none"), #表示样本间表达式水平累积分布函数非参数估计时使用的内核字符串。当基因表达值是连续时(对数)，使用"Gaussian", 当基因表达值是整数计数时(非对数)，使用"Poisson"
#      abs.ranking=FALSE, #当mx.diff=TRUE时才会用到该参数。 abs.ranking=FALSE(默认值)，使用修正的Kuiper统计量来计算富集分数，取最大的正随机游走偏差和负随机游走偏差之间的量级差。 当abs.ranking=TRUE时，使用最大的正的和负的随机游走偏差之和的原始Kuiper统计量。
#      min.sz=1, #gene set的最小基因数
#      max.sz=Inf, #gene set的最大基因数
#      parallel.sz=1L, #并行计算时要使用的执行线程数。 参数BPPARAM允许设置并行后端并优化其配置。
#      mx.diff=TRUE, #提出从KS随机游走统计量计算富集统计量的两种方法。 mx.diff=FALSE, 计算为随机游走到0的最大距离。 TRUE（默认）时，计算最大的正的和负的随机游走偏差之间的幅度差
#      tau=switch(method, gsva=1, ssgsea=0.25, NA), #定义由gsva和ssgsea方法执行的随机游走中尾部权重的指数。
#      ssgsea.norm=TRUE, #当为TRUE时，运行ssgsea时，通过最小值和最大值之间的绝对差对分数进行标准化。否则忽略这步标准化
#      verbose=TRUE, 是否打印输出每一步计算，默认是false
#      BPPARAM=SerialParam(progressbar=verbose))  #BiocParallelParam类的一个对象，指定与此函数内的一些任务和计算的并行执行相关的参数。


###########################
#Input
###########################
#表达数据
#gene set， kegg的那些
#method  "gsva", "ssgsea", "zscore", "plage" 之一

######################################################
#boss要求输出-- 矩阵数据，热图， limma做的通路差异表达
######################################################


#要求第一列是基因名称，第二列开始是样本
# gsva_input_data <- read.csv("GSVA_input.csv", row.names = 1)
# 
# geneset <- GSEABase::getGmt("example_pathway.gmt", 
#                             geneIdType = SymbolIdentifier())
# 
# result <- gsva(as.matrix(gsva_input_data), geneset, mx.diff=FALSE, 
#                verbose=FALSE, parallel.sz=2, method = "plage")
# 
# write.csv(result, file = "GSVA_result.csv")



