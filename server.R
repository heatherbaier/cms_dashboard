shinyServer(function(input, output, session) {


# SNI Methodology Table ---------------------------------------------------
    output$variables_table <- renderTable(methodology, colnames = TRUE, striped = TRUE, hover = TRUE, align = "c")
    
# Time Series Map ---------------------------------------------------------
    mapdata_react <- reactive({
        time_series <- time_series[time_series$School_Year == input$year_map,]
        time_series <- filter(time_series, shi_score >= input$shi_score_map[1] & shi_score <= input$shi_score_map[2])
        time_series <- filter(time_series, Student_Teacher_Ratio >= input$stratio_map[1] & Student_Teacher_Ratio <= input$stratio_map[2])
        time_series <- filter(time_series, Student_Classroom_Ratio >= input$scratio_map[1] & Student_Classroom_Ratio <= input$scratio_map[2])
        time_series <- time_series[time_series$Original_Water_Boolean %in% input$water_map,]
        time_series <- time_series[time_series$Original_Internet_Boolean %in% input$internet_map,]
        time_series <- time_series[time_series$Original_Electricity_Boolean %in% input$elec_map,]
        time_series <- filter(time_series, remoteness_index >= input$ri_map[1] & remoteness_index <= input$ri_map[2])
        time_series <- filter(time_series, cct_percentage >= input$cct_map[1] & remoteness_index <= input$cct_map[2])
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
                       clusterOptions = markerClusterOptions()
                       )
    })
    


# Time Series Data Table --------------------------------------------------
    output$timeseries_table <- DT::renderDataTable(DT::datatable(data = ts_clean, options = list(autoWidth = FALSE), filter = "top"))


# School Profiles ---------------------------------------------------------
    

# Update Select Inputs ----------------------------------------------------
    # observe({
    #     districts <- if (is.null(input$region_profile)) {
    #         character(0) } else {
    #             filter(time_series, Region_Name %in% input$region_profile) %>%
    #                 `$`(`District_Name`) %>%
    #                     unique() %>%
    #                         sort()
    #         }
    #     stillSelected <- isolate(input$district_profile[input$district_profile %in% districts])
    #     updateSelectInput(session, "district_profile", choices = districts,
    #                       selected = stillSelected)
    # })
    # 
    # 
    # observe({
    #     schools <- if (is.null(input$region_profile)) {
    #         character(0) } else {
    #             time_series %>% 
    #                 filter(Region_Name %in% input$region_profile,
    #                                    is.null(input$district_profile) | District_Name %in% input$district_profile) %>%
    #                 `$`('School_Name') %>%
    #                     unique() %>%
    #                         sort()
    #         }
    #         stillSelected <- isolate(input$school_profile[input$school_profile %in% schools])
    #         updateSelectInput(session, "school_profile", choices = schools, selected = stillSelected)
    # })
    
    
    observe({
        
        time_series <- time_series[time_series$Region_Name == input$region_profile,]
        
        updateSelectInput(session, "division_profile", choices = unique(time_series$Division_Name))
        
    })
    
    
    observe({
        
        #time_series <- filter(time_series, Region_Name == input$region_profile & District_Name == input$district_profile)
        
        #time_series <- filter(time_series, Region_Name == input$region_profile & District_Name == input$district_profile)
        
        time_series <- time_series[time_series$Region_Name == input$region_profile,]
        
        time_series <- time_series[time_series$Division_Name == input$division_profile,]

        updateSelectInput(session, "district_profile", choices = unique(time_series$District_Name))
        
    })
    
    observe({
        
        #time_series <- filter(time_series, Region_Name == input$region_profile & District_Name == input$district_profile)
        
        time_series <- time_series[time_series$Region_Name == input$region_profile,]
        
        time_series <- time_series[time_series$Division_Name == input$division_profile,]
        
        time_series <- time_series[time_series$District_Name == input$district_profile,]
        
        updateSelectInput(session, "school_profile", choices = unique(time_series$School_Name))
        
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
        
        
        # validate(
        #     
        #     need(dim(), paste("Reports and data cannot be downloaded for", indicator_key(), sep = " "))
        # 
        #     )
        
        
        profile_data_react()
    })
    
    

# Profiles: Histogram -----------------------------------------------------
    output$profile_hist <- renderPlot({
        
        #hist_var <- input$profle_hist_var
        
        if (input$profle_hist_var == 'shi_score') {
            hist_var = basic$shi_score
            xlim_var = c(0.001946283,1.501641408)
            breaks_var = 50
            #lines_var1 = c(basic$shi_score, basic$shi_score)
            #lines_var2 = c(0,500)
        }
        else if (input$profle_hist_var == 'cct_percentage') {
            hist_var = basic$cct_percentage
            xlim_var = c(0,100)
            breaks_var = 40
        }
        else if (input$profle_hist_var == 'remoteness_index') {
            hist_var = basic$remoteness_index
            xlim_var = c(-800,1000)
            breaks_var = 160
        }
        else if (input$profle_hist_var == 'Student_Teacher_Ratio') {
            hist_var = basic$Student_Teacher_Ratio
            xlim_var = c(0,250)
            breaks_var = 120
        }
        else if (input$profle_hist_var == 'Student_Classroom_Ratio') {
            hist_var = basic$Student_Classroom_Ratio
            xlim_var = c(0,250)
            breaks_var = 120
        }
        else if (input$profle_hist_var == 'Water_Access') {
            hist_var = basic$Original_Water_Boolean
            xlim_var = c(0,1)
            breaks_var = 2
        }
        else if (input$profle_hist_var == 'Electricity_Access') {
            hist_var = basic$Original_Electricity_Boolean
            xlim_var = c(0,1)
            breaks_var = 2
        }
        else if (input$profle_hist_var == 'Internet_Access') {
            hist_var = basic$Original_Internet_Boolean
            xlim_var = c(0,1)
            breaks_var = 2
        }
        else {
            hist_var = basic$cct_percentage
            xlim_var = c(0,1000)
            breaks_var = 50
        }
        
        hist(hist_var,
             #probability = TRUE,
             xlim = xlim_var,
             breaks = breaks_var,
             abline(v=mean(time_series), col = "red"),
             col="blue",
             xlab = "Remoteness",
             main = "hayhayhayay"
        )
        #lines(c(200,200), c(0,2000), col = "red", lwd = 4)
        #lines(lines_var1, lines_var2, col = "red", lwd = 4)
    })
    
    

# Profiles: Gender Pie Chart ----------------------------------------------
    pie_react <- reactive({
        #basic <- basic[basic$School_Name == as.character(input$school_profile),]
        if (input$school_profile != "") {
            
            basic <- basic[basic$School_Name == as.character(input$school_profile),]
            
            #basic <- c(basic$Total_Female, basic$Total_Male)
            
            basic <- c(basic$Total_Female, basic$Total_Male)

        } else {
            
            basic <- c(50, 50)
            
        }
        
        #basic <- c(basic$Total_Female, basic$Total_Male)
        
        #basic <- c(basic$Total_Female, basic$Total_Male)
    })
    
    output$distPie <- renderPlot({
        #par(bg = "#DCDCDC")
        pie(pie_react(), labels = c("Female", "Male"), col = c('#e6a6c7', '#347dc1'))#, radius = 4)#, main, col, clockwise)
    })
    

# Profiles: Basic Data Chart ----------------------------------------------
    basic_data_react <- reactive({
        basic_vars <- c(
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
        
        basic <- basic[basic$School_Name == as.character(input$school_profile),]
        
        if (input$p_schoolid != "") {
            basic <- basic[basic$School_ID == as.integer(input$p_schoolid),]
        }
        
        basic <- basic[basic_vars]
        
        basic <- setNames(basic, c('Province',
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
        #basic$Variable <- profile_vars
        #colnames(sni) <- c("Variable", "Data")
        #colnames(sni)[1] <- "Variable"
    })
    
    output$p_table2 <- renderTable(basic_data_react(), colnames = FALSE)

    
    
    
})
