# README

## Building the command line

- Install [opam](https://opam.ocaml.org/doc/Install.html). Typically:

```
sudo apt-get install aspcud
sudo apt-get install opam
```

- Run `opam init --comp 4.05.0`

- Do the following once opam is installed:

```
opam install core opium yojson hmap tyxml
```

Then:

```
opam pin add github https://github.com/rvantonder/ocaml-github.git 
```

Then: come back to this repository and do `make`. You should now be able to just run `./crunch.exe`, the main command line utility. If you want to build the MSR data set, continue below.


## MSR data publishing

Place the raw data files ([final link TBA](https://tba.com)) in a folder called `datastore`.

Run `./pipeline.sh`. 

This starts off running 4 processes in parallel, decompressing the tars,
generating intermediate CSVs for each date, and then delete the uncompressed
data so it doesn't consume lots of space. Once all CSVs in the directories are
generated, it is collated into a single file and sorted. At the end you get
`all-sorted.csv`, the final file, in the current directory.  Generating the CSV
takes about 1 hour on my Macbook pro 15".

This will first recover some data (for single days).  Then it will normalize
the data (add null values for all dates and all keys in the raw data set). The
final csv is `all-sorted-recovered-sanitized.csv`. 

## Building the site

Run `./deploy.sh datastore/your-date`. This will generate a site for the chosen date in a folder called `release-site`.
