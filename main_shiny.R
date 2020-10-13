
# this is the shiny script for the bumpfinder User Interface


   

# load all required libraries
library(shiny)
library(shinydashboard)
library(ggplot2)
library(ggrepel)
library(dplyr)
library(shinyjs)
library(shinyalert)


# shinydashboard sidebar layout is created. Each tab is named.
sidebar <- dashboardSidebar(
	width = 500,
	sidebarMenu(

		menuItem("", tabName = ""), # 

		menuItem("Step 1: Project Naming ", tabName = "Step1", icon = icon("folder-open-o")),

		menuItem("Step 2: Fastq.gz Samples ", tabName = "Step2", icon = icon("file-archive-o")),

		menuItem("step 3: Sample Information ", tabName = "Step3", icon = icon("file-excel-o")),

		menuItem("Start Pipeline", tabName = "Run", icon = icon("play")),

		menuItem("", tabName = ""), #

		menuItem("Transcripts", tabName = "Transcript", icon = icon("bar-chart" )),

		menuItem("Volcano Plot", tabName = "Volcano", icon = icon("angle-double-down")),

		menuItem("Diricore RPF Plot", tabName = "Diricore", icon = icon("line-chart")),

		menuItem("Bumpfinder Plot", tabName = "Bumpfinder", icon = icon("chart-area"))

	)) # end of the shinydashboard sidebar


