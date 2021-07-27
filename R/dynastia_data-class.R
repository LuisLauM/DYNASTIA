
#' @method print dynastia_data
#' @export
print.dynastia_data <- function(x, n = 6L, ...){

  cat("\nclass: dynastia_data\n")

  for(i in seq_along(x)){

    data <- x[[i]]

    cat(sprintf("\n%s data: %s x %s", toupper(names(x)[i]), nrow(data), ncol(data)))
    cat("\nData:\n\n")

    print(head(x = as.data.frame(data), n = n))

    if(nrow(data) > n){
      cat(sprintf("\n(*)We are omitting %s rows\n", nrow(data) - n))
    }
  }

  return(invisible())
}
