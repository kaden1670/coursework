#Exercise2_script.R


library("DESeq2")
load("preprocessed_data.RData")

# Examine the dataset dds
dim(counts(dds))
head(counts(dds),3)

# Select the columns of interest to us.
dds <- dds[,c("DLD1_etop_1.bam", "DLD1_etop_2.bam", 
              "DLD1_noDrug_1.bam", "DLD1_noDrug_2.bam")]

#Check to see that our selection worked:
head(counts(dds),3)

colSums(counts(dds))
colData(dds)
head(rowRanges(dds),1)


#r-log transform the data
rld = rlog(dds)

#Let's look at how our transformation changed the data.
par( mfrow = c( 1, 2 ) ) #This line tells R we want two plots in one window, side by side

dds = estimateSizeFactors(dds) #For the log2 approach, we need to first estimate size
#factors to account for different number of total reads in each sample, known as 
#sequencing depth. Sequencing depth correction is done automatically for the rlog method.

plot(log2(counts(dds, normalized=TRUE)[,1:2] + 1), pch=16, cex=0.3) #In the first plot, we graph log2 of the counts 
#in the dds object, normalized for sequencing depth.
#pch tells plot what shape to use for each point in the scatter plot, 
#and cex tells it the size of the points.

plot(assay(rld)[,1:2], pch=16, cex=0.3) #In the second plot, we use the rld object.


# Now we can cluster our samples. Make a heatmap comparing the samples to one another.
library("pheatmap")
trld = t(assay(rld))
sampleDists = dist(trld, method = "euclidean")

#Note that we do not have to use euclidean distance metrics; there are 
# other methods available.
pheatmap(sampleDists, labels_row=rownames(colData(dds)))

#Note that the names of the samples (rows) are the names of .bam files. 
#Let's rename the row names so that they no longer include the .bam extension.
pheatmap(sampleDists, labels_row=c("DLD1_noDrug_1", "DLD1_noDrug_2", 
                                   "DLD1_etop_1", "DLD1_etop_2"))


#If we specify the number of desired clusters while generating the heatmaps, 
# do we get expected results?
pheatmap(sampleDists, labels_row=rownames(colData(dds)), cutree_rows = 2)


#Now let's generate a PCA plot using DESeq's plotPCA function.
plotPCA(rld, intgroup = c("group"))
#Save this image as a jpeg. How does the PCA compare to the distance heatmap?


# For visualization's sake, let's generate heatmap with the first 2000 genes. 
mat = assay(rld)
mat = mat - rowMeans(mat)
df = as.data.frame(colData(rld)[,c("line","dnadamage")]) 
# remove row and column labels to avoid overcluttered axes
pheatmap(mat[1:2000,], annotation_col=df, show_rownames = F, show_colnames = F)


# Now make a heatmap comparing the top 20 most variable genes.
topVarGenes = head(order(rowVars(assay(rld)), decreasing = TRUE), 20)
mat = assay(rld)[topVarGenes, ]
mat = mat - rowMeans(mat)
df = as.data.frame(colData(rld)[,c("line","dnadamage")])
pheatmap(mat, annotation_col=df, angle_col = "315")


# Take another look at our samples.
colData(dds)
# The formula indicates that we want to compare differential gene expression by the dnadamage column/variable.
design(dds) = formula(~ dnadamage) 

#Calculate differential genes
dds = DESeq(dds)
res = results(dds, contrast=c("dnadamage", "etop","none"))
summary(res)
res

#Find the number of genes with FDR < 0.1
sum(res$padj < 0.1, na.rm=TRUE)

#Find the gene with the lowest fold change
resslim = res[complete.cases(res$padj),] #complete.cases removes rows with padj = N/A
head(resslim[ order(resslim$log2FoldChange), ])

#Add gene ontology information to res data frame
library("AnnotationDbi")
library("org.Hs.eg.db")
res$go = mapIds(org.Hs.eg.db,
                keys=row.names(res),
                column="GO",
                keytype="SYMBOL",
                multiVals="list")
head(res)

#Create topGOdata object
library("topGO")
resslim = res[complete.cases(res$padj),] #remove rows with "NA" p values

# Filter the results for down-regulated genes 
resslimDown = resslim[resslim$log2FoldChange<0, ] 
# Why is it important to filter by p value, and not by log2FoldChange alone?

GOdataDown = new("topGOdata", ontology = "BP",
                 allGenes = setNames(resslimDown$padj, rownames(resslimDown)), 
                 geneSel = function(allScore) {return(allScore<0.1)}, 
                 #geneSel: function to select significant genes
                 nodeSize = 10, annot = annFUN.gene2GO, gene2GO = resslimDown$go)


#Run statistical tests on GOdataDown
resultFisher = runTest(GOdataDown, algorithm = "classic", statistic = "fisher")
resultKS = runTest(GOdataDown, algorithm = "classic", statistic = "ks")
allResDown = GenTable(GOdataDown, classicFisher = resultFisher, 
                      classicKS = resultKS, orderBy = "classicKS", 
                      ranksOf = "classicFisher",topNodes = 20)
allResDown


#Now let's consider how to find all the genes associated with a GO term.
#Identify the GO ID for mRNA processing
mrna_spl_go = allResDown[allResDown$Term == "mRNA splicing, via spliceosome",]$GO.ID
mrna_spl_go

#Let's go back and look at the resslimDown table contatining our DE results
head(resslimDown)

# A function that gets all the genes associated with a GO term has already been written 
# for you.
source("get_gene_from_GO.R")  #load the function

#what do you need to input into this function?
mrna_spl_genes = get_gene_from_GO(mrna_spl_go, resslimDown)
mrna_spl_genes

#Identify the GO ID for RNA splicing
rna_splicing_go = allResDown[allResDown$Term == "RNA splicing",]$GO.ID
rna_splicing_go
rna_sp_genes = get_gene_from_GO(rna_splicing_go, resslimDown)
rna_sp_genes


#Find indexes of mrna_spl_genes elements that are also in rna_sp_genes. 
#Note that rna_sp_genes is our shorter list.
overlap_idx = which( rna_sp_genes %in% mrna_spl_genes)

#Extract the gene names from reg_genes
rna_sp_genes[overlap_idx]


#Save your work
save.image("Ex2_afterAnalysis.RData")


#Create a new GOdataUp object - write your code here!


library("topGO")
resslim = res[complete.cases(res$padj),] #remove rows with "NA" p values

# Filter the results for down-regulated genes 
resslimUp = resslim[resslim$log2FoldChange>0, ] 
# Why is it important to filter by p value, and not by log2FoldChange alone?

GOdataUp = new("topGOdata", ontology = "BP",
                 allGenes = setNames(resslimUp$padj, rownames(resslimUp)), 
                 geneSel = function(allScore) {return(allScore<0.1)}, 
                 #geneSel: function to select significant genes
                 nodeSize = 10, annot = annFUN.gene2GO, gene2GO = resslimUp$go)


#Run statistical tests on GOdataDown
resultFisher = runTest(GOdataUp, algorithm = "classic", statistic = "fisher")
resultKS = runTest(GOdataUp, algorithm = "classic", statistic = "ks")
allResUp = GenTable(GOdataUp, classicFisher = resultFisher, 
                      classicKS = resultKS, orderBy = "classicKS", 
                      ranksOf = "classicFisher",topNodes = 20)
allResUp

write.csv(allResUp, "allResUP.csv")
