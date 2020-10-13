WD <- getwd()

bumps = read.table(file.path(WD,"_ONLY_AWAY_DETAILED.bed"))

bumps$mid = round (bumps$V2 + ((bumps$V3-bumps$V2)/2) )

cds = read.table ("CDS.bed", head=F)

colnames (cds) = c("V1","CS","CE")

bumps_cds=  merge (bumps, cds, by="V1")
bumps_cds$aa_mid = round ((bumps_cds$mid - bumps_cds$CS)/3) +1
bumps_cds_atleast30= bumps_cds[ bumps_cds$aa_mid >= 30,]
bumps_cds$aa_length= round ((bumps_cds$CE - bumps_cds$CS)/3) 
bumps_cds_atleast30= bumps_cds[ bumps_cds$aa_mid >= 30 & ( (bumps_cds$aa_length - bumps_cds$aa_mid) > 30),]

write.table (bumps_cds_atleast30, "bumps_cds_atleast30.txt",sep="\t", quote=F, row.names=F)
