#' A clock utility to display the TWS server time
#'
#' adapted from the code in the links in references
#' @param format format
#' @param refresh refresh rate
#' @param verbose be verbose about what clientId you are connected with?
#' @usage twsClock(format = "\%H:\%M:\%S", refresh = 1, verbose=TRUE)
#' @return live updating current time as reported by \code{reqCurrentTime}. Press escape to exit clock utility.
#' @references
#' \url{http://stackoverflow.com/questions/5953718/overwrite-current-output-in-the-r-console}
#'
#' \url{http://4dpiecharts.com/2011/05/11/a-clock-utility-via-console-hackery/}
#'
#' \url{http://www.asciitable.com/}
#' @examples
#' \dontrun{
#' twsClock()
#' twsClock("\%A \%d \%B \%Y \%I:\%M:\%OS3 \%p", 1e-3)
#' }
twsClock <- function(format = "%H:%M:%S", refresh = 1, verbose=TRUE)
{
    tryCatch({
            tws <- try(twsConnect(1010))
        if (inherits(tws, "try-error")) 
            tws <- try(twsConnect(1011))
        if (inherits(tws, "try-error")) 
            tws <- twsConnect(9999)
        if (isConnected(tws) && verbose) 
            cat(paste("Connected with clientId", tws$clientId, '\n'))
        if (tws$clientId == 9999) 
            warning("IB TWS should be restarted.")    
        repeat
        {
            cat("\r", format(reqCurrentTime(tws), format), sep = "")
            flush.console()
            Sys.sleep(refresh)
        }
    }, finally = {
        twsDisconnect(tws)
    })
}
