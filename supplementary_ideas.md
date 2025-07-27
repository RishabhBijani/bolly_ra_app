> Supplementary Ideas
>
> 1\. Thematic Keywords -

Description -

TMDb contains thematic keywords for every movie which describe the major
themes in the movie.

Data Collection Approach --

The TMDb API contains the following endpoint which can be used to scrape
keywords for a move using its IMDb/TMDb ID --

[[https://api.themoviedb.org/3/movie/{tmdb_id}/keywords]{.underline}](https://api.themoviedb.org/3/movie/%7btmdb_id%7d/keywords)

Reasoning --

> \- Keywords can help in more pointed, focussed prompted of LLMs for
> thematic analysis.
>
> \- Keywords can also be used for confirming the theme inferred by the
> LLM by analysing the subtitles and description as a form of robustness
> check.
>
> 2\. Actors --

Description --

The Kaggle dataset
([[https://www.kaggle.com/datasets/pncnmnp/the-indian-movie-database]{.underline}](https://www.kaggle.com/datasets/pncnmnp/the-indian-movie-database))
contains the information on the actors in a particular film.

Data Collection Approach --

The file archive/2010-2019/Bollywood_text_2010-2019.csv and also TMDb
API can be used to extract the names of the actors in a particular film.
The file archive/2010-2019/Bollywood_text_2010-2019.csv has the names of
actors in a string vector which can be matched with the file
archive/1950-2019/Bollywood_crew_data_1950-2019.csv which identifies
each actor with a unique crew_id.

> 3\. Writers

Description --

The Kaggle dataset
([[https://www.kaggle.com/datasets/pncnmnp/the-indian-movie-database]{.underline}](https://www.kaggle.com/datasets/pncnmnp/the-indian-movie-database))
contains information on writers as well.

Data Collection Approach --

The file archive/1950-2019/Bollywood_crew_1950-2019.csv lists unique
crew_id of writers for each film. The file
archive/1950-2019/bollywood_writers_data_1950-2019.csv lists out all
writers with their unique crew_id.

Combined Reasoning for Points 2 and 3 --

Identifying the actors and writers with each film and then, correlating
it with the themes and sentiment-scores can help us in profiling of
actors and writers.
