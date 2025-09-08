# Code Optimization checklist

## Abstract

The focus is on optimizing code for a data-centric pipeline.

In particular, these workloads either ingest, process, or output a "large" amount of data, and as such often involve a considerable number of factors that can affect overall performance. And because these processes rarely exist in isolation, as a means to an end, rather than an end in and of itself, overall performance/execution time is often felt as "the waiting before I can proceed with the important work".

An assumption is made that reasonably capable hardware is available to run this process, and that there isn't any immediate option to simply throw more power at this problem at the moment (either due to cost constraints, or maybe even logistical issues procuring/installing new infrastructure). It is also assumed that this guide is being applied by practitioners on programs that are non-trivial.

* ELT/ETL data cleaning/curation pipelines 
* Report generation pipelines 
* Post-hoc explorative/diagnostic analyses
* Model training pipelines 
* Simulations/stochastic scenario evaluations 


# Section A - Evaluation

Donald Knuth from The Art of Computer Programming:
"The real problem is that programmers have spent far too much time worrying about efficiency in the wrong places and at the wrong times; premature optimization is the root of all evil (or at least most of it) in programming."

Section A seeks to deter premature optimization, therefore optimizing first and foremost for development-time being spent. 

If you do happen to have an abundance of time either to practice this skill or to generate free increases in efficiency on existing code, then there is no concern about optimization being premature.


## Step -1: Does it execute?

If not*, optimization isn't even in the question yet.

*If you are even remotely concerned about failure to execute due to optimization, work on a smaller sample.


## Step 0: Does it function correctly?

If not, the answer to "is it time to think about optimization?" is still NO.

Once you have a small but representative sample of data being processed correctly, it will inherently provide you with the first thing necessary for optimization, which is an empirically-measurable baseline for performance. 


## Step 1: It time to optimize

If the decision is made to optimize for execution performance, and you have a baseline execution time from a small sample, then two more very important pieces of information are needed.

It doesn't need to be precise, but an estimate is needed for both:  
1. What is the necessary/reasonable target for optimized performance?  
2. What is the approximate scale from your sample data to the intended full-size data set?  

For 1., it is important to know when to stop optimizing, and to a lesser extent to know how far you need to go. 
If a simulation is satisfactory if it can run in 12 hours as a schduled job overnight, then that's your target. 
If a report needs to be available with a 1 hour latency from data availability to consumption, then that's your target. 
And if a diagnostic process needs to be run dozens of times daily, while an analyst waits in real-time for the results, then perhaps 2-10 minutes is the most that can be afforded.

For 2., this should be an objective fact, and this step simply calls it to mind. If your sample input was 1000 records, the execution time was 10min, and you have a 1hr limitation, then it matters if you expect the full data to be 16,000 records, or 10,000,000 records. 


## Step 2: Priorities

Profiling/benchmarking the performance of the code is valuable, but can be complex. 
At the very least, if code is not performing to the desired level, logging of timestamps at the start/end of major steps will allow empirical observation of what operations are taking the most time, and just as importantly will inform if targetted optimization is having an effect.

Optimization efforts should be focused on the longest-running sections, not just what operations may be most intuitive to optimize. 

# Section B - Logical Optimization 

This section deals with issues that are most broadly applicable to all types of data workloads, universal across infrastructure, and potentially require the least coding knowledge/experience to implement. That is why these are always the first items to work through.

## Step 3: Avoid extra work 

It should be obvious, but it is worth saying explicitly: if calculations are being done, or data is being collected/moved/manipulated in ways that do not contribute to the correctness of the desired output, do not do them. Often, these can be artefacts from development (ie diagnostic outputs, redundant checks) that no longer need to be executed, or that were initially required in earlier version but were made unnecessary in the latest implementation.
What may be more helpful are some guidelines that identify these wasted efforts that may not be obvious, especially for complex code, and doubly so for code that you did not implement yourself.

* initially extract no more raw data than is needed (fields or records)
* filters that reduce the working set of data should be applied as early in the process as they can be evaluated, so that later steps have less to deal with
* operations that apply to the entire set of records (ie sorting) should be done when the data is either the most-reduced, or the least-complex
* parsing/formatting operations should also be pushed to where there are the fewest records (ie early on when the record count is expanding such as a simulation, or later on when the output is a subset of the initial records, such as a filtered report or set of training data)

## Step 4: Algorithmic efficiency 

This requires the most in-depth understanding of the logic/calculations that are needed to generate the correct output, and so in many cases this is not a step that will yield opportunities for outside help in optimizing. 

And while nobody sets out to make an inefficient algorithm, now is the time to consider the order of execution time and memory space that will be used as the size of your data increases, and whether your data is being handled in structures that are reasonably condensed and performant for the type of operations that are most prevalent. 


## Step 5: Modularity 

In most cases this re-organization of code will not yield a large performance benefit by itself. Modularity is the grouping of logical blocks of similar/related operations, while increasing separation from other operations. Commonly, this could mean collecting several steps that operate on the same data into a function, so that the input is limited to a few data structures, and the output is similarly simplified. Benefits can come from having fewer elements of data being worked on at a time, or culling/discarding intermediate steps once they are no longer needed for later steps. The most extreme beneficial case would be if certain modular steps can be offloaded to more specialized execution environments that can accelerate the specific type of processing needed for those steps.

The goal is to make it more clear where certain types of operations are more concentrated which allows more effective profiling, and makes it easier to reason about what changes might be the most effective for which steps.


# Section C - Software + Hardware Optimization






# Optimization case study

Clean Linux Mint VM
    Installed 
        ~/local/
        *Python
            "pandas[all]"
            pyarrow
            sqlite3
            duckdb
        Julia
            DataFrames
            SQLite
            DuckDB
        Spark
        Postgres
    500GB free disk
        ~/local/data/
Raw data: 1,000,000,000 records NYC Taxi rides in CSV
    ~/local/data/raw/
    10E3 -                 try 1,000
    10E5 -              test 100,000
    10E7 -          scale 10,000,000
    10E9 - demonstrate 1,000,000,000
Profile: 
    Time limit 300 seconds 
    ~/local/logs/
        {task}-{tool}-{sample_size}
Ingest (Clean?)
    ~/local/scripts/ingest/
        *Python
        Julia
        Pyspark
    ~/local/data/db_storage/
        *SQLite
            index?
        Parquet
            partition
        Postgres
Query:
    ~/local/scripts/analysis/
    Tasks: 
        extract dimension mappings
            *regions
            *quarters
            profiles
        extract normalized observations
            *ordered text key
            ordered integer key
            *hash text key
            hash binary key
            *region key
            *time period key
            *time_start, time_end
            *loc_start, loc_end
            profile key
        aggregate across all observations along different dimensions
            *duration percentiles
            *distance/displacement percentiles
            *speed/velocity percentiles
            *by start loc
            by end loc
            by start hour
            *by time period
        aggregate across randomly sampled windows
        reconstruct from bootstrap samples
    Engines: 
        *SQLite
        PySpark
        Pandas
        Polars
        *DuckDB
        Postgres
Export: 
    ~/local/data/out/
    *CSV
    *Parquet
    *SQLite
    Postgres
Report: 





