# This script provides the analysis which was used to obtain example data for the MAVEN app
# Discovery of a selective inhibior of DCLK1
# Also required are the following files:
# - GSE140490_PDAC_cell_line_cuffnorm_all_fpkm_exprs.txt

# Install required packages
if (!requireNamespace("BiocManager"))
  install.packages("BiocManager")
BiocManager::install(c("limma", "edgeR", "Glimma", "org.Hs.eg.db", "gplots", "RColorBrewer", "NMF", "BiasedUrn"))

# Load packages
library(edgeR)
library(ggplot2)
library(limma)
library(Glimma)
library(gplots)
library(RColorBrewer)

# Open counts file
countdata <- read.delim("GSE140490_PDAC_cell_line_cuffnorm_all_fpkm_exprs.txt",stringsAsFactors=F)
head(countdata)

# Convert counts to DGEList object
DGEListObject <- DGEList(countdata)

# Filter lowly expressed genes
thresh <- countdata > 0.5 # FPKM < 0.5 is the chosen threshold
keep <- rowSums(thresh) >= 3 # keep if TRUE in at least 3 samples
summary(keep)
DGEListObject <- DGEListObject[keep, keep.lib.sizes=FALSE]

# QC
# The next three lines are to make the x-labels easier to read
ss <- strsplit(colnames(DGEListObject),"_") 
unmerged <- lapply(ss, function(x) x[-1])
merged <- lapply(unmerged, function(x) paste(unlist(x),collapse="_"))

# Barplot of library sizes
ggplot(data=DGEListObject$samples,
       aes(x=rownames(DGEListObject$samples),y=lib.size))+
  geom_bar(stat="identity")+
  scale_x_discrete(labels=merged)+
  theme(axis.text.x=element_text(angle=45,hjust=1))+
  ggtitle("Barplot of library sizes")+
  labs(x="Sample",y="Library Size")

# Boxplots to check normality
logcounts <- log2(countdata)
boxplot(logcounts,xlab="",ylab="Log2 FPKM",las=2)
title("Boxplots of logFPKMs (unnormalised)")

# Hierarchical clustering w/ top 100 most variable genes
var_genes <- apply(logcounts,1,var)
head(var_genes)
select_var <- names(sort(var_genes,decreasing=T))[1:500]
head(select_var)
highly_variable_lfpkm <- logcounts[select_var,]
dim(highly_variable_lfpkm)
head(highly_variable_lfpkm)

## Get some nicer colours
mypalette <- brewer.pal(11,"RdYlBu")
morecols <- colorRampPalette(mypalette)

# Plot the heatmap
colnames(highly_variable_lfpkm) = merged
heatmap.2(as.matrix(highly_variable_lfpkm),col=rev(morecols(50)),trace="none", main="Top 500 most variable genes across samples",scale="row")

# Normalisation for composition bias
DGEListObject <- calcNormFactors(DGEListObject)

# limma differential expression
# Get groups
sample_names = rownames(DGEListObject$samples)
ss <- strsplit(sample_names,"_") 
unmerged <- lapply(ss, function(x) x[-length(x)])
merged <- lapply(unmerged, function(x) paste(unlist(x),collapse="_"))
DGEListObject$samples$group <- merged
group = unlist(merged)
levels(group) = unique(group)

# Design matrix
design <- model.matrix(~ 0 + group)
colnames(design) <- levels(group)

# Contrast matrix
contr.matrix <- makeContrasts(
  PAU89988T_6h = PATU8988T_DMSO - PATU8988T_DCLK1IN1_6h,
  PAU89988T_24h = PATU8988T_DMSO - PATU8988T_DCLK1IN1_24h,
  PATU8902_6h = PATU8902_DMSO - PATU8902_DCLK1IN1_6h,
  PATU8902_24h = PATU8902_DMSO - PATU8902_DCLK1IN1_24h,
  levels = colnames(design)
)
contr.matrix

v = voom(DGEListObject,design,plot=T,normalize.method="none")

fit <- lmFit(v,design)
fit2 <- contrasts.fit(fit,contr.matrix)
fit2 <- eBayes(fit2,trend=F)
results <- decideTests(fit2,p.value=.05,lfc=log2(2))
topGenes = topTable(fit2,number=Inf)
write.csv(topGenes,file="all_conds.csv")

experiments = colnames(topGenes)[1:4]
for(i in c(1,2,3,4)){
  sub = data.frame(topGenes[,c(i)])
  sub$Genes = rownames(topGenes)
  colnames(sub) = c(experiments[i],"Genes")
  sub = sub[,c(2,1)]
  fname = paste0(experiments[i],"_logfc.txt")
  write.table(sub,fname,quote=F,sep="\t",row.names=F,col.names = T)
}
