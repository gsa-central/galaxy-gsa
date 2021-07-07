###############################################################################
# title: msigdb_kegg_geneSet
# author: Xiaowei
# time: Jan.7 2021
# function: kegg.download, path.to.geneSet, kegg.geneSet
###############################################################################


###############################################################################
# load packages 
###############################################################################
suppressPackageStartupMessages(library(KEGGREST))
suppressPackageStartupMessages(library(GSEABase))


###############################################################################
# Function -- kegg.download 
# description: download pathway from kegg
# input: One or more KEGG identifiers
# output: A list wrapping a KEGG flat file.
###############################################################################
kegg.download <- function(pathway.list){
  #因为keggGet()一次最大查询10条，所以这里先将pathway.list分成10*n个，每10个放在pathway.x中
  #确定pathway.x长度
  if (length(pathway.list)%%10 == 0){
    pathway.x.len <- length(pathway.list)%/%10
  }else{
    pathway.x.len <- length(pathway.list)%/%10 + 1
  }
  #pathway.x,每个中包含10个pathway
  pathway.x <- vector(mode = "list", length = pathway.x.len)
  for (i in 1:length(pathway.x)){
    min.x <- 10*(i -1)+1
    max.x <- 10*i
    pathway.x[[i]] <- names(pathway.list)[min.x:max.x]
    rm(min.x,max.x)
  }
  #下载n次，每次下载10个pathway
  pathway.kegg <- list()
  for (i in 1:pathway.x.len){
    pathway.kegg.x <- keggGet(pathway.x[[i]])
    pathway.kegg <- append(pathway.kegg, pathway.kegg.x)
    rm(pathway.kegg.x)
  }
  
  names(pathway.kegg) <- unlist(lapply(names(pathway.list), function(x){trimws(strsplit(x, ':', fixed = TRUE)[[1]][2])} ))
  
  return(pathway.kegg)
  
}

###############################################################################
# Function -- path.to.GeneSet
# description: make the result of kegg.download to GeneSet
# input: the result of kegg.download
# Output: A GeneSet object 
###############################################################################
path.to.geneSet <- function(kegg.path){
  genes <- kegg.path$GENE
  
  if(!is.null(genes)){
    genelist_entrez <- genes[1:length(genes)%%2 ==1]  #entrez
    
    gs <- GeneSet(geneIds = as.character(genelist_entrez), 
                  geneIdType = EntrezIdentifier(), 
                  #organism = 'hsa', 
                  collectionType = KEGGCollection(),
                  #longDescription = kegg.path$DESCRIPTION,
                  #shortDescription = names(kegg.path$PATHWAY_MAP),
                  setName = kegg.path$PATHWAY_MAP, 
    )
  }else{gs = NULL}
  
  return(gs)
}

###############################################################################
# Function -- kegg.geneSet
# description: download pathway of one organism from KEGG and make it as GeneSetCollection 
# input: a KEGG organism code (list via keggList("organism"))
# output: A GeneSetCollection object or/and GMT file, gene ID is Entrez 
###############################################################################

kegg.geneSet <- function(organism = "hsa", outputfile = NULL){
  pathway.list <- keggList("pathway", organism) #获取所有pathway的名称和kegg标识符
  
  kegg.path <- kegg.download(pathway.list = pathway.list) #download pathway
  
  kegg.geneSetCollection <- mapply(path.to.geneSet, kegg.path) #pathway to GeneSet
  
  null.index <- unlist(lapply(kegg.geneSetCollection, is.null)) #remove NULL
  kegg.geneSetCollection <- GeneSetCollection(kegg.geneSetCollection[!null.index])
  
  #导出为gmt文件
  if (!is.null(outputfile)){toGmt(x=kegg.geneSetCollection, con = outputfile)}
  
  return(kegg.geneSetCollection)
}

