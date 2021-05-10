###############################################################################
# title: MethylGSA
# author: Xiaowei
# time: Mar.31 2021
###############################################################################

spec <- matrix(c("data_file", "D",1, "character", "txt file",
                 "test_method","M",1,"character", "Test method",
                 "array_type","T",1,"character","Array type, 450K, EPCI",
                 "group","G",1,"character","group: all, body, promoter1, promoter2",
                 "GS_list","L",1,"character","Gene Set tested: Gene Ontology, KEGG, Reactome",
                 "minsize","I",1,"integer", "Minimum gene set size",
                 "maxsize","A",1,"integer", "Maximum gene set size",
                 "result", "R", 1, "character", "result table"
                 ), byrow = TRUE, ncol = 5)

opt <- getopt::getopt(spec)


# #===========================================================================
# #输入的参数
# #===========================================================================
# # txt文件
# opt$data_file
# opt$test_method
# opt$array_type
# opt$group
# opt$GS_list
# opt$minsize
# opt$maxsize


temp = read.table(opt$data_file)
cpg.pval1 = temp[,2]
names(cpg.pval1) = temp[,1]
inputmethod = opt$test_method

#================================================================
#run codes
#================================================================
suppressPackageStartupMessages(library(methylGSA))


if(opt$array_type=="450K"){
  suppressMessages(library(IlluminaHumanMethylation450kanno.ilmn12.hg19))
}else{
  suppressMessages(library(IlluminaHumanMethylationEPICanno.ilm10b4.hg19))
}

if(inputmethod == "methylglm"){
  res <- methylglm(cpg.pval = cpg.pval1, array.type = opt$array_type,
              group = opt$group, GS.list=NULL, 
              GS.idtype = "SYMBOL", GS.type = opt$GS_list, 
              minsize = opt$minsize, maxsize = opt$maxsize)

}

if(inputmethod == "RRA_ORA"){
  res <- methylRRA(cpg.pval = cpg.pval1, array.type = opt$array_type, 
              group = opt$group, method = "ORA", 
              GS.list=NULL, GS.idtype = "SYMBOL", GS.type = opt$GS_list, 
              minsize = opt$minsize, maxsize = opt$maxsize)
}

if(inputmethod == "RRA_GSEA"){
  res <- methylRRA(cpg.pval = cpg.pval1, array.type = opt$array_type, 
              group = opt$group, method = "GSEA", 
              GS.list=NULL, GS.idtype = "SYMBOL", GS.type = opt$GS_list, 
              minsize = opt$minsize, maxsize = opt$maxsize)
}

if(inputmethod == "gometh"){
  res <- methylgometh(cpg.pval = cpg.pval1, sig.cut = 0.001, array.type = opt$array_type, 
                 GS.list=NULL, GS.idtype = "SYMBOL", GS.type = opt$GS_list, 
                 minsize = opt$minsize, maxsize = opt$maxsize)
}

#===============================================================================
write.csv(res, file = opt$result)
