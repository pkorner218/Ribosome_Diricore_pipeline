tDispEsts <- function(cds) {
  
## plot function from the howto
  plot(rowMeans(counts(cds, normalized=TRUE)),
       fitInfo(cds)$perGeneDispEsts,
       pch='.', log="xy")
  xg <- 10^seq(-.5,5,length.out=300)
  lines(xg, fitInfo(cds)$dispFun(xg),col="red")
 
}

cmpConditions <- function(cds,
			  cond1,
			  cond2,
                          fdr.thres) {
  ## calculation of DESeq results
  ## returns a list with objects needed for plotting and
  ## printing

  ## complete result set from nbinomTest
  res <- nbinomTest(cds, cond1, cond2);

  ## row index of significant results
  sig.res.ridx <- which(res$padj <= fdr.thres);

  ## table of significant results
  tab <- res[sig.res.ridx, -c(2,5)];

  ## order table by adjusted p-value
  ord <- order(tab$padj);
  tab <- tab[ord,];

  ## also store condition names in DSet list, so that
  ## this can be used in plots later on
  DSet=list(
    cond1=cond1,
    cond2=cond2,
    tab=tab,
    res=res,
    sig.res.ridx=sig.res.ridx);
  
  return(DSet);
}

plotSigGenes <- function(DSet, toDisk=FALSE,filename=NA, ...) {
  ## create a scatter plot for two conditions
  ## with red marks for significan genes
  ## input must be DSet result list from cmpConditions() above

  ## either just plot on default device or write png to disk
  if (toDisk) {
    if (is.na(filename)) {
      fname=paste(
      "DESeq_scatter_", DSet$cond1, "_",
       DSet$cond2, ".pdf", sep="");
     
    }
    else {
      fname = filename;
    }
   # bitmap(type="pdf",
   #        file=pdf,
           #res=144,
   #        width=8,
    #       height=8,
     #      );
  }
pdf(paste("DESeq_scatter_", DSet$cond1, "_", DSet$cond2, ".pdf", sep="") ) 
 
  with(DSet$res,
       #pdf("fname")
	plot(baseMeanA, baseMeanB,
            xlab=paste("Average", DSet$cond1),
            ylab=paste("Average", DSet$cond2),
            pch=20,
	    col="lightgreen",
            log="xy"),
       );
    
  points(DSet$res[DSet$sig.res.ridx,"baseMeanA"],
         DSet$res[DSet$sig.res.ridx,"baseMeanB"],
         cex=1.2,
         col="red");
  
  if (toDisk)
    {
      dev.off();
    }
}

xtableSigGenes <- function(DSet,...){
  library(xtable);
  ## create latex table for significant genes
  ## input must be DSet result list from cmpConditions() above
  xtableSig <- xtable(DSet$tab,
                      label=paste(
                        "tabDESeq.",
                        DSet$cond1,
                        ".",
                        DSet$cond2),
                      digits=c(0, 1, 1, 1, 2, -1, -1),
                      caption=paste("Differentially expressed transcripts between",
                        DSet$cond1,
                        "and",
                        DSet$cond2),
                      size="scriptsize",
                      include.rownames=FALSE);
  return(xtableSig);
}

csvSigGenes <- function(DSet) {
  ## take DSet list and write a csv file with significant genes
  ## todo: filename argument
  write.table(DSet$tab,
              file=paste("DESeq_tab_sig_",
                DSet$cond1, "_",
                DSet$cond2, ".csv", sep=""),
              quote=FALSE,
              sep="\t",
              row.names=FALSE);
             
}

#============================

#Addtional file with value for all genes
 
csvAllGenes <- function(DSet) {
  ## take DSet list and write a csv file with all genes
  ## todo: filename argument
  write.table(DSet$res,
              file=paste("DESeq_tab_All_",
                DSet$cond1, "_",
                DSet$cond2, ".csv", sep=""),
              quote=FALSE,
              sep="\t",
              row.names=FALSE);

}
#===========================

