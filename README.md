# PredictionIO Template: House Prices

## Overview

This repository is PredictionIO Template for [House Prices: Advanced Regression Techniques](https://www.kaggle.com/c/house-prices-advanced-regression-techniques) on Kaggle.

## Dataset

Download train.csv and test.csv from [Data](https://www.kaggle.com/c/house-prices-advanced-regression-techniques/data) and put them to data directory.

## Requirement

* Docker

## Getting Started

### Run Jupyter

```
PIO_MODE=jupyter docker-compose up --abort-on-container-exit
```

Open eda.ipynb at Jupyter Notebook page(http://localhost:8888/).


### Run Train Steps on Docker

`train` mode executes create-app, import-data, build and train process.

```
PIO_MODE=train docker-compose up --abort-on-container-exit
```

### Run Deploy Step on Docker

`deploy` mode starts Rest API on Docker container.

```
PIO_MODE=deploy docker-compose up --abort-on-container-exit
```

and then check a prediction:

```
curl -s -H "Content-Type: application/json" -d '{"attr0":5.1,"attr1":3.5,"attr2":1.4,"attr3":0.2}' http://localhost:8000/queries.json
```

