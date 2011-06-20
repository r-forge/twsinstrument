#download.file('https://www.spdrs.com/library-content/public/public-files/etfnav.csv?docname=Most%20Recent%20Net%20Asset%20Values&onyx_code1=1299&onyx_code2=NA', destfile=tmp)

#There is a link called "Most Recent Net Asset Values" on https://www.spdrs.com/product/
#it has all the SPDR funds, and it should be used here instead of just the sectorspdrs.

getHoldings <-function(symbols, env=.GlobalEnv) {
	tmp <- tempfile()
	download.file("http://us.ishares.com/product_info/fund/excel_profile.htm",destfile=tmp)
	ishr.syms <- read.csv(tmp)
	ishr.syms <- as.character(ishr.syms$Fund.Name)[-1]
	unlink(tmp)
	spdr.syms <- c('XLY','XLP','XLE','XLF','XLV','XLI','XLB','XLK','XLU')
	if (missing(symbols)) symbols <- c(ishr.syms,spdr.syms)
	ishr.out <- spdr.out <- NULL
	for (symbol in symbols) {
		if(!is.na(match(symbol,spdr.syms))) {
			tmp <- tempfile()
			download.file(paste("http://www.sectorspdr.com/content/?do=indexComposition&symbol=", 
								symbol, "&filetype=csv", sep=""), destfil=tmp) 
			fr <- read.csv(tmp,sep="\t",stringsAsFactors=FALSE)
			unlink(tmp)
			fr <- data.frame(as.numeric(fr[,4]),row.names=as.character(fr[,3]))			
			colnames(fr) <- paste(symbol,'Weight',sep='.')
			#fr2 <- data.frame(as.character(fr[,3]),as.character(fr[,2]),as.numeric(fr[,4]))
			#colnames(fr) <- c('Symbol','Name','Weight')
			assign(paste(symbol,'h',sep='.'),fr,pos=env)
			spdr.out <- c(spdr.out,paste(symbol,'h',sep='.'))
		} else if(!is.na(match(symbol,ishr.syms))) {		
			tmp <- tempfile()
			download.file(paste('http://us.ishares.com/product_info/fund/excel_holdings.htm?ticker=',symbol,sep=""), destfile=tmp)
			fr <- read.csv(tmp,skip=11)
			unlink(tmp)
			fr <- fr[1:(length(fr[,1])-3),c(1,3)]
			fr <- fr[fr$Symbol!='--',] #maybe this is dangerous, but I'm ignoring stuff with Symbol=="--" (e.g. BLACKROCK FDS III)
			#colnames(fr) <- c('Symbol','Name',paste(symbol,'Weight',sep='.'))
			fr <- data.frame(fr[,2],row.names=fr[,1])			
			colnames(fr) <- paste(symbol,'Weight',sep='.')
			assign(paste(symbol,'h',sep='.'),fr,pos=env)
			ishr.out <- c(ishr.out,paste(symbol,'h',sep='.'))
		} else stop("Unrecognized ETF. Make sure your symbols are either iShares or Sector SPDRs.")	
	}
	paste(c(ishr.out,spdr.out))
}
