# ********************************************************************
# ********************************************************************
# FILE NAME:		 20190917_MainFig.R
# 
# AUTHOR:					Kate Mansfield		
# VERSION:				v2
# DATE VERSION CREATED: 	2019-Sep-17
# 
# DESCRIPTION OF FILE:	Produce a forest plot with main analysis 
#                        results from England including column headers
# ********************************************************************
# ********************************************************************


library(forestplot)


# ********************************************************************
# 1. create dataframe for each model
# ********************************************************************
# -------------------------------------------------------------------
# 1.2 English results
# -------------------------------------------------------------------
# t1
t1 <- structure(list(
  hr      = c(NA, 1.00, 2.05, 1.40, 1.13, 1.33), 
  lower   = c(NA, NA, 1.80, 1.31, 1.02, 1.24),
  upper   = c(NA, NA, 2.34, 1.50, 1.24, 1.46),
  nevents = c("", "7495", "630", "1710", "705", "830"),
  rate   = c(NA, 58.6, 246.3, 92.0, 61.0, 78.1)),
  .Names = c("mean", "lower", "upper", "nevents", "rate"), 
  row.names = c(NA, -6L), 
  class = "data.frame")


# ********************************************************************
# 2. Create tabletext
# ********************************************************************
rownames <- c("Historical comparator",
              "February 2020 to August 2020",
              "September 2020 to June 2021",
              "July 2021 to November 2021",
              "December 2021 to October 2022")



t1$txt <- paste(sprintf("%.2f", t1$mean), " (", sprintf("%.2f", t1$lower), ", ", sprintf("%.2f", t1$upper), ")", sep="")

# HR (95% CI) text
t1$alltxt <- paste(ifelse(!is.na(t1$mean), t1$txt, ""))


# event count text
t1$txteventCount <- paste(t1$nevents, sep="")
t1$txtrate <- paste(t1$rate, sep="")


# population with event text
t1$txtRD <- paste(t1$rdiff, sep="\n")

t1$txtRDiff <- paste(t1$txtRD, t2$txtRD, t3$txtRD, sep="\n")



#tabletext <- cbind(rownames, t1$alltxt)
tabletext <- cbind(c("Symptom", rownames), 
                   c("HR (95% CI)", t1$alltxt[2:6]),
                   c("N events", t1$txteventCount[2:6]),
                   c("Rate per 100,000 person years", t1$txtrate[2:6]))




# ********************************************************************
# 6. Put Eng and DK data on one plot
# ********************************************************************
forestplot(tabletext, 
           mean = cbind(t1[, "mean"]), # include point estimates as the coeffs for all models
           lower = cbind(t1[, "lower"]), # lower CI
           upper = cbind(t1[, "upper"]), # upper CI
           col=fpColors(zero="#707070", box=c("#C0C0C0", "#707070", "black")), # makes colours for models different shades light grey to black
          # fn.ci_norm = c(fpDrawNormalCI, fpDrawCircleCI, fpDrawDiamondCI), # estimation indicators are squares and circles
           zero=1, # set the zero line at 1
           boxsize = .1,
           grid = TRUE,
           line.margin=.1,
           graphwidth = unit(4, "inches"), 
           colgap = unit(2, "mm"),
           txt_gp = fpTxtGp(ticks=gpar(cex=.6),
                            xlab=gpar(cex = .9),
                            summary=list(gpar(cex=1),
                                         gpar(cex=.85),
                                         gpar(cex=.85),
                                         gpar(cex=.85)),
                            label=list(gpar(cex=.85),
                                       gpar(cex=.85),
                                       gpar(cex=.85),
                                       gpar(cex=.85))),

           #xlog=TRUE,
           xlab="OR (95% CI)",
           clip =c(.25, 4), # clip axis
           xticks = c(.25, .5, 1, 2, 3), # specified positions for xticks
           align = c("l", "c", "c", "c"), # Use "l", "c", or "r" for left, center, or right aligned
           is.summary=c(TRUE,rep(FALSE,6)), # vector with logical values representing if value is a summary val (will have diff font style)
           graph.pos=2)



