###############################################################################
#title: Reactome Pathway enrich Analysis of a gene set
#author: xiaowei
# time: Mar.31 2021
###############################################################################


#####################
#Input argument for this function
#####################
# title
  # Reactome Pathway enrich Analysis of a gene set

# description
  #Input a vector of all different expression gene and Output the enriched Significant Reactome Pathways

# basic input: 
  # genelist, g, 1, character, an csv file contained all different expression genes with entrez gene id, and has one column as DEgenes

# Optional:
  # pvalueCutoff  , p , 1, numeric  , Cutoff value of p-value,
  # organism      , o , 1, character, one of 'human', 'rat', 'mouse', 'celegans', 'yeast', 'zebrafish' and 'fly',
  # pAdjustMethod , w , 1, character, one of 'holm', 'hochberg', 'hommel', 'bonferroni', 'BH', 'BY', 'fdr', 'none',
  # minGSSize     , i , 1, integer  , minimal size of genes annotated by Ontology term for testing,
  # maxGSSize     , a , 1, integer  , maximal size of each geneSet for analyzing,
  # convertId     , c , 0, logical  , whether papping gene ID to gene Name,


# OUT:
  # sigP, s, 1, character, output csv file name

##############################################################################
#Input argument
###############################################################################
#args <- commandArgs(trailingOnly = TRUE)

spec <- matrix(c("genelist", "g", 1, "character", "an csv file contained all different expression genes with entrez gene id",
                 "pvalueCutoff", "p", 1, "numeric", "Cutoff value of p-value",
                 "organism", "o", 1, "character", "one of 'human', 'rat', 'mouse', 'celegans', 'yeast', 'zebrafish' and 'fly'",
                 "pAdjustMethod","w", 1, "character", "one of 'holm', 'hochberg', 'hommel', 'bonferroni', 'BH', 'BY', 'fdr', 'none'",
                 "minGSSize", "i",1, "integer", "minimal size of genes annotated by Ontology term for testing",
                 "maxGSSize", "a",1, "integer", "maximal size of each geneSet for analyzing",
                 "convertId", "c",0, "logical", "whether papping gene ID to gene Name",
                 "sigP", "s", 1, "character", "output csv file name"),
               byrow = TRUE, ncol = 5)


if (!requireNamespace("getopt", quietly = TRUE))
  install.packages("getopt")


opt <- getopt::getopt(spec)

#-------整理输入的参数----------------
de <- opt$genelist 
if(is.null(opt$pvalueCutoff)){
  pvalueCutoff = 0.05
}else{
  pvalueCutoff <- opt$pvalueCutoff
}

if(is.null(opt$organism)){
  organism <- "human"
}else{
  organism <- opt$organism
}

if(is.null(opt$pAdjustMethod)){
  pAdjustMethod <- "BH"
}else{
  pAdjustMethod <- opt$pAdjustMethod  
}

if(is.null(opt$minGSSize)){
  minGSSize <- 10
}else{
  minGSSize <- opt$minGSSize  
}

if(is.null(opt$maxGSSize)){
  maxGSSize <- 500
}else{
  maxGSSize <- opt$maxGSSize  
}


if(is.null(opt$convertId)){
  convertId <- FALSE
}else{
  convertId <- opt$convertId
}

if(is.null(opt$sigP)){
  opt$sigP <- "Significant_Reactome_Pathway_result.csv"
}

###############################################################################
#运行代码
###############################################################################
de <- read.csv(de)
de <- de$DEgenes

suppressPackageStartupMessages(
  if (!requireNamespace("ReactomePA", quietly = TRUE)){
    if (!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager")
    BiocManager::install("ReactomePA")
  })

#suppressPackageStartupMessages(library(ReactomePA))

#Pathway Enrichment Analysis of a gene set
result_sigP <- ReactomePA::enrichPathway(gene=de, #entrez id 的基因 向量
                             pvalueCutoff= pvalueCutoff,  #p值阈值
                             organism = organism, #有机体是"human"、"rat"、"mouse"、"celegans"、"yeast"、"zebrafish"、"fly"其中一个
                             pAdjustMethod = pAdjustMethod, #"holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none" 其中一个
                             #unverse, #背景基因
                             minGSSize = minGSSize, #检验本体术语时，限制最少基因个数
                             maxGSSize = maxGSSize, #分析基因集时，限制最大基因个数
                             readable=convertId) #是否将geneID映射到基因名称

result_sigP <- as.data.frame(result_sigP)



###############################################################################
#输出
###############################################################################
write.csv(result_sigP, file = opt$sigP, row.names = FALSE)



