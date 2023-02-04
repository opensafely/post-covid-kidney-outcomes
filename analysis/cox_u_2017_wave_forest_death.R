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
  hr      = c(NA, 1.00, 3.01, 2.11, 1.40, 2.74), 
  lower   = c(NA, 1.00, 2.91, 2.07, 1.36, 2.68),
  upper   = c(NA, 1.00, 3.11, 2.16, 1.44, 2.81),
  number  = c(NA, 10399825, 108275, 1054695, 1042910, 1349535),
  nevents = c("", "93610", "12955", "27490", "7185", "17405"),
  rate   = c(NA, 731, 5416, 1477, 622, 1636)),
  .Names = c("mean", "lower", "upper", "number", "nevents", "rate"), 
  row.names = c(NA, -6L), 
  class = "data.frame")


# ********************************************************************
# 2. Create tabletext
# ********************************************************************
rownames <- c("No COVID-19 (pre-pandemic)",
              "COVID-19 February 2020 to August 2020",
              "COVID-19 September 2020 to June 2021",
              "COVID-19 July 2021 to November 2021",
              "COVID-19 December 2021 to October 2022")



t1$txt <- paste(sprintf("%.2f", t1$mean), " (", sprintf("%.2f", t1$lower), ", ", sprintf("%.2f", t1$upper), ")", sep="")

# HR (95% CI) text
t1$alltxt <- paste(ifelse(!is.na(t1$mean), t1$txt, ""))

# event count text
t1$txtnumber <- paste(t1$number, sep="")
t1$txtneventCount <- paste(t1$nevents, sep="")
t1$txtrate <- paste(t1$rate, sep="")

#tabletext <- cbind(rownames, t1$alltxt)
tabletext <- cbind(c("Death", rownames), 
                   c("HR (95% CI)", t1$alltxt[2:6]),
                   c("Number", t1$txtnumber[2:6]),
                   c("Events", t1$txtneventCount[2:6]),
                   c("Rate (per 100,000 person years", t1$txtrate[2:6]))




# ********************************************************************
# 6. Put Eng and DK data on one plot
# ********************************************************************
forestplot(tabletext, 
           mean = cbind(t1[, "mean"]), # include point estimates as the coeffs for all models
           lower = cbind(t1[, "lower"]), # lower CI
           upper = cbind(t1[, "upper"]), # upper CI
           col=fpColors(zero="black", box=c("black", "black", "black")), # makes colours for models different shades light grey to black
          # fn.ci_norm = c(fpDrawNormalCI, fpDrawCircleCI, fpDrawDiamondCI), # estimation indicators are squares and circles
           zero=1, # set the zero line at 1
           boxsize = .1,
           grid = TRUE,
           line.margin=.1,
           graphwidth = unit(4, "inches"), 
           colgap = unit(3, "mm"),
           txt_gp = fpTxtGp(ticks=gpar(cex=.6),
                            xlab=gpar(cex = .9),
                            summary=list(gpar(cex=1),
                                         gpar(cex=.85),
                                         gpar(cex=.85),
                                         gpar(cex=.85)),
                            label=list(gpar(cex=1),
                                       gpar(cex=1),
                                       gpar(cex=1),
                                       gpar(cex=1))),

           #xlog=TRUE,
           xlab="HR (95% CI)",
           clip =c(.25, 4), # clip axis
           xticks = c(.25, .5, 1, 2, 3, 4), # specified positions for xticks
           align = c("l", "c", "c", "c", "c"), # Use "l", "c", or "r" for left, center, or right aligned
           is.summary=c(TRUE,rep(FALSE,6)), # vector with logical values representing if value is a summary val (will have diff font style)
           graph.pos=2)



