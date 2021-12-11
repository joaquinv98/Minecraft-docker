# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1
if [ -z ${FORCE_JAVA} ]; then
	# Use java for the version
		if [[ $MC_VERSION =~ ^1\.(18|19|20|21|22|23) ]] || [[ $MC_VERSION == "latest" ]]; then
		# Use Java 17
		export JAVA_VERSION="17"
	else
		if [[ $MC_VERSION =~ ^1\.(17) ]]; then
		# Use Java 16
		export JAVA_VERSION="16"
	else
		export JAVA_VERSION="8"
		fi
	fi
	else
		export JAVA_VERSION=${FORCE_JAVA}
fi

# Print Java version
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mjava -version\n"
java -version

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}