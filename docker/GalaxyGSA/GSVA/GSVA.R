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





