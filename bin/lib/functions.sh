# This function starts the component with the given image name and instance.
# USAGE: athena.plugins.selenium.start_component <name_prefix> <docker_image> <instance_id> <string_in_logs> [<docker_option>...]
# RETURN: 0 (true), 1 (false)
function athena.plugins.selenium.start_component()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "name prefix"
	athena.argument.argument_is_not_empty_or_fail "$2" "docker image"
	athena.argument.argument_is_not_empty_or_fail "$3" "instance id"
	athena.argument.argument_is_not_empty_or_fail "$4" "string in logs"
	local name_prefix=$1
	local docker_image="$2"
	local instance_id="$3"
	local string_in_logs="$4"

	local container_name="${name_prefix}-${instance_id}-$(athena.os.get_instance)"
	local -a docker_options=("-d" "--name" "$container_name" "${@:5}")

	if athena.docker.is_container_running "$container_name"; then
		athena.os.exit_with_msg "container '$container_name' already started"
	fi

	athena.color.print_info "starting '$container_name'"

	athena.docker.run "${docker_options[@]}" "$docker_image" 1>/dev/null
	if [ $? -ne 0 ]; then
		athena.os.exit_with_msg "problem starting container '$container_name'!"
	fi
	athena.docker.wait_for_string_in_container_logs "$container_name" "$string_in_logs"
}

# USAGE: athena.plugins.selenium._type_prefix <type>
function athena.plugins.selenium._type_prefix()
{
	case $1 in
		"hub")
			echo athena-selenium-hub
			;;
		"firefox"|"firefox-debug"|"chrome"|"chrome-debug"|"phantomjs")
			echo athena-selenium-node-$1
			;;
		*)
			athena.os.exit_with_msg "type '$1' not supported!"
			;;
	esac
}

# Start a Selenium Hub with given docker image and instance ID.
# USAGE: athena.plugins.selenium.start_hub <docker_image> <instance_id>
function athena.plugins.selenium.start_hub()
{
	local name_prefix="$(athena.plugins.selenium._type_prefix hub)"
	local docker_image=$1
	local instance_id=$2
	local string_in_logs="Selenium Grid hub is up and running"

	athena.plugins.selenium.start_component \
		"$name_prefix" \
		"$docker_image" \
		"$instance_id" \
		"$string_in_logs" \
		"${@:3}"
}

# Start a browser with given options. This function will wait for the
# container logs, to have the given <string_in_logs>.
# USAGE: athena.plugins.selenium.start_browser <type> <docker_image> <instance_id> <string_in_logs>
function athena.plugins.selenium.start_browser()
{
	local name_prefix="$(athena.plugins.selenium._type_prefix $1)"
	local docker_image=$2
	local instance_id=$3
	local string_in_logs="$4"

	athena.plugins.selenium.start_component \
		"$name_prefix" \
		"$docker_image" \
		"$instance_id" \
		"$string_in_logs" \
		"${@:5}"
}

# Start a Selenium browser of a given type., such as firefox, firefox-debug, etc.
# USAGE: athena.plugins.selenium.start_selenium_browser <type> <docker_image> <instance_id>
function athena.plugins.selenium.start_selenium_browser()
{
	local string_in_logs="The node is registered to the hub and ready to use"
	athena.plugins.selenium.start_browser "$1" "$2" "$3" "$string_in_logs" "${@:4}"
}

# Start a PhantomJS Browser with given image and instance ID.
# USAGE: athena.plugins.selenium.start_phantomjs_browser <docker_image> <instance_id>
function athena.plugins.selenium.start_phantomjs_browser()
{
	local string_in_logs="Registered with grid hub"
	athena.plugins.selenium.start_browser "phantomjs" "$1" "$2" "$string_in_logs" "${@:3}"
}



# Stop a component with a given container name and instance ID.
# E.g. athena.plugins.selenium.stop_component athena-selenium 1
# This would would stop the first running container with name athena-selenium.
# USAGE: athena.plugins.selenium.stop_component <container_name> <instance_id>
function athena.plugins.selenium.stop_component()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "container name"
	athena.argument.argument_is_not_empty_or_fail "$2" "instance id"
	athena.docker.stop_container "${1}-${2}-$(athena.os.get_instance)"
}

# Stop a running selenium hub with given instance ID.
# E.g. athena.plugins.selenium.stop_hub 1
# This would stop the first instance of a running selenium hub.
# USAGE: athena.plugins.selenium.stop_hub <instance_id>
function athena.plugins.selenium.stop_hub()
{
	local name_prefix="athena-selenium-hub"
	local instance_id="$1"
	athena.color.print_info "Stopping hub with port or instance id of '$instance_id'.."
	athena.plugins.selenium.stop_component "$name_prefix" "$instance_id"
}

# Stop a running browser of type and given instance ID.
# E.g. athena.plugins.selenium.stop_browser firefox 1
# This would stop the first running instance of a firefox browser.
# USAGE: athena.plugins.selenium.stop_browser <type> <instance_id>
function athena.plugins.selenium.stop_browser()
{
	local name_prefix="athena-selenium-node-${1}"
	local instance_id="$2"
	athena.color.print_info "Stopping $1 browser with port or instance id of '$instance_id'.."
	athena.plugins.selenium.stop_component "$name_prefix" "$instance_id"
}

# Stop all running selenium hubs.
# USAGE: athena.plugins.selenium.stop_all_hubs
function athena.plugins.selenium.stop_all_hubs()
{
	athena.color.print_info "Stopping all hubs..."
	athena.docker.stop_all_containers "athena-selenium-hub"
}

# Stop all running browsers. You can optionally define a browser type.
# E.g. athena.plugins.selenium.stop_all_browsers firefox
# USAGE: athena.plugins.selenium.stop_all_browsers [<type>]
function athena.plugins.selenium.stop_all_browsers()
{
	if [[ -z "$1" ]]; then
		athena.color.print_info "Stopping all browsers..."
		athena.docker.stop_all_containers "athena-selenium-node"
		return 0
	fi

	athena.color.print_info "Stopping all $1 browsers..."
	athena.docker.stop_all_containers "athena-selenium-node-$1"
}


# Get the image name for given type
# e.g. athena.plugins.selenium.get_image_name firefox
# USAGE: athena.plugins.selenium.get_image_name <type>
function athena.plugins.selenium.get_image_name()
{
	local type=$1

	case "$type" in
		"hub")
			echo "selenium/hub"
		;;
		"firefox"|"firefox-debug"|"chrome"|"chrome-debug")
			echo "selenium/node-${type}"
		;;
		"phantomjs")
			echo "akeem/selenium-node-phantomjs"
		;;
		*)
			athena.os.exit_with_msg "Unrecognized component ${type}."
		;;
	esac
}

# Remove all docker images of the specified type
# USAGE: athena.plugins.selenium.remove_images_of_type <type>
function athena.plugins.selenium.remove_images_of_type()
{
	local answer
	local image_name=$(athena.plugins.selenium.get_image_name $1)

	for image in $(athena.docker.images --format "{{.Repository}}:{{.Tag}}" | grep "^$image_name:"); do
		athena.color.print_info "Do you want to remove image '$image' (Y/n)?"
		read answer
		if [[ "$answer" != "n" ]]; then
			athena.docker.rmi -f "$image"
		fi
	done
}
