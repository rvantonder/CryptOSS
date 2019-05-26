# CryptOSS

This repository contains tooling for collecting and viewing Cryptocurrency Open Source Software (OSS) development.

<details>
  <summary>Click to expand Papers and Citations related to this project.</summary>
  
```
@inproceedings{trockman-striking-gold-2019, 
  title = {{Striking Gold in Software Repositories? An Econometric Study of Cryptocurrencies on GitHub}},
  booktitle = "International Conference on Mining Software Repositories", author = "Trockman, Asher and {van~Tonder}, Rijnard and Vasilescu, Bogdan",
  series = {MSR '19},
  year = 2019
}
```
[Paper Link](https://cmustrudel.github.io/papers/msr19crypto.pdf)

```
@inproceedings{van-tonder-crypto-oss-2019, 
  title = {{A Panel Data Set of Cryptocurrency Development Activity on GitHub}},
  booktitle = "International Conference on Mining Software Repositories",
  author = "{van~Tonder}, Rijnard and Trockman, Asher and {Le~Goues}, Claire",
  series = {MSR '19},
  year = 2019
} 
```
[Paper Link](https://www.cs.cmu.edu/~rvantond/pdfs/crypto-oss-msr-data-2019.pdf)
</details>

## CSV and raw data

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2595588.svg)](https://doi.org/10.5281/zenodo.2595588)

[View the GitHub data online](https://rvantonder.github.io/CryptOSS). This does not include the full data available in the CSV above, which includes cryptocurrency prices, market cap, and trading volumes.

## Building the tooling

- Install [opam](https://opam.ocaml.org/doc/Install.html). Typically:

```
sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)
```

- Then run 
```
opam init
opam switch create 4.05.0 4.05.0 
```

- Next:

```
opam install core opium yojson hmap tyxml
```

Then:

```
opam pin add github https://github.com/rvantonder/ocaml-github.git 
```

Then type `make` in this repository. The scripts and command-line utilities should now work. Let's step through the possible uses. 

### Collecting your own data

The `cronjob` folder contains the `crontab` for actively polling and collecting GitHub data. It's a good place to look if you want to understand how to collect data.

- `cronjob/crontab`: The crontab pulls data by invoking `cronjob/save.sh` and `cronjob/ranks.sh` at certain intervals (these can be customized).

- `cronjob/save.sh`: Essentially runs the `crunch.exe save` command (with a user-supplied GitHub token), see [here](https://github.com/rvantonder/CryptOSS/blob/master/cronjob/save.sh#L14). This command takes a list of comma-separated names registered in the `db.ml` [file](https://github.com/rvantonder/CryptOSS/blob/master/lib/db.ml). You can see the invocation of the `save.sh` script in the `crontab` [file](https://github.com/rvantonder/CryptOSS/blob/master/cronjob/crontab). 

- `cronjob/ranks.sh`: Pulls cryptocurrency data from CoinMarketCap

- `batches`: The crontab uses batches of cryptcurrencies (listed in files) [example](https://github.com/rvantonder/CryptOSS/blob/master/cronjob/batches/batch-0.txt)). Each batch corresponds to a list of cryptocurrencies that fit within the 5000 request rate limit for GitHub, so that batched requests can be spaced out over 24 hours. The interval and batch size can be changed depending on need (see `cronjob/batches/generate.sh`).

Besides the cronjob, you can manually save data by running, say, `crunch.exe save Bitcoin -token <your-github-token>`. This produces a `.dat` file, as processed by `./pipeline.sh`.

The list of supported cryptocurrencies are in the [database file](https://github.com/rvantonder/CryptOSS/blob/master/lib/db.ml). Modify it to include your own, and type `make` again to update the tooling. You can then run `crunch.exe save <My Crypto> -token ...`. 

### Processing data

If you want more control over data processing besides `./pipeline.sh`, you can use `crunch.exe load`. You can generate a CSV file from a `.dat` with a command like:

```
crunch.exe load -no-forks -csv -with-ranks <ranks.json file from CoinMarketCap> -with-date <DD-MM-YYYY> <some-dat-file>.dat
```

A similar command is [used in the csv-of-dat.sh script](https://github.com/rvantonder/CryptOSS/blob/master/csv-of-dat.sh#L17) to generate the MSR data set.

You can generate aggregate values by running `./crunch.exe aggregate` on some directory containing `.dat` files. This will create `.agg` files. `.agg` files can be used to generate the web view.

### Generating the web view

The `./deploy.sh` [script](https://github.com/rvantonder/CryptOSS/blob/master/deploy.sh#L13-L18) builds a static site. If you want to create the webview for a particular date, say Oct 10, 2018 (containing `.dat`s), simply run `./deploy.sh datastore/2018-10-10`. This will generate a web view in `docs`.

### Recreating the MSR dataset from the raw data

Create a directory called `datastore`. Download and untar the [raw data file](https://zenodo.org/record/2595588/files/raw-data-2018-01-21-to-2019-02-04.tar.gz?download=1) in this directory.
In the toplevel of this repository, run `./pipeline.sh <N>`, where `N` is the number of parallel jobs (this speeds up processing). You can ignore any warnings/errors. Once finished, you'll have generated `.csv` files in the toplevel directory.

Feel free to add your own data in the `datastore` (for some date), and rerun `./pipeline.sh`.

-----

[![DOI](https://zenodo.org/badge/169338876.svg)](https://zenodo.org/badge/latestdoi/169338876)
