define_FX <- define_exchange_rates <- function(pairs, counter_currencies=NULL, second_currencies=NULL, use.IB=TRUE) {
    if (missing(pairs)) {
        if (is.null(counter_currencies) && is.null(second_currencies) ) { #nothing is given
            pairs <- c("EUR.USD","USD.JPY","GBP.USD","USD.CHF","AUD.USD","USD.CAD","NZD.USD","GBP.JPY","EUR.JPY")
        } else {
            pairs <- NULL
            if (is.null(second_currencies)) {
                if (length(ls_currencies())==1) {
                    second_currencies <- ls_currencies()[1]
                } else second_currencies <- "USD"
            }
            for (qc in second_currencies) {
                pairs <- c(pairs, paste(counter_currencies, qc, sep="."))
            }
        }    
    }
    lastc <- function(x) substr(x,nchar(x),nchar(x))
    if (!(all(do.call(c,lapply(strsplit(pairs,"\\."),length)) == 2))) { #not formatted like EUR.USD    
        if (all(do.call(c,lapply(strsplit(pairs,"/"),length)) == 2)) { #EUR/USD
            pairs <- gsub("/","\\.",pairs)
        } else if (all(do.call(c,lapply(pairs,nchar)) == 6)) { #EURUSD
            pairs <- paste(paste(substr(pairs,1,3),".",sep=""),substr(pairs,4,6),sep="")        
        } else if (all(do.call(c, lapply(pairs,nchar)) == 4)
                    && all(do.call(c, lapply(pairs,lastc)) == ".")) {
            #EUR.
            pairs <- paste(pairs,"USD",sep="")
        }
    }
    for (pair in pairs) {
        instrument.tws(primary_id=pair, 
                currency=strsplit(pair,"\\.")[[1]][2],
                multiplier=1,
                tick_size=0.01,
                symbol_currency = strsplit(pair,"\\.")[[1]][1],
                type = c("exchange_rate","currency"), assign_i = TRUE)            
    }
    if (use.IB) update_instruments.IB(pairs)
}
