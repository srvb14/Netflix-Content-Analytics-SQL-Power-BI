# Netflix-Content-Analytics-SQL-Power-BI
End-to-end Netflix data analysis using SQL and Power BI to explore content distribution, trends, and insights from the Netflix Movies &amp; TV Shows dataset.

## Project Overview
This project performs an exploratory data analysis of Netflix movies and TV shows using SQL and Power BI.
The goal is to analyze the distribution of content, identify trends in movie and TV show releases, and generate insights about Netflix's catalog.
The project demonstrates a typical data analyst workflow, including data querying, transformation, and dashboard visualization.

## Tools & Technologies
  - SQL
  - Power BI
  - CSV dataset

## Dataset
Dataset used: Netflix Movies and TV Shows Dataset
It contains information such as:
  -index
  -id
  -title
  -type
  -description
  release_year
  -age_certification
  -runtime
  -imdb_id
  -imdb_score
  -imdb_votes

## SQL Analysis Performed
  -Key SQL operations used in this project include:
  -Data filtering
  -Aggregations (COUNT, GROUP BY)
  -Sorting and ranking
  -Handling missing values
  -Text pattern analysis

## Objectives: The project addresses the following analytical questions:
  - 1. Content Breakdown
       Analyze the distribution of Netflix titles by:
       Content type (Movie vs TV Show), Age certification
    This helps determine which demographic Netflix is targeting the most.

  - 2. High-Performing Content
       Identify titles that meet the following criteria:
       IMDb score greater than 8.0
       IMDb votes greater than 10,000
    These represent popular and highly rated titles on the platform.

  - 3. Historical Quality Trends:
       Analyze how content quality has evolved over time by calculating:
       Average IMDb score per year
       Comparison between Movies vs TV Shows
    Goal: Determine whether content quality improved or declined as content volume increased.

  - 4. Runtime Analysis
       Categorize movies into runtime groups:
       Short (< 90 minutes), Standard (90–120 minutes), Long (>120 minutes)
    Then compare their average IMDb ratings to see whether runtime influences audience perception.

  - 5. Identifying Hidden Gems:
       Identify titles with:
       IMDb score greater than 8.5
       Low vote counts
       These titles may represent high-quality but under-discovered content, often referred to as hidden gems.

## Power BI Dashboard
The dashboard visualizes the insights discovered through SQL analysis.
KPI Cards, Key summary metrics:
  -Total Titles
  -Average IMDb Score
  -Most Common Age Certification
  -Peak Release Year
  -Distribution of Movies vs TV Shows
  -Top 10 Age Certifications by number of titles
  -Runtime vs IMDb Score
  -List of Hidden Gems
  -Includes slicer for Release Year and Type

<img width="1341" height="751" alt="image" src="https://github.com/user-attachments/assets/9a802386-89b6-4cb8-be3d-97eb0b2d427c" />

