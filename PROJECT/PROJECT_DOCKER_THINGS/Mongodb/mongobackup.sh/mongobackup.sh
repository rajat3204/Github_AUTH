#!/bin/sh
date
CONTAINER_SERVICE_NAME="mongo"
DATABASE_NAME="prod-stable-coin"
USER_NAME="Stable-Coin-prod-mongo-admin"
PASSWORD="9tgyhgjvnhryu8l"
TIMESTAMP=`date +%b-%d-%y`
DOCKER_COMPOSE_PATH="/opt/docker/apps/docker-compose.yml"
BUCKET_URL="stable-coin-prod/prod-mongo-backup/"



docker compose -f ${DOCKER_COMPOSE_PATH} exec -T ${CONTAINER_SERVICE_NAME} mongodump  -u ${USER_NAME} -p ${PASSWORD} --authenticationDatabase=admin --db ${DATABASE_NAME} --out /data/db/${DATABASE_NAME}-backup-${TIMESTAMP}

DUMP_NAME=$(ls -lt /opt/docker/apps/data/mongodata | grep "prod" | grep -v '.tar.gz' | awk '{print $NF}' | head -n 1)

echo "${DUMP_NAME}"

DUMP_STATUS=$?

# Check the status of the mongodump command
if [ ${DUMP_STATUS} -eq 0 ]
then
  echo "Mongodump completed successfully for ${DUMP_NAME}"

  # Create a tarball of the backup
  cd /opt/docker/apps/data/mongodata
  sudo tar -cvzf ${DUMP_NAME}.tar.gz  ${DUMP_NAME}
  TAR_STATUS=$?

  # Check the status of the tar command
  if [ ${TAR_STATUS} -eq 0 ]
  then
    echo "Tar creation successful for ${DUMP_NAME}."
    echo "PUSHING BACKUP TO S3"
    echo "${PWD}"
    aws s3 cp ${DUMP_NAME}.tar.gz s3://${BUCKET_URL}
  else
    echo "Error creating tar for ${DUMP_NAME}."
  fi
else
  echo "Mongodump failed for ${DUMP_NAME}."
fi

PUSH_STATUS=$?

  if [ ${PUSH_STATUS} -eq 0 ]
    then
	    echo "REMOVING ${DUMP_NAME}.tar.gz and ${DUMP_NAME}"
    	    sudo rm -rf ${DUMP_NAME}*
	    echo "BACKUP SUCCESSFULLY DELETED"
  else
	  echo "BACkUP not PUSHED"

  fi	  

echo "-----------FINISHED---------"  
date
echo "----------------------------"
