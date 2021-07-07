###############################################################################
# title: chipenrich
# author: Xiaowei
# time: Mar.31 2021
###############################################################################

spec <- matrix(c("input_peaks", "P",1, "character", "peaks file",
                 "input_genome","G",1, "character", "genome",
                 "input_locusdef","L",1,"character", "locusdef",
                 "input_mappability","Map",0, "logical", "mappability",
                 "input_qc_plot","Q",0, "logical", "qc_plot",
                 "input_method","M",1,"character", "method",
                 "input_geneset","GS",1,"character", "geneset_category",
                 "input_minSize","Min",1,"integer","minSize",
                 "input_maxSize","Max",1,"integer", "maxSize",
                 "input_randomization","random",1,"character","randomization",
                 "input_reglocation","reg",1,"character","reglocation",
                 "input_num_peak_threshould","threshould",1,"numeric", "peak_threshould",
                 "output_peaks","out_peaks",1,"character","output_peaks",
                 "output_peaks_per_gene","out_ppg",1,"character","peaks per gene",
                 "output_enrich_results","out_er",1,"character", "enrich result",
                 "output_qc_plot", "out_qc", 1,"character","output_qc_plot"
                 ),byrow = TRUE, ncol = 5)

opt <- getopt::getopt(spec)


#----------------------------------------------------------------

input_peaks <- read.csv(opt$input_peaks,header = TRUE)
input_genome = opt$input_genome
input_locusdef = opt$input_locusdef

if (!is.null(opt$input_mappability)){
  input_mappability = 24 #根据表格来填写
}else{
  input_mappability = NULL #supported_read_lengths()
}

if(!is.null(opt$input_qc_plot)){
  input_qc_plot = opt$input_qc_plot
  input_output_name = "x"
}else{
    input_qc_plot = FALSE
    input_output_name = NULL
}


if (!is.null(opt$input_method)){input_method = opt$input_method}else{input_method ="chipenrich"}
if(!is.null(opt$input_geneset)){input_geneset = strsplit(opt$input_geneset, split = ",")[[1]]}else{input_geneset = NULL}
if(!is.null(opt$input_minSize)){input_minSize = opt$input_minSize}else{input_minSize = 15}
if(!is.null(opt$input_maxSize)){input_maxSize = opt$input_maxSize}else{input_maxSize = 2000}
if(!is.null(opt$input_randomization) & opt$input_randomization != "NULL"){input_randomization = opt$input_randomization}else{input_randomization = NULL}
input_core = parallel::detectCores()
if(!is.null(opt$input_reglocation)){input_reglocation = opt$input_reglocation}else{input_reglocation = "tss"} #proxReg
#chipenrich、hybridenrich
if(!is.null(opt$input_num_peak_threshould)){input_num_peak_threshould = opt$input_num_peak_threshould}else{input_num_peak_threshould = 1}
#================================================================
#run codes
#================================================================
suppressPackageStartupMessages(library(chipenrich))
## ---- chipenrich----------------------------------------
if (input_method == "chipenrich"){
  results = chipenrich(peaks = input_peaks, genome = input_genome, genesets = input_geneset,
                       locusdef = input_locusdef, qc_plots = FALSE, out_name = input_output_name, 
                       mappability = input_mappability,
                       min_geneset_size = input_minSize,
                       max_geneset_size = input_maxSize,
                       randomization = input_randomization,
                       num_peak_threshold = input_num_peak_threshould,
                       n_cores = input_core)
}


## ----polyenrich----------------------------------------
if (input_method == "polyenrich"){
  results = polyenrich(peaks = input_peaks, genome = input_genome, genesets = input_geneset,
                       method = 'polyenrich',
                       locusdef = input_locusdef, qc_plots = FALSE, out_name = input_output_name, 
                       mappability = input_mappability,
                       min_geneset_size = input_minSize,
                       max_geneset_size = input_maxSize,
                       randomization = input_randomization,
                       n_cores = input_core)
}

## ----hybridenrich----------------------------------------
if (input_method == "hybridenrich"){
  results = hybridenrich(peaks = input_peaks, genome = input_genome, genesets = input_geneset,
                         locusdef = input_locusdef, qc_plots = FALSE, out_name = input_output_name, 
                         mappability = input_mappability,
                         min_geneset_size = input_minSize,
                         max_geneset_size = input_maxSize,
                         randomization = input_randomization,
                         num_peak_threshold = input_num_peak_threshould,
                         n_cores = input_core)
}

## ----proxReg----------------------------------------
if (input_method == "proxReg"){
  results = proxReg(peaks = input_peaks, reglocation = input_reglocation,
                         genome = input_genome, genesets=input_geneset, 
                         min_geneset_size = input_minSize,
                         max_geneset_size = input_maxSize,
                         randomization = input_randomization,
                         out_name=input_output_name,
                         n_cores = input_core)
}

## ----broadenrich----------------------------------------peaks_H3K4me3_GM12878---
if (input_method == "broadenrich"){
  results = broadenrich(peaks = input_peaks, genome = input_genome, genesets = input_geneset,
                        locusdef = input_locusdef, qc_plots = FALSE, out_name = input_output_name, 
                        mappability = input_mappability,
                        min_geneset_size = input_minSize,
                        max_geneset_size = input_maxSize,
                        randomization = input_randomization,
                        n_cores = input_core)
}
 
#===============================================================================
# 输出
#===============================================================================
output_peaks = opt$output_peaks
output_peaks_per_gene = opt$output_peaks_per_gene
output_enrich_result = opt$output_enrich_results

if (!is.null(output_peaks)){
  write.csv(results$peaks, file = output_peaks)  
}

if (!is.null(output_peaks_per_gene)){
  if (input_method != "proxReg"){
    write.csv(results$peaks_per_gene, file = output_peaks_per_gene)  
  }  
}

if (!is.null(output_enrich_result)){
  write.csv(results$results, file = output_enrich_result)  
}

