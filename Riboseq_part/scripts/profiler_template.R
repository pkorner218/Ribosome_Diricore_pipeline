list= read.table ("ids.txt", head=F)
dataframe= read.table ("data.txt", head=T)


for (gene2 in 1: nrow (list))
{

gene=  data.frame (id=list[gene2,"V1"])
gene = merge (gene, dataframe, by="id")
gene = gene[ order (gene$start),]

gene$minus = Means1 
gene$plus = Means2  

gene$average = rowMeans (gene[,c("minus","plus")])

if ( log2(sum(gene$average)) > 5)
{
gene$plus_log= ave(gene$plus, FUN=function(x) c(0, diff(x)))
gene$minus_log= ave(gene$minus, FUN=function(x) c(0, diff(x)))


gene$plus_log_norm= (gene$plus_log-min(gene$plus_log))/(max(gene$plus_log)-min(gene$plus_log))
gene$minus_log_norm= (gene$minus_log-min(gene$minus_log))/(max(gene$minus_log)-min(gene$minus_log))

gene$prof= gene$plus_log_norm -  gene$minus_log_norm
gene$prof_norm= (gene$prof-min(gene$prof))/(max(gene$prof)-min(gene$prof))

data=t(gene$prof)
data= data.frame (data)
data$name = unique (gene$id)
data[,c(which(colnames(data)=="name"),which(colnames(data)!="name"))]

data2=t(gene$prof_norm)
data2= data.frame (data2)
data2$name = unique (gene$id)
data2[,c(which(colnames(data2)=="name"),which(colnames(data2)!="name"))]

data3=t(gene$minus_log_norm)
data3= data.frame (data3)
data3$name = unique (gene$id)
data3[,c(which(colnames(data3)=="name"),which(colnames(data3)!="name"))]

data4=t(gene$plus_log_norm)
data4= data.frame (data4)
data4$name = unique (gene$id)
data4[,c(which(colnames(data4)=="name"),which(colnames(data4)!="name"))]

write.table (gene, "GENE_DETAILS.txt", sep="\t", quote=F, row.names=F, col.names=F, append=T)
write.table (data, "PROF_RC_NONSCALED_DETAILS.txt",sep="\t", quote=F, row.names=F, col.names=F,append=T)
write.table (data2, "PROF_RC_SCALED_DETAILS.txt",sep="\t", quote=F, row.names=F, col.names=F,append=T)
write.table (data3, "PROF_MINUS_LOG_NORM.txt",sep="\t", quote=F, row.names=F, col.names=F,append=T)
write.table (data4, "PROF_PLUS_LOG_NORM.txt",sep="\t", quote=F, row.names=F, col.names=F,append=T)

}


}

