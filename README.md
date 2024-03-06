# Ribosome_diricore_pipeline


## Summary
This pipeline was created to provide a toolset for the comprehensive and detailed analysis of differences in total ribosome occupancy on transcripts, ribosomal occupancy across codons, ribosomal stalling, and the underlying causal amino-acid/codons. The pipeline was designed to take ribosomal fastq files, preprocess, align and analyze them, finally creating figures from which the mentioned analytical differences between conditions can be interpreted. 


## Download 

The large Reference files (`see folder Riboseq_part/REF/`) files are possibly not downloaded correctly if the entire pipeline is downloaded via github as zip. Please check this and download Reference files individually if necessary. 
Please ensure you have this much space in your system before starting the download.
One option to decrease space usage is to only download the relevant Reference files for your target species.

Please ensure that you have permissions to write in the folders and to execute all scripts before attempting to start the analysis ! 

## Package Content and Folder structure

./Shiny_Ribopipeline_deliverable\
├── Projectfolder\
│       &nbsp;&nbsp;└── input\
│       &nbsp;&nbsp;└── output\
├── Riboseq_part


Riboseq_part contains all the scripts for the actual ribosome sequencinganalysis as well as the REF subfolder containing all the necessary Reference files. Upon giving a Projectname in the shiny user interface a Projectfolder will be created in the and will be filled automatically with the files and plots that are created during bumpfinder analysis. 

Diricore contains the subsequence_shift_plots for the individual comparisons as well as the rpf summary files. ( individual RPF plots can be found in the `./Riboseq_part/output/plots/rpf/`  folder).

## Input
The fastq.gz files and the sample information files which are uploaded by the user are transferred here and will then subsequently be processed and analyzed. 

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

## Input
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

The analys can be started directly via the command line by using the main.sh script in the.

The email adress does not serve a purpose at this moment, but the user is required to give a string here. 

`bash ./Riboseq_part/main.sh [./Analysis_part/projectfolder] [species] [adapter] [optional adapter2]`

In this case the fastq.gz files as well as the file information given as tab separated "summary.txt" are to be stored in the projectfolder. 

### Diricore RPF plots

Here two diricore RPF plots can be compared. All comparisons are summarized in the `all_rpf_shiny.txt` file that is located in the `user_output/Diricore` folder. 







