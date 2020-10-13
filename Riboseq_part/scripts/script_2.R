
library(pracma)

gene = read.table ("GENE_DETAILS.txt", head=T)
##colnames (gene)= c("id","start","end","m1","m2","p1","p2","minus","plus","average","plus_log","minus_log","plus_log_norm","minus_log_norm","prof","prof_norm")

gene=gene[complete.cases (gene),]

plus_only = read.table ("PLUS_ONLY_CLOSEST.txt", head=F)
plus_only_away= plus_only [ plus_only$V15 < 0 | plus_only$V15> 9,]

gene$id_chr = paste (gene$id,gene$start, gene$end, sep="_")

plus_only_away$id_chr = paste (plus_only_away$V1, plus_only_away$V2, plus_only_away$V3, sep="_")
plus_only_away_detailed=merge (plus_only_away, gene, by="id_chr")

write.table (plus_only_away_detailed, "PLUS_ONLY_AWAY_DETAILED.xls",sep="\t", quote=F, row.names=F)

pdf ("PLUS_MINUS_PROF_CUTOFF_REASON.pdf")
par (mfrow=c(3,1))
plot (density ( plus_only_away_detailed$minus_log_norm), type="l", col="red", main="MINUS", lwd=3)
plot (density ( plus_only_away_detailed$plus_log_norm), type="l", col="green", main="PLUS", lwd=3)
plot (density ( plus_only_away_detailed$plus_log_norm), type="l", col="green", lwd=3)
lines (density ( plus_only_away_detailed$minus_log_norm), type="l", col="red", main="MINUS", lwd=3)
dev.off()

plus_only_detailed_prof10= plus_only_away_detailed [ plus_only_away_detailed$plus_log_norm - plus_only_away_detailed$minus_log_norm > 0.1, ]
plus_only_detailed_prof10_diff = plus_only_detailed_prof10[ plus_only_detailed_prof10$diff > 20,]

write.table (plus_only_detailed_prof10_diff, "PLUS_ONLY_DETAILED_PROF10_DIFF.xls",sep="\t", quote=F, row.names=F)

#PART THREE: RUN bedtools.sh before this part. MINUS_SPECIFIC
minus_only = read.table ("MINUS_ONLY_CLOSEST.txt", head=F)

minus_only_away= minus_only [ minus_only$V15 < 0 | minus_only$V15> 9,]
minus_only_away$id_chr = paste (minus_only_away$V1, minus_only_away$V2, minus_only_away$V3, sep="_")
minus_only_away_detailed=merge (minus_only_away, gene, by="id_chr")

write.table (minus_only_away_detailed, "MINUS_ONLY_AWAY_DETAILED.xls",sep="\t", quote=F, row.names=F)

minus_only_detailed_prof10= minus_only_away_detailed [ minus_only_away_detailed$plus_log_norm - minus_only_away_detailed$minus_log_norm > 0.1, ]
#NO diff cutoff- for stats)

write.table (minus_only_detailed_prof10, "MINUS_ONLY_DETAILED_PROF10.xls",sep="\t", quote=F, row.names=F)

minus_only_detailed_prof10_diff = minus_only_detailed_prof10[ minus_only_detailed_prof10$diff > 20,]

write.table (minus_only_detailed_prof10_diff, "MINUS_ONLY_DETAILED_PROF10_DIFF.xls",sep="\t", quote=F, row.names=F)

