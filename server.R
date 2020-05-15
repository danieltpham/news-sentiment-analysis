library(tm)
library(httr)
library(dplyr)
library(tidyr)
library(tokenizers)
library(stopwords)
library(syuzhet)
library(ggplot2)
library(magrittr)
library(sentimentr)
library(wordcloud)
library(stringr)

# GLOBAL VARS
key <- 'ec8cfebda55d49c59b87eddf9c5ddd28'
domains <- 'abc.net.au/news,afr.com,news.com.au,theguardian.com,smh.com.au,couriermail.com.au,theage.com.au,dailytelegraph.com.au,9news.com.au,perthnow.com.au'

shinyServer(function(input, output, session) {
    search_term <- reactive({
        sapply(strsplit(input$search_target, ",")[[1]],  
                       function(x) tolower(noquote(x)))
    })
    
    # Helper 1: Classify sentiments
    sentiment_cl <- function(val) {
      if (val<0) {
        return('negative')
      }
      return('positive')
    }
    
    # Helper 2: Word-based Sentiment Analysis
    s_a <- function(txt) {
      # Tokenize
      token <- tokenize_words(txt,
                              stopwords = stopwords()) %>%
        unlist(use.names = FALSE) %>%
        unique()
      
      # Sentiment scoring
      sentiment <- get_sentiment(token)
      score <- sum(sentiment)
      
      # Create DF
      class <- sapply(sentiment, sentiment_cl)
      df <- drop_na(as.data.frame(subset(cbind(token, sentiment, class),
                                              sentiment != 0)))
      colnames(df) <- c('token','sentiment','class')
      df$sentiment <- as.numeric(as.character(df$sentiment))
      df <- arrange(df, sentiment)
      
      return(list("token"=token,
                  "sentiment"=sentiment,
                  "score"=score,
                  "df"=df))
    }
    
    # Helper 3: Plot Word Sentiment Bar Plot
    sentiment_plt <- function(dtf) {
      g <- ggplot(dtf, 
             aes(dtf$token, dtf$sentiment)) + 
        geom_bar(stat="identity", show.legend = FALSE,
                 fill = ifelse(dtf$sentiment < 0, 
                               "tomato",
                               "springgreen")) +
        expand_limits(x = 0, y = 0) +
        theme(axis.title.x=element_blank(),
              axis.title.y=element_blank(),
              axis.ticks.x=element_blank(),
              axis.ticks.y=element_blank(),
              panel.background = element_rect(fill = "transparent",colour = NA),
              plot.background = element_rect(fill = "transparent",colour = NA),) +
        coord_flip()
      return(g)
    }
    
    # Helper 4: Sentence-based (semantic) Analysis
    sen_a <- function(txt) {
      return(sentiment_by(get_sentences(txt))$ave_sentiment)
    }
    
    # Helper 5: Compare Word-based & Sentence-based
    comp_sen <- function(wb, sb, where) {
      if (wb*sb<0) {
        return(paste(' This suggests there may be ambiguities in the wordings of the ',where,'.'))
      }
      else {
        return(paste(' This suggests the word-based sentiment analysis of the ',where,' would probably be correct.'))
      }
    }
    
    ############# MAIN()
    # Init
    cont <- reactiveValues()
    
    observeEvent(input$goButton, {
      # HTTP GET Method
      query <- list("q"=search_term(),
                    "apiKey"=key,
                    "pageSize"="20",
                    "domains"=domains,
                    "sortBy"="publishedAt")
      cont$full_search <- content(GET("http://newsapi.org/v2/everything", query = query),
                                  as="parsed")
      
      ########################### AGGREGATED
      cont$all_title = ''
      cont$all_desc = ''
      cont$all_cont = ''
      
      for (i in 1:cont$full_search$totalResults){
        cont$all_title <- paste(cont$all_title,cont$full_search$articles[i][[1]]$title, sep=". ")
        cont$all_desc <- paste(cont$all_desc,cont$full_search$articles[i][[1]]$description, sep=". ")
        cont$all_cont <- paste(cont$all_cont,cont$full_search$articles[i][[1]]$content, sep=". ")
      }
      
      cont$all_title <- cont$all_title %>%
        str_remove(pattern = "\\.") %>%
        str_remove_all(pattern = " \\. ") %>%
        str_remove_all(pattern = "\\.\\.")
      
      cont$all_desc <- cont$all_desc %>%
        str_remove(pattern = "\\.") %>%
        str_remove_all(pattern = " \\. ") %>%
        str_remove_all(pattern = "\\.\\.")
      
      cont$all_cont <- cont$all_cont %>%
        str_remove(pattern = "\\.") %>%
        str_remove_all(pattern = " \\. ") %>%
        str_remove_all(pattern = "\\.\\.") %>%
        str_remove_all(pattern = "\\[.+\\]")
      
      # Analyse aggregated titles
      title_sa <- s_a(cont$all_title)
      cont$title_token <- title_sa$token
      cont$title_sentiment <- title_sa$sentiment
      cont$title_score <- title_sa$score
      cont$title_df <- title_sa$df
      
      # Analyse aggregated descriptions
      desc_sa <- s_a(cont$all_desc)
      cont$desc_token <- desc_sa$token
      cont$desc_sentiment <- desc_sa$sentiment
      cont$desc_score <- desc_sa$score
      cont$desc_df <- desc_sa$df
      
      # Analyse aggregated contents
      cont_sa <- s_a(cont$all_cont)
      cont$cont_token <- cont_sa$token
      cont$cont_sentiment <- cont_sa$sentiment
      cont$cont_score <- cont_sa$score
      cont$cont_df <- cont_sa$df
      
      # Word Cloud from Description & Title
      cont$agg_df <- rbind(cont$title_df, cont$desc_df)
      cont$agg_pos <- subset(cont$agg_df, class=='positive')
      cont$agg_neg <- subset(cont$agg_df, class=='negative')
      
      ########################### SINGLE ARTICLE
      
      # Get individual article by id
      cont$art <-cont$full_search$articles[1][[1]]
      
      # Analyse individual article
      ind_sa <- s_a(paste(cont$art$description,
                          cont$art$title,
                          cont$art$content, sep=" "))
      cont$id_token <- ind_sa$token
      cont$id_sentiment <- ind_sa$sentiment
      cont$id_score <- ind_sa$score
      cont$id_df <- ind_sa$df
    })
    
    ########################################### SWITCH TABS
    observeEvent(input$switchTab, {
      updateTabsetPanel(session, "nav",selected="Sentiment Analysis")})
    
    ########################################### OUTPUT
    
    # STDOUT GET data
    output$display_title <- renderText({
      cont$art$title
    })
    output$display_desc <- renderText({
      cont$art$description
    })
    output$display_src <- renderUI({
      a(paste(cont$art$source$name),href=paste(cont$art$url))
    })
    output$display_content <- renderText({
      cont$art$content
    })
    
    output$display_aggSent <- renderUI({
      if (input$goButton == 0)
        return()
      txt <- paste(paste0("You've searched for the term: <code>",input$search_target,"</code>"),
              paste0("- There were <code>",cont$full_search$totalResults,"</code> Australian articles for this topic."),
              paste0("- The word-based sentiment score from the <b>titles</b> of these articles is: <code>",round(cont$title_score,2),"</code>. This means that the news titles for this topic are generally ",sentiment_cl(cont$title_score),"."),
              paste0("- The sentence-based semantic score from the <b>titles</b> of these articles is: <code>",round(sen_a(cont$all_title),2),"</code>",comp_sen(cont$title_score,sen_a(cont$all_title),'titles')),
              paste0("- The word-based sentiment score from the <b>descriptions</b> these articles is: <code>",round(cont$desc_score,2),"</code>. This means that the contents for this topic are generally ",sentiment_cl(cont$desc_score),"."),
              paste0("- The sentence-based semantic score from the <b>descriptions</b> of these articles is: <code>",round(sen_a(cont$all_desc),2),"</code>",comp_sen(cont$desc_score,sen_a(cont$all_desc),'descriptions')),
              sep = '<br/><br/>')
      HTML(txt)
      })

    # STDOUT Sentiment Analysis
    
    # Single ID Sentiment Statement
    
    # Single ID Sentiment Plot 
    output$ind_plot <- renderPlot({
        if (input$goButton == 0)
            return()
      #browser()
      # Individual Article Sentiment Plot
      sentiment_plt(cont$id_df)
    }, bg="transparent") 
    
    # Top 100 Topic Wordcloud
    output$top100_wc <- renderPlot({
      if (input$goButton == 0)
        return()
      #browser()
      wordcloud(tokenize_words(paste(cont$all_title, cont$all_desc))[[1]]
                , max.words=100, min.freq=2, scale=c(2.5,.5))
    }, bg="transparent")
    
    # Random 100 Positive Wordcloud
    output$pos_wc <- renderPlot({
      if (input$goButton == 0)
        return()
      wordcloud(cont$agg_pos$token
                , max.words=100, scale=c(2.5,.5), colors=c('springgreen'))
    }, bg="transparent")
    
    # Random 100 Negative Wordcloud
    output$neg_wc <- renderPlot({
      if (input$goButton == 0)
        return()
      wordcloud(cont$agg_neg$token
                , max.words=100, scale=c(2.5,.5), colors=c('tomato'))
    }, bg="transparent")
    
    # Headlines
    output$headlines <- renderPlot({
      if (input$goButton == 0)
        return()
      highlight(sentiment_by(get_sentences(cont$all_title)))
    }, bg="transparent")
})