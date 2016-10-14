import os
from pprint import pprint, pformat
from time import sleep
import sys
import subprocess
from core import database
import logging

from core.script_monitoring import exit_if_already_running

PYTHONPATH = '/var/www/pipeline/venv/bin/python'
DATABASE = 'heroku'
DELAY_TIME = 1800   # Seconds between starting each query.


def connect_db(host=DATABASE):
    dbCreds = database.getDBCreds(host)
    connection = database.Connection(*dbCreds.connectioncreds)
    return connection


def run_query(query, conn=None):
    if not conn:
        conn = connect_db()
        conn.con.autocommit=True
    response = conn.tryexecute(query)
    return response


def readSqlFile(filePath):
    with open(filePath, 'rb') as reader:
        sql = reader.read()
    return sql


def runSql(sqlFile):
    logger = logging.getLogger(os.path.basename(sqlFile))
    logger.info('Running {0}'.format(os.path.basename(sqlFile)))
    sql = readSqlFile(sqlFile)
    logger.debug('SQL:\n{0}'.format(sql))
    try:
        response = run_query(sql)
        if response[1] == 0:
            logger.info('Query completed successfully.')
        sleep(2)
        if response[0]:
            logger.debug('Response:\n{0}'.format(pformat(response[0])))
    except:
        logger.exception('Error occurred.')

def runSubprocess(sqlFile):
    exit_if_already_running(sqlFile)
    cmd = ' '.join([PYTHONPATH, os.path.realpath(__file__), sqlFile])
    print cmd
    proc = subprocess.Popen(cmd, shell=True)
    return proc


def runFiles(sqlFilesDir, host=DATABASE):
    logging.info('Running sql files in directory {0} on database {1}'.format(sqlFilesDir, host))

    files = []
    for r, d, f in os.walk(sqlFilesDir):
        for fil in f:
            if os.path.splitext(fil)[1] == '.sql':
                fPath = os.path.join(r, fil)
                files.append(fPath)

    for sqlFile in sorted(files, reverse=True):
        runSubprocess(sqlFile)
        sleep(DELAY_TIME)


if __name__ == '__main__':
    args = sys.argv

    if len(args) < 2:
        print 'Need argument for directory or .sql file.'
        sys.exit(1)

    src = args[1]

    parDir = os.path.dirname(os.path.realpath(__file__))
    if src in os.listdir(parDir):
        src = os.path.join(parDir, src)

    if os.path.isfile(src):
        if os.path.splitext(src)[1] == '.sql':
            logFormat = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            logFile = os.path.join(os.path.dirname(src), 'logs', os.path.basename(src)+'.log')
            if not os.path.exists(os.path.dirname(logFile)):
                os.makedirs(os.path.dirname(logFile))
            logging.basicConfig(format=logFormat, level=logging.INFO, filename=logFile)
            runSql(src)
    else:
        runFiles(src)