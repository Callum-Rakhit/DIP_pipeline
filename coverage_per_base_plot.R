GetPackages <- function(required.packages) {
  packages.not.installed <- required.packages[!(
    required.packages %in% installed.packages()[, "Package"])]
  if(length(packages.not.installed)){install.packages(packages.not.installed, dependencies = T)}
  suppressMessages(lapply(required.packages, require, character.only = T))
}

tot=10000
new=1500

for(i in 1:11){
  new=new*1.1
  tot=tot+new
}

options(scipen = 999)
(0.5*7000000000)*0.01

GetPackages(c("ggplot2", "reshape2", "plyr"))
args = commandArgs(trailingOnly = T)

if (length(args) < 2) {stop(paste(
  "Supply a coverage output file from the samtools depth function\ne.g. RScript coverage_per_base.R my.coverage",
  sep = ""), call. = F)
}

temp <- read.table(
  file = args[1], 
  header = F, sep = "\t", na.strings = "NA", dec = ".", strip.white = T)

temp <- rename(temp, c(V1 = "region", V2 = "base", V3 = "depth"))

CoveragePerBase <- function(dataframe){
  ggplot(dataframe, aes(x = base, y = depth)) +
    geom_line(color = "red") +
    facet_wrap(~ dataframe$region, ncol = 4) +
    xlab("Position in segment (nucleotides)") +
    ylab("Coverage Depth") +
    # scale_fill_manual(values = colour_palette) +
    ggtitle("Coverage per base plots for the 8 influenza A genome segments") +
    theme(# Lengends to the top
      plot.title = element_text(hjust = 0.5),
      legend.position = "none",
      # Remove the y-axis
      axis.title.y = element_blank(),
      # Remove panel border
      panel.border = element_blank(),
      # Remove panel grid lines
      panel.grid.major.x = element_blank(),
      # explicitly set the horizontal lines (or they will disappear too)
      panel.grid.major.y = element_line(size = .25, color = "black"),
      panel.grid.minor = element_blank(),
      # Remove panel background
      panel.background = element_blank(),
      # Rotate the x-axis labels 0 degrees
      axis.text.x = element_text(angle = 0, hjust = 0))
}

output <- CoveragePerBase(temp)
ggsave(
  paste("/home/callum.rakhit/Addenbrooks_DIP_pos_flu/", args[2], sep = ""), 
  output, width = 16*1, height = 9*1
  )
