#' Forest plot
#' 
#' It makes a forest plot for gene-environment interactions (GxE) across
#' multiple sub-studies for all the SNPs in a set (e.g., a gene).
#' 
#' 
#' @param coef a matrix contains the GxE effect sizes. Each row corresponds to
#' a SNP in a set, and each column represents a study. If the matrix has
#' colnames and/or rownames for SNPs and studies respectively, they will be
#' used as labels in the forest plot.
#' @param se a matrix contains the standard errors for the GxE effect
#' estimates. Each row corresponds to a SNP in a set, and each column
#' represents a study.
#' @param sort logical. If TRUE, the SNPs are sorted by averaged effect sizes
#' across different studies. The default is TRUE.
#' @param exp logical. If TRUE, coef will be exponentiated. This option is
#' mainly used for log odds ratios obtained from logistic regressions. The
#' default is FALSE.
#' @return A forest plot across multiple sub-studies for all the SNPs in a set
#' (e.g., a gene).
#' @examples
#' 
#' 
#' coef = matrix(rnorm(6 * 6), 6, 6)
#' se = matrix(abs(runif(6 * 6, 0.1, 0.15)), 6, 6)
#' 
#' forest_plot(coef, se)
#' 
#' @export forest_plot

forest_plot = function(coef, se, sort = TRUE, exp = FALSE) {
  
  if(is.null(rownames(coef))) rownames(coef) = paste0('SNP', 1:nrow(coef))
  if(is.null(colnames(coef))) colnames(coef) = paste0('Study', 1:ncol(coef))
  
  if(sort) {
    means = rowMeans(coef)
    coef = coef[order(means),]
    se = se[order(means),]
  }
  
  lower = coef - qnorm(.975)*se
  upper = coef + qnorm(.975)*se
  
  snp = rownames(coef)
  study = colnames(coef)
  
  # exp to be odds ratio
  
  d3 = cbind(as.vector(t(coef)), as.vector(t(lower)), as.vector(t(upper)))
  if(exp) d3 = exp(d3)
  colnames(d3) = c('coef', 'lower', 'upper')
  rownames(d3) = rep(snp, rep(length(study), length(snp)))
  
  clrs = fpColors(box="black", lines="black", summary="black")
  
  tabletext =list(rep(snp, rep(length(study), length(snp))), rep(study, length(snp)))
  
  hrzl_lines = vector('list', nrow(coef) - 1)
  for(i in 1:(nrow(coef) - 1)) hrzl_lines[[i]] = gpar(lty=2)
  names(hrzl_lines) = as.character((1:(nrow(coef) - 1)) * length(study) + 1)
  
  forestplot(tabletext, hrzl_lines = hrzl_lines,
             d3, ol = clrs, zero = ifelse(exp, 1, 0), xlab="GxE effect size")
}
