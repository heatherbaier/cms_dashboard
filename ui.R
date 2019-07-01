shinyUI(navbarPage(" ", theme = "styles.css",
                   
                   tabPanel(h4("Welcome", style = "color: #ffffff;"),
                            
                            mainPanel(width = 11,
                                      
                                      column(10, offset = 1,
                                             
                                              h1(tags$u("CheckMySchool School Neediness Index"), align = "center"),
                                              
                                              h4("This School Neediness Index Map identifies which among 
                                                  the 44,751 public elementary and secondary schools in the 
                                                  country are in need of resources. The index consists of 
                                                  seven variables grouped into three categories: accessibility (remoteness, 
                                                  percentage of students receiving conditional cash transfers);
                                                  amenities (water access, internet access, electricity access); 
                                                  and classroom condition (student-teacher ratio, student-classroom ratio). 
                                                  It made use of DepEd data from the Enhanced Basic Education Information 
                                                  System (E-BEIS), the National School Building Inventory conducted by the 
                                                  Education Facilities Division (EFD), and the Remoteness Index developed 
                                                  by the School Effectiveness Division (SED).", align = "center"),
                                              
                                              h4("Heather Baier and Angela Yost worked on this map and the study on School Neediness Index. 
                                                 They came to the Philippines last May to July 2018 as Summer Fellows of William & Mary’s Global 
                                                 Research Institute.", align = "center"),
                                              
                                              h3(tags$u("Index variables and definitions:"), align = "center"),
                                              
                                              div(tableOutput("variables_table"), align = "center"),
                                             
                                             div(img(src='CMS Logo hi res.jpg', height = 125, width = 350), align = "center"),

                                              div(img(src='ansa_logo.png', height = 100, width = 325), align = "center"),
                                             
                                                     div(img(src='Goalkeepers Logo.jpg', height = 125, width = 340), align = "center"),
                                             
                                             div(img(src='wm_logo1.png', height = 100, width = 200), align = "center")#,
                                             
                                              
                                              # img(src='ansa_logo.png', align = "left", height = 100, width = 325),
                                              # 
                                              # img(src='cms_logo.png', align = "right", height = 100, width = 350)
                                      
                                      )
                                      
                            )
                            
                   ),
                   
                   # tabPanel("About the School Neediness Index",
                   #          
                   #          column(10, offset = 1,
                   #          
                   #          h1("School Neediness Index Methodology", align = "center"),
                   #          
                   #          h1(" "),
                   #          
                   #          h5("The variables in the School Neediness Index were determined based on focus group and 
                   #              individual discussions with school teachers and principals in Guimaras and Rizal.", align = "center"),
                   #          
                   #          h1(" "),
                   #          
                   #          hr(),
                   #          
                   #          fluidRow(
                   #              
                   #              column(10, offset = 1,
                   #                     
                   #                     tableOutput("variables_table")
                   #                     
                   #              )
                   #              
                   #          ),
                   #          
                   #          hr()
                   #          
                   #      )
                   #          
                   # ),
                   
                   tabPanel(h4("School Neediness Index Map", style = "color: #ffffff;"),
                            
                            sidebarLayout(
                                
                                sidebarPanel(
                                    
                                    selectInput('year_map', "School Year", choices = c(2015, 2016, 2017), selected = 2015),
                                    
                                    sliderInput("shi_score_map", "School Neediness Index Score", 0, max(time_series$shi_score),
                                                
                                                value = range(0, max(time_series$shi_score)), step = 0.1),
                                    
                                    sliderInput("stratio_map", "Student Teacher Ratio", min(time_series$Student_Teacher_Ratio), max(time_series$Student_Teacher_Ratio),
                                                
                                                value = range(time_series$Student_Teacher_Ratio), step = 1),
                                    
                                    sliderInput("scratio_map", "Student Classroom Ratio", min(time_series$Student_Classroom_Ratio), max(time_series$Student_Classroom_Ratio),
                                                
                                                value = range(time_series$Student_Classroom_Ratio), step = 1),
                                    
                                    selectInput('water_map', "Access to Water", choices = c(0, 1), multiple = TRUE, selected = c(0, 1)),
                                    
                                    selectInput('internet_map', "Access to Internet", choices = c(0, 1), multiple = TRUE, selected = c(0, 1)),
                                    
                                    selectInput('elec_map', "Access to Electricity", choices = c(0, 1), multiple = TRUE, selected = c(0, 1)),
                                    
                                    sliderInput("ri_map", "Remoteness Index", min(time_series$remoteness_index, na.rm = TRUE), max(time_series$remoteness_index, na.rm = TRUE),
                                                
                                                value = range(time_series$remoteness_index, na.rm = TRUE), step = 100),
                                    
                                    sliderInput("cct_map", "Percentage of Student's Recieving CCT's", min(time_series$cct_percentage, na.rm = TRUE), max(time_series$cct_percentage, na.rm = TRUE),
                                                
                                                value = range(time_series$cct_percentage, na.rm = TRUE), step = 10)
                                    
                                ),
                                
                                mainPanel(
                                    
                                    leafletOutput("map", width = '1150px', height = '850px')
                                    
                                )
                                
                          )
                            
                   ),
                   
                   tabPanel(h4("Data Explorer", style = "color: #ffffff;"),
                            
                            DT::dataTableOutput("timeseries_table")
                            
                   ),
                   
                   tabPanel(h4("School Profiles", style = "color: #ffffff;"),
                            
                            sidebarLayout(
                                
                                sidebarPanel(width = 3,
                                             
                                             #selectInput("school_profile", label = "Choose School", choices = c(as.character(basic$School_Name))),
                                             
                                             #textInput("p_schoolid", label = "Optional: School ID", value = ""),
                                             
                                             selectInput('region_profile', "Choose School Region", choices = c("Select Region" = "", unique(as.character(time_series$Region_Name)
                                             )
                                             )
                                             ),
                                             
                                             conditionalPanel("input.region_profile",
                                                              
                                                              selectInput('division_profile', "Select Division", choices = c("All Divisions" = "")
                                                                          
                                                              )
                                                              
                                             ),
                                             
                                             conditionalPanel("input.division_profile",
                                                              
                                                              selectInput('district_profile', "Select District", choices = c("All Districts" = "")
                                                                          
                                                              )
                                                              
                                             ),
                                             
                                             
                                             conditionalPanel("input.district_profile",
                                                              
                                                              selectInput('school_profile', "Select School", choices = c("All Schools" = "")
                                                                          
                                                              )
                                                              
                                             ),
                                             
                                             hr(),
                                             
                                             helpText("Select a school to see its resources and classroom conditions and how it stacks up to national averages.")#,
                                             
                                             #helpText("If there is more than one school with your selected name, filter to your desired school by entering its School ID from the table to the left.")
                                             
                                ),
                                
                                mainPanel(
                                    
                                    fluidRow(
                                        column(5, style = "background-color: #DCDCDC; border-radius: 5px; height: 500px;",
                                               
                                               div(h4(tags$u("School Neediness Index Data")), align = "center"),
                                               
                                               tableOutput("snitable_profile")
                                               
                                        ),
                                        
                                        column(1, " "),
                                        
                                        column(5, style = "border: 2px solid #DCDCDC; border-radius: 5px; height: 500px;",
                                               
                                               div(h4(tags$u("SNI Data Visualization")), align = "center"),
                                               
                                               div(selectInput('profle_hist_var', ' ', choices = vars), align = "center"),
                                               
                                               plotOutput("profile_hist", height = "300px")
                                               
                                        ),
                                        
                                        column(1)
                                        
                                    ),
                                    
                                    hr(),
                                    
                                    fluidRow(
                                        
                                        column(5, style = "background-color: #DCDCDC; border-radius: 5px; height: 500px;",
                                               
                                               div(h4(tags$u("Basic School Data")), align ="center"),#, style="color:red"),
                                               
                                               tableOutput("p_table2")
                                               
                                        ),
                                        
                                        column(1, " "),
                                        
                                        column(5, style = "border: 2px solid #DCDCDC; border-radius: 5px; height: 500px;",
                                               
                                               div(h4(tags$u("Male to Female Student Ratio")), align ="center"),
                                               
                                               plotOutput("distPie")
                                               
                                        )#columnrowclose
                                        
                                    ),
                                    
                                    hr()#fluidrowclose
                                    
                                )#mainpanelrowclose
                                
                            )#sidebarlayoutclose
                            
                   )
                   
)

)