###############################################################################
# title: Gene set analysis in R
# author: Xiaowei
# time: Mar.31 2021
###############################################################################
#=================================================================
#how to pass parameters
#=================================================================
spec <- matrix(c("expr_file",'E', 1, 'character', 'Gene expression data which is an CSV file of expression values where rows correspond to genes and columns correspond to samples.',
                 "geneSet_file", 'G', 1, 'character', 'Gene set',
                 "design_file", 'D', 1, 'character', 'Design for the samples of expression data',
                 "min_size", 'I',1, 'numeric','a numeric value indicating the minimum allowed gene set size. Default value is 10.',
                 "max_size", 'A',1,  'numeric','a numeric value indicating the maximum allowed gene set size. Default value is 500.',
                 "test_method", 'T',1, 'character', "a character parameter indicating which statistical method to use for testing the gene sets. Must be one of 'GSNCAtest', 'WWtest', 'KStest', 'MDtest', 'RKStest', 'RMDtest'.",
                 "nperm_number", 'N', 1, 'numeric',"number of permutations used to estimate the null distribution of the test statistic. If not given, a default value 1000 is used.",
                 "cor_method", 'M', 1, 'character',"a character string indicating which correlation coefficient is to be computed. Possible values are 'pearson' (default), 'spearman' and 'kendall'. Default value is 'pearson'.", 
                 "threshold_value", "V", 1, 'numeric', 'Threshold value for setting significant geneSet.',
                 "GSAR_output_p_value", 'R', 1, 'character',"P-value table", 
                 "GSAR_output_plot", 'P', 1, 'character',"Plot genes relationships of significant pathway"
                 
),
byrow = TRUE, ncol = 5)


if (!requireNamespace("getopt", quietly = TRUE))
  install.packages("getopt")

opt <- getopt::getopt(spec)

#----------------
#整理参数
#----------------
# expr_file
# geneSet_file
# design_file
if (is.null(opt$min_size)){min_size = 10}else{min_size = opt$min_size}
if (is.null(opt$max_size)){max_size = 500}else{max_size = opt$max_size}
if (is.null(opt$test_method)){test_method = "GSNCAtest"}else{test_method = opt$test_method}
if (is.null(opt$nperm_number)){nperm_number = 1000}else{nperm_number = opt$nperm_number}
if (is.null(opt$cor_method)){cor_method = "pearson"}else{cor_method = opt$cor_method}
if (is.null(opt$threshold_value)){threshold_value = 0.05}else{threshold_value = opt$threshold_value}


#================================================================
#run codes
#================================================================

#--- load package ------------------

suppressPackageStartupMessages(library(GSAR))
suppressPackageStartupMessages(library(GSEABase))
options(stringsAsFactors = FALSE)
#---input --------------------------
# expr
data <- as.matrix(read.csv(opt$expr_file, row.names = 1))

# design
design <- read.csv(opt$design_file, row.names = 1)
group <- design$group
label <- design$label

# geneSet
load(opt$geneSet_file)
geneSetlist <- lapply(geneSet, geneIds)
names(geneSetlist) <- names(geneSet)

#-------GSAR -------------------------
# test.method <- c("GSNCAtest", "WWtest", "KStest", "MDtest", "RKStest", "RMDtest")
#  “GSNCAtest”, “WWtest”, “KStest”, “MDtest”, “RKStest”, “RMDtest” 
results <- TestGeneSets(object=data, group=group, 
                        geneSets=geneSetlist, min.size=min_size, 
						max.size=max_size, test=test_method, 
						nperm = nperm_number)



#================================================================
#output
#================================================================


# output p-value----------------------------------------------------
resutlts1 <- as.data.frame(t(as.data.frame(results)))
colnames(resutlts1) = "P_value"
resutlts1$geneSet <- rownames(resutlts1)
resutlts1 <- resutlts1[,c("geneSet", "P_value")]
resutlts1 <- resutlts1[order(resutlts1$P_value),]
write.csv(resutlts1, file = opt$GSAR_output_p_value, row.names = FALSE)
#-------------------------------------------------------------------



#plot -------------------------------------------------------------
sig.paths <- names(results[results  <= threshold_value])


group1 <- unique(design[design$group == 1, "label"])
group2 <- unique(design[design$group == 2, "label"])
allgenes <- rownames(data)

