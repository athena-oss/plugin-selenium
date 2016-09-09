# Get container name for given component
# USAGE: athena.plugins.selenium.get_container_name [<type>] [<instance_id>]
function athena.plugins.selenium.get_container_name()
{
	local container_name
	container_name="$(athena.os.get_prefix)-selenium-$(athena.os.get_instance)"
	if [[ -n "$1" ]]; then
		container_name="$container_name-${1}"
	fi
	if [[ -n "$2" ]]; then
		container_name="$container_name-${2}"
	fi
	echo "$container_name"
}

# Get the image name for given type
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
			athena.os.exit_with_msg "Grid component '${type}' not supported...."
		;;
	esac
}


# This function starts the component with the given image name and instance.
# USAGE: athena.plugins.selenium.start_component <container_name> <image_name> <string_in_logs> [<docker_option>...]
# RETURN: 0 (true), 1 (false)
function athena.plugins.selenium.start_component()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "container name"
	athena.argument.argument_is_not_empty_or_fail "$2" "image name"
	athena.argument.argument_is_not_empty_or_fail "$3" "string in logs"
	local container_name="$1"
	local image_name="$2"
	local string_in_logs="$3"
	local docker_options=("-d" "--name" "$container_name" "${@:4}")

	if athena.docker.is_container_running "$container_name"; then
		athena.os.exit_with_msg "Container '$container_name' already started..."
	elif ! athena.docker.run "${docker_options[@]}" "$image_name" 1>/dev/null; then
		athena.os.exit_with_msg "Problem starting container '$container_name'..."
	fi
	athena.color.print_info "Starting '$container_name'..."
	athena.docker.wait_for_string_in_container_logs "$container_name" "$string_in_logs"
}

# Start a Selenium Hub of <version>.
# USAGE: athena.plugins.selenium.start_hub <version> <instance_id> [<docker_options>...]
function athena.plugins.selenium.start_hub()
{
	local container_name="$(athena.plugins.selenium.get_container_name hub $2)"
	local image_name="$(athena.plugins.selenium.get_image_name hub):${1}"
	local string_in_logs="Selenium Grid hub is up and running"
	local docker_options=("${@:3}")

	athena.plugins.selenium.start_component "$container_name" "$image_name" "$string_in_logs" "${docker_options[@]}"
}

# Start a browser with given options. This function will wait for the
# container logs, to have the given <string_in_logs>.
# USAGE: athena.plugins.selenium.start_browser <type> <version> <instance_id> <string_in_logs> [<docker_options>...]
function athena.plugins.selenium.start_browser()
{
	local container_name="$(athena.plugins.selenium.get_container_name $1 $3)"
	local image_name="$(athena.plugins.selenium.get_image_name $1):${2}"
	local string_in_logs="$4"
	local docker_options=("${@:5}")

	athena.plugins.selenium.start_component "$container_name" "$image_name" "$string_in_logs" "${docker_options[@]}"
}

# Start a Selenium browser of a given type., such as firefox, firefox-debug, etc.
# USAGE: athena.plugins.selenium.start_selenium_browser <type> <version> <instance_id> [<docker_options>...]
function athena.plugins.selenium.start_selenium_browser()
{
	local docker_options=("${@:4}")
	local string_in_logs="The node is registered to the hub and ready to use"
	athena.plugins.selenium.start_browser "$1" "$2" "$3" "$string_in_logs" "${docker_options[@]}"
}

# Start a PhantomJS Browser with given image and instance ID.
# USAGE: athena.plugins.selenium.start_phantomjs_browser <version> <instance_id> [<docker_options>...]
function athena.plugins.selenium.start_phantomjs_browser()
{
	local string_in_logs="Registered with grid hub"
	local docker_options=("${@:3}")
	athena.plugins.selenium.start_browser "phantomjs" "$1" "$2" "$string_in_logs" "${docker_options[@]}"
}

# Stop a running selenium hub with given instance ID.
# This would stop the first instance of a running selenium hub.
# USAGE: athena.plugins.selenium.stop_components [<type>] [<instance_id>]
function athena.plugins.selenium.stop_components()
{
	athena.docker.stop_all_containers "$(athena.plugins.selenium.get_container_name $1 $2)" --global
}

# Remove all docker images of the specified type
# USAGE: athena.plugins.selenium.remove_images_of_type <type>
function athena.plugins.selenium.remove_images_of_type()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "type"
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

# USAGE: athena.plugins.selenium.add_link_to_docker_options <type> <link_name>
function athena.plugins.selenium.add_link_to_docker_options()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "type"
	athena.argument.argument_is_not_empty_or_fail "$2" "link_name"
	local type="$1"
	local link_name="$2"

	if athena.argument.argument_exists_and_remove "--skip-${type}"; then
		athena.color.print_info "Skipping auto link with ${type}..."
		return 1
	fi

	container_name=
	if athena.argument.argument_exists "--link-${type}"; then
		athena.argument.get_argument_and_remove "--link-${type}" "container_name"

		if ! athena.docker.is_container_running "$container_name"; then
			athena.os.exit_with_msg "Failed to auto link with ${type} '${container_name}'. Container is not running.."
		fi
	else
		if [[ "$type" == "proxy" ]]; then
			athena.plugin.require "proxy" "0.3.1"
			container_name=$(athena.plugins.proxy.get_container_name)
		else
			container_name="$(athena.plugins.selenium.get_container_name $type)"
		fi

		if ! athena.docker.is_container_running "$container_name"; then
			athena.color.print_debug "Skipped auto link with ${type} '${container_name}'. Container is not running."
			return 1
		fi
	fi

	athena.color.print_info "Auto linking with $type container '${container_name}'..."
	docker_options+=("--link" "${container_name}:${link_name}")
}
