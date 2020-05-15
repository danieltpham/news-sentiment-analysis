library(shiny)
library(shinythemes)

shinyUI(
  
  navbarPage("News Sentiment Analysis", id="nav"
             , collapsible = TRUE, inverse = TRUE, theme = shinytheme("united"),
             tabPanel("FAQ",
                      fluidPage(
                        fluidRow(
                          column(2),
                          column(8,
                                 HTML('<h3>What is Sentiment Analysis?</h3>
<p><strong>Sentiment analysis</strong> is the interpretation and classification of emotions (<span style="color: #339966;">positive</span>, <span style="color: #800000;">negative</span> and neutral) within text data using text analysis techniques.</p>
<img width="100%" src="example1.jpg"></img>
<p>&nbsp;</p>
<p><strong>Word-based sentiment score</strong> only analyses individual words; for example: the phrase <em>not not good</em>&nbsp;will have a negative score because there are 2 negative words in the phrase and only 1 positive word. <strong>Sentence-based semantic score</strong> also considers the semantic meaning, so <em>not not good</em>&nbsp;will have a positive score because of the double-negative grammar.</p>'),
actionButton("switchTab", " Try it out", icon("paper-plane"), 
             style="background-color: #5c2040; border: none; margin: 0 65% 0 45%;"),
HTML('
<h3>What is this web app for?</h3>
<p>This web app applies both word-based and sentence-based Sentiment Analysis to <strong>identify emotions from news articles about a topical issue</strong> from Australian news sources such as Sydney Morning Herald, The Age, and The Herald Sun.</p>
<p>Although sentence-based analysis is theoretically better than word-based analysis, it requires a longer text in order to analyse. This drawback prevents it from being a good technique to analyse short text data such as news headlines or even short descriptions, so for this web app, sentence-based analysis is only used as a secondary scoring.</p>
<h3>How do I use this web app?</h3>
<p>Once you search for a specific term, the web app will gather all the news articles with that search term from the internet and perform Sentiment Analysis on the <strong>Titles</strong>&nbsp;and <strong>Short descriptions</strong>&nbsp;(i.e. a summary of article content) of all of these articles. The app will then plot 3 wordclouds that summarise the top 100 words related to your search term.</p>
<p>The app will also perform a Sentiment Analysis for the most recent article. The sentiment bar plot will show the exact sentiment score of each positive or negative word in that article content.</p>
<h3>What technologies are used under the hood?</h3>
<p>This web app is built using <strong><code>Shiny R</code></strong>. News data is collected by calling the News API from <a href="https://newsapi.org">https://newsapi.org</a>, with Australian news sources only.</p>
<p>Word-based analysis is performed with R package <code>syuzhet</code> using the Bing dictionary as reference. Sentence-based analysis is performed with R package <code>sentimentr</code> which is an extension of syuzhet. Standard text data preprocessing techniques such as removing stopwords and HTML tags were performed in R.</p>
<h3>Why are you building this web app?</h3>
<p>As an avid data scientist, I believe that <strong>Sentiment Analysis</strong> can be very useful to identify new business opportunities as a machine learning approach to collect business intelligence.</p>
<p>I chose News analysis as a non-commercial application, but just by tweaking the API calls, this very basic web app can be commercialised into a dashboard for businesses who want to collect &amp; analyse user feedback on their branding and products.&nbsp;</p>
<p><em><span style="color: #3366ff;"><strong>tldr;</strong> A just-for-fun project that I built to learn basic Shiny R and apply basic ML techniques into developing quick web app.</span></em></p>
<p>&nbsp;</p>')
                                 
                          ),
                          column(2)
                        )
                      )),# END OF PAGE
             
             tabPanel("Sentiment Analysis",
                      fluidPage(
                        # INPUT
                        sidebarLayout(
                          sidebarPanel(
                            textInput("search_target",
                                      "Search topic:",
                                      value = "coronavirus"),
                            actionButton("goButton", "Analyse", icon("search"),
                                         style="background-color: #5c2040; border: none;")
                          ),
                          
                          # OUTPUT
                          mainPanel(
                            h3("Overall Topic Analysis"),
                            htmlOutput("display_aggSent"),
                            tabsetPanel(type="tab",
                                        tabPanel("Top 100 Word Cloud", plotOutput('top100_wc')),
                                        tabPanel("Positive Words", plotOutput('pos_wc')),
                                        tabPanel("Negative Words", plotOutput('neg_wc'))
                            ),
                            
                            
                            h3("Most Recent Article"),
                            h4("Title"),
                            textOutput('display_title'),
                            h4("Source & Link"),
                            htmlOutput('display_src'),
                            h4("Description"),
                            textOutput('display_desc'),
                            h4("Short Content"),
                            textOutput('display_content'),
                            h4("Sentiment Analysis"),
                            tabsetPanel(type="tab",
                                        tabPanel("Sentiment Plot", plotOutput('ind_plot')))
                          ))
                      )), # END OF PAGE
             
             tabPanel("Contact",
                      fluidPage(
                        fluidRow(
                          column(4,
                                 img(src='Logo_Light.png', 
                                     width = 85,
                                     align = "right")),
                          column(8,
                                 HTML("<h3>Daniel P.</h3>
<p>Data Scientist | Digital Marketer</p>
<p>Melbourne, Australia</p>
<blockquote><em>I want to challenge the tedium and bring the boldness back to Decision Making &amp; Digital Experience. A big believer in Analytics, Big Data and Social Psychology, I am a student of everyone with a story and a mentor of anyone with a dream.</em></blockquote>
<p><strong>E:</strong> <a href='mailto:thenifinity@gmail.com'>thenifinity@gmail.com</a></p>
<p><strong>W</strong><strong>:</strong> <a href='https://thenifinity.com'>https://thenifinity.com</a></p>
<p><strong>LinkedIn:&nbsp;</strong><a href='https://www.linkedin.com/in/daniel-pham-digital/'>https://www.linkedin.com/in/daniel-pham-digital/</a></p>
<p><strong>Github:&nbsp;</strong><a href='https://github.com/danieltpham'>https://github.com/danieltpham</a></p>
<p>&nbsp;</p>
"))
                        )
                      )), # END OF PAGE

tags$script(" $(document).ready(function () {
         $('#switchTab').bind('click', function (e) {
               $(document).load().scrollTop(0);
               });});") # Scroll to top for switchTab button
             
  ))
