######################################################################
# ggExpress is the fastest way to create, annotate and export plots in R.
######################################################################
# try(source("~/GitHub/Packages/ggExpressDev/ggExpress.functions.R"), silent = T)
# try(source("https://raw.githubusercontent.com/vertesy/ggExpressDev/main/ggExpress.functions.R"), silent = T)

require(ggpubr)
require(cowplot)
suppressWarnings(vx <- require(MarkdownReportsDev)); if (!vx) MarkdownReports # Either version is fine, preffered dev.
 # https://github.com/vertesy/MarkdownReportsDev


######################################################################
# Auxiliary functions for ggExpress
######################################################################
try(source("~/GitHub/Packages/ggExpressDev/ggExpress.auxiliary.functions.R"))


######################################################################
# Original functions
######################################################################

# ------------------------------------------------------------------------------------------------
qhistogram <- function(vec, ext = "pdf", xlab = F, vline = F, plot = TRUE, save = TRUE, mdlink = TRUE
                       , plotname = make.names(as.character(substitute(vec)))
                       , logX = F, logY = F
                       , w = 5, h = w, suffix = NULL, ...) {
  if (isFALSE(xlab)) xlab = plotname
  df <- qqqCovert.named.vec2tbl(namedVec = vec, thr = 50)

  p <- gghistogram(data = df, x = "value"
                , title = plotname, xlab = xlab
                , add = "median"
                , color = "names", fill = "names"
                , palette = 'jco', ...
  ) +
  if (length(unique(df$"names")) == 1) theme(legend.position = "none")
  if (logX) p <- p + scale_x_log10()
  if (logY) p <- p + scale_y_log10()
  if (vline) p <- p + geom_vline(xintercept = vline)
  fname = kpp(plotname, suffix, "hist", flag.nameiftrue(logX), flag.nameiftrue(logY), ext)
  if (save) qqSave(ggobj = p, title = plotname, fname = fname, ext = ext, w = w, h = h)
  if (mdlink & save) qMarkdownImageLink(fname)
  if (plot) p
}
# weight <- rnorm(1000); qhistogram(weight, vline = 3)




# ------------------------------------------------------------------------------------------------
qdensity <- function(vec, ext = "pdf", xlab = F, plot = TRUE, save = TRUE, mdlink = TRUE
                     , plotname = make.names(as.character(substitute(vec)))
                     , logX = F, logY = F
                     , w = 5, h = w, suffix = NULL, ...) {
  if (isFALSE(xlab)) xlab = plotname
  df <- qqqCovert.named.vec2tbl(namedVec = vec, thr = 50)

  p <- ggdensity(data = df, x = "value" # , y = "..count.."
                 , title = plotname, xlab = xlab
                 , add = "median", rug = TRUE
                 , color = "names", fill = "names"
                 , palette = 'jco', ...
  ) +
    if (length(unique(df$"names")) == 1) theme(legend.position = "none")
  if (logX) p <- p + scale_x_log10()
  if (logY) p <- p + scale_y_log10()
  fname = kpp(plotname, suffix, "dens", flag.nameiftrue(logX), flag.nameiftrue(logY),  ext)
  if (save) qqSave(ggobj = p, title = plotname, fname = fname, ext = ext, w = w, h = h)
  if (mdlink & save) qMarkdownImageLink(fname)
  if (plot) p
}
# qdensity(weight)
# qdensity(weight2)


