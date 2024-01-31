library(shiny)
library(readr)
library(dplyr)
library(DT)
library(shinydashboard)
library(visNetwork)
library(shinyjs)

# User interface ----
shinyUI(fluidPage(
  
  # 添加自定义CSS样式
  tags$head(
    tags$style(HTML("
      body > .container-fluid {
        max-width: 1200px; /* 设置最大宽度 */
        margin: auto !important; /* 居中显示 */
      }
    "))
  ),
  
  
 titlePanel(
    fluidRow(
      tags$head(
        tags$style(type = 'text/css',
                   '.navbar { background-color: #3935A0;
                                                                     font-family: Arial;
                                                                     font-size: 20px;font-weight:bold;margin-top:-5px}',
                   '.navbar-nav a{
                     color: #74DD9A !important;
                   }',
                          
        )),
      div(
        HTML('<div style="color:black;font-family:Calibri;font-size:30px;text-align:justify;">
                                                                              <p><b><font size="35px">&nbsp;&nbsp;IMetaboMap</font></b>
                                                                              -&nbsp;<u>I</u>mmnune responses and circular <u>Metabo</u>lic interactions <u>Map</u></p>
                                                                              </div>'),
        p(),
        
        style = "margin-left:15px;margin-right:15px;margin-top:8px"),
      
    ),
    windowTitle = "IMetaboMap" ), 
  
  #div(id="main",
      
  navbarPage(title = "",
             
             tabPanel("Overview", 
                      div(
                        br(),
                        div(
                          div(
                            HTML('<div style="color:black;font-family:Calibri;font-size:20px;text-align:justify;">
                                                                              <p><b>IMetaboMap</b>, is a pioneering resource that catalogs interactions between plasma metabolites and cytokine responses to various stimuli in humans. This tool is instrumental in examining how these interactions differ among various populations, between sexes, and across different cell systems. Our findings in Cohort_EU1 revealed a total of 125,307 metabolite-cytokine associations. In contrast, Cohort_EU2 yielded 28,833 associations, while Cohort_AF added another 80,550, bringing the comprehensive tally to 234,690 unique associations cataloged in IMetaboMap. This tool stands as a testament to our comprehensive approach, enabling detailed exploration of the dynamic relationships between metabolites and cytokines, and shedding light on specific associations that may vary by sex and population.
                                                                              </p>
                                 </div>'),
                            
                            
                            style = "margin-left:15px;margin-right:15px;margin-top:8px"),
                          style = "border:2px dashed #E5F6E1; background-color: #E5F6E1;margin-left:-15px;margin-right:-15px"
                        ),
                        
                        
                        br(),
                        
                        img(src = "imetabomap.workflow.png", width = "100%", style = "width: 90%; display: block; margin: 0 auto;"),
                        
                        br(),
                        div(
                          div(
                            HTML('<div style="color:black;font-family:Calibri;font-size:20px;text-align:left;margin-top:-5px">
                            <p><b>Cohorts’ description</b></p>
                            <p>The first cohort, designated as Cohort_EU1, is part of the Human Functional Genomics Project\'s 500FG cohort and comprises 534 healthy Caucasian individuals, with ages spanning from 18 to 75 years. This cohort was carefully selected to exclude individuals with mixed genetic backgrounds or chronic diseases. Key measurements within Cohort_EU1 included cytokine production in response to various stimulations and comprehensive metabolomic profiling. More detailed information can be found in previous publications (Li et al., 2016). The second cohort from Western Europe, Cohort_EU2, included 324 healthy volunteers of Western European descent, aged 18 to 71 years. These participants were enrolled in the 300BCG cohort from April 2017 to June 2018, with further details documented in previous publication (Koeken et al., 2020). The third cohort, Cohort_AF, encompasses 323 healthy Tanzanians between 18 to 65 years old from the Kilimanjaro region, who were recruited through the Kilimanjaro Christian Medical Center and Lucy Lameck Research Center from March to December 2017, as previously described (Temba et al., 2021). Plasma samples of these donors were obtained and used to measure their circulating metabolites profiles. For the metabolomics analysis, untargeted measurements from plasma samples were conducted using high-throughput flow injection-time-of-flight mass spectrometry (Fuhrer et al., 2011). Blood samples of these donors were also collected and exposed to different stimulators for cytokine profile measurement.</p>
                                                                              </div>'),
                            br(),
                            HTML('<div style="color:black;font-family:Calibri;font-size:20px;text-align:left;margin-top:-5px">
                                                                              <p><font color="black"><b>Citing the article:</b></font></p>
                                                                              <p>Jianbo Fu, Nhan Nguyen, Nienke van Unen, Leo A.B. Joosten, Cheng-Jian Xu, Mihai G. Netea, Yang Li. Deciphering Cross-Cohort Metabolic Signatures of Immune Responses and Their Implications in Disease Pathogenesis.
                                                                              </p></div>'),
                            
                            
                            style = "margin-left:15px;margin-right:15px;margin-top:8px"),
                          style = "border:2px dashed #F6F2F8; background-color: #F6F2F8;margin-left:-15px;margin-right:-15px"
                        ),
                        
                        style="margin-top:-30px")),
             
             tabPanel("Map",
                      sidebarLayout(
                        sidebarPanel(
                          
                          useShinyjs(),  # 初始化 shinyjs
                          
                          # 添加选择Metabolite的下拉框
                          # 添加选择Cytokines的下拉框
                          selectInput("selectedNode", "Search metabolite:", 
                                      choices = c("", unique_metabolites)),
                          
                          #selectizeInput("selectedNode", "Search a Metabolite:", choices = c("", unique_metabolites), multiple = FALSE, options = list(create = TRUE)),
                         # 显示样例代谢物，并添加点击事件
                          div(id = "example-metabolites",
                             span("Example metabolites:", style = "margin-right: 2px;"),  # 添加文字，右侧留有间隔
                             HTML(paste0(
                               sapply(1:length(example_metabolites), function(i) {
                                 metabolite <- example_metabolites[i]
                                 link <- a(href = "#", onclick = sprintf("updateSelectedNode('%s')", metabolite), metabolite)
                                 if (i < length(example_metabolites)) {
                                   paste0(as.character(link), ",")
                                 } else {
                                   as.character(link)
                                 }
                               }),
                               collapse = " "
                             )),
                             style = "margin-top: -20px;"  # 适当的上边距
                         ),
                          
                         # 在Shiny应用的JavaScript部分添加一个新的函数
                         tags$script("
    function updateSelectedNode(metabolite) {
        Shiny.setInputValue('selectedNode', metabolite);
    }
"),
                          p(),
                          
                          # 添加选择Cytokines的下拉框
                          selectInput("selectedCytokine", "Choose cytokine:", 
                                      choices = c("", unique_cytokines)),  # 这里的choices应根据您的实际数据集进行替换
                          
                          # 添加选择Stimulus的下拉框
                          selectInput("selectedStimulus", "Choose stimulus:", 
                                      choices = c("", unique_Stimulus)),  # 这里的choices也应根据您的实际数据集进行替换
                          
                          conditionalPanel(
                            condition = "input.selectedNode != ''",
                            downloadButton("downloadData", "Download correlation data")
                          )
                        ),
                        mainPanel(
                          tabsetPanel(
                            tabPanel("Cohort_EU1", 
                                     div(id = "loading", "Waiting...", style = "position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); font-size: 20px;"),  # 加载指示器
                                     
                                     # 网络图的输出
                                     div(style = "position: relative;",  # 设置相对定位
                                         
                                         visNetworkOutput("networkPlot1"),
                                         # 注释说明，浮动在网络图的右上角
                                         div(
                                           div("Legend:", style = "font-size: 12px;"),
                                           div(
                                             div(span(style = "display: inline-block; width: 10px; height: 2px; background-color: #DA4143; margin-right: 5px;vertical-align: middle;"),
                                                     "Positive correlation", style = "font-size: 10px; color: black;"),
                                             
                                             div(span(style = "display: inline-block; width: 10px; height: 2px; background-color: #3976EE; margin-right: 5px;vertical-align: middle;"),
                                                     "Negative correlation", style = "font-size: 10px; color: black;"),
                                             
                                             div(span(style = "display: inline-block; width: 10px; height: 10px; background-color: #00D76A; border-radius: 50%; margin-right: 5px; vertical-align: middle;"),
                                                 "Cytokine", style = "font-size: 10px; color: black;"),
                                             div(span(style = "display: inline-block; width: 10px; height: 10px; background-color: #F2C045; border-radius: 50%; margin-right: 5px; vertical-align: middle;"),
                                               "Metabolite", style = "font-size: 10px; color: black;")
                                           ),
                                           style = "position: absolute; top: 10px; right: 10px; background-color: #FFF; padding: 10px; border-radius: 5px;"
                                         )
                                     )
                                     ),
                            tabPanel("Cohort_AF", 
                                     # 网络图的输出
                                     div(style = "position: relative;",  # 设置相对定位
                                         visNetworkOutput("networkPlot2"),
                                         # 注释说明，浮动在网络图的右上角
                                         div(
                                           div("Legend:", style = "font-size: 12px;"),
                                           div(
                                             div(span(style = "display: inline-block; width: 10px; height: 2px; background-color: #DA4143; margin-right: 5px;vertical-align: middle;"),
                                                 "Positive correlation", style = "font-size: 10px; color: black;"),
                                             
                                             div(span(style = "display: inline-block; width: 10px; height: 2px; background-color: #3976EE; margin-right: 5px;vertical-align: middle;"),
                                                 "Negative correlation", style = "font-size: 10px; color: black;"),
                                             
                                             div(span(style = "display: inline-block; width: 10px; height: 10px; background-color: #00D76A; border-radius: 50%; margin-right: 5px; vertical-align: middle;"),
                                                 "Cytokine", style = "font-size: 10px; color: black;"),
                                             div(span(style = "display: inline-block; width: 10px; height: 10px; background-color: #F2C045; border-radius: 50%; margin-right: 5px; vertical-align: middle;"),
                                                 "Metabolite", style = "font-size: 10px; color: black;")
                                           ),
                                           style = "position: absolute; top: 10px; right: 10px; background-color: #FFF; padding: 10px; border-radius: 5px;"
                                         )
                                     )),
                            tabPanel("Cohort_EU2", 
                                     # 网络图的输出
                                     div(style = "position: relative;",  # 设置相对定位
                                         visNetworkOutput("networkPlot3"),
                                         # 注释说明，浮动在网络图的右上角
                                         div(
                                           div("Legend:", style = "font-size: 12px;"),
                                           div(
                                             div(span(style = "display: inline-block; width: 10px; height: 2px; background-color: #DA4143; margin-right: 5px;vertical-align: middle;"),
                                                 "Positive correlation", style = "font-size: 10px; color: black;"),
                                             
                                             div(span(style = "display: inline-block; width: 10px; height: 2px; background-color: #3976EE; margin-right: 5px;vertical-align: middle;"),
                                                 "Negative correlation", style = "font-size: 10px; color: black;"),
                                             
                                             div(span(style = "display: inline-block; width: 10px; height: 10px; background-color: #00D76A; border-radius: 50%; margin-right: 5px; vertical-align: middle;"),
                                                 "Cytokine", style = "font-size: 10px; color: black;"),
                                             div(span(style = "display: inline-block; width: 10px; height: 10px; background-color: #F2C045; border-radius: 50%; margin-right: 5px; vertical-align: middle;"),
                                                 "Metabolite", style = "font-size: 10px; color: black;")
                                           ),
                                           style = "position: absolute; top: 10px; right: 10px; background-color: #FFF; padding: 10px; border-radius: 5px;"
                                         )
                                     ))
                          )
                        )
                      )
                      ),
             
             tabPanel("Data", 
                      
                      sidebarLayout(
                        sidebarPanel(
                          textInput('search', "Search whole data", placeholder = "Search ..."),
                          div(
                            div(
                              HTML('<div style="color:black;font-family:Calibri;font-size:15px;text-align:justify;">
                                                                              <p>Example search queries: ADP, IL6, S.aureus, PBMC</p></div>'),
                              style = "margin-left:15px;margin-right:15px;margin-top:8px"),
                            style = "margin-left:-15px;margin-right:-15px"
                          ),
                          # div(
                          #   div(
                          #     HTML('<div style="color:black;font-family:Calibri;font-size:15px;text-align:justify;">
                          #                                                     <p>Cohort_EU1: 458 healthy Europeans (<a href="https://www.sciencedirect.com/science/article/pii/S0092867416314003" style="color:#23439B;" target="view_window;"><i>Cell. 167: 1099-1110, 2016</i></a>; <a href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6022810/" style="color:#23439B;" target="view_window;"><i>Nat Immunol. 19: 776-786, 2018</i></a>; <a href="https://link.springer.com/article/10.1186/s13059-021-02413-z" style="color:#23439B;" target="view_window;"><i>Genome Biol. 22: 1-22, 2021</i></a>);
                          #                                                     </p></div>'),
                          #     HTML('<div style="color:black;font-family:Calibri;font-size:15px;text-align:justify;">
                          #                                                     <p>Cohort_EU2: 323 healthy Europeans (<a href="https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.3001765" style="color:#23439B;" target="view_window;"><i>PLoS Biol. 20: e3001765, 2022</i></a>).
                          #                                                     </p></div>'),
                          #     HTML('<div style="color:black;font-family:Calibri;font-size:15px;text-align:justify;">
                          #                                                     <p>Cohort_AF: 325 healthy Africans (<a href="https://www.nature.com/articles/s41590-021-00867-8" style="color:#23439B;" target="view_window;"><i>Nat Immunol. 22: 287-300, 2021</i></a>).
                          #                                                     </p></div>'),
                          #     style = "margin-left:15px;margin-right:15px;margin-top:8px"),
                          #   style = "margin-left:-15px;margin-right:-15px"
                          # ),
               
                        ),
                        mainPanel(
                          tabsetPanel(id = "tabsetPanelID",
                                      type = "tabs",
                                      
                                      tabPanel("Multi-Population/Multi-cohort/Cell systems", 
                                               br(),
                                               column(12,
                                                      
                                                      div(
                                                        HTML('<div style="color:black;font-family:Calibri;font-size:20px;text-align:center;">
                                                                              <p><b>Cohort_EU1</b></p></div>'),
                                                        style = "margin-left:15px;margin-right:15px;margin-top:8px"),
                                                      
                                                      style="font-family:Calibri;font-size:18px;text-align:center;"),
                                               column(12, DTOutput('DT1')),
                                               br(),
                                               
                                               column(12,
                                                      div(
                                                        hr(style="padding: 0;
                                                                         border: none;
                                                                         height: 1px;
                                                                         background-image: -webkit-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -moz-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -ms-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -o-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         color: #333;
                                                                         text-align: center;"),
                                                        HTML('<div style="color:black;font-family:Calibri;font-size:20px;text-align:center;">
                                                                              <p><b>Cohort_EU2</b></p></div>'),
                                                        style = "margin-left:15px;margin-right:15px;margin-top:8px"),
                                                     
                                                      
                                                      style="font-family:Calibri;font-size:18px;text-align:center;"),
                                               column(12, DTOutput('DT3')),
                                               br(),
                                               column(12,
                                                   
                                                      div(
                                                        hr(style="padding: 0;
                                                                         border: none;
                                                                         height: 1px;
                                                                         background-image: -webkit-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -moz-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -ms-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -o-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         color: #333;
                                                                         text-align: center;"),
                                                        HTML('<div style="color:black;font-family:Calibri;font-size:20px;text-align:center;">
                                                                              <p><b>Cohort_AF</b></p></div>'),
                                                        style = "margin-left:15px;margin-right:15px;margin-top:8px"),
                                                      style="font-family:Calibri;font-size:18px;text-align:center;"),
                                               column(12, DTOutput('DT2'))
                                               
                                      ),
                                      tabPanel("Sex difference", 
                                               br(),
                                               column(12,
                                                      div(
                                                        HTML('<div style="color:black;font-family:Calibri;font-size:20px;text-align:center;">
                                                                              <p><b>Cohort_EU1</b></p></div>'),
                                                        style = "margin-left:15px;margin-right:15px;margin-top:8px"),
                                                      style="font-family:Calibri;font-size:18px;text-align:center;"),
                                               column(12, DTOutput('DT4')),
                                               column(12,
                                                      div(
                                                        hr(style="padding: 0;
                                                                         border: none;
                                                                         height: 1px;
                                                                         background-image: -webkit-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -moz-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -ms-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -o-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         color: #333;
                                                                         text-align: center;"),
                                                        HTML('<div style="color:black;font-family:Calibri;font-size:20px;text-align:center;">
                                                                              <p><b>Cohort_EU2</b></p></div>'),
                                                        style = "margin-left:15px;margin-right:15px;margin-top:8px"),
                                                      style="font-family:Calibri;font-size:20px;text-align:center;"),
                                               column(12, DTOutput('DT6')),
                                               column(12,
                                                      div(
                                                        hr(style="padding: 0;
                                                                         border: none;
                                                                         height: 1px;
                                                                         background-image: -webkit-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -moz-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -ms-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -o-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         color: #333;
                                                                         text-align: center;"),
                                                        HTML('<div style="color:black;font-family:Calibri;font-size:20px;text-align:center;">
                                                                              <p><b>Cohort_AF</b></p></div>'),
                                                        style = "margin-left:15px;margin-right:15px;margin-top:8px"),
                                                      style="font-family:Calibri;font-size:20px;text-align:center;"),
                                               column(12, DTOutput('DT7'))
                                      ),
                                      tabPanel("Metabolites information", 
                                               br(),
                                               DTOutput('DT5'))
                          )
                        )
                        
                      )             
		      ),  
	    
	     tabPanel("Manual",
	              div(
	                br(),
	                div(
	                  div(
	                    
	                    a(id = "part0"), 
	                    br(),
	                    p(strong("Three main sections of the tool"), style = "font-size: 24px;font-family:Calibri;text-align:left;margin-top:-10px;"),
	                    h4(a("1. Overview",href = "#part1"),style = "font-size: 19px;text-align:left;margin-top:0px;"),
	                    h4(a("2. Map",href = "#part2"),style = "font-size: 19px;text-align:left;margin-top:0px;"),
	                    h4(a("3. Data",href = "#part3"),style = "font-size: 19px;text-align:left;margin-top:0px;"), 
	                    h4(a("3.1 Search by metabolite only", href = "#part3.1"),style = "text-indent:1.1em;font-size: 19px;text-align:left;margin-top:0px;"),
	                    h4(a("3.1.1 Results in multi-cohorts", href = "#part3.1.1"),style = "text-indent:2.6em;font-size: 19px;text-align:left;margin-top:0px;"),
	                    h4(a("3.1.2 Results in different sex", href = "#part3.1.2"),style = "text-indent:2.6em;font-size: 19px;text-align:left;margin-top:0px;"),
	                    h4(a("3.1.3 Metabolites’ information", href = "#part3.1.3"),style = "text-indent:2.6em;font-size: 19px;text-align:left;margin-top:0px;"),
	                    
	                    h4(a("3.2 Search by metabolite and cytokine", href = "#part3.2"),style = "text-indent:1.1em;font-size: 19px;text-align:left;margin-top:0px;"),
	                    h4(a("3.2.1 Results in multi-cohorts", href = "#part3.2.1"),style = "text-indent:2.6em;font-size: 19px;text-align:left;margin-top:0px;"),
	                    h4(a("3.2.2 Results in different sex", href = "#part3.2.2"),style = "text-indent:2.6em;font-size: 19px;text-align:left;margin-top:0px;"),
	                    
	                    h4(a("3.3 Search by metabolite, cytokine, and stimulus", href = "#part3.3"),style = "text-indent:1.1em;font-size: 19px;text-align:left;margin-top:0px;"),
	                    h4(a("3.3.1 Results in multi-cohorts", href = "#part3.3.1"),style = "text-indent:2.6em;font-size: 19px;text-align:left;margin-top:0px;"),
	                    h4(a("3.3.2 Results in different sex", href = "#part3.3.2"),style = "text-indent:2.6em;font-size: 19px;text-align:left;margin-top:0px;"),
	                    
	                    h4(a("5. About", href = "#part4"),style = "font-size: 19px;text-align:left;margin-top:0px;"), 
	                    
	                    style = "margin-left:15px;margin-right:15px;margin-top:8px"),
	                  style = "border:2px dashed #FDEBEB; background-color: white;margin-left:-15px;margin-right:-15px"
	                ),
	                br(),
	                div(
	                  a(id = "part1"),
	                  div(
	                    
	                    div(
	                      p(strong("1. Overview"), a(icon("arrow-circle-up"),href = "#part0",style="font-size: 16px;"), style = "font-size: 24px;color: black;text-align:left;margin-top:0px;"),
	                      style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                    ),
	                    
	                    
	                    HTML('
                                                                              <div style="color:black;text-align:left;margin-top:0px;font-size:19px;">
                                                                              <p>Study overview and cohorts information.
                                                                              </p></div>
                                                                              '),
	                    
	                    
	                    style = "border:1px solidwhite;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  
	                  img(src = "Fig.1A.png", width = "60%", style = "display: block;margin-top:20px")
	                  
	                ),
	                tags$hr(style = "border-color:#D9D9D9;margin-top:30px;"),
	                
	                div(
	                  a(id = "part2"),
	                  div(
	                    
	                    div(
	                      p(strong("2. Network"), a(icon("arrow-circle-up"),href = "#part0",style="font-size: 16px;"), style = "font-size: 24px;color: black;text-align:left;margin-top:0px;"),
	                      style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                    ),
	                    
	                    
	                    HTML('
                                                                              <div style="color:black;text-align:left;margin-top:0px;font-size:19px;">
                                                                              <p>Step 1. Either entering the metabolite manually or selecting it from a dropdown box. The network graph shown on the right is based on your search, but of course you can also download the correlation data based on your search.
                                                                              </p></div>
                                                                              '),
	                    
	                    
	                    style = "border:1px solidwhite;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  
	                  img(src = "screencapture.network.step1.png", width = "80%", style = "display: block;margin-top:20px")
	                  
	                ),
	                
	                div(div(
	                    
	                    div(
	                      p(a(icon("arrow-circle-up"),href = "#part0",style="font-size: 16px;"), style = "font-size: 24px;color: black;text-align:left;margin-top:0px;"),
	                      style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                    ),
	                    
	                    
	                    HTML('
                                                                              <div style="color:black;text-align:left;margin-top:0px;font-size:19px;">
                                                                              <p>Step 2. Enter the cytokine yourself or select it from the drop down box.
                                                                              </p></div>
                                                                              '),
	                    
	                    
	                    style = "border:1px solidwhite;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  
	                  img(src = "screencapture.network.step2.png", width = "80%", style = "display: block;margin-top:20px")
	                  
	                ),
	                div(div(
	                  
	                  div(
	                    p(a(icon("arrow-circle-up"),href = "#part0",style="font-size: 16px;"), style = "font-size: 24px;color: black;text-align:left;margin-top:0px;"),
	                    style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  
	                  
	                  HTML('
                                                                              <div style="color:black;text-align:left;margin-top:0px;font-size:19px;">
                                                                              <p>Step 3. Enter the stimulus yourself or select it from the drop down box.
                                                                              </p></div>
                                                                              '),
	                  
	                  
	                  style = "border:1px solidwhite;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                ),
	                
	                img(src = "screencapture.network.step3.png", width = "80%", style = "display: block;margin-top:20px"),
	                HTML('
                                                                              <div style="color:black;text-align:left;margin-top:0px;font-size:19px;">
                                                                              <p><b>Note</b>: If the steps are not followed above, for example, if only cytokines or stimuli are entered, the network graph on the right may take a long time to wait or even get stuck because of the amount of data, and needs to be turned off and re-entered.
                                                                              </p></div>
                                                                              ')
	                ),
	                tags$hr(style = "border-color:#D9D9D9;margin-top:30px;"),
	                
	                div(
	                  
	                  a(id = "part3"),
	                  div(
	                    
	                    div(
	                      p(strong("3. Data"), a(icon("arrow-circle-up"),href = "#part0",style="font-size: 16px;"), style = "font-size: 24px;color: black;text-align:left;margin-top:0px;"),
	                      style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                    ),
	                    
	                    
	                    HTML('
                                                                              <div style="color:black;text-align:left;margin-top:0px;font-size:19px;">
                                                                              <p>The results of associations analysis between plasma metabolites and cytokine responses to various stimuli. Users can search for their target metabolite or cytokine, or both, as explained below for the corresponding results of various combinations of searches. Please wait for a new table to be generated during the search.
                                                                              </p></div>
                                                                              '),
	                    
	                    
	                    style = "border:1px solidwhite;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  
	                  a(id = "part3.1"),
	                  div(id = "intro_main2", class = "simpleDiv",
	                      div(id = "intro_main2", class = "simpleDiv",  
	                          p(strong("3.1 Search by metabolite only"), a(icon("arrow-circle-up"), href = "#part0",style="font-size: 16px;"), style = "font-size: 22px;color: black;margin-top:0px;"),
	                          style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                      ),
	                      style = "border:1px solid white;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  a(id = "part3.1.1"),
	                  div(id = "intro_main2", class = "simpleDiv",
	                      div(id = "intro_main2", class = "simpleDiv",  
	                          p(strong("3.1.1	Results in multi-cohorts"), a(icon("arrow-circle-up"), href = "#part0",style="font-size: 16px;"), style = "font-size: 22px;color: black;margin-top:0px;"),
	                          style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                      ),
	                      p(img(src= "screencapture.ADP.multi.png", width = "80%"), style = "text-align: left;margin-top:10px;"),
	                      style = "border:1px solid white;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  a(id = "part3.1.2"),
	                  div(id = "intro_main2", class = "simpleDiv",
	                      div(id = "intro_main2", class = "simpleDiv",  
	                          p(strong("2.1.2	Results in different sex"), a(icon("arrow-circle-up"), href = "#part0",style="font-size: 16px;"), style = "font-size: 22px;color: black;margin-top:0px;"),
	                          style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                      ),
	                      p(img(src= "screencapture.ADP.sex.png", width = "80%"), style = "text-align: left;margin-top:10px;"),
	                      style = "border:1px solid white;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  a(id = "part3.1.3"),
	                  div(id = "intro_main2", class = "simpleDiv",
	                      div(id = "intro_main2", class = "simpleDiv",  
	                          p(strong("2.1.3 Metabolites’ information"), a(icon("arrow-circle-up"), href = "#part0",style="font-size: 16px;"), style = "font-size: 22px;color: black;margin-top:0px;"),
	                          style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                      ),
	                      p(img(src= "screencapture.ADP.png", width = "80%"), style = "text-align: left;margin-top:10px;"),
	                      style = "border:1px solid white;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  
	                  a(id = "part3.2"),
	                  div(id = "intro_main2", class = "simpleDiv",
	                      div(id = "intro_main2", class = "simpleDiv",  
	                          p(strong("3.2 Search by metabolite and cytokine"), a(icon("arrow-circle-up"), href = "#part0",style="font-size: 16px;"), style = "font-size: 22px;color: black;margin-top:0px;"),
	                          style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                      ),
	                      style = "border:1px solid white;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  a(id = "part3.2.1"),
	                  div(id = "intro_main2", class = "simpleDiv",
	                      div(id = "intro_main2", class = "simpleDiv",  
	                          p(strong("3.2.1	Results in multi-cohorts"), a(icon("arrow-circle-up"), href = "#part0",style="font-size: 16px;"), style = "font-size: 22px;color: black;margin-top:0px;"),
	                          style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                      ),
	                      p(img(src= "screencapture.ADP.IL6.multi.png", width = "80%"), style = "text-align: left;margin-top:10px;"),
	                      style = "border:1px solid white;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  a(id = "part3.2.2"),
	                  div(id = "intro_main2", class = "simpleDiv",
	                      div(id = "intro_main2", class = "simpleDiv",  
	                          p(strong("3.2.2	Results in different sex"), a(icon("arrow-circle-up"), href = "#part0",style="font-size: 16px;"), style = "font-size: 22px;color: black;margin-top:0px;"),
	                          style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                      ),
	                      p(img(src= "screencapture.ADP.IL6.sex.png", width = "80%"), style = "text-align: left;margin-top:10px;"),
	                      style = "border:1px solid white;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  
	                  a(id = "part3.3"),
	                  div(id = "intro_main2", class = "simpleDiv",
	                      div(id = "intro_main2", class = "simpleDiv",  
	                          p(strong("3.3 Search by metabolite, cytokine, and stimulus"), a(icon("arrow-circle-up"), href = "#part0",style="font-size: 16px;"), style = "font-size: 22px;color: black;margin-top:0px;"),
	                          style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                      ),
	                      style = "border:1px solid white;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  a(id = "part3.3.1"),
	                  div(id = "intro_main2", class = "simpleDiv",
	                      div(id = "intro_main2", class = "simpleDiv",  
	                          p(strong("3.3.1	Results in multi-cohorts"), a(icon("arrow-circle-up"), href = "#part0",style="font-size: 16px;"), style = "font-size: 22px;color: black;margin-top:0px;"),
	                          style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                      ),
	                      p(img(src= "screencapture.ADP.IL6.SA.png", width = "80%"), style = "text-align: left;margin-top:10px;"),
	                      style = "border:1px solid white;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  a(id = "part3.3.2"),
	                  div(id = "intro_main2", class = "simpleDiv",
	                      div(id = "intro_main2", class = "simpleDiv",  
	                          p(strong("3.3.2	Results in different sex"), a(icon("arrow-circle-up"), href = "#part0",style="font-size: 16px;"), style = "font-size: 22px;color: black;margin-top:0px;"),
	                          style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                      ),
	                      p(img(src= "screencapture.ADP.IL6.SA.sex.png", width = "80%"), style = "text-align: left;margin-top:10px;"),
	                      style = "border:1px solid white;background-color: white;color: black; font-weight:normal;font-style:normal;"
	                  )
	                  
	                  
	                  
	                ),
	                
	                tags$hr(style = "border-color:#D9D9D9;margin-top:30px;"),
	                
	                div(
	                  
	                  a(id = "part4"), 
	                  div(
	                    p(strong("5. About"), a(icon("arrow-circle-up"),href = "#part0",style="font-size: 16px;"), style = "font-size: 24px;color: black;text-align:left;margin-top:0px;"),
	                    HTML('
                                                                              <div style="color:black;text-align:left;margin-top:0px;font-size:19px;">
                                                                              <p>Supplementary information concerning the contact references and data release platforms.
                                                                              </p></div>
                                                                              '),
	                    style = "background-color:white;color: black; font-weight:normal;font-style:normal;"
	                  ),
	                  
	                  style = "margin-left:15px;margin-right:15px;margin-top:8px"),
	                style="margin-top:-30px")
	     ),
	     tabPanel("About",
	              
	              
	              
	              div(
	                
	                
	                # 
	                tags$ul(
	                  
	                  fluidRow(
	                    column(6,
	                           HTML('<p align="center"><img src="HZI.png" width="100%"></p>') 
	                           ,style="font-family:Calibri;font-size:20px;text-align:center;"),
	                    column(6,
	                           HTML('<p align="center"><img src="CiiM.png" width="60%"></p>') 
	                           ,style="font-family:Calibri;font-size:20px;text-align:center;")
	                  ),
	                  
	                  hr(style="padding: 0;
                                                                         border: none;
                                                                         height: 1px;
                                                                         background-image: -webkit-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -moz-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -ms-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -o-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         color: #333;
                                                                         text-align: center;"),
	                  
	                  HTML('<p style="font-family:Calibri;font-size: 25px;text-align:center;">Please feel free to visit our website at <a href="https://lab-li.ciim-hannover.de/" style="color:#2571B3;" target="view_window;"><i>https://lab-li.ciim-hannover.de/</i></a></p>'),
	                  
	                 
	                  hr(style="padding: 0;
                                                                         border: none;
                                                                         height: 1px;
                                                                         background-image: -webkit-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -moz-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -ms-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         background-image: -o-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.75), rgba(0,0,0,0));
                                                                         color: #333;
                                                                         text-align: center;"),
	                  #br(""),
	                  fluidRow(
	                    column(4,
	                           div(
	                             HTML('<div style="color:black;font-family:Calibri;font-size:30px;text-align:center;">
                                                                              <p>Contacts</p></div>'),
	                             style = "margin-left:15px;margin-right:15px;margin-top:8px"),
	                    #HTML('<p align="center"><img src="contact_2.png" width="30%"></p>
                      #                                                                <p style="font-size:22px;color:#F6A24D;text-align:center;"><b>Email</b></p>'),
	                           column(12,
	                                  p(a("Dr. Jianbo Fu", href = "mailto:jian-bo.fu@helmholtz-hzi.de", target = "_blank", style = "color:#2571B3;")),
	                                  p(a("Prof. Chenjian Xu", href = "mailto:Xu.Chengjian@mh-hannover.de", target = "_blank", style = "color:#2571B3;")),
	                                  p(a("Prof. Mihai G. Netea* ", href = "mailto:Mihai.Netea@radboudumc.nl", target = "_blank", style = "color:#2571B3;")),
	                                  (HTML('<p><a href="mailto:yang.li@helmholtz-hzi.de" target="_blank">Prof. Yang Li* </a></p>')) 
	                                  ,style="font-family:Calibri;font-size:20px;text-align:center;")),
	                    
	                    
	                    column(4, 
	                           
	                           div(
	                             HTML('<div style="color:black;font-family:Calibri;font-size:30px;text-align:center;">
                                                                              <p>Resources</p></div>'),
	                             style = "margin-left:15px;margin-right:15px;margin-top:8px"),
	                           column(12,
	                                  p(a("Human Functional Genomics Projects", href = "http://www.humanfunctionalgenomics.org/site/", target = "_blank", style = "color:#2571B3;"), style = "color:black;"),
	                                  p(a("NOREVA", href = "https://github.com/idrblab/NOREVA", target = "_blank", style = "color:#2571B3;"), style = "color:black;"),
	                                  p(a("MetaboAnalyst", href = "https://www.metaboanalyst.ca/", target = "_blank", style = "color:#2571B3;"), style = "color:black;"),
	                                  p(a("UniProt", href = "http://www.uniprot.org/", target = "_blank", style = "color:#2571B3;"), style = "color:black;")
	                                  #p(a("CiiM", href = "https://www.ciim-hannover.de/de/forschung/forschungsgruppen/gruppe-yang-li/", target = "_blank", style = "color:#2571B3;"), style = "color:black;"),
	                                  #p(a("Helmholtz-HZI", href = "https://www.helmholtz-hzi.de/en/research/research-topics/immune-response/computational-biology-for-individualised-medicine/our-research/", target = "_blank", style = "color:#2571B3;"), style = "color:black;")
	                                  
	                                  ,style="font-family:Calibri;font-size:20px;text-align:center;")),
	                    
	                    column(4, 
	                           div(
	                             HTML('<div style="color:black;font-family:Calibri;font-size:30px;text-align:center;">
                                                                              <p>Address</p></div>'),
	                             style = "margin-left:15px;margin-right:15px;margin-top:8px"),
	                           column(12,p(a("Centre for Individualised Infection Medicine (CiiM)", href = "https://www.ciim-hannover.de", target = "_blank", style = "color:#2571B3;"), style = "color:black;"),
	                                  #p("Helmholtz Centre for Infection Research,"), 
	                                  p(a("Helmholtz Centre for Infection Research", href = "https://www.helmholtz-hzi.de/en/research/research-topics/immune-response/computational-biology-for-individualised-medicine/our-research/", target = "_blank", style = "color:#2571B3;"), style = "color:black;"),
	                                  p("Hannover, Germany"),
	                                  p("Postal Code: 30625"), style="font-family:Calibri;font-size:20px;text-align:center;"))
	                    
	                    # column(3,HTML('<p align="center"><img src="contact_3.png" width="50%"></p>
	                    #               <p style="font-size: 22px;color:#F6A24D;text-align:center;"><b>Phone/Fax</b></p>'),
	                    #        column(12,"+0511220027226",style="font-family:Calibri;font-size:20px;text-align:center;"))
	                    
	                  )
	                  
	                  ),
	                
	                style="margin-left:-15px;margin-right:-15px;text-align:center;"
	                
	              )
	              
	              
	     ),
	     ),
  #style = "padding-bottom:100px;background-color: white;" ),
  
  div(id="footer",
      div(source("./page_tail.R", local=T)$value,
        style = "margin-top:100px")

  ),
  
	)
)