# start of the main body. This is the visible user interface part including all buttons and widgets
body <- dashboardBody( 


	useShinyjs(), # loading javascript dependent shiny libraries
	useShinyalert(),
		
############## tab step 1 

		tabItems(

			tabItem(tabName = "Step1",

				fluidRow(
					box(
						textInput('project_path','Project name'), 
						actionButton('save_files','Use this projectname')),
					box(
						p('First enter your projectname and create the folder. This must be done before any files are uploaded !', style = "font-size:15px"),
						p('uploaded files will later automatically be copied to the projectfolder', style = "font-size:15px"))
					)




			), # end tabItem 1

##################### tab step 2

			tabItem(tabName = "Step2",

				
				fluidRow(
					box(
						column(4,fileInput('fastq_file',label=h5(''),accept=c('.gz'),multiple=TRUE))
						),
						
					box(
						p('Upload all your fastq samples in a gziped format with the ending .fastq.gz', style = "font-size:15px"),
						p('Wait until all your samples have been uploaded, before continuing. Once all samples are uploaded succesfully you will see an overview of them beneath the upload window.', style = "font-size:15px"))
					),


				fluidRow(
					box( width = 12,	
						verbatimTextOutput('value'))
					),
			
				fluidRow(
					box(
						column(8, selectInput(inputId = "flag_replicates", label = " Fastq files are replicates that should be merged", choices = c(" No", " Yes")))),	
	
					box(		
						id="myBox_replicates",
						p('Upload a tab separated csv or txt file with the same format as the example giving the replicate samplenames and the name of the future merged file'),
						p('Please give in the further steps then the merged samplenames instead of the individual replicate sample names !!'))
					),

				fluidRow(
					box(id="myBox_replicates2",
					width = 2, fileInput('merge_file', label = 'Samples to be merged', accept = c('.csv','.txt'))),
					box(id="myBox_replicates3",
					width = 10, tableOutput(outputId = 'merge_table.output'))
					),


				fluidRow(
					box(
					
						(textInput('adapters',' Adapter sequences'))
						),
					box(
						p('Give your adapter sequence. If you have 2 Adapters give them both into the window separated by a space',style = "font-size:15px"))

					),

				fluidRow(
					box(
				
						radioButtons("radio_species_genome", label = h3("Species / Genome Build"),
						choices = list("Human ( hg19 )" = "human", "Mouse ( GRCm38.73 )" = "mouse", "Yeast ( EF4.69 )" = "yeast"), selected = 1),
						column(8,verbatimTextOutput('value_species_genome'))),

					box(
						p('Choose the species that your samples originate from',style = "font-size:15px"))	
					)


			), # end tabItem 2  


######################## tab step 3

			tabItem(tabName = "Step3",
			
				fluidRow(
					box(
						p('Upload a tab separated .csv or .txtfile with the information about your samples. A template can be seen below.',style = "font-size:15px"),
						p('Please give in the further steps then the merged samplenames instead of the individual replicate sample names !!',style = "font-size:15px")),
					box(
						p('If you want to run the Bumpfinder or the differential expression analysis several times with changing conditions, please choose multiple conditions below.',style = "font-size:15px"),
						p('This will allow you to upload up to two additional files in tab separated .csv .txt format. For the format please look at the new template files',style = "font-size:15px"))
					),


				fluidRow(
					box(
						
						column(4, fileInput('inputFile_sample_information', label = 'Sample information file', accept = c('.csv','.txt')))), # inputFile

					box(	
						column(4, selectInput(inputId = "multi_conditions", label = " Add multiple conditions", choices = c(" Only two Conditions", " Multiple Conditions"))))
					
					),
					

				fluidRow(	
					box(
						width = 12,			
						column(12,tableOutput(outputId = 'sample_information_table.output')))
					),

				fluidRow(
					box(
						id="myBox_sample_information_additional", fileInput('sample_information_additional_1', label = "Additonal File 1"),
						fileInput('sample_information_additional_2', label = "Additional File 2"))
					),
		
				fluidRow(

					box(
						id="myBox_sample_information_additional_1", 
						column(8, tableOutput(outputId = 'table_sample_information_additional_1.output'))),
					box(
						id="myBox_sample_information_additional_2",
						column(8, tableOutput(outputId = 'table_sample_information_additional_2.output')))

					)
								
			), # end tabitem 3


#################### tab RUN

			tabItem(tabName = "Run",

			
				fluidRow(
					box(
						width = 12,
						column(4,textInput('email','Email adress')),
						column(2,p("")),	
						column(6,radioButtons("radio_anonymous", label = h3("Do you want your data to be treated Anonymous ?"),
						choices = list("Yes" = "Yes", "No" = "No"), selected = "No")))
					),	
				

				fluidRow(
					box(

 						width = 12,

						includeHTML("/home/pierre/Ribopipeline/App-1/www/terms.html"), #
						
						radioButtons("radio_terms_conditions", label = h3(""),
						choices = list("Yes" = "Yes", "No" = "No"), selected = "No"))
					),

	
				fluidRow(


					box(
						width = 12,
						id="myBox_start_analysis",
						column(4,actionButton('run','Start the analysis'),class = "btn btn-success btn btn-primary btn-lg btn-block"))
					)

			), # end tabItem Run

######################################################################################################################################################################################

####################### Transcript RPF Density 

			tabItem(tabName= "Transcript",

				fluidRow(
					box(	width = 12,
						p('Upload your transcript RPF files. This can take a longer time depending on the filesize.',style = "font-size:15px"))
						
					),


				fluidRow(
					box(
						fileInput('Transcript_RPF_File1', label = 'Inputfile Transcripts1', accept = c('.txt'))),
					box(
						fileInput('Transcript_RPF_File2', label = 'Inputfile Transcripts2', accept = c('.txt')))				
					),
	
				fluidRow(
					box(	width =12,
						p('Writing a genename into the GENE field will list all ENST ids found for this gene inside the datasets. Writing the ENST id into the ENST field will show the RPF distribution over this transcript.',style = "font-size:15px"))
					),

				fluidRow(
					box(	width = 4,
						textInput('inputId_ENST_Transcript_RPF',' ENST')), #inputID5
					box(
						width = 4,
						verbatimTextOutput('RPF_ENST_GENE_table')),

					box(    width = 4,
						textInput('inputId_GENE_Transcript_RPF',' GENE')) # inputId66
					),	

				fluidRow(
					box(	width=12,
						p('The Read distribution as percentile per transcript. The lower plots show for each uploaded datafile the corresponding frame distributions and the distribution of reads per frame in the 5UTR, CDS, 3UTR.',style = "font-size:15px"))
					),

				fluidRow(
					box(
						width = 12,
						plotOutput("plotRPFTranscript"),
						hr())					
					),


				fluidRow(
					box(plotOutput("plotRPFTranscript_2"),hr()),
					box(plotOutput("plotRPFTranscript_4"),hr())
					),

				fluidRow(
					box(plotOutput("plotRPFTranscript_3"),hr()),
					box(plotOutput("plotRPFTranscript_5"),hr())	
					)			

	

			), # end tabItem Transcript RPF Density 

####################### Volcano

			tabItem(tabName = "Volcano",
	
				fluidRow(
					box(
						fileInput('VolcanoinputFile', label = 'Inputfile Volcanoplot', accept = c('.txt'))),
					box(
						p('Upload a .txt file resulting from DEseq or DEseq2 analysis. The file must contain the columns:   ID, log2FoldChange, Padj.',style = "font-size:15px"),
						p('A volcano plot will automatically be created from this dataset. Use the axis sliders to filter for significant genes. Individual genes can be viewed by clicking on the dot in the plot or by entering the genename in the Genelist field.',style = "font-size:15px"))
				
					),

				fluidRow(
					box(
						width = 12,
						plotOutput("plot_Volcano", click = "plot_click"),
						hr()) # plot1
					),

			

				fluidRow(
					box(
						selectizeInput('inputId_Volcano_Genelist', 'Genelist', choices = c(), multiple = T)),	#inputId

					box(
						tableOutput("clicked_Volcano"))
					),



				fluidRow(
					box(
						uiOutput("log2Foldchange_window"),
						uiOutput("padj_window")) #linex liney
					),


				fluidRow(
					box(
						downloadButton('download_sig_Volcano',"Download the highly significant genes"))
					)	

			), # end tabItem Volcano 
	
####################### Diricore 

			tabItem(tabName = "Diricore",

				fluidRow(
					box(
						fileInput('Diricore_RPFinputFile', label = 'Diricore RPF inputfile', accept = c('.txt'))), #RPFinputFile_1,
					box(
						p('Upload your Diricore RPF file.',style = "font-size:15px"),

						p('Then choose the codons from the diricore runs to be displayed. You can also type in the codon you are looking for. The plot will then automatically be displayed',style = "font-size:15px"),
						p('The Y axis range can be changed via the slider.',style = "font-size:15px"))
					),

				fluidRow(
					box(
						width = 12,
						plotOutput("Diricore_plot"),
						hr())
					),

				fluidRow(
					box(
						selectizeInput('inputId_Diricore_Codon', 'Codon', choices = c(), multiple = T)),
					box(
						selectizeInput('inputId_Diricore_Codon_2', 'Codon 2', choices = c(), multiple = T))

					),

				fluidRow(
					box(
						sliderInput("RPF_range_Y", "Y axis limits", min = -5, max = 5, value = c(-1,1), step = 0.1))
					)


			), # end tabItem Diricore

################## Bumpfinder

			tabItem(tabName = "Bumpfinder",	

	

				fluidRow(
					box(
						fileInput('BumpfinderFile_1', label = 'Bumpfinder RPF inputfile', accept = c('.txt'))),

					box(	width = 4,
						p(" Upload your bumpfinder datafile. Then choose The Amino Acids to be displayed from this file",style = "font-size:15px")) 
					),

				fluidRow(
					box(
						width = 6,
						plotOutput("Bumpfinderplot"),
						hr()),


					box(	
						width = 6,
						column(6, tableOutput(outputId = 'IUPAC')))
					),

				fluidRow(
					box(
						selectizeInput('inputId_Bumpfinder_AminoAcid_1', 'AminoAcid_1', choices = c("","A","C","D","E","F","M","N","G","H","I","K","L","P","Q","R","S","T","V","Y","W"), multiple = F, selected = "X")),
					box(
						selectizeInput('inputId_Bumpfinder_AminoAcid_2', 'AminoAcid_2', choices = c("","A","C","D","E","F","M","N","G","H","I","K","L","P","Q","R","S","T","V","Y","W"), multiple = F, selected = "X"))
					), #inputId6 inputId7

				fluidRow(
					box(
						sliderInput("Bumpfinder_RPF_range_Y", "Y axis limits", min = 0, max = 1, value = c(0,0.1), step = 0.001))
					)

	
			) # end tabItem Bumpfinder

	), # end all tabItems

#### mainPanel and bash output to command line ################################################################################################################################

	mainPanel(

		verbatimTextOutput('bash'), #RENAME BASHS.....
		verbatimTextOutput('bash2'),
		verbatimTextOutput('bash3')

	)

)