# ------------------------------------------------------------------------------------------------
qbarplot <- function(vec, ext = "pdf", plot = TRUE, title =F
                     , save = TRUE, mdlink = TRUE
                     , hline = F, filtercol = 1
                     , palette_use = 'jco', col = as.character(1:3)[1]
                     , xlab.angle = 90, xlab = F
                     , logY = F
                     , w = qqqAxisLength(vec), h = 5, suffix = NULL, ...) {
  plotname <- if (isFALSE(title)) kpp(make.names(as.character(substitute(vec))), suffix) else title

  if (isFALSE(xlab)) xlab = plotname
  df <- qqqCovert.named.vec2tbl(namedVec = vec, thr = 50)

  if (length(unique(df$"names")) == 1) df$"names" <- as.character(1:length(vec))

  df[["col"]] <- if (hline) {
    if (filtercol == 1 ) (df$"value" > hline) else if (filtercol == -1 ) (df$"value" < hline)
  } else {rep(col, length(vec))[1:length(vec)]}

  p <- ggbarplot(data = df, x = "names", y = "value"
                 , title = plotname, xlab = xlab
                 , color = "col", fill = "col"
                 , palette = palette_use, ...
  ) + grids(axis = 'y') +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = xlab.angle, hjust = 1)
    )

  if (hline) p <- p + geom_hline(yintercept = hline)
  if (logY) p <- p + scale_y_log10()
  fname = kpp(plotname, suffix, "bar", flag.nameiftrue(logY), ext)
  if (save) qqSave(ggobj = p, title = plotname, fname = fname, ext = ext, w = w, h = h)
  if (mdlink & save) qMarkdownImageLink(fname)
  if (plot) p
}

# weight3 <- runif (12)
# qbarplot(weight3, filtercol = -1, hline = .5)
# qbarplot(weight3, filtercol = 1, hline = .5)


# ------------------------------------------------------------------------------------------------
# qpie ------------------------------------------------------------------------------------------------
qpie <- function(vec, ext = "pdf", plot = TRUE, save = TRUE, mdlink = TRUE
                 , LegendSide = T, LegendTitle = as.character(substitute(vec)), NoLegend = F
                 , plotname = make.names(as.character(substitute(vec)))
                 , pcdigits = 2, NamedSlices =F
                 , color.palette = 'jco'
                 , w = 5, h = w, suffix = NULL, ...) {
  # plotname <- as.character(substitute(vec))
  df <- qqqCovert.named.vec2tbl(namedVec = vec, thr = 50)
  pcX <- df$"value" / sum(df$"value")
  labs <- paste(100 * signif (pcX, pcdigits), "%", sep = "")
  if (NamedSlices) labs <- paste(df$names, "\n", labs)

  p <- ggpubr::ggpie(data = df, x = "value", label = labs
                     , fill = "names", color = "white"
                     , title = plotname
                     , palette = color.palette, ...)
  if (LegendSide) p <- ggpar(p, legend = "right", legend.title = LegendTitle)
  p <- if (NoLegend) p + NoLegend() else p
  fname = kpp(plotname, suffix, "pie",  ext)
  if (save) qqSave(ggobj = p, title = plotname, fname = fname, ext = ext, w = w, h = h)
  if (mdlink & save) qMarkdownImageLink(fname)
  if (plot) p
}
# xvec <- c("A"=12, "B"=29); qpie(vec = xvec)


# qscatter ------------------------------------------------------------------------------------------------
qscatter <- function(tbl_X_Y_Col_etc, ext = "pdf", title =F
                     , cols = c(NULL , 3)[1]
                     , logX = F, logY = F
                     , hline = F, vline = F, plot = TRUE, save = TRUE, mdlink = TRUE
                     , w = 7, h = w, suffix = NULL, ...) {
  plotname <- if (isFALSE(title)) kpp(make.names(as.character(substitute(tbl_X_Y_Col_etc))), suffix) else title
  vars <- colnames(tbl_X_Y_Col_etc)
  df <- tbl_X_Y_Col_etc
  p <- ggscatter(data = df, x = vars[1], y = vars[2], color = cols
                 , title = plotname, ...) +
    grids(axis = 'xy')
  if (hline) p <- p + geom_hline(yintercept = hline)
  if (vline) p <- p + geom_vline(xintercept = vline)

  if (logX) p <- p + scale_x_log10()
  if (logY) p <- p + scale_y_log10()
  fname = kpp(plotname, suffix, "scatter", flag.nameiftrue(logX), flag.nameiftrue(logY), ext)
  if (save) qqSave(ggobj = p, title = plotname, fname = fname, ext = ext, w = w, h = h)
  if (mdlink & save) qMarkdownImageLink(fname)
  if (plot) p
}
# dfx <- as.data.frame(cbind("AA"=rnorm(12), "BB"=rnorm(12)))
# qscatter(dfx, suffix = "2D.gaussian")




# ------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------
## -------------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------


