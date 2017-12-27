# -*- coding: utf-8 -*-

import argparse
import subprocess
from logging import getLogger
import pandas as pd
import predictionio
import os
import sys

logger = getLogger('main')


def get_app_id(args):
    appid_cmd = f'{args.pio_cmd} app list'.split(' ')
    p = subprocess.run(appid_cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if p.returncode == 0:
        cmd_output = p.stdout.decode('utf-8')
        for line in cmd_output.split('\n'):
            values = line.split('|')
            if values[2].strip() == args.access_key:
                return values[1].strip()
    return ''


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Import data")
    parser.add_argument('--access-key', dest='access_key')
    parser.add_argument('--pio-cmd', dest='pio_cmd', default="/opt/predictionio/bin/pio")
    parser.add_argument('--csv-name', dest='csv_name')
    parser.add_argument('--input-dir', dest='input_dir')

    args = parser.parse_args()
    logger.info(args)

    if args.access_key is None:
        logger.error("No access key.")
        sys.exit(1)

    logger.info(f'Accessing an access key')
    appid_cmd = f'{args.pio_cmd} app list'
    app_id = get_app_id(args)
    if len(app_id) == 0:
        logger.error('app_id is empty.')
        sys.exit(1)

    csv_file = f'{args.input_dir}/{args.csv_name}.csv'
    if not os.path.exists(csv_file):
        logger.error(f"{csv_file} is not found")
        sys.exit(1)

    logger.info(f'Loading {args.csv_name}.csv')
    exporter = predictionio.FileExporter(file_name=f'/tmp/{args.csv_name}.ndjson')
    df = pd.read_csv(csv_file, encoding = "utf-8")
    for i, v in df.iterrows():
        event_response = exporter.create_event(event=f"{args.csv_name}",
                                               entity_type='data',
                                               entity_id=str(i),
                                               properties={x:str(v[x]) for x in df.columns})
    exporter.close()

    logger.info(f'Storing /tmp/{args.csv_name}.ndjson')
    subprocess.run(f'{args.pio_cmd} import --appid {app_id} --input /tmp/{args.csv_name}.ndjson'.split(' '))

