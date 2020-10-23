# Bumpfinder


## Summary
The Bumpfinder pipeline was created to provide a toolset for the comprehensive and detailed analysis of differences in total ribosome occupancy on transcripts, ribosomal occupancy across codons, ribosomal stalling, and the underlying causal amino-acid/codons as well as collisions. The pipeline was designed to take ribosomal fastq files, preprocess, align and analyze them, finally creating figures from which the mentioned analytical differences between conditions can be interpreted.  In order to make the usage user friendly and widely accessible the pipeline comes with a shiny user interface which allows the upload of samples and sample information files, as well as the individual further visualization of results after the initial pipeline has finished. 

It was originally designed as a webserver which is the reason that users have to agree to terms and conditions of a webserver and give an email adress. If the pipeline is downloaded and used as standalone tool the acceptance of terms and conditions and the giving of the email adress are only for technical reasons. Instead of an email adress users can just give any string. However the email variable can not be left empty.

## Download 

The large Reference files (`see folder Riboseq_part/REF/`) files are possibly not downloaded correctly if the entire pipeline is downloaded via github as zip. Please check this and download Reference files individually if necessary. 

The entire pipepline including reference files is ~18 GB large. Please ensure you have this much space in your system before starting the download.
One option to decrease space usage is to only download the relevant Reference files for your target species.


## Package Content and Folder structure

./Shiny_Ribopipeline_deliverable\
├── Analysis_part\
│   └──Projectfolder\
│    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   └── user_output\
├── main_shiny.R\
├── Riboseq_part\
├── Shiny_part\
└── user_output

The package contains the main_shiny.R which is the script that opens the user interface and through which all analysis and visualization steps can be directed. Further does the package contain 3 Folders: Riboseq_part which contains all the scripts for the actual bumpfinder analysis as well as the REF subfolder containing all the necessary Reference files, The shiny_part folder which contains several template and example files used in the shiny user interface and the Analysis_part folder which is empty. Upon giving a Projectname in the shiny user interface a Projectfolder will be created in the Analysis_part and will be filled automatically with the files and plots that are created during the bumpfinder analysis. The folder user_output will be created as a subfolder inside the Analysis_part/Projectfolder and will at the end only contain a subset of plots and the most important result files copied there from the Analysis part folder.

## User_output Folder structure

The user_output folder is automatically created at the end of the bumpfinder pipeline run and it contains the main plots and results of the run in a user friendly organized way.

./user_output/\
├── Bumpfinder\
├── DEseq\
├── Diricore\
├── QualityControl\
│   ├── align_summaries.txt\
│   ├── transcript_summaries.txt\
│   └── cutadapt_summaries.txt\
├── Readcounts\
└── Wig

The Bumpfinder folder contains subfolders for the individual differential comparisons the plots as pdf. 

Similarly the DEseq folder contains the same subfolders which include The used readcount files, One GENE_DESEQ2.txt file which has the foldchange, p value and further data per gene, one DESEQ2.txt file containing the same data per transcript. A number of differential plots such as a PCA plot, The normalized count file for this comparison. 

Diricore contains the subsequence_shift_plots for the individual comparisons as well as the rpf summary files. ( individual RPF plots can be found in the `./Riboseq_part/output/plots/rpf/`  folder).

The QualityControl folder contains for each sample the ribowaltz quality control plots as well as summaries of the cutadapt preprocessing, alignment, and transcript alignment. 

The Readcounts folder contains the htseq out readcounts per sample. 

Last the Wig folder has per sample a wig file that can be uploaded at UCSC for visualization.

Analysis_part folder. This is the foiled on which the analysis takes place. The fastq.gz files and the sample information files which are uploaded by the user are transferred here and will then subsequently be processed and analyzed. 

./input/\
├── fastq\
│   ├── 1.fastq.gz\
│   ├── 2.fastq.gz\
│   ├── 3.fastq.gz\
│   └── 4.fastq.gz\
└── metadata\
    ├── rpf_density_contrasts.tsv\
    ├── samplenames.tsv\
    └── subsequence_contrasts.tsv

The output folder contains all further created samples, files and plots.

./output/\
├── align_summaries.txt\
├── bumpfinder\
├── clean\
├── cutadapt_summaries.txt\
├── h5_files\
├── htseq_out\
├── plots\
├── RPF_density.pdf\
├── rpf_R_plotmatrix.csv\
├── rpf_summary.csv\
├── tophat_out\
├── transcript\
└── wig\

## Technical
The bumpfinder pipeline is a set of scripts in multiple programming languages, utilizing a high number of available softwares and tools. The exact versions and technical details can be obtained from (…). In the following several of the main sofwares which are required are listed.
* python2  (set as “python” default)
* python3 
* R
* Perl
* bowtie2
* tophat2
* cutadapt
* hdf5
* DEseq and DEseq2
* samtools

## Usage
The pipeline was designed to be used via the R shiny user interface.

`R -e "shiny::runApp('shiny_share.R')"`

The analys can also be started directly via the command line by using the main.sh script in the ./Riboseq_part folder.
Take into account that the main.sh script should be started from the folder level of main_shiny.R (see code beneath). 
The email adress does not serve a purpose at this moment, but the user is required to give a string here. 

`bash ./Riboseq_part/main.sh [./Analysis_part/projectfolder] [species] [anonymous: Yes or No] [email adress] [adapter] [optional adapter2]`

In this case the fastq.gz files as well as the file information given as tab separated "summary.txt" are to be stored in the projectfolder. Additional comparisons for the Bumpfinder and DEseq can be given in the same folder named 2_BumpDEsummary.txt, 3_BumpDEsummary.txt (... etc.) The projectfolder should further be empty and should not contain any further files and no subfolders.

## Visualization

The shiny user interface does not only allow to give input files and start the pipeline with the correct details, it also allows the individual visualization of plots and data.

### Transcript RPF plots

This shiny tab allows the upload of two files for the per transcrit comparison of the readcount disctribution along the transcript. Per sample one file is created and ending on  `rpftranscript_output.txt` and they are located in the `user_output/Diricore/` folder. 

### Volcano plots

In this tab DEseq2 output files can be displayed as volcano plot including the options for filtering and visualization of specific IDs. Per comparison one` DESEQ.txt / DESEQ2.txt` and one `GENE_DESEQ.txt / GENE_DESEQ2.txt` are to be found in the `user_output/Bumpfinder` folder. The difference is that the GENE_DESEQ files are per gene and not per transcript making the visualization easier. The shiny allows the volcano plot visualization of any DESEQ2 output file that has the following columns / headers in tab separated format: ` ID	baseMean	log2FoldChange	lfcSE	stat	pvalue	padj`.

### Diricore RPF plots

Here two diricore RPF plots can be compared. All comparisons are summarized in the `all_rpf_shiny.txt` file that is located in the `user_output/Diricore` folder. 

### Bumpfinder plots

For each comparison one `bumpfinderScores.txt` file is created which can visualize two amino acids of this bumpfinder at the same time. It is located in the `user_output/Bumpfinder/`subfolder. 







