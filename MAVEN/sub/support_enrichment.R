library(piano)
library(parallel)
library(GSEABase)
library(snowfall)
library(readr)

#Copyright (C) 2020  Aurelien Dugourd, Alberto Valdeolivas, Rosa Hernansaiz-Ballesteros
#Contact : aurelien.dugourd@bioquant.uni-heidelberg.de

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

#'\code{gmt_to_csv}
#'
#'This function is designed to convert a gmt file into a two column dataframe where first column correspond to omic features and second column correspond to associated terms.
#'
#'@param gmtfile a full path name of the gmt file to be converted
#'@param outfile an optional output file name. If none is provided, the function will simply return a dataframe.
#'If outfile is provided with a full length path name file, the dataframe will be written as a csv file to the path provided.
#'@return a two column dataframe where first column correspond to omic features and second column correspond to associated terms.
gmt_to_csv <- function(gmtfile, fast = T)
{
  if(fast)
  {
    genesets = GSEABase::getGmt(con = gmtfile)
    genesets = unlist(genesets)

    gene_to_term =plyr::ldply(genesets,function(geneset){
      temp <- GSEABase::geneIds(geneset)
      temp2 <- setName(geneset)
      temp3 <- as.data.frame(cbind(temp,rep(temp2,length(temp))))

    },.progress = plyr::progress_text())
    names(gene_to_term) <- c("gene","term")
    return(gene_to_term[complete.cases(gene_to_term),])
  }
  else
  {
    genesets = getGmt(con = gmtfile)
    genesets = unlist(genesets)

    gene_to_term <- data.frame(NA,NA)
    names(gene_to_term) <- c("gene","term")
    for (geneset in genesets)
    {
      temp <- GSEABase::geneIds(geneset)
      temp2 <- setName(geneset)
      temp3 <- as.data.frame(cbind(temp,rep(temp2,length(temp))))
      names(temp3) <- c("gene","term")
      gene_to_term <- rbind(gene_to_term,temp3)
    }

    return(gene_to_term[complete.cases(gene_to_term),])
  }
}

#'\code{extractCARNIVALnodes}
#'
#'Function to extract the nodes that appear in CARNIVAL network and the
#'background genes (all genes present in the prior knowledge network).
#'
#'@param CarnivalResults CARNIVAL output.
#'@return List with 2 objects the success and the background genes.
#'NB edited Sept2022 to work with CARNIVAL v2.6.2
extractCARNIVALnodes <- function(CarnivalResults){
  
  CarnivalNetwork <- 
    as.data.frame(CarnivalResults$weightedSIF, stringsAsFactors = FALSE)
  
  colnames(CarnivalNetwork) <- c("source", "sign", "target", "Weight")
  
  ## added below line for v.2.6.2
  CarnivalNetwork = subset(CarnivalNetwork,Weight!=0)
  
  ## We define the set of nodes interesting for our condition
  sucesses <- unique(c(gsub("_.*","",CarnivalNetwork$source), 
                       gsub("_.*","",CarnivalNetwork$target)))
  
  CarnivalAttributes <- as.data.frame(CarnivalResults$nodesAttributes, 
                                      stringsAsFactors = FALSE)
  
  ## We define the background as all the genes in our prior knowledge network.
  bg <- unique(gsub("_.*","",CarnivalAttributes$Node))     
  
  return(list(sucesses = sucesses, bg= bg))
}

