#!/bin/bash

APP_NAME=HousePrices
ACCESS_KEY=HOUSE_PRICES
PYTHON_CMD=/opt/conda/bin/python
IMPORT_PYFILE=data/import_eventserver.py
PIO_CMD=/opt/predictionio/bin/pio
PIO_BUILD_ARGS="--verbose"
PIO_TRAIN_ARGS="--main-py-file train.py"
PIO_DEPLOY_ARGS=

if [ x"$1" != "x" ] ; then
  PIO_MODE=$1
fi

install_modules() {
  pip install matplotlib
  pip install seaborn
  pip install scipy
  pip install sklearn
}

run_cmd() {
  echo "[PIO-SETUP] User: $PIO_USER Command: $@"
  if [ x"$PIO_USER" = "xroot" ] ; then
    $@
  else
    sudo -i -u $PIO_USER $@
  fi
}

create_app() {
  run_cmd $PIO_CMD app new --access-key $ACCESS_KEY $APP_NAME
  run_cmd $PIO_CMD app list
}

delete_app() {
  run_cmd $PIO_CMD app delete -f $APP_NAME
}

import_data() {
  run_cmd $PYTHON_CMD $IMPORT_PYFILE --access-key $ACCESS_KEY --input-dir `dirname $IMPORT_PYFILE` --csv-name train
  run_cmd $PYTHON_CMD $IMPORT_PYFILE --access-key $ACCESS_KEY --input-dir `dirname $IMPORT_PYFILE` --csv-name test
}

build() {
  run_cmd $PIO_CMD build $PIO_BUILD_ARGS
}

train() {
  run_cmd $PIO_CMD train $PIO_TRAIN_ARGS
}

deploy() {
  run_cmd $PIO_CMD deploy $PIO_DEPLOY_ARGS
}

run_jupyter() {
  /opt/conda/bin/pip install jupyter
  TMP_FILE=/tmp/run_jupyter.$$
  cat <<EOS > $TMP_FILE
#!/bin/bash
export PYSPARK_PYTHON=/opt/conda/bin/python
export PYSPARK_DRIVER_PYTHON=/opt/conda/bin/jupyter
export PYSPARK_DRIVER_PYTHON_OPTS="notebook --ip=0.0.0.0 --allow-root"
/opt/predictionio/bin/pio-shell --with-pyspark
EOS
  run_cmd /bin/bash $TMP_FILE
}

case "$PIO_MODE" in
  jupyter)
    install_modules
    delete_app
    create_app
    import_data
    run_jupyter
    ;;
  install-modules)
    install_modules
    ;;
  create-app)
    create_app
    ;;
  delete-app)
    delete_app
    ;;
  import-data)
    import_data
    ;;
  build)
    build
    ;;
  train-only)
    train
    ;;
  train)
    install_modules
    create_app
    import_data
    build
    train
    ;;
  deploy)
    install_modules
    deploy
    ;;
  *)
    echo "Usage: $SCRIPTNAME {create-app|delete-app|import-data|build|train|train-only|deploy|jupyter}" >&2
    exit 3
    ;;
esac
