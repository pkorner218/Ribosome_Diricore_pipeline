library('DESeq2')
library('ggplot2')
library(BiocParallel)

directory <- getwd()

######### read files in and create with condition and type a sampleTable #############

sampleFiles<-grep('.out',list.files(directory),value=TRUE)

sampleCondition<-c('','')
sampleType<-c('','')
sampleTable<-data.frame(sampleName=sampleFiles, fileName=sampleFiles, condition=sampleCondition, type=sampleType)

ddsHTSeq<-DESeqDataSetFromHTSeqCount(sampleTable=sampleTable, directory=directory, design=~condition)

sampleTable


######## get normalized readcounts and write them to txt file #############

norm_dds <- estimateSizeFactors(ddsHTSeq)
sizeFactors(norm_dds)
normalized_counts <- counts(norm_dds, normalized=TRUE)

write.table(normalized_counts, file=ProjectName_normalized_counts.txt", sep="\t", quote=F, col.names=NA)


######## create a barplot and correlation cluster plots of normalized reads per sample #############

CM <- normalized_counts 

pdf(file=ProjectName_barplotTranscriptReadsPerSample.pdf", width=7, height=5)
par(font.lab=2, mar=c(12, 5.5, 2, 2))
barplot(colSums(CM), col="sienna", las=2, ylab=NA)
mtext(side=2, line=4.5, text="Number of transcript-counted reads", font=2)
dev.off()

nrow(which(CM>1e5, arr.ind=TRUE))

### correlation:
CM.cor <- cor(CM, method="spearman")

## general correlation between samples:
CM.dists <- 1-as.dist(cor(CM, method="spearman"))
CM.hc <- hclust(CM.dists)

pdf(file=ProjectName_dendrogramCorrelationHclust.pdf", width=7, height=5, bg="transparent")
par(mar=c(8, 4, 2, 2), font.lab=2)
plot(CM.hc, main=NA, xlab="Spearman correlation distance")
dev.off()






####### get collision data ########

colData(ddsHTSeq)$condition<-factor(colData(ddsHTSeq)$condition, levels=c("COND1","COND2"))

dds<-DESeq(ddsHTSeq)

####### MA plot ############


#pdf(file=ProjectName_MA.pdf", width=7, height=5)
#par(font.lab=2, mar=c(12, 5.5, 2, 2))
#print(plotMA(dds, intgroup=c('condition','type')))
#dev.off()


res<-results(dds)

pdf(file=ProjectName_res_MA.pdf", width=7, height=5)
par(font.lab=2, mar=c(12, 5.5, 2, 2))
print(plotMA(res, intgroup=c('condition','type')))
dev.off()

########################

res<-res[order(res$padj),]
head(res)

rld<- rlogTransformation(dds, blind=TRUE)



pdf(file=ProjectName_PCA.pdf", width=7, height=5)
par(font.lab=2, mar=c(12, 5.5, 2, 2))

print(plotPCA(rld, intgroup=c('condition','type')))
#dev.copy(png,ProjectName_pca.png")
dev.off()

###############

data <- plotPCA(rld, intgroup=c("condition", "type"), returnData=TRUE)
percentVar <- round(100 * attr(data, "percentVar"))

pdf(file=ProjectName_deseq2_PCA.pdf", width=7, height=5)
par(font.lab=2, mar=c(12, 5.5, 2, 2))
ggplot(data, aes(PC1, PC2)) + geom_point(aes(fill=type,shape=condition), size=3, alpha=7/8) +
scale_shape_manual(values=c(24,21,22,23,25))+ scale_fill_manual(values=c("violetred2","red","orange","blueviolet","blue3","steelblue","green","seagreen","green4"))+ xlab(paste0("PC1: ",percentVar[1],"% variance")) + ylab(paste0("PC2: ",percentVar[2],"% variance")) + coord_fixed()
#dev.copy(png,'53745_53767_2_deseq2_pca.png')
dev.off()


#############

pca = prcomp(t(assay(rld)))
summary(pca)
head(pca$rotation)
head(pca$x)
write.table(as.data.frame(pca$rotation),file=ProjectName_pca_geneloadingsx.txt",quote=F,sep="\t")
#quit()


######### calculate actual logFC and padj and write to txt file ##############


dds <- ddsHTSeq[ rowSums(counts(ddsHTSeq)) > 10, ]
DEseqresult <- DESeq(dds)
rld <- rlogTransformation(DEseqresult, blind=TRUE)

DEcellresults <- results(DEseqresult, contrast=c("condition","COND1","COND2"))
summary(DEcellresults)
write.table(as.data.frame(DEcellresults),file=ProjectName_DESEQ2.txt",quote=F,sep="\t")

#########


library("ggrepel")

df <- read.table(ProjectName_DESEQ2.txt", header = TRUE)

pdf(file=ProjectNamebasic_volcano.pdf", width=7, height=5, bg="transparent")
par(mar=c(8, 4, 2, 2), font.lab=2)
ggplot(df, aes(log2FoldChange, -log10(pvalue))) +   
geom_point() 
dev.off()

