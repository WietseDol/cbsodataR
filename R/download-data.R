#' Gets all data from a cbs table.
#' 
#' Gets all data via bulk download. Dumps the data in (international) csv format.
#' @param id of cbs open data table
#' @param path of data file, defaults to "<id>/data.csv"
#' @param ... optional filter statements to select rows of the data, e.g.
#' @param select optional names of columns to be returned.
download_data <- function(id, path=file.path(id, "data.csv"), ..., select=NULL){
  url <- whisker.render("{{BASEURL}}/{{BULK}}/{{id}}/UntypedDataSet?$format=json"
                        , list( BASEURL = BASEURL
                                , BULK = BULK
                                , id = id
                        )
  )
  url <- paste0(url, get_query(..., select=select))
  
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  data_file <- file(path, open = "wt")  
  
  # retrieve data
  message("Retrieving data from table '", id ,"'")
  res <- jsonlite::fromJSON(url)
  write.table( res$value, 
               file=data_file, 
               row.names=FALSE, 
               na="",
               sep=",")
  url <- res$odata.nextLink

  while(!is.null(url)){
    skip <- gsub(".+skip=(\\w+)", "\\1", url)
    message("Reading...")
    res <- jsonlite::fromJSON(url)
    message("Writing...")
    write.table( res$value
               , file=data_file
               , row.names=FALSE
               , col.names = FALSE
               , na=""
               , sep=","
               )
    url <- res$odata.nextLink
    #break
  }
  close(data_file)
  message("Done!")
}

#testing
#download_data("81819NED")


## big table
#download_data("70072ned")