require(Seurat)
require(dplyr)
require(Matrix)
require(magrittr)
library(scales)
library(ggplot2)
library(configr)
library(cowplot)
library(Hmisc)
library(RColorBrewer)
library(presto)
library(presto)
library(Seurat)
library(SeuratData)
library(SeuratWrappers)
library(ComplexHeatmap)
library(circlize)

grid.col<-colorRampPalette(brewer.pal(9, "Set2"))(4)[1:4]
rds<-readRDS('/annoroad/data1/bioinfo/PROJECT/big_Commercial/Cooperation/B_TET/TET_PUBLIC/zhaoyue/project/B_TET_074/dimplot/Mac_without_UK.rds')
Idents(rds)<-rds@meta.data$cell.type
rds<-subset(rds,idents='MonMac')
Idents(rds)<-rds@meta.data$sampleID
markers <- FindAllMarkers(object = rds, group.by = 'sampleID',logfc.threshold = 0.25,test.use = "wilcox",min.pct = 0.1,p_val_adj=0.05)
print (head(markers))
top5 <- markers %>% group_by(cluster) %>% top_n(n = 20, wt = avg_log2FC)
write.table(top5,'MonMac.marker.xls',sep='\t',quote=F,col.names=T,row.names=F)
mat<-rds@assays$RNA@data
gene<-c('Hspa1a','Cd81','Jun','Txnip','Cx3cr1','Pf4','Ccl4','Cxcl10','Nfkbia','Ccl3','Isg15','Mmp12','Lpl','Cd36','Prdx1','Mmp19','Pf4','Chil3','Ccl7','Ecm1','Eno1')
index<-match(gene,top5$gene)
mat = as.matrix(mat[top5$gene,])
base_mean = rowMeans(mat)
mat_scaled = t(apply(mat, 1, scale))
newd<-rds@meta.data[order(rds@meta.data$sampleID),]
colnames(mat_scaled)<-row.names(rds@meta.data)
mat_scaled = as.matrix(mat_scaled[,row.names(newd)])
mat_scaled = as.matrix(mat_scaled[top5$gene,])
pdf('MonMac_heatmap.pdf',h=10,w=10)
har = rowAnnotation(foo = anno_mark(at = index, labels = gene))
df=data.frame(sample=newd$sampleID)
hac =  HeatmapAnnotation(df = df, annotation_name_side = "right",col=list(sample=c('D0' = "#E41A1C",'D7'="#658E67",'D14'="#FFD422",'D21'="#F781BF")))
ht_list = Heatmap(mat_scaled, name = "expression",  col = colorRamp2(c(-2, 0, 2), c("#11659A", "white", "#A61B29")),top_annotation = hac, show_column_names = FALSE,show_row_names = FALSE, row_title = NULL, show_row_dend = FALSE,right_annotation = har,cluster_rows = FALSE,cluster_columns = FALSE,row_gap = unit(0, "mm"), column_gap = unit(0, "mm"))
draw(ht_list)
dev.off()