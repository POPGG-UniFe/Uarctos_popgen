library(dplyr)
library(ggplot2)

options("scipen"=100, "digits"=4)

## load Fst in sliding windows
fst_AB <- read.table("fst_A-B_50kWin_50kStep.windowed.weir.fst", header = T)
fst_AB$WEIGHTED_FST[fst_AB$WEIGHTED_FST < 0] <- 0
fst_AB$"T" <- -log(1-fst_AB$WEIGHTED_FST)

fst_AC <- read.table("fst_A-C_50kWin_50kStep.windowed.weir.fst", header = T)
fst_AC$WEIGHTED_FST[fst_AC$WEIGHTED_FST < 0] <- 0
fst_AC$"T" <- -log(1-fst_AC$WEIGHTED_FST)

fst_AD <- read.table("fst_A-D_50kWin_50kStep.windowed.weir.fst", header = T)
fst_AD$WEIGHTED_FST[fst_AD$WEIGHTED_FST < 0] <- 0
fst_AD$"T" <- -log(1-fst_AD$WEIGHTED_FST)

fst_BC <- read.table("fst_B-C_50kWin_50kStep.windowed.weir.fst", header = T)
fst_BC$WEIGHTED_FST[fst_BC$WEIGHTED_FST < 0] <- 0
fst_BC$"T" <- -log(1-fst_BC$WEIGHTED_FST)

fst_BD <- read.table("fst_B-D_50kWin_50kStep.windowed.weir.fst", header = T)
fst_BD$WEIGHTED_FST[fst_BD$WEIGHTED_FST < 0] <- 0
fst_BD$"T" <- -log(1-fst_BD$WEIGHTED_FST)


## keep only the windows in common
rownames(fst_AB) <- paste0(fst_AB$CHROM, "_", fst_AB$BIN_START)
rownames(fst_AC) <- paste0(fst_AC$CHROM, "_", fst_AC$BIN_START)
rownames(fst_AD) <- paste0(fst_AD$CHROM, "_", fst_AD$BIN_START)
rownames(fst_BC) <- paste0(fst_BC$CHROM, "_", fst_BC$BIN_START)
rownames(fst_BD) <- paste0(fst_BD$CHROM, "_", fst_BD$BIN_START)

list_of_data = list(fst_AB, fst_AC, fst_AD, fst_BC, fst_BD)
common_names = Reduce(intersect, lapply(list_of_data, row.names))
list_of_data = lapply(list_of_data, function(x) { x[row.names(x) %in% common_names,] })

# check that the elements of the list all have the same dimensions
lapply(list_of_data, dim)


## compute PBS for the windows in common
pbs <- data.frame(list_of_data[[1]]$CHROM, list_of_data[[1]]$BIN_START, list_of_data[[1]]$BIN_END, ((2*list_of_data[[1]]$"T" + list_of_data[[2]]$"T" + list_of_data[[3]]$"T" - list_of_data[[4]]$"T" - list_of_data[[5]]$"T")/4))
colnames(pbs) <- c("CHROM", "BIN_START", "BIN_END", "PBS")

# there can be negative PBS values, change them for 0
pbs$PBS[pbs$PBS < 0] <- 0

# order chr
pbs$CHROM <- as.numeric(gsub("Scaffold_", "", pbs$CHROM))
pbs.ord <- pbs[order(pbs$CHROM),]

# change Inf values to 10 times the max PBS finite value
# or multiple only by 2 to make visualization more appealing
pbs.ord$PBS[pbs.ord$PBS == Inf] <- 2*max(pbs.ord$PBS[-which(pbs.ord$PBS == Inf)], na.rm = T)

# format in bed to save result
# revert to chr names that start with Scaffold_ for compatibility with other files
pbs.ord.chrNames <- pbs.ord %>% filter(CHROM < 38)
pbs.ord.chrNames$CHROM <- gsub("^", "Scaffold_", pbs.ord.chrNames$CHROM, perl = T)


## Outlier detection
# 99, 99.5, 99.9% threshold
q <- quantile(pbs.ord.chrNames$PBS, probs = c(.99, .995, .999), na.rm = T)


## Manhattan plot

# format the dataset for the script in ggplot
pbs.ord.plot <- data.frame(rownames(pbs.ord), pbs.ord$CHR, (pbs.ord$BIN_START+pbs.ord$BIN_END-1)/2, pbs.ord$PBS)
colnames(pbs.ord.plot) <- c("SNP", "CHR", "BP", "P")

# select only chr 1-37 for better visualization
pbs.ord.plot <- pbs.ord.plot %>% filter(CHR < 38)


# add info for plotting
# NOTE: in case I don't use the "snpsOfInterest" file, stop creation of "don" object at mutate(BPcum=BP+tot)
don <- pbs.ord.plot %>%

  # Compute chromosome size
  group_by(CHR) %>%
  summarise(chr_len=max(BP)) %>%

  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%

  # Add this info to the initial dataset
  left_join(pbs.ord.plot, ., by=c("CHR"="CHR")) %>%

  # Add a cumulative position of each SNP
  arrange(CHR, BP) %>%
  mutate(BPcum=BP+tot) #%>%

  # Add highlight and annotation information
#  mutate( is_highlight=ifelse(P >= q, "yes", "no")) %>%
#  mutate( is_highlight=ifelse(SNP %in% snpsOfInterest, "yes", "no")) %>%
#  mutate( is_annotate=ifelse(-log10(P)>4, "yes", "no"))

# Prepare X axis
axisdf <- don %>% group_by(CHR) %>% summarize(center=( max(BPcum) + min(BPcum) ) / 2 )

# Make the plot
p <- ggplot(don, aes(x=BPcum, y=P)) +

  # Show all points
  geom_point( aes(color=as.factor(CHR)), alpha=0.8, size=0.9) +
  scale_color_manual(values = rep(c("grey", "skyblue"), 19 )) +

  # custom X axis:
  scale_x_continuous( label = axisdf$CHR, breaks= axisdf$center ) +
  scale_y_continuous(expand = c(0.1, 0.1) ) +     # remove space between plot area and x axis

  # Add highlighted points
#  geom_point(data=subset(don, is_highlight=="yes"), color="red", size=1.3) +

  # Add label using ggrepel to avoid overlapping, only for significant SNPs
#  geom_label_repel( data=subset(don, is_annotate=="yes"), aes(label=SNP), size=2, max.overlaps = 50) +

  # Custom the theme:
  theme_bw() +
  theme(
    legend.position="none",
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
    ) +
  labs(x = "Chromosome", y = "PBS") +
  geom_hline(yintercept = q[3], col = "red")


ggsave("pbs_manhattan_50kWin_50kStep.pdf", plot = p, device = "pdf", width = 33, heigh = 6, units = "cm", dpi = 300)



## Download PBS values in bed format
pbs.ord.chrNames.bed <- pbs.ord.chrNames
pbs.ord.chrNames.bed$BIN_START <- pbs.ord.chrNames.bed$BIN_START -1
write.table(pbs.ord.chrNames.bed, file = "pbs4pop_50kWin_50kStep.bed", sep = "\t", row.names = F, col.names = F, quote=F)


## Download thresholds
write.table(unname(q), "threshold_top_1_0.5_0.1", row.names = F, col.names = F, quote=F)


## save work
save.image(file = "pbs_50kWin_50kStep.RData")

