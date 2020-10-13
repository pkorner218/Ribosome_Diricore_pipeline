library(pracma)

gene = read.table ("GENE_DETAILS.txt", head=T)
##colnames (gene)= c("id","start","end","m1","m2","p1","p2","minus","plus","average","plus_log","minus_log","plus_log_norm","minus_log_norm","prof","prof_norm")

gene=gene[complete.cases (gene),]

minus_log_peaks=findpeaks(as.numeric(gene$minus_log), nups=1, ndowns=1, minpeakheight=10 )
plus_log_peaks=findpeaks(as.numeric(gene$plus_log), nups=1, ndowns=1, minpeakheight=10 )

gene_plus_trial= gene[ plus_log_peaks[,2],]
gene_minus_trial= gene[ minus_log_peaks[,2],]

gene_minus_trial_inverse= gene[ -minus_log_peaks[,2],]
gene_plus_trial_inverse= gene[ -plus_log_peaks[,2],]

gene_minus_trial$class_minus = "MINUS_PEAK"

gene_minus_trial_inverse$class_minus = "MINUS_NOPEAK"

gene_minuss_details = rbind (gene_minus_trial, gene_minus_trial_inverse)

gene_plus_trial_inverse$class_plus = "PLUS_NOPEAK"

gene_plus_trial$class_plus = "PLUS_PEAK"

gene_plus_details = rbind (gene_plus_trial, gene_plus_trial_inverse)

write.table (gene_minus_trial[,c(1,2,3,8,9,11,12)], "MINUS_peaks.txt",sep="\t", quote=F, row.names=F, col.names=F)
write.table (gene_plus_trial[,c(1,2,3,8,9,11,12)], "PLUS_peaks.txt",sep="\t", quote=F, row.names=F, col.names=F)

gene$diff= gene$plus_log - gene$minus_log

