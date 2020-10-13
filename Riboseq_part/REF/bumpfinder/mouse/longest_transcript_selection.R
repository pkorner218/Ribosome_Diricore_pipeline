cds = read.table ("CDS.bed",head=F)
colnames (cds)=c("id","start","end")
gene =read.table ("ENST_genes.txt", head=F)
colnames (gene)=c("id","gene")
cds_gene = merge (cds, gene, by="id")
cds_gene[1:4,]
cds_gene$dist = cds_gene$end - cds_gene$start
cds_gene[1:4,]
library ("data.table")
cds_gene [ , max(dist), by = "gene"]
cds_gene [ , max(dist), by = gene]
cds_gene [ , max(dist), by =gene]
length (cds_gene$id)
library ("dplyr")
cds_gene %>% group_by(gene) %>% top_n(1, dist)
longest_transcript=cds_gene %>% group_by(gene) %>% top_n(1, dist)
longest_transcript$gene
length (longest_transcript$gene)
length (unique (longest_transcript$gene))
longest_transcript[1:3,]
table (longest_transcript$gene)
longest_transcript[ longest_transcript$gene == "ZSWIM1",]
longest_transcript [ !duplicated (longest_transcript$gene),]
longest_transcript=longest_transcript [ !duplicated (longest_transcript$gene),]
write.table (longest_transcript,"longest_transcript_selected.txt",sep="\t", quote=F, row.names=F)
quit()
