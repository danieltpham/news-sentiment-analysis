# Shiny R Web App - Australian News Articles Sentiment Analysis
Deployed through ShinyR.io at https://thenifinity.shinyapps.io/sentimentanalysis/

# What is this web app for?
This web app applies both word-based and sentence-based Sentiment Analysis to identify emotions from news articles about a topical issue from Australian news sources such as Sydney Morning Herald, The Age, and The Herald Sun.

Although sentence-based analysis is theoretically better than word-based analysis, it requires a longer text in order to analyse. This drawback prevents it from being a good technique to analyse short text data such as news headlines or even short descriptions, so for this web app, sentence-based analysis is only used as a secondary scoring.

# What is Sentiment Analysis?
Sentiment analysis is the interpretation and classification of emotions (positive, negative and neutral) within text data using text analysis techniques. Word-based sentiment score only analyses individual words; for example: the phrase not not good will have a negative score because there are 2 negative words in the phrase and only 1 positive word. Sentence-based semantic score also considers the semantic meaning, so not not good will have a positive score because of the double-negative grammar.

# How do I use this web app?
Once you search for a specific term, the web app will gather all the news articles with that search term from the internet and perform Sentiment Analysis on the Titles and Short descriptions (i.e. a summary of article content) of all of these articles. The app will then plot 3 wordclouds that summarise the top 100 words related to your search term.

The app will also perform a Sentiment Analysis for the most recent article. The sentiment bar plot will show the exact sentiment score of each positive or negative word in that article content.

# What technologies are used under the hood?
This web app is built using Shiny R. News data is collected by calling the News API from https://newsapi.org, with Australian news sources only.

Word-based analysis is performed with R package syuzhet using the Bing dictionary as reference. Sentence-based analysis is performed with R package sentimentr which is an extension of syuzhet. Standard text data preprocessing techniques such as removing stopwords and HTML tags were performed in R.

# Why are you building this web app?
As an avid data scientist, I believe that Sentiment Analysis can be very useful to identify new business opportunities as a machine learning approach to collect business intelligence.

I chose News analysis as a non-commercial application, but just by tweaking the API calls, this very basic web app can be commercialised into a dashboard for businesses who want to collect & analyse user feedback on their branding and products. 

tldr; A just-for-fun project that I built to learn basic Shiny R and apply basic ML techniques into developing quick web app.