##################### Header bar

header <- dashboardHeader(title = "Riboseq Pipeline", titleWidth = 458, 

	dropdownMenu(type=c("messages"),
		icon = icon("info"),		
		headerText="",
		badgeStatus=NULL,

		messageItem(
			from = "",
			message = "Contact",
			icon = icon("address-book"),
			href = "Contact.html" 
		),

		messageItem(
			from = "",
			message = "Manual / pdf",
			icon = icon("book"),
			href = "index.html"
		),

		messageItem(
			from ="",
			message = "Citation / Paper",
			icon = icon("quote-left"),
			href = "citation.html"	
		)


	) # end menu
	) # end header	


################### main ui inclusion

ui <- dashboardPage(skin = "black",
	header,
	sidebar,
	body,
	)

###################################### start of the server part / underlying scripts ######################################333333333333333333333333333333333333333333333333


server <- function(input, output, session) { 

	options(shiny.maxRequestSize=8000*1024^2) # maximum upload in GB (8GB) 8000


######### get folder name


	observeEvent(input$project_path, { # First check whether name already exists and warn if it exists

		req(input$project_path)

		raw_path <- input$project_path

		total_path <- paste('./Analysis_part/',raw_path,'/',sep='') # change saver !!!!!
		if(dir.exists(total_path)){
			shinyalert("This Path Already exists", "Please use another Path name", type = "error")			
			}
		})

	

	get_path <- eventReactive(input$save_files,{ # upon pressing the save files button the project folder is created , if dir does not exist

		raw_path <- input$project_path


		total_path <- paste('./Analysis_part/',raw_path,'/',sep='')

		if(dir.exists(total_path)){
			shinyalert("This Path Already exists, The analysis will not start with the given path ! ", " Please change the path name and agree to the terms and condition again before starting the run", type = "error")			

			} else {
				return(raw_path) 
			}
		})	


###### get fastq files and their info

	output$value <- renderPrint({str(input$fastq_file)})

	output$value_species_genome <- renderPrint({ input$radio_species_genome })



####### csv file sample_information 1

	dataFrame <- reactive({


		if(is.null(input$inputFile_sample_information)) {
			table_sample_information <- read.table("./Shiny_part/template.csv",sep = '\t', header = TRUE)  
			return(table_sample_information)
		} else { 

			inFile <- input$inputFile_sample_information
			table_sample_information <- read.csv(inFile$datapath,sep = '\t', header = FALSE) 
			return(table_sample_information)
		}
	})

	output$sample_information_table.output <- renderTable({
	dataFrame()
	})   

######
	observeEvent(input$multi_conditions, { # if multi conditions show template boxes 

	if(input$multi_conditions==" Only two Conditions"){
		shinyjs::hide(id = "myBox_sample_information_additional")
		shinyjs::hide(id = "myBox_sample_information_additional_1")
		shinyjs::hide(id = "myBox_sample_information_additional_2")
	}else{
		shinyjs::show(id = "myBox_sample_information_additional")
		shinyjs::show(id = "myBox_sample_information_additional_1")
		shinyjs::show(id = "myBox_sample_information_additional_2")
	}
	})


###### csv file multi 1

	dataFrame_multi1 <- reactive({

		if(is.null(input$sample_information_additional_1)) {
			table_multi1 <- read.table("./Shiny_part/template2.csv",sep = '\t', header = TRUE)  
			return(table_multi1)
		} else { 

			inFile_multi1 <- input$sample_information_additional_1
			table_multi1 <- read.table(inFile_multi1$datapath,sep = '\t', header = FALSE) 
			return(table_multi1)
		}
	})

	output$table_sample_information_additional_1.output <- renderTable({
	dataFrame_multi1()
	})   
  

########## csv multi 2

	dataFrame_multi2 <- reactive({

		if(is.null(input$sample_information_additional_2)) {
			table_multi2 <- read.table("./Shiny_part/template3.csv",sep = '\t', header = TRUE)  
			return(table_multi2)
		} else { 

			inFile_multi2 <- input$sample_information_additional_2
			table_multi2 <- read.table(inFile_multi2$datapath,sep = '\t', header = FALSE)
			return(table_multi2)
		}
	})

	output$table_sample_information_additional_2.output <- renderTable({
	dataFrame_multi2()
	})   
  
######### csv merge 1

	observeEvent(input$flag_replicates, { # if samples contain replicates show the template boxes 

	if(input$flag_replicates==" Yes"){
		shinyjs::show(id = "myBox_replicates")
		shinyjs::show(id = "myBox_replicates2")
		shinyjs::show(id = "myBox_replicates3")
	}else{
		shinyjs::hide(id = "myBox_replicates")
		shinyjs::hide(id = "myBox_replicates2")
		shinyjs::hide(id = "myBox_replicates3")

	}
	})


	dataFrame_merge1 <- reactive({

		if(is.null(input$merge_file)) {
			table_merge <- read.table("./Shiny_part/merge_template.csv",sep = '\t', header = FALSE)  
			return(table_merge)
		} else { 

			inFile_merge <- input$merge_file
			table_merge <- read.table(inFile_merge$datapath,sep = '\t', header = FALSE) 
			return(table_merge)
		}
	})

	output$merge_table.output <- renderTable({
	dataFrame_merge1()
	})   
 


####### email

	email_return <- eventReactive(input$run,{
		email_string <- input$email
		return(email_string)})


########################################################## RUN part ######################

	
	observeEvent(input$radio_terms_conditions, {
	
	input$radio_terms_conditions == NULL

	if(input$radio_terms_conditions == "Yes"){ # If the terms and conditions are accepted ! 
		shinyjs::show(id = "myBox_start_analysis") # show the box with the start button 

		project_path <- get_path() # get path
		total_path <- paste('./Analysis_part/',project_path,sep='') #full later path

		if(dir.exists(total_path)){ # check if directory already exists
			print("Directory already exists !!!")
		}else{
			print("Directory does not exist ") # if directory does not exist copy the files and start bash scripts 

			adapter_return <- eventReactive(input$run,{
				adapter_one <- input$adapters
				return(adapter_one)})

			Species_return <- eventReactive(input$run,{
				species_chosen <- input$radio_species_genome
				return(species_chosen)})

			output$bash2 <- renderPrint({
				adapters <- adapter_return()
				Species <- Species_return()
				project_path <- get_path()
				email_variable <- email_return()
				total_path <- paste('./Analysis_part/',project_path,sep='')
			

				system(paste('./Riboseq_part/main.sh',total_path,Species,input$radio_anonymous,email_variable,adapters)) # start the test.sh script with the user given variables pathname, species, anonymous, email adapters 
			})


			output$bash <- renderPrint({ 
				project_path <- get_path()

				totalpath <- paste('mkdir ./Analysis_part/',project_path,sep='') # creation of the project folder

				req(project_path)
				system(paste(totalpath))
				})

			observe({     
				project_path <- get_path()
				files <- input$fastq_file[,1]
				total_path <- paste('./Analysis_part/',project_path,'/',files,sep='')

				file.copy(input$fastq_file$datapath, total_path) # if all files are uploaded and a path was given/submitted copy the files to this path. Filenames are replaced by numbers...  
			observe({
				project_path <- get_path()
				tblfiles <- input$sample_information_additional_1[,1]
				xtotalpath <- paste('./Analysis_part/',project_path,'/',"2_BumpDEsummary.txt",sep='')

				file.copy(input$sample_information_additional_1$datapath, xtotalpath) # if all files are uploaded and a path was given/submitted copy the files to this path.  

			})

			observe({
				project_path <- get_path()
				tblfiles <- input$sample_information_additional_2[,1]
				xtotalpath <- paste('./Analysis_part/',project_path,'/',"3_BumpDEsummary.txt",sep='')

				file.copy(input$sample_information_additional_2$datapath, xtotalpath) # if all files are uploaded and a path was given/submitted copy the files to this path.  
			})


			observe({
				project_path <- get_path()
				tblfiles <- input$inputFile_sample_information[,1]
				xtotalpath <- paste('./Analysis_part/',project_path,'/',"summary.txt",sep='')

				file.copy(input$inputFile_sample_information$datapath, xtotalpath) # if all files are uploaded and a path was given/submitted copy the files to this path.  
	
			})


			observe({
				project_path <- get_path()
				tblfiles <- input$merge_file[,1]
				xtotalpath <- paste('./Analysis_part/',project_path,'/',"mergefile.txt",sep='')
				file.copy(input$merge_file$datapath, xtotalpath) # if all files are uploaded and a path was given/submitted copy the files to this path.  
	
			})
			})

	}

	}else{ 
		shinyjs::hide(id = "myBox_start_analysis") # If the terms and conditions are not accepted the box stays hidden  
	}
	})



################################################################### visualization part 


############################### transcript RPF #########


	dfTranscript_1 <- reactive({
	
		transcript_RPF_df1 <- input$Transcript_RPF_File1

		if (is.null(transcript_RPF_df1))
			return(NULL)

		df_transcript_RPF <- read.table(transcript_RPF_df1$datapath, header = T)
	
		return(df_transcript_RPF)
		})


	dfTranscript_2 <- reactive({
	
		transcript_RPF_df2 <- input$Transcript_RPF_File2

		if (is.null(transcript_RPF_df2))
			return(NULL)

		df_transcript_RPF_2 <- read.table(transcript_RPF_df2$datapath, header = T)

		return(df_transcript_RPF_2)
		})

	show_transcript_RPF <- reactive({
	
		transcript_RPF_df1 <- input$Transcript_RPF_File1

		if (is.null(transcript_RPF_df1))
			return(NULL)

		df_transcript_RPF1 <- read.table(transcript_RPF_df1$datapath, header = T)
	
		req(input$inputId_GENE_Transcript_RPF)

		df_transcript_RPF1 <- filter(df_transcript_RPF1, GENE == input$inputId_GENE_Transcript_RPF)

		df_transcript_RPF_filtered <- df_transcript_RPF1[ , 1:2]	

		output$RPF_ENST_GENE_table <- renderPrint(df_transcript_RPF_filtered)

		return(df_transcript_RPF_filtered)
		})	
	

	output$plotRPFTranscript <- renderPlot({

		df_Transcript1 <- dfTranscript_1()
		df_Transcript2 <- dfTranscript_2()

		array_df <- df_Transcript1[ , 16:315]
		array_df2 <- df_Transcript2[ , 16:315]
	
		req(input$inputId_ENST_Transcript_RPF)

		rownames(array_df) <- df_Transcript1[,1]
		rownames(array_df2) <- df_Transcript2[,1]

		vectordf <- as.numeric(array_df[c(input$inputId_ENST_Transcript_RPF),])
		vectordf2 <- as.numeric(array_df2[c(input$inputId_ENST_Transcript_RPF),])

		#print(vectordf)

		#vectors <- c(vectordf,vectordf2) 
		#xrange <- range(vectors)

		if(is.null(input$Transcript_RPF_File1)){
	
		} else {
			
			return_plot <- function(){
				plot(vectordf, type = "o", col = "red",ylab="Reads Distribution Percentile",xlab="UTR5 (0-100)											CDS (100-200)											UTR3 (200-300)", ylim =range(vectordf,vectordf2)) 
				lines(vectordf2, type = "o", col="blue")
				legend("topleft", legend=c("File 1", "File 2"), col=c("red", "blue"),lty=2)
				}
			return_plot()
			

		}
		})
		

	output$plotRPFTranscript_2 <- renderPlot({

		df_Transcript1 <- dfTranscript_1()
		
		req(input$inputId_ENST_Transcript_RPF)

		df_Transcript2 <- filter(df_Transcript1, ENST == input$inputId_ENST_Transcript_RPF)

		output$RPFcount1 <- renderPrint({ df_Transcript2$Count })

		psite_df <- df_Transcript2[ , 4:6]

		sum <- rowSums(psite_df)
		psite_df <- (psite_df/sum)

		rownames(psite_df) <- df_Transcript2[,1]
	
		psite_df <- t(psite_df)

		psite_df <- as.data.frame.matrix(psite_df)

		psite_df$names <- rownames(psite_df)
	
		colname <- input$inputId_ENST_Transcript_RPF

		level_order <- factor(psite_df$names, level = c('UTR5_psites', 'CDS_psites', 'UTR3_psites'))


		if(is.null(input$Transcript_RPF_File1)){
	
		} else {
			ggplot(psite_df, aes_string(x=level_order, y=colname)) + geom_bar(stat="identity")

		}
		})

	
	observeEvent(input$inputId_GENE_Transcript_RPF, {
		show_transcript_RPF()
	})

	output$plotRPFTranscript_3 <- renderPlot({

		df_Transcript1 <- dfTranscript_1()

		req(input$inputId_ENST_Transcript_RPF)

		df_Transcript_filter <- filter(df_Transcript1, ENST == input$inputId_ENST_Transcript_RPF)
		
		frame_df <- df_Transcript_filter[ , 7:15]

		frame_sum <- rowSums(frame_df)

		frame_df <- (frame_df/frame_sum)

		rownames(frame_df) <- df_Transcript_filter[,1]

		frame_df <- t(frame_df)

		frame_df <- as.data.frame.matrix(frame_df)

		frame_df$names <- rownames(frame_df)

		colname <- input$inputId_ENST_Transcript_RPF

		level_order <- factor(frame_df$names, level = c('UTR5_frames_0','UTR5_frames_1','UTR5_frames_2','CDS_frames_0','CDS_frames_1','CDS_frames_2','UTR3_frames_0','UTR3_frames_1','UTR3_frames_2'))


		frame_vectordf <- as.numeric(frame_df[c(input$inputId_ENST_Transcript_RPF),])

		if(is.null(input$Transcript_RPF_File1)){

		} else {
	
			ggplot(frame_df, aes_string(x=level_order, y=colname)) + geom_bar(stat="identity")	
		}

		})


	output$plotRPFTranscript_4 <- renderPlot({

		req(input$Transcript_RPF_File2)

		df_Transcript2 <- dfTranscript_2()
		
		req(input$inputId_ENST_Transcript_RPF)
		

		df_Transcript2_filter <- filter(df_Transcript2, ENST == input$inputId_ENST_Transcript_RPF)

		output$RPFcount1 <- renderPrint({ df_Transcript2_filter$Count })

		psite_df <- df_Transcript2_filter[ , 4:6]
		
		sum <- rowSums(psite_df)
		psite_df <- (psite_df/sum)

		rownames(psite_df) <- df_Transcript2_filter[,1]
	
		psite_df <- t(psite_df)

		psite_df <- as.data.frame.matrix(psite_df)

		psite_df$names <- rownames(psite_df)

	
		colname <- input$inputId_ENST_Transcript_RPF

		level_order <- factor(psite_df$names, level = c('UTR5_psites', 'CDS_psites', 'UTR3_psites'))

		if(is.null(input$Transcript_RPF_File2)){
	
		} else {
			ggplot(psite_df, aes_string(x=level_order, y=colname)) + geom_bar(stat="identity")
		}
		})


	output$plotRPFTranscript_5 <- renderPlot({

		df_Transcript2 <- dfTranscript_2()

		req(input$inputId_ENST_Transcript_RPF)
		req(input$Transcript_RPF_File2)

		df_Transcript_filter <- filter(df_Transcript2, ENST == input$inputId_ENST_Transcript_RPF)

		frame_df <- df_Transcript_filter[ , 7:15]


		frame_sum <- rowSums(frame_df)

		frame_df <- (frame_df/frame_sum)

		rownames(frame_df) <- df_Transcript_filter[,1]

		frame_df <- t(frame_df)

		frame_df <- as.data.frame.matrix(frame_df)

		frame_df$names <- rownames(frame_df)

		colname <- input$inputId_ENST_Transcript_RPF

		level_order <- factor(frame_df$names, level = c('UTR5_frames_0','UTR5_frames_1','UTR5_frames_2','CDS_frames_0','CDS_frames_1','CDS_frames_2','UTR3_frames_0','UTR3_frames_1','UTR3_frames_2'))


		frame_vectordf <- as.numeric(frame_df[c(input$inputId_ENST_Transcript_RPF),])

		if(is.null(input$Transcript_RPF_File2)){

		} else {
			ggplot(frame_df, aes_string(x=level_order, y=colname)) + geom_bar(stat="identity")	
		}

		})



############# Volcano Plot #############################

	dataFrame_Volcano <- reactive({

		df_Volcano <- input$VolcanoinputFile		

		   if (is.null(df_Volcano))
			return(NULL)

		Volcano_df <- read.table(df_Volcano$datapath, header = T, sep = '\t')

		Volcano_df <- na.omit(Volcano_df)

		updateSelectizeInput(session,'inputId_Volcano_Genelist',selected='all',choices = c('all',as.character(Volcano_df[,1])),
			options=list(delimiter = ' ',
				create=I('function(input,callback){
					return{value:input,
					text:input
						};					
							}')
						)
		)
		
	return(Volcano_df)
	})

###########

	output$padj_window <- renderUI({

		Volcano_df <- dataFrame_Volcano()
		sliderInput('padj_slider',"padj",label='p-adjusted value',min = min(Volcano_df$padj), max = max(Volcano_df$padj),0.1, step=0.05)
	})

	output$log2Foldchange_window <- renderUI({

		Volcano_df <- dataFrame_Volcano()
		sliderInput('log2FC_slider','Log 2 Foldchange',min=0,max=max(Volcano_df$log2FoldChange),0,step=0.1) 
	})


	click <- reactive({
		nearPoints(dataFrame_Volcano(), input$plot_click, xvar='log2FoldChange', yvar = 'padj')
	})

	output$clicked_Volcano <- renderTable({
		click()
		}, rownames = T)



	yline <- reactive({
		thatline <- input$padj_slider
		return(thatline)
	})


	xline <- reactive({
		theline <- input$log2FC_slider
		return(theline)
	})




##############

	output$plot_Volcano <- renderPlot({

		

		Volcano_df <- dataFrame_Volcano()

		{
			Volcano_df$sig <- 'Not_Sig'
		}


		yliney <- yline()
		req(yliney)
 
		xlinex <- xline()
		req(xlinex)

		Volcano_df$sig[Volcano_df$log2FoldChange > input$log2FC_slider[1] | Volcano_df$log2FoldChange < input$log2FC_slider[1]*-1]<-'logFC'
		Volcano_df$sig[Volcano_df$padj < yline()]<-'Pval'

		for(i in 1:nrow(Volcano_df)){
			row <- Volcano_df[i,]    
			if (row$sig == "Pval"){
				if (row$log2FoldChange > input$log2FC_slider[1] | row$log2FoldChange < input$log2FC_slider[1]*-1){
					Volcano_df[i,]$sig<-'Pval_logFC'
				}	
			}
		}

		dffilter <- filter(Volcano_df, sig == 'Pval_logFC')


		output$download_sig_Volcano <- downloadHandler(



     			filename = function(){paste("Volcano_significant.txt",sep='')}, 
			content = function(fname){    
			write.table(dffilter,fname, row.names = F, quote = F)
			})	




		req(Volcano_df)
		req(input$inputId_Volcano_Genelist)

		if(is.null(input$inputId_Volcano_Genelist)){

		}

			else if (('all' %in% input$inputId_Volcano_Genelist) == FALSE) {		
				subdf <- Volcano_df[Volcano_df[,1]%in%input$inputId_Volcano_Genelist,]
				ggplot(Volcano_df,aes(x=log2FoldChange, y=padj, color = sig)) + geom_point() + coord_cartesian() + scale_y_reverse() + 
					geom_vline(xintercept = xline(), size = 0.5, linetype='dotted', color = 'red') + 
					geom_hline(yintercept = yline(), size = 0.5, linetype= 'dotted', color = 'blue') +
					scale_color_manual(values = c('logFC' = 'cornflowerblue', 'Pval' = 'firebrick', 'Not_Sig' = 'indianred', 'Pval_logFC' = 'skyblue')) + 
					geom_label_repel(data = subdf,mapping = aes(x=log2FoldChange, y=padj, label = ID) ,color = 'black', min.segment.length = unit(0,'lines'),nudge_y = .05 ) + xlim(-max(Volcano_df$log2FoldChange, na.rm = TRUE), max(Volcano_df$log2FoldChange, na.rm = TRUE))
		}
			else {
				req(Volcano_df)
				ggplot(Volcano_df,aes(x=log2FoldChange, y=padj, color = sig)) + geom_point() + coord_cartesian() + scale_y_reverse() + 
					geom_vline(xintercept = xline(), size = 0.5, linetype='dotted', color = 'red') + 
					geom_hline(yintercept = yline(), size = 0.5, linetype= 'dotted', color = 'blue') +
					scale_color_manual(values = c('logFC' = 'cornflowerblue', 'Pval' = 'firebrick', 'Not_Sig' = 'indianred', 'Pval_logFC' = 'skyblue')) + xlim(-max(Volcano_df$log2FoldChange, na.rm = TRUE), max(Volcano_df$log2FoldChange, na.rm = TRUE))


		}

 
	}) # end Volcano plot
		



##### diricore RPF file ###################################################

	dataFrame_Diricore <- reactive({

		diricore_df <- input$Diricore_RPFinputFile

		   if (is.null(diricore_df))
			return(NULL)

		diricore_df_return <- read.table(diricore_df$datapath, header = T, sep = '\t')

		updateSelectizeInput(session,'inputId_Diricore_Codon',choices = c(as.character(diricore_df_return[,1])),
			options=list(delimiter = ' ',
				create=I('function(input,callback){
					return{value:input,
					text:input
						};					
							}')
						)
		)

		updateSelectizeInput(session,'inputId_Diricore_Codon_2',choices = c(as.character(diricore_df_return[,1])),
			options=list(delimiter = ' ',
				create=I('function(input,callback){
					return{value:input,
					text:input
						};					
							}')
						)
		)


	return(diricore_df_return)
	})


	output$Diricore_plot <- renderPlot({

		df_diricore <- dataFrame_Diricore()

		req(input$inputId_Diricore_Codon)
		
		dfoverlay <- df_diricore

		df_filtered <- filter(df_diricore, codon == input$inputId_Diricore_Codon)
		
		
		if(is.null(input$inputId_Diricore_Codon_2)){
			ggplot( ) + geom_line(data=df_filtered, aes(x=position, y=(sample2-sample1),colour = "Codon1")) + geom_hline(yintercept=0) + scale_y_continuous(limits = c(input$RPF_range_Y[1], input$RPF_range_Y[2])) + scale_color_manual(values=c('Codon1' = 'red')) + labs(color = '')


		} else {
			req(input$inputId_Diricore_Codon_2)
			df_filtered2 <- filter(df_diricore, codon == input$inputId_Diricore_Codon_2)
			ggplot() + geom_line(data=df_filtered, aes(x=position, y=(sample2-sample1), colour = "Codon1")) + geom_hline(yintercept=0) + scale_y_continuous(limits = c(input$RPF_range_Y[1], input$RPF_range_Y[2])) + geom_line(data=df_filtered2, aes(x=position, y=(sample2-sample1), colour = "Codon2")) +  scale_color_manual(values = c("Codon1" = "red", "Codon2" = "blue")) + labs(color="")
				
		}

	
		})

############################## Bumpfinder plot ###############################################

	dataFrame_IUPAC <- reactive({

			table_IUPAC <- read.csv("./Shiny_part/IUPAC.csv")  
			return(table_IUPAC)
			})

	output$IUPAC <- renderTable({
		dataFrame_IUPAC()
		})   

##################################

	return_dataFrameBumpfinder <- reactive({

		bumpfinder_df <- input$BumpfinderFile_1

		   if (is.null(bumpfinder_df))
			return(NULL)

		return_bumpfinder_df <- read.table(bumpfinder_df$datapath, header = T, sep = '\t')


	return(return_bumpfinder_df)
	})

	output$Bumpfinderplot <- renderPlot({

		bumpfinder_df <- return_dataFrameBumpfinder()

	
		req(input$inputId_Bumpfinder_AminoAcid_1)
		AA_wanted <- input$inputId_Bumpfinder_AminoAcid_1

		AA_wanted2 <- input$inputId_Bumpfinder_AminoAcid_2

		if(AA_wanted2 == ""){
			ggplot() + geom_line(data = bumpfinder_df,aes_string(y=AA_wanted,x=bumpfinder_df$index, group=1, colour ='"Amino Acid 1"'))  + scale_y_continuous(limits = c(input$Bumpfinder_RPF_range_Y[1], input$Bumpfinder_RPF_range_Y[2])) + scale_color_manual(values=c('Amino Acid 1' = 'red')) + labs(color = '')
		}else{
			ggplot() + geom_line(data = bumpfinder_df,aes_string(y=AA_wanted,x=bumpfinder_df$index, group = 1,colour = '"Amino Acid 1"')) + scale_y_continuous(limits = c(input$Bumpfinder_RPF_range_Y[1], input$Bumpfinder_RPF_range_Y[2])) + geom_line(data=bumpfinder_df, aes_string(y=AA_wanted2,x=bumpfinder_df$index, color = '"Amino Acid 2"')) + scale_color_manual(values=c('Amino Acid 1' = 'red','Amino Acid 2' = 'blue')) + labs(color = '')
		}	
	
		})

####################################################################################################################################################################

} # end server

############################## main
shinyApp(ui, server)


