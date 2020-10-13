########################################
##
## READ COUNT DATA FROM htseq-count
##
## To run : R CMD BATCH deseq.R deseq.Rout 
## sample names; also used for file names
## here with the suffix _readcounts.tsv
## file names are constructed with paste below.

## To Run: R CMD BATCH ./deseq.R log.Rout

## EMT_R3_d10_merged_t_htseq_count.out
library("xtable")
library("gplots")
library("RColorBrewer")
library("DESeq")
diffanalysis<-1

samples <- c(sample1,sample2);


infiles <- paste(samples, ".out", sep="");
inlist <- lapply(infiles, read.table);
alltrans <- unique(unlist(lapply(inlist, "[[", 1), use.names=FALSE));

## construct empty count matrix
CM <- structure(matrix(as.integer(NA),
                       nrow=length(alltrans),
                       ncol=length(samples)),
                dimnames=list(alltrans, samples))

## fill count matrix
for (i in 1:length(samples)) {
  CM[match(inlist[[i]]$V1, rownames(CM)), i] <- inlist[[i]]$V2;
}


## drop non-unique alignments and other non-gene entries
dropClasses <- c("alignment_not_unique", "no_feature", "ambiguous",
                 "too_low_aQual", "not_aligned")

if (any(dropClasses %in% rownames(CM)))
  CM <- CM[-match(dropClasses, rownames(CM)),]

#CM <- CM[rowSums(CM)>0L,]

####################
##
## count matrix CM for downstream processing saved in CM.RData
##
#save(CM, file="CM.RData");
#save(CM, file="UntrvsNTC.RData");
##
#########################################################################################################################################

### plot read numbers per sample:
pdf(file="barplotTranscriptReadsPerSample.pdf", width=7, height=5)
par(font.lab=2, mar=c(12, 5.5, 2, 2))
barplot(colSums(CM), col="sienna", las=2, ylab=NA)
mtext(side=2, line=4.5, text="Number of transcript-counted reads", font=2)
dev.off()


## load(file.path(dataDir, "CM.RData"))

## first look:
nrow(which(CM>1e5, arr.ind=TRUE))

### correlation:
CM.cor <- cor(CM, method="spearman")

## general correlation between samples:
CM.dists <- 1-as.dist(cor(CM, method="spearman"))
CM.hc <- hclust(CM.dists)

pdf(file="dendrogramCorrelationHclust.pdf", width=7, height=5, bg="transparent")
par(mar=c(8, 4, 2, 2), font.lab=2)
plot(CM.hc, main=NA, xlab="Spearman correlation distance")
dev.off()


##----------------------------------------------------------------------

############################################################################################################################################
##
## DESeq analysis

#library(DESeq);
source("DESeq_helper_lib.R");

## analysis of count matrix CM

## define conditions (same order as samples above)
conds <- factor(c("condition1", "condition2"));

cds <- newCountDataSet(CM, conds)
cds <- estimateSizeFactors(cds)
AllSizeFactors<-sizeFactors(cds)
#x<-cds
cds <- estimateDispersions(cds ,method="blind", sharingMode="fit-only")

plotDispEsts(cds);
write.table(round(counts(cds, normalize=TRUE), digits=2), file="NormalizedReadCount.txt", sep="\t",  row.names=TRUE, col.names=TRUE, quote=FALSE)

###-----------------------------------------------------------------
## Variance stabilisation of sample read counts
##----------------------------------------------------------------

## write out normalised read counts:

## obtain variance-stabilised data:
V <- getVarianceStabilizedData(cds)
write.table(round(V, digits=2), sep="\t", file="VarianceStablizedReadCount.txt", row.names=TRUE, col.names=TRUE, quote=FALSE)

pdf("PCA.pdf")
x<-estimateDispersions(cds, method="blind")
vsdFull = varianceStabilizingTransformation(x )
print(plotPCA(vsdFull))
dev.off()
pdf("BoxPlot.pdf")
par(mar=c(10,4,4,4))
boxplot(V, las=2)
dev.off()

##======================================================
## compare 16_5_I and 16_5_D
## DSet is generated in helper function
## contains values for all genes, indexes of significant genes
## condition names (here "COND1" and "WT")
#========================================================

if(diffanalysis==1)
{
DSet.Cond1.Cond2<-cmpConditions(cds, "condition1", "condition2", .1);

## generate scatter plot with significant genes in red
plotSigGenes(DSet.Cond1.Cond2, toDisk=TRUE);

## generate csv table of significant genes
csvSigGenes(DSet.Cond1.Cond2);

#Scatter plot with significant genes in red
plotSigGenes(DSet.Cond1.Cond2, toDisk=TRUE);

## generate csv table of all genes
csvAllGenes(DSet.Cond1.Cond2);

## generate volcano plot
#plotVolcanoPlot(DSet.Cond1.Cond2, toDisk=TRUE);
#=========================================================

#=======================================================
#=======================================================



#=======================================================


#========================================================

#=======================================================

#=========================================================

#=======================================================




}

