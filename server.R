library(shiny)
library(readr)
library(dplyr)
library(DT)
library(shinydashboard)

shinyServer(function(input, output, session) {
  
  load('./fg.shiny.rda')
  load('./bcg.shiny.rda')
  load('./tan.shiny.rda')
  
  load('./fg.sex.shiny.rda')
  load('./bcg.sex.shiny.rda')
  load('./tan.sex.shiny.rda')
  
  load('./my.bcg.metabolites.rda')
  row.names(fg.shiny1) <- NULL
  row.names(tan.shiny1) <- NULL
  row.names(bcg.shiny1) <- NULL
  
  row.names(tan.sex.shiny) <- NULL
  row.names(bcg.sex.shiny) <- NULL
  row.names(fg.sex.shiny) <- NULL
  
  row.names(my.bcg) <- NULL
  
  is.num <- sapply(fg.shiny1, is.numeric)
  fg.shiny1[is.num] <- lapply(fg.shiny1[is.num], round, 4)
  
  is.num <- sapply(tan.shiny1, is.numeric)
  tan.shiny1[is.num] <- lapply(tan.shiny1[is.num], round, 4)
  
  is.num <- sapply(bcg.shiny1, is.numeric)
  bcg.shiny1[is.num] <- lapply(bcg.shiny1[is.num], round, 4)
  
  xx  = c("ionIdx")
  my.bcg = my.bcg[,!colnames(my.bcg) %in% xx]
  
  colnames(fg.shiny1)[colnames(fg.shiny1) == "Metabolites"] <- "Metabolite"
  colnames(fg.shiny1)[colnames(fg.shiny1) == "Cytokines"] <- "Cytokine"
  
  colnames(tan.shiny1)[colnames(tan.shiny1) == "Metabolites"] <- "Metabolite"
  colnames(tan.shiny1)[colnames(tan.shiny1) == "Cytokines"] <- "Cytokine"
  
  colnames(bcg.shiny1)[colnames(bcg.shiny1) == "Metabolites"] <- "Metabolite"
  colnames(bcg.shiny1)[colnames(bcg.shiny1) == "Cytokines"] <- "Cytokine"
  
  output$DT1 <- renderDT({
    
    datatable(fg.shiny1, options = list(scrollX = TRUE), rownames = FALSE) %>%
      formatStyle("Correlation coefficient", backgroundColor = styleInterval(0, c('#89A5EF', '#DF9692')))
    
  })
  
  DTProxy1 <- dataTableProxy("DT1")
  output$DT2 <- renderDT({
    datatable(tan.shiny1, options = list(scrollX = TRUE), rownames = FALSE) %>%
      formatStyle("Correlation coefficient", backgroundColor = styleInterval(0, c('#89A5EF', '#DF9692')))
  })
  
  DTProxy2 <- dataTableProxy("DT2")
  
  #output$DT3 = renderDT(bcg.shiny1,options = list(scrollX = TRUE))
  output$DT3 <- renderDT({
    datatable(bcg.shiny1, options = list(scrollX = TRUE), rownames = FALSE) %>%
      formatStyle("Correlation coefficient", backgroundColor = styleInterval(0, c('#89A5EF', '#DF9692')))
  })
  
  DTProxy3 <- dataTableProxy("DT3")
  
  colnames(fg.sex.shiny)[colnames(fg.sex.shiny) == "Metabolites"] <- "Metabolite"
  colnames(fg.sex.shiny)[colnames(fg.sex.shiny) == "Cytokines"] <- "Cytokine"
  
  colnames(bcg.sex.shiny)[colnames(bcg.sex.shiny) == "Metabolites"] <- "Metabolite"
  colnames(bcg.sex.shiny)[colnames(bcg.sex.shiny) == "Cytokines"] <- "Cytokine"
  
  colnames(tan.sex.shiny)[colnames(tan.sex.shiny) == "Metabolites"] <- "Metabolite"
  colnames(tan.sex.shiny)[colnames(tan.sex.shiny) == "Cytokines"] <- "Cytokine"
  
  #output$DT4 = renderDT(fg.sex.shiny,options = list(scrollX = TRUE))
  output$DT4 <- renderDT({
    datatable(fg.sex.shiny, options = list(scrollX = TRUE), rownames = FALSE) %>%
      formatStyle("Correlation coefficient", backgroundColor = styleInterval(0, c('#89A5EF', '#DF9692')))
  })
  
  DTProxy4 <- dataTableProxy("DT4")
  #output$DT6 = renderDT(bcg.sex.shiny,options = list(scrollX = TRUE))
  output$DT6 <- renderDT({
    datatable(bcg.sex.shiny, options = list(scrollX = TRUE), rownames = FALSE) %>%
      formatStyle("Correlation coefficient", backgroundColor = styleInterval(0, c('#89A5EF', '#DF9692')))
  })
  
  DTProxy6 <- dataTableProxy("DT6")
  #output$DT7 = renderDT(tan.sex.shiny,options = list(scrollX = TRUE))
  output$DT7 <- renderDT({
    datatable(tan.sex.shiny, options = list(scrollX = TRUE), rownames = FALSE) %>%
      formatStyle("Correlation coefficient", backgroundColor = styleInterval(0, c('#89A5EF', '#DF9692')))
  })
  
  DTProxy7 <- dataTableProxy("DT7")
  
  output$DT5 = renderDT(my.bcg,options = list(scrollX = TRUE))
  DTProxy5 <- dataTableProxy("DT5")
  
  observeEvent(c(input$search, input$tabsetPanelID), {
    updateSearch(DTProxy1, keywords = list(global = input$search, columns = NULL))
    updateSearch(DTProxy2, keywords = list(global = input$search, columns = NULL))
    updateSearch(DTProxy3, keywords = list(global = input$search, columns = NULL))
    updateSearch(DTProxy4, keywords = list(global = input$search, columns = NULL))
    updateSearch(DTProxy5, keywords = list(global = input$search, columns = NULL))
    updateSearch(DTProxy6, keywords = list(global = input$search, columns = NULL))
    updateSearch(DTProxy7, keywords = list(global = input$search, columns = NULL))
  })
  
  
  # 使用 updateSelectizeInput 来设置选项，并开启服务器端模式
 # updateSelectizeInput(session, "selectedNode", choices = c("", unique_metabolites), server = TRUE)
  
  # 定义一个函数来处理每个数据集
  process_dataset <- function(dataset_name) {
    # 加载数据集
    load(paste0("./", dataset_name, ".rda"))
    
    # 获取数据集
    dataset <- get(dataset_name)
    
    # 数据处理
    dataset <- dataset %>%
      filter(P.value < 0.05) %>%
      mutate(to = apply(.[, c("Cytokines", "Stimulus", "Cell system", "Duration")], 1, function(x) paste(x, collapse = "_"))) %>%
      select(Metabolites, Cytokines, Stimulus, to, `Correlation coefficient`, P.value, Cohort) %>%
      rename(from = Metabolites, correlation = `Correlation coefficient`, p_value = P.value)
    
    # 添加颜色列
    dataset$color <- ifelse(dataset$correlation > 0, "#DA4143", "#3976EE")
    
    # 将修改后的数据集保存回环境中
    assign(dataset_name, dataset, envir = .GlobalEnv)
  }
  
  # 数据集名称
  dataset_names <- c("edges_dataset1", "edges_dataset2", "edges_dataset3")
  
  # 对每个数据集应用处理函数
  for (name in dataset_names) {
    process_dataset(name)
  }
  
  render_network <- function(data_name) {
    output <- renderVisNetwork({
      
      hide("loading")  # 使用 shinyjs 隐藏加载指示器
      data <- get(data_name)
      
      # 搜索不区分大小写
      selected_node <- tolower(input$selectedNode)
      selected_cytokine <- tolower(input$selectedCytokine)
      selected_stimulus <- tolower(input$selectedStimulus)
      
      # 定义要展示的代谢物名称列表
      metabolites_to_show <- c('Acetone', 'Citrulline', 'Glycine', 'Itaconate', 'Lactate', 'Urate') # 替换为您想要展示的代谢物名称
      
      # 根据输入条件确定过滤逻辑
      filtered_edges <- if (selected_node == "" && selected_cytokine == "" && selected_stimulus == "") {
        # 没有输入任何内容
        #head(data, 100)
        data[data$from %in% metabolites_to_show, ]
      } else if (selected_node != "") {
        # 根据用户输入的代谢物名称过滤，考虑 Cytokine 和 Stimulus（如果有选择）
        data %>%
          filter(
            (tolower(from) %in% selected_node | tolower(to) %in% selected_node) &
              (selected_cytokine == "" | tolower(Cytokines) == selected_cytokine) &
              (selected_stimulus == "" | tolower(Stimulus) == selected_stimulus)
          )
      } else {
        # 只根据 Cytokine 和/或 Stimulus 过滤
        data %>%
          filter(
            (selected_cytokine == "" | tolower(Cytokines) == selected_cytokine) &
              (selected_stimulus == "" | tolower(Stimulus) == selected_stimulus)
          )
      }
      
      # 构建节点和边
      relevant_nodes <- unique(c(filtered_edges$from, filtered_edges$to))
      nodes <- data.frame(id = relevant_nodes, 
                          label = relevant_nodes, 
                          color = ifelse(grepl("PBMC", relevant_nodes) | grepl("WB", relevant_nodes) | grepl("macroPG", relevant_nodes), "#00D76A", "#F2C045"),
                          shape = ifelse(grepl("PBMC", relevant_nodes) | grepl("WB", relevant_nodes) | grepl("macroPG", relevant_nodes), "box", "ellipse"))
      
      visNetwork(nodes, filtered_edges) %>%
        visNodes(font = list(size = 14)) %>%
        visEdges(arrows = 'to', color = list(color = filtered_edges$color)) %>%
        visOptions(highlightNearest = TRUE, nodesIdSelection = FALSE)%>% 
        visPhysics(stabilization = FALSE)%>%
        visInteraction(navigationButtons = TRUE)
    })
    return(output)
  }
  
  output$networkPlot1 <- render_network("edges_dataset1")
  output$networkPlot2 <- render_network("edges_dataset2")
  output$networkPlot3 <- render_network("edges_dataset3")
  
  # 下载功能
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("combined_data-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      # 获取用户输入
      selected_node <- tolower(input$selectedNode)
      selected_cytokine <- tolower(input$selectedCytokine)
      selected_stimulus <- tolower(input$selectedStimulus)
      
      # 初始化一个空的数据框用于存储合并的数据
      combined_data <- data.frame()
      
      # 遍历数据集进行过滤
      for (name in dataset_names) {
        dataset <- get(name)
        
        # 根据输入条件确定过滤逻辑
        filtered_data <- if (selected_node == "" && selected_cytokine == "" && selected_stimulus == "") {
          # 没有输入任何内容
          head(dataset, 100)
        } else if (selected_node != "") {
          # 根据用户输入的代谢物名称过滤，考虑 Cytokine 和 Stimulus（如果有选择）
          dataset %>%
            filter(
              (tolower(from) %in% selected_node | tolower(to) %in% selected_node) &
                (selected_cytokine == "" | tolower(Cytokines) == selected_cytokine) &
                (selected_stimulus == "" | tolower(Stimulus) == selected_stimulus)
            )
        } else {
          # 只根据 Cytokine 和/或 Stimulus 过滤
          dataset %>%
            filter(
              (selected_cytokine == "" | tolower(Cytokines) == selected_cytokine) &
                (selected_stimulus == "" | tolower(Stimulus) == selected_stimulus)
            )
        }
        
        # 合并到最终的数据框中
        combined_data <- rbind(combined_data, filtered_data)
      }
      
      # 写入文件
      write.csv(combined_data, file, row.names = FALSE)
    }
  )
  
}
)