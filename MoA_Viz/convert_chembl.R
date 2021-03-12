pidgin_results = preds_converted
ids = as.character(preds_converted$Gene_ID)
uniprot_mapping <- function(ids) {
  uri <- 'https://www.ebi.ac.uk/chembl/api/data/target/search?q='
  idStr <- ids
  fullUri <- paste0(uri,idStr)
  data <- read_xml(fullUri)
  chembl = xml_find_all(data,".//target_chembl_id")
  id = xml_text(chembl)
  return(id[[1]])
}

## Usage
chembl_ids = list()
hgncs = list()
n = length(ids)
pb <- txtProgressBar(0, n, style = 3)
for (i in 1:n) {
  setTxtProgressBar(pb, i)
  hgnc = ids[[i]]
  hgncs = c(hgncs,hgnc)
  #ERROR HANDLING
  possibleError <- tryCatch(
    uniprot_mapping(hgnc),
    error=function(e) e
  )
  
  if(!inherits(possibleError, "error")){
    #REAL WORK
    converted = uniprot_mapping(hgnc)
    chembl_ids = c(chembl_ids,converted)
  }else{
    chembl_ids = c(chembl_ids,"NaN")
  }
  
}  #end for

hgncs = unlist(hgncs)
chembl_ids = unlist(chembl_ids)

df = data.frame(cbind(hgncs,chembl_ids))

df$url = paste0("https://www.ebi.ac.uk/chembl/g/#browse/activities/filter/target_chembl_id%3A",df$chembl_ids)
df$url = ifelse(df$chembl_ids=="NaN","",df$url)
saveRDS(df, file = "../sub/hgnc_chembl_url.rds")

preds_and_url = merge(pidgin_results,df,by.x="Gene_ID",by.y="hgncs")
preds_and_url$test <- paste0("<a href='",preds_and_url$url,"' target='_blank'>",preds_and_url$Gene_ID,"</a>")
