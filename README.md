# mktextbl

This program makes TeX table script.
In other words, 
this program converts roff's **tbl**-format table to tabular-env. on LaTeX.
It is useful when you use **tbl**-format table in LaTeX document.
And this program is useful to batch processing with scripts.

## tbl features

This program supports several features of **tbl** but not full.
Here, we show supported feaures.

- option
    + **center** centering
    + **tab()** separater of items in line
- format
    + **l** left
    + **c** center
    + **r** right
    + **s** span
    + **|** vertical line. double vertical line when used that twice
- format suffix
    + **b** bold
    + **i** italic
    + *num* speparation ('en'-base. convert that to 'em'-base)
- data
    + **_** single horizontal line
    + **=** double horizontal line

## not supported features

- **_** and **=** in format; latex tabular has same feature
- **^**, **a**, **n** in format

## LaTeX commands

This program don't care LaTeX/roff commands.
You can insert LaTeX's command in document.
Do not expect any translation from roff commands to LaTeX commands.

## history

- In 1992, This program was producuted for integration **tbl** to TeX.
  Because TeX's tabular env. was complex than **tbl**.
- 2025-06-14:
    + Fix right vertical line in "allbox" style.
    + Insert newline per line.

## references

- tbl(1)
- M.E.Lesk "TBL -- A Program to Format Tables", 1997.