pdf(file = opt$GSAR_output_plot, width = 10.92)
if (length(sig.paths) > 0){
  for (sig.path in sig.paths){
    path.index <- allgenes %in% geneSetlist[[sig.path]] 
    ## Plot MST2 for a pathway in two conditions
    plotMST2.pathway(object=data[path.index,],
                     group=group, name=sig.path,
                     legend.size=1.2, #leg.x=-1.2, leg.y=2,
                     label.size=1, label.dist=0.8, cor.method=cor_method, group1.name = group1, group2.name = group2)
    
    rm(sig.path, path.index)
  }
  
}
dev.off() 














# 
# 
# 
# library(GSAR)
# 
# data <- as.matrix(read.csv("GSAR_input_p53DataSet.csv", row.names = 1))
# 
# # group <- data.frame(group=c(rep(1,17), rep(2,33)), label = c(rep("control",17), rep("test",33)) ,row.names = names(data))
# # write.csv(group, file = "group.csv", row.names = TRUE)
# 
# design <- read.csv("group.csv", row.names = 1)
# group <- design$group
# label <- design$label
# 
# load("msigdb.kegg.human.symbol.rdata")
# 
# library(GSEABase)
# geneSetlist <- lapply(geneSet, geneIds)
# names(geneSetlist) <- names(geneSet)
# 
# # test.method <- c("GSNCAtest", "WWtest", "KStest", "MDtest", "RKStest", "RMDtest")
# #  “GSNCAtest”, “WWtest”, “KStest”, “MDtest”, “RKStest”, “RMDtest” 
# results <- TestGeneSets(object=data, group=group, 
#                         geneSets=geneSetlist, min.size=10, max.size=100, test=c("GSNCAtest"))
# 
# 
# results
# 
# 
# # 参数
# # object 矩阵，行是基因，列是样本
# # group vector, 跟样本相关的分组信息
# # geneSets list, 每个样本包含gene id 
# # min.size geneSet的最小基因数
# # max.size geneSet的最大基因数
# # test 检验统计方法： “GSNCAtest”, “WWtest”, “KStest”, “MDtest”, “RKStest”, “RMDtest” 其中一个
# # nperm permutation的次数
# # mst.order 考虑最小生成树合并的值（当选择“RKStest”或“RMDtest"时），默认为1，最大值为5
# # pvalue.only logical. 默认为TRUE, 只返回p值。false,返回观察的统计树，pemuted 统计， p-value
# 
# # 结果
# # list, p值
# 
# # output p-value----------------------------------------------------
# resutlts1 <- as.data.frame(t(as.data.frame(results)))
# colnames(resutlts1) = "P_value"
# resutlts1$geneSet <- rownames(resutlts1)
# resutlts1 <- resutlts1[,c("geneSet", "P_value")]
# resutlts1 <- resutlts1[order(resutlts1$P_value),]
# write.csv(resutlts1, file = "results.csv", row.names = FALSE)
# #-------------------------------------------------------------------
# 
# #作图
# sig.paths <- names(results[results  <= 0.05])
# 
# 
# group1 <- unique(design[design$group == 1, "label"])
# group2 <- unique(design[design$group == 2, "label"])
# allgenes <- rownames(data)
# 
# pdf(file = "rplot.pdf", width = 10.92)
# for (sig.path in sig.paths){
#   path.index <- allgenes %in% geneSetlist[[sig.path]] 
#   ## Plot MST2 for a pathway in two conditions
#   plotMST2.pathway(object=data[path.index,],
#                    group=group, name=sig.path,
#                    legend.size=1.2, #leg.x=-1.2, leg.y=2,
#                    label.size=1, label.dist=0.8, cor.method="pearson", group1.name = group1, group2.name = group2)
#   
#   rm(sig.path, path.index)
# }
# dev.off() 


# 参数
# object 矩阵，行是基因(必须得跟该通路是相关的)，列是样本
# group 数字标签，尽可能是1和2
# name 图片的名称
# cor.method 计算相关系数的方法。"person"(default)、"spearman"、"kendall"
# min.sd 最小标准偏差
# legend.size 图例大小
# leg.x #图例的x位置
# leg.y 图例的y位置
# return.weights logical， 默认FALSE
# group1.name group1的名称，默认是group1
# group2.name group2的名称，默认是group2
# label.size 顶点标签大小
# label.color 顶点标签颜色
# label.dist 顶点标签和顶点中心的距离，默认是0.5
# vertex.size 顶点大小
# vertex.label.font 顶点字体类别
# edge.width 传递给参数edge的数值