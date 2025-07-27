RA-ship Application: Bollywood Thematic Analysis

> A. Description -
>
> This repository contains the code, datasets and plots for conducting a
> cultural and thematic analysis of a random sample of Bollywood movies
> posr-2010 as part of an RA-ship application.
>
> B. Justification the Proposed Theme
>
> Apart from analysis the prescribed themes of Hindu-Muslim Relations,
> Gender Relations and Nationalism, this project also explores LGBTQIA+
> themes the justification for which is as follows --
>
> 1\. Historical Marginalisation --
>
> LGBTQIA+ characters and narratives have long existed on the fringes of
> Bollywood cinema. However, movies like Aligarh (2015), Ek Ladki Ko
> Dekha Toh Aisa Laga (2019), and Shubh Mangal Zyada Saavdhan (2020)
> have opened space for more authentic representation. This makes
> LGBTQIA+ themes a timely and meaningful domain for computational
> tracking and analysis.
>
> 2\. Legal and Cultural Inflection Point --
>
> The 2018 Supreme Court verdict decriminalizing homosexuality marks a
> watershed moment in India's sociopolitical landscape. Tracing how
> Bollywood responded to (or ignored) this moment offers a
> quasi-historical perspective on cultural change.
>
> C. Repository Structure

1.  /code_files

> 1.1 random_sampling.R
>
> 1.2 api_test.ipynb
>
> 1.3 primary_data_download.ipynb
>
> 1.4 secondary_data_download.ipynb
>
> 1.5 ai_gender_inf.ipynb
>
> 1.6 web_scraping.ipynb
>
> 1.7 fuzzy_matching_new.ipynb
>
> 1.8 sentiment_analysis_new.ipynb
>
> 1.9 text_parsing.ipynb
>
> 1.10 plotting_visulisation.R

2.  /cleaned_datasets

> 2.1 bollywood_full_1950-2019.csv
>
> 2.2 movies_random_sample.csv
>
> 2.3 bollywood_box_office_2010_2024.csv
>
> 2.4 director_gender_full_ouput.csv
>
> 2.5 sentiment_raw_ouput.txt
>
> 2.6 sentiment_parsed_ouput.csv

3.  /movie_data

> 3.1 data/description
>
> 3.2 data/posters
>
> 3.2 data/subtitles

4.  /plots

> 4.1 bollywood_average_score.png
>
> 4.2 bollywood_stacked_area_plot.png
>
> 4.3 bollywood_theme_frequency.png

D. Data Pipeline and Reproductibility

NOTE:

1.  Please create a folder titled ra_app on your desktop.

