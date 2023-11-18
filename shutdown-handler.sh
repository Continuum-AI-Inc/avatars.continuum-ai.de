#!/bin/bash


# Function to handle shutdown signals
shutdown() {
	echo "Container stopped, performing cleanup..."
	echo "Generating database backup..."
	docker exec -t database pg_dumpall -c -U main > backup/dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql
	echo "Backup generated successfully!"

  # Continue with the default shutdown behavior
  exec "$@"
}

# Trap SIGTERM and SIGINT signals to call the shutdown function
trap 'shutdown' SIGTERM
trap 'shutdown' SIGINT

# Start your application
exec "$@"