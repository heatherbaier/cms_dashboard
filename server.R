shinyServer(function(input, output, session) {
    
    
# SNI Methodology Table ---------------------------------------------------
    output$variables_table <- renderTable(methodology, colnames = TRUE, striped = TRUE, hover = TRUE, align = "c")
    
# Time Series Map ---------------------------------------------------------
    mapdata_react <- reactive({
        time_series <- time_series[time_series$School_Year == input$year_map,]
        time_series <- subset(time_series, shi_score >= input$shi_score_map[1] & shi_score <= input$shi_score_map[2])
        
        # time_series <- filter(time_series, shi_score >= input$shi_score_map[1] & shi_score <= input$shi_score_map[2])
        time_series <- subset(time_series, Student_Teacher_Ratio >= input$stratio_map[1] & Student_Teacher_Ratio <= input$stratio_map[2])
        time_series <- subset(time_series, Student_Classroom_Ratio >= input$scratio_map[1] & Student_Classroom_Ratio <= input$scratio_map[2])
        time_series <- time_series[time_series$Original_Water_Boolean %in% input$water_map,]
        time_series <- time_series[time_series$Original_Internet_Boolean %in% input$internet_map,]
        time_series <- time_series[time_series$Original_Electricity_Boolean %in% input$elec_map,]
        time_series <- subset(time_series, remoteness_index >= input$ri_map[1] & remoteness_index <= input$ri_map[2])
        time_series <- subset(time_series, cct_percentage >= input$cct_map[1] & cct_percentage <= input$cct_map[2])
        time_series
    })
    
    output$map <- renderLeaflet({
        leaflet(data = mapdata_react()) %>%
            clearMarkerClusters() %>%
            addTiles(
                urlTemplate = 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}{r}.png',
                attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
            ) %>%
            setView(lat = 12.8797, lng = 122.7740, zoom = 6) %>%
            addMarkers(
                clusterOptions = markerClusterOptions(), popup = ~paste("<b>School Name:</b>", time_series$School_Name, "<br/>",
                                                                        "<b>School ID:</b>", time_series$School_ID, "<br/>",
                                                                        "<b>School Neediness Score:</b>", time_series$shi_score, "<br/>",
                                                                        "<b>Student Teacher Ratio:</b>", time_series$Student_Teacher_Ratio, "<br/>",
                                                                        "<b>Student Classroom Ratio:</b>", time_series$Student_Classroom_Ratio, "<br/>",
                                                                        "<b>Water Access:</b>", time_series$Original_Water_Boolean, "<br/>",
                                                                        "<b>Internet Access:</b>", time_series$Original_Internet_Boolean, "<br/>",
                                                                        "<b>Electricity Access:</b>", time_series$Original_Electricity_Boolean, "<br/>",
                                                                        "<b>Remoteness Index:</b>", time_series$remoteness_index, "<br/>",
                                                                        "<b>CCT Percentage:</b>", time_series$cct_percentage, "<br/>")
            )
    })
    
    
    
# Time Series Data Table --------------------------------------------------
    output$timeseries_table <- DT::renderDataTable(DT::datatable(data = ts_clean, options = list(autoWidth = FALSE), filter = "top"))
    
    
# School Profiles ---------------------------------------------------------

    observe({
        time_series <- time_series[time_series$Region_Name == input$region_profile,]
        updateSelectInput(session, "division_profile", choices = c("All Divisions" = "", sort(unique(as.character(time_series$Division_Name)))))
    })
    
    
    observe({
        if (input$division_profile != "") {
            time_series <- time_series[time_series$Region_Name == input$region_profile,]
            time_series <- time_series[time_series$Division_Name == input$division_profile,]
            updateSelectInput(session, "district_profile", choices = c("All Districts" = "",  sort(unique(as.character(time_series$District_Name)))))
        }
    })
    
    observe({
        if (input$district_profile != "") {
            time_series <- time_series[time_series$Region_Name == input$region_profile,]
            time_series <- time_series[time_series$Division_Name == input$division_profile,]
            time_series <- time_series[time_series$District_Name == input$district_profile,]
            updateSelectInput(session, "school_profile", choices = c("All Schools" = "",  sort(unique(as.character(time_series$School_Name)))))
        }
    })
    
    
# Profiles: SNI Table -----------------------------------------------------
    profile_data_react <- reactive({
        basic <- basic[basic$Region_Name == input$region_profile,]
        basic <- basic[basic$Division == input$division_profile,]
        basic <- basic[basic$District == input$district_profile,]
        basic <- basic[basic$School_Name_y == input$school_profile,]
        basic <- basic[profile_vars]
        basic <- basic[basic$School_Name_y == as.character(input$school_profile),]
        basic <- setNames(basic, c(
            'School Name',
            "School ID",
            "Region",
            "Division",
            "District",
            'SNI Score',
            'Remoteness Index',
            'CCT Percentage',
            'Student Teacher Ratio',
            'Student Classroom Ratio',
            'Water Access',
            'Internet Access',
            'Electricity Access'
        ))
        basic <- as.data.frame(t(basic))
        basic <- tibble::rownames_to_column(basic, "Variable")
    })
    
    output$snitable_profile <- renderTable({
        profile_data_react()
    })
    
    
    
    
    hist_data_react <- reactive({
        basic <- basic[basic$Region_Name == input$region_profile,]
        basic <- basic[basic$Division == input$division_profile,]
        basic <- basic[basic$District == input$district_profile,]
        basic <- basic[basic$School_Name_y == input$school_profile,]
        basic <- basic[profile_vars]
    })
    
    
    
# Profiles: Histogram -----------------------------------------------------
    output$profile_hist <- renderPlot({
        mv <- time_series[time_series$Region_Name == input$region_profile,]
        mv <- mv[mv$Division_Name == input$division_profile,]
        mv <- mv[mv$District_Name == input$district_profile,]
        mv <- mv[mv$School_Name == input$school_profile,]
        
        if (input$profle_hist_var == 'shi_score') {
            hist_var = basic$shi_score
            xlim_var = c(0.001946283,1.501641408)
            breaks_var = 50
            mv <- mv$shi_score
            xlabel <- "School Neediness Index"
        }
        else if (input$profle_hist_var == 'cct_percentage') {
            hist_var = basic$cct_percentage
            xlim_var = c(0,100)
            breaks_var = 40
            mv <- mv$cct_percentage
            xlabel <- "Percentage of Students Recieving Conditional Cash Transfers"
            
        }
        else if (input$profle_hist_var == 'remoteness_index') {
            hist_var = basic$remoteness_index
            xlim_var = c(-800,1000)
            breaks_var = 160
            mv <- mv$remoteness_index
            xlabel <- "Remoteness Index"
            
        }
        else if (input$profle_hist_var == 'Student_Teacher_Ratio') {
            hist_var = basic$Student_Teacher_Ratio
            xlim_var = c(0,250)
            breaks_var = 120
            mv <- mv$Student_Teacher_Ratio
            xlabel <- "Student Teacher Ratio"
            
        }
        else if (input$profle_hist_var == 'Student_Classroom_Ratio') {
            hist_var = basic$Student_Classroom_Ratio
            xlim_var = c(0,250)
            breaks_var = 120
            mv <- mv$Student_Classroom_Ratio
            xlabel <- "Student Classroom Ratio"
            
        }
        else if (input$profle_hist_var == 'Water_Access') {
            hist_var = basic$Original_Water_Boolean
            xlim_var = c(0,1)
            breaks_var = 2
            mv <- mv$Original_Water_Boolean
            xlabel <- "Water Access"
            
        }
        else if (input$profle_hist_var == 'Electricity_Access') {
            hist_var = basic$Original_Electricity_Boolean
            xlim_var = c(0,1)
            breaks_var = 2
            mv <- mv$Original_Electricity_Boolean
            xlabel <- "Electricity Access"
            
        }
        else if (input$profle_hist_var == 'Internet_Access') {
            hist_var = basic$Original_Internet_Boolean
            xlim_var = c(0,1)
            breaks_var = 2
            mv <- mv$Original_Internet_Boolean
            xlabel <- "Internet Access"
            
        }
        else {
            hist_var = basic$cct_percentage
            xlim_var = c(0,1000)
            breaks_var = 50
            mv <- mv$cct_percentage
            xlabel <- "Percentage of Students Recieving Conditional Cash Transfers"
            
        }

        hist(hist_var,
             xlim = xlim_var,
             breaks = breaks_var,
             col = "#1C307E",
             xlab = input$profle_hist_var,
             main = xlabel#,
             # xlab = xlabel
            )
        #abline(v = mv, col="red", lwd = 5)
    })
    
    
    
# Profiles: Gender Pie Chart ----------------------------------------------
    pie_react <- reactive({
        if (input$school_profile != "") {
            
            basic <- basic[basic$Region_Name == input$region_profile,]
            basic <- basic[basic$Division == input$division_profile,]
            basic <- basic[basic$District == input$district_profile,]
            basic <- basic[basic$School_Name_y == input$school_profile,]

            basic <- c(basic$Total_Female, basic$Total_Male)
        } else {
            basic <- c(50, 50)
        }
        
    })
    
    output$distPie <- renderPlot({
        pie(pie_react(), labels = c("Female", "Male"), col = c('#e6a6c7', '#347dc1'))#, radius = 4)#, main, col, clockwise)
    })
    
    
# Profiles: Basic Data Chart ----------------------------------------------
    basic_data_react <- reactive({
        basic_vars <- c(
            "School_Name_y",
            "Province",
            "Municipality",
            "Region_Name",
            "District",
            "Division",
            "Year_Established",
            "Elementary_Classification",
            "Night_Classes",
            "Implermenting_Unit",
            "Total_Enrollment_x",
            "Total_Teachers",
            "Total_Female",
            "Total_Male"
        )
        

        basic <- basic[basic_vars]
        basic <- basic[basic$Region_Name == input$region_profile,]
        basic <- basic[basic$Division == input$division_profile,]
        basic <- basic[basic$District == input$district_profile,]
        basic <- basic[basic$School_Name == input$school_profile,]
        basic <- setNames(basic, c("School Name",
                                   'Province',
                                   'Municipality',
                                   'Region',
                                   'District',
                                   'Division',
                                   'Year Established',
                                   'Elementary Classification',
                                   'Night Classes',
                                   'Implermenting Unit',
                                   'Total Enrollment',
                                   'Total Teachers',
                                   'Total Female',
                                   'Total Male'))
        
        
        basic <- as.data.frame(t(basic))
        basic <- tibble::rownames_to_column(basic, "Variable")
        basic
        
    })
    
    output$p_table2 <- renderTable(basic_data_react(), colnames = FALSE)
    
    
    output$school_select_map <- renderLeaflet({
        basic <- basic[basic$Region_Name == input$region_profile,]
        basic <- basic[basic$Division == input$division_profile,]
        basic <- basic[basic$District == input$district_profile,]
        basic <- basic[basic$School_Name == input$school_profile,]
        
        leaflet(data = basic) %>%
            clearMarkerClusters() %>%
            # addTiles(
            #     urlTemplate = 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}{r}.png',
            #     attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
            # ) %>%
            addTiles() %>%
            # setView(lat = 12.8797, lng = 122.7740, zoom = 6) %>%
            addCircleMarkers()
        
    })
    
})