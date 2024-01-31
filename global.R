library(shiny)
library(readr)
library(dplyr)
library(DT)
library(shinydashboard)
library(visNetwork)
library(shinyjs)
library(shiny)
library(readr)
library(dplyr)
library(DT)
library(shinydashboard)

load('./edges_dataset1.rda')
load('./edges_dataset2.rda')
load('./edges_dataset3.rda')
####################################

unique_metabolites1 <- unique(edges_dataset1$Metabolites)
unique_metabolites2 <- unique(edges_dataset2$Metabolites)
unique_metabolites3 <- unique(edges_dataset3$Metabolites)

# 合并这些名字并去除重复项
all_unique_metabolites <- union(unique_metabolites1, unique_metabolites2)
unique_metabolites <- union(all_unique_metabolites, unique_metabolites3)
unique_metabolites <- unique_metabolites[order(!grepl("^[A-Za-z]", unique_metabolites), unique_metabolites)]

####################################
# 提取每个数据集中的唯一细胞因子名字
unique_cytokines1 <- unique(edges_dataset1$Cytokines)
unique_cytokines2 <- unique(edges_dataset2$Cytokines)
unique_cytokines3 <- unique(edges_dataset3$Cytokines)

# 合并这些名字并去除重复项
all_unique_cytokines <- union(unique_cytokines1, unique_cytokines2)
unique_cytokines <- union(all_unique_cytokines, unique_cytokines3)
unique_cytokines <- unique_cytokines[order(!grepl("^[A-Za-z]", unique_cytokines), unique_cytokines)]

####################################
# 提取每个数据集中的唯一刺激名字
unique_Stimulus1 <- unique(edges_dataset1$Stimulus)
unique_Stimulus2 <- unique(edges_dataset2$Stimulus)
unique_Stimulus3 <- unique(edges_dataset3$Stimulus)

# 合并这些名字并去除重复项
all_unique_Stimulus <- union(unique_Stimulus1, unique_Stimulus2)
unique_Stimulus <- union(all_unique_Stimulus, unique_Stimulus3)
unique_Stimulus <- unique_Stimulus[order(!grepl("^[A-Za-z]", unique_Stimulus), unique_Stimulus)]
# 样例数据
example_metabolites <- c('Acetone','Citrulline','Glycine',"Itaconate", 'Lactate','Urate')
