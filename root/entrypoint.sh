#!/bin/sh

if [ -z "${HCLOUD_TOKEN}" ] ; then
	echo "HCLOUD_TOKEN missing!"
	echo
	echo "Please set it to a hetzner cloud api token for the enviornment the server"
	echo "Should be created in."
	sleep 60s
	exit 1
fi

if [ -z "${CATTLE_URL}" ] ; then
	echo "No Cattle URL was specified. Exiting."
	echo "Please set the environment variable CATTLE_URL to your rancher api url"
	echo ""
	echo "Note that Rancher sets this variable for you if you specify the following labels"
	echo "io.rancher.container.create_agent=true"
	echo "io.rancher.container.agent.role=environmentAdmin,agent"
	exit 1
fi

start() {

	cd /opt/playbook
	if [ "${BACKUP}" != "true" ] ; then
		ansible-playbook install.yml --skip-tags mysql_backup,mysql_backup_cluster
	else
		ansible-playbook install.yml
	fi
}

init() {
	SERVER1=${SERVER1:-mysql01}
	SERVER2=${SERVER1:-mysql02}

	SERVER_TYPE="${SERVER_TYPE:-cx21}"
	SERVER_LOCATION="${SERVER_LOCATION:-fsn1}"
	EXTERNAL_STACK="${EXTERNAL_STACK:-Database}"
	EXTERNAL_NAME="${EXTERNAL_NAME:-mysql}"

	ADMIN_USERNAME="${ADMIN_USERNAME:-admin}"
	# Environment variable ADMIN_PASSWORD has no default

	BACKUP="${BACKUP:-true}"
	# Environment variable BACKUP_URL has no default
	# Environment variable BACKUP_KEY has no default

	FLOATING_IP="${FLOATING_IP:-mysql}"

	SSH_KEY_NAME="${SSH_KEY_NAME:-mysql_key}"
	SSH_KEY_PATH="${SSH_KEY_PATH:-./id_rsa}"
	CLUSTER_INI="${CLUSTER_INI:-./cluster.ini}"
}

init

COMMAND=${1}
case ${COMMAND} in
	wait)
		echo "Debug entrypoint 'wait': sleeping for 3600s, use this time to exec into the container"
		sleep 3600s
		;;
	*)
		start
		;;
esac
