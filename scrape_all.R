require('RSelenium')
library('XML')
remDr <- remoteDriver(remoteServerAddr = "192.168.99.100" 
                      , port = 4445L
                      , browserName = "firefox"
)
remDr$open()


site <- "https://www.industriaavicola.net/member-login/" 
remDr$navigate(site) 

webElem <- remDr$findElement(using = 'name', value = "log")
webElem$sendKeysToElement(list("XXXXXXXXXXXXXXX"))
webElem <- remDr$findElement(using = 'name', value = "pwd")
webElem$sendKeysToElement(list("XXXXXXXXXXXXX", key = "enter"))

message("Wait 5 seconds")
Sys.sleep(10)

perLink <- function(item){
  elemtxt <- item$getElementAttribute("outerHTML")[[1]] # gets us the HTML
  elemxml <- htmlTreeParse(elemtxt, useInternalNodes=T,encoding="utf-8") # parse string into HTML tree to allow 
  unlist(xpathApply(elemxml, '//a',xmlGetAttr, 'href'))  
}

parseItem <- function(country, name,title,value,year){
  pollos <- ""
  ponedoras <- ""
  pavos <- ""
  po_i <- grep("Pollos Sacrificados", title)
  tu_i <- grep("TurkeysSlaughtered", title)
  pd_i <- grep("Ponedoras", title)
  if(length(po_i)>0) pollos <- as.double(value[po_i])*10^6
  if(length(tu_i)>0) pavos <- as.double(value[tu_i])*10^6
  if(length(pd_i)>0) ponedoras <- as.double(value[pd_i])*10^6
  year <- strtoi(year)
  #line <- paste(country, name, year, pollos, ponedoras, pavos, sep=",")
  #message(line, Encoding(line))
  #write(line,file="RESULT.csv",append=TRUE, )
  df <- data.frame(country = country, name=name,year=year,pollos=pollos,ponedoras=ponedoras,pavos=pavos)
  #write.csv(df, "eggs.csv", append = TRUE, row.names=FALSE, col.names=FALSE, fileEncoding="UTF-8")
  write.table(df, "eggs2.csv", append = TRUE, quote=FALSE, row.names=FALSE, col.names=FALSE, fileEncoding="UTF-8",sep=",")
}



#Final 14
final <- 14
for (j in 14:final){
  message("P�gina ",j)
  site <- paste("https://www.industriaavicola.net/directorio-de-companias/?pg=",j,sep="") 
  remDr$navigate(site)
  
  webElem <- remDr$findElements(using = 'class', "cmbd_tiles_view_title")
  l <-length(webElem)
  list_links <- lapply(webElem,perLink)    
  #TESTING
  #l=1
  for(m in 1:l){
    message("Empresa ",m)
    remDr$navigate(list_links[[m]])
    
    webElem <- remDr$findElement(using = 'id', "innerPage")
    elemtxt <- webElem$getElementAttribute("outerHTML")[[1]]
    elemxml <- htmlTreeParse(elemtxt, useInternalNodes=T,encoding="utf-8")      
    country <- sapply(unlist(xpathApply(elemxml, '//li[@class="cmbd-output-items-top-label"]/following-sibling::li[1]')),xmlValue)
    webElem <- remDr$findElement(using = 'class', "cmbd-title")
    name <-webElem$getElementText()[[1]]
    name <- trimws(sub("Nombre de la compa��a", "", name))
    
    #The table
    webElem <- remDr$findElements(using = 'class', "cmbd_ad_table_frontend")
    tables <-length(webElem)
    for(n in 1:tables){
      
      class_ <- webElem[[n]]$getElementAttribute("class")
      year <- sub(".*_", "", class_)
      
      
      elemtxt <- webElem[[n]]$getElementAttribute("outerHTML")[[1]] 
      elemtxt
      elemxml <- htmlTreeParse(elemtxt, useInternalNodes=T,encoding="utf-8") # parse string into HTML tree to allow 
      
      title <- lapply(unlist(xpathApply(elemxml, '//td[@class="cmbd_AnnualTableLabel"]')),xmlValue)
      value <- lapply(unlist(xpathApply(elemxml, '//td[@class="cmbd_AnnualTableLabel"]/following-sibling::td[1]')),xmlValue)
      
      parseItem(country, name,title,value,year)
    }
  }
  
}