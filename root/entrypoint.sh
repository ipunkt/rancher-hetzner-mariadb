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
		while ! ansible-playbook install.yml --skip-tags "mysql-backup,mysql_backup_cluster"
		do sleep 1s
		done
	else
		while ! ansible-playbook install.yml
		do sleep 1s
		done
	fi
}

init() {
	export SERVER1=${SERVER1:-mysql01}
	export SERVER2=${SERVER2:-mysql02}

	export SERVER_TYPE="${SERVER_TYPE:-cx21}"
	export SERVER_LOCATION="${SERVER_LOCATION:-fsn1}"
	export EXTERNAL_STACK="${EXTERNAL_STACK:-Database}"
	export EXTERNAL_NAME="${EXTERNAL_NAME:-mysql}"

	export ADMIN_USERNAME="${ADMIN_USERNAME:-admin}"
	# Environment variable ADMIN_PASSWORD has no default

	export BACKUP="${BACKUP:-true}"
	export BACKUP_USER="${BACKUP_USER:-backup}"
	export BACKUP_PATH="${BACKUP_PATH:-/backup}"
	# Environment variable BACKUP_SERVER has no default
	# Environment variable BACKUP_KEY has no default

	export FLOATING_IP="${FLOATING_IP:-mysql}"

	export SSH_KEY_NAME="${SSH_KEY_NAME:-mysql_key}"
	export SSH_KEY_PATH="${SSH_KEY_PATH:-./id_rsa}"
	export CLUSTER_INI="${CLUSTER_INI:-./cluster.ini}"
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