###############################################################################
# Function -- msigdbr.geneSet
# description: download pathway of one organism from msigdb and make it as GeneSetCollection 
# input: 
# species: Species name, such as Homo sapiens or Mus musculus,See more  via msigdbr_species()
# category: MSigDB collection abbreviation, such as H or C1. See more via msigdbr_collections()
# subcategory: MSigDB sub-collection abbreviation, such as CGP or BP. 
# if it has more than one subcategories using `,` connected the words. example: "GO:BP,GO:CC,GO:MF", See more via msigdbr_collections()
# geneIdType: Default as "entrez". one of "entrez" and "symbol"
# output: A GeneSetCollection object or/and GMT file
###############################################################################
msigdb.geneSet <- function(species, category = NULL, subcategory = NULL, geneIdType ="entrez", outputfile = NULL){
  suppressPackageStartupMessages(library(msigdbr))
  suppressPackageStartupMessages(library(GSEABase))
  print(subcategory)
  # 下载基因集数据框
  if (is.null(subcategory)){
    gs = msigdbr(species = species, category = category, subcategory = NULL)
  }else{
    subcategory = strsplit(subcategory, ",")[[1]]
    gs.list <- lapply(subcategory, function(x) msigdbr(species = species, category = category, subcategory = x))
    gs = do.call(rbind, gs.list)
  }
  
  if (geneIdType == "entrez"){
    genes = gs$entrez_gene
    geneIdsType = EntrezIdentifier()
  }else if (geneIdType == "symbol"){
    genes = gs$gene_symbol
    geneIdsType = SymbolIdentifier()
  }
  
  # 根据GeneSet name 转变成list
  gs.names <- unique(gs$gs_name)
  gs.list <- lapply(gs.names, function(x){
    unique(genes[which(gs$gs_name == x)])
  })
  names(gs.list) = gs.names
  
  # 变成GeneSetCollection
  gs.geneSetCollection <- GeneSetCollection(mapply(function(x,y){
    genes = as.character(unlist(x))
    GeneSet(geneIds = genes,
            geneIdType = geneIdsType,
            collectionType = NullCollection(),
            setName = y
    )
  }, gs.list, gs.names))
  
  #导出为gmt文件
  if (!is.null(outputfile)){toGmt(x=gs.geneSetCollection, con = outputfile)}
  
  return(gs.geneSetCollection)
}


#=================================================================
#how to pass parameters
#=================================================================
spec <- matrix(c("source","S", 1, "character", "KEGG or Msigdb", 
                 "organism","O",1, "character", "a KEGG organism code",
                 "species","P",1,"character", "Species name, such as Homo sapiens or Mus musculus",
                 "category","C",1,"character", "MSigDB collection abbreviation, such as H or C1.",
                 "subcategory","G",1,"character", "MSigDB sub-collection abbreviation, such as CGP or BP.",
                 "geneIdType","T",1, "character", "Default as 'entrez'. one of 'entrez' and 'symbol'",
                 "whetherOutputfile", "W",0, "logical", "Whether output GMT file",
                 "outputGMTFile","F",1, "character", "The GMT file Name",
                 "outputRData", "R", 1,"character", "The RData file for the GeneSet "), byrow = T, ncol = 5)

opt <- getopt::getopt(spec)

#=================================================================
# run codes
#=================================================================
if (opt$source == "KEGG"){
  geneSet <- kegg.geneSet(opt$organism, outputfile = opt$outputFile)
}

if (opt$source == "Msigdb"){
  if(is.null(opt$category)){opt$category = NULL}
  if(is.null(opt$subcategory)){opt$subcategory = NULL}
  if(is.null(opt$geneIdType)){opt$geneIdType = "entrez"}
  
  geneSet <- msigdb.geneSet(species = opt$species, 
                                   category = opt$category, 
                                   subcategory = opt$subcategory, 
                                   geneIdType = opt$geneIdType)
}

#=================================================================
# Output file
#=================================================================
if (!is.null(opt$whetherOutputfile)){
  if (opt$whetherOutputfile){toGmt(x=geneSet, con = opt$outputGMTFile)}
}


save(geneSet, file = opt$outputRData)