2.  The Kaggle dataset
    ([[https://www.kaggle.com/datasets/pncnmnp/the-indian-movie-database]{.underline}](https://www.kaggle.com/datasets/pncnmnp/the-indian-movie-database))
    when downloaded as a zip file is saved as a folder titled 'archive'.
    Transfer the file archive/1950-2019/bollywood_full_1950-2019.csv to
    the folder Desktop/ra_app just created. Alternatively, this file has
    been uploaded onto the repository under /cleaned_datasets and can be
    downloaded directly from there.

The data pipeline can be explained as follows -

1.  random_sampling.R

> Description: Use to randomly select a sample of 100 movies from the
> Kaggle dataset under the set.seed 05042004 (Note: No particular reason
> for this, it is just my date of birth) for reproducibility.
>
> Input File: bollywood_full_1950-2019.csv
>
> Output File: movies_random_sample.csv

2.  api_test.ipynb

> Description: Tests API keys hardcoded into the script, downloads just
> one file for testing. NOTE: TMDb API doesn't work in India without a
> VPN connection.
>
> Input File, Output File: None, all keys and tokens hardcoded

3.  primary_data_download.ipynb

> Description: Downloads posters, subtitles and descriptions of the
> movies in the random sample. Creates the folders data/descriptions,
> data/posters, data/subtitles. Also, logs the downloads. Descriptions,
> posters and subtitles are named with the IMDb ID of the movie.
>
> NOTE: Data Sources - Subtitles: OpenSubtitles, Posters, Descriptions:
> TMDb
>
> Input File: movies_random_sample.csv
>
> Output File: data/description, data/posters, data/subtitles,
> download_report.csv, log_downloads.txt

4.  secondary_data_download.ipynb

> Description: primary_data_download.ipynb leaves certain subtitles,
> posters and descriptions undownloaded as they are not available at
> TMDb.
>
> NOTE: Data Sources: For posters: poster_path in
> movies_random_sample.csv (which is in turn taken from Kaggle), for
> descriptions: wiki_link i.e. Wikipedia in movies_random_sample.csv.
>
> Input File: movies_random_sample.csv
>
> Output File: data/description, data/posters, data/subtitles

5.  ai_gender_inf.ipynb

> Description: Uses TMDb API to extract the name and biographical sketch
> of the director of the movie. Uses Open AI API to prompt GPT-4 to
> infer the gender of the director and assign a confidence score. Also
> logs failed cases.
>
> NOTE: Open AI API key is required (provided over email)
>
> Input File: movies_random_sample.csv
>
> Output File: director_gender_full_output.csv,
> director_gender_failed_cases.csv

6.  web_scraping.ipynb

> Description: Scrapes the Bollywood Hungama website
> ([[https://www.bollywoodhungama.com/box-office-collections/]{.underline}](https://www.bollywoodhungama.com/box-office-collections/))
> for the box office collection of all bollywood movies from 2010 to
> 2024.
>
> Input File: None
>
> Output File: bollywood_box_office_2010_2024.csv

7.  fuzzy_matching_new.ipynb

> Description: Applies fuzzy string matching to borh, title_kaggle and
> original_title in movies_random_sample.csv with movie_name in
> bollywood_box_office_2010_2024.csv i.e. the output file of
> web_scarping.ipynb. Finds the best match (in terms of confidence
> score) of the two and retains that. If confidence score \<70 for both,
> return NA. Adds lifetime_collection_matched.csv to
> movies_random_sample.csv.
>
> Input File: movies_random_sample.csv,
> bollywood_box_office_2010_2024.csv
>
> Output File: movies_random_sample.csv (appended)

8.  sentiment_analysis_new.ipynb

> Description: Carries out sentiment analysis of bollywood movies using
> GPT-4 as the LLM. If either description or subtitles of a movie are
> missing, skipped for analysis. If subtitles are \<100 characters, also
> skilled for analysis.
>
> If a certain theme out of the four (i.e Hindu-Muslim Relations, Gender
> Relations, LGBTQIA+ Themes, Nationalism) is present, it is assigned a
> score on each of the following axes: positive-negative,
> progressive-conservative and inclusionary-exclusionary. Scores are
> assigned on a continuum of -1 and +1 where -1 represents most
> negative, conservative and exclusionary sentiments and +1 represents
> most positive, inclusionary and progressive sentiments.
>
> Input Files: movies_random_sample.csv, data/description,
> data/subtitles
>
> Output File: sentiment_raw_output.txt

9.  text_parsing.ipynb

> Description: Parses sentiment_raw_ouput.txt and saves the measures of
> sentiment in a .csv file.
>
> Input File: sentiment_raw_output.txt
>
> Input File: sentiment_parsed_output.csv

10. plotting_visualisation.R

> Description: Generates plots
>
> Input File: movies_random_sample.csv, sentiment_parsed_output.csv
>
> Output File: bollywood_average_score.png,
> bollywood_stacked_area_plot.png, bollywood_theme_frequency.png

E. Plots

1.  bollywood_theme_frequency.png

> Main plot tracing the frequency of themes

2.  bollywood_theme_frequency.png,
    bollywood_average_score_positive_negative.png,
    bollywood_average_score_exclusionary_inclusive.png

> Trace the average score of axes by themes

3.  bollywood_stacked_area_plot.png

F. Prompts

Prompts are used twice in this data pipeline once in ai_gender_inf.ipynb
and then in sentiment_analysis_new.ipynb. They are as follows -

1.  For ai_gender_inf.ipynb -

prompt = f\"\"\"

Based on the following name and biography of a film director associated
with Indian cinema (especially Bollywood), what is the most likely
gender of this person?

Name: {name}

Biography: {bio}

Respond in JSON format with two fields:

{{

\"gender\": \"male\" or \"female\",

\"confidence\": a number between 0.0 and 1.0 indicating how confident
you are in this classification

}}

\"\"\"

2.  For sentiment_analysis_new.ipynb

You are a social scientist and analyst who is tasked with analysing
cultural and political themes in the subtitles and descriptions of
Bollywood (i.e. Indian film industry) films since 2010.

Your task is to --

1\. Detect whether each of the following themes appears --

1\. Hindu-Muslim Relations

2\. Gender Relations

3\. Nationalism

4\. LGBTQIA+ Themes

2\. For each theme that is present, assess it on the following axes --

1\. Exclusionary v/s Inclusionary

2\. Negative v/s Positive

3\. Conservative v/s Progressive

3\. For each axis, assign a score on a continuous scale from \*\*-1 to
+1\*\*:

\- A score of \*\*-1\*\* represents the most Exclusionary, Negative, or
Conservative representation possible.

\- A score of \*\*+1\*\* represents the most Inclusionary, Positive, or
Progressive representation possible.

\- A score of \*\*0\*\* indicates a neutral or balanced portrayal.

Thematic definitions of the themes are as follows --

1\. Hindu-Muslim Relations

In India, Hindus form about 79% of the population whereas Muslims form
about 14%. Hindu-Muslim relations are characterised by periods of both,
amity, cooperation and syncretism and also with strife and violence.

2\. Gender Relations

UNICEF defines gender relations as follows: A specific sub-set of social
relations uniting men and women as social groups in a particular
community. Gender relations intersect with all other influences on
social relations -- age, ethnicity, race, religion -- to determine the
position and identity of people in a social group. Since gender
relations are a social construct, they can be changed.

3\. Nationalism

Oxford Reference defines nationalism as follows: A political ideology
and associated movement intended to realize or further the aims of a
nation, most notably for independent self-government in a defined
territory. In a broader sense, nationalism also refers to sentiments of
attachment to or solidarity with a national identity or purpose.

4\. LGBTQIA+ Themes

Cambridge Dictionary defines LQBTBQIA+ themes as follows: abbreviation
for lesbian, gay, bisexual, transgender, queer (or questioning),
intersex, and asexual (or ally): relating to or characteristic of people
whose sexual orientation is not heterosexual (= sexually or romantically
attracted to women if you are a man, and men if you are a woman) or
whose gender identity is not cisgender (= having a gender that matches
the physical body you were born with).

Definitions of the axes are as follows:

1\. Exclusionary v/s Inclusionary

Cambridge Dictionary defines exclusionary to be: limited to only one
group or particular groups of people, in a way that is unfair; resulting
in a person or thing not being included in something.

Cambridge Dictionary defines inclusion to be: the act of including
someone or something as part of a group, list, etc., or a person or
thing that is included; the idea that everyone should be able to use the
same facilities, take part in the same activities, and enjoy the same
experiences, including people who have a disability or other
disadvantage.

2\. Negative v/s Positive

Cambridge Dictionary defines negative to be: not expecting good things,
or likely to consider only the bad side of a situation; bad or harmful.

Cambridge Dictionary defines positive to be: full of hope and
confidence, or giving cause for hope and confidence.

3\. Conservative v/s Progressive

Cambridge Dictionary defines conservative to be: not usually liking or
trusting change, especially sudden change.

Cambridge Dictionary defines progressive to be: Progressive ideas or
systems are new and modern, encouraging change in society or in the way
that things are done.

\-\--

Please analyze the following \*\*Movie Description and Subtitle
Transcript\*\* carefully and respond using this structure:

For each of the 4 themes, do the following:

\- Presence: Present / Not Present / Ambiguous

\- If Present, assign a score between -1 and +1 on each of the following
axes:

\- Exclusionary--Inclusionary

\- Negative--Positive

\- Conservative--Progressive

\-\--

Movie Plot Description:

{description}

\-\--

Subtitle Transcript:

{subtitles}

\"\"\"
