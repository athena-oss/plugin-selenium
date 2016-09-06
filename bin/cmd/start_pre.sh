CMD_DESCRIPTION="Starts the component(s)."

athena.usage 2 "<type> <version> [--port=<port>|--instances=<nr_of_instances>] [<docker_options>...]" "$(cat <<EOF
    <type>                          ; Type of component (hub, firefox, firefox-debug, chrome, chrome-debug and phantomjs).
    <version>                       ; Version of the component. Check the documentation on how to get a list of available versions.
    [--port=<port>]                 ; Specifies which port to be exposed on the host machine.
    [--instances=<nr_of_instances>] ; Start <nr_of_instances> intances in parallel.
EOF
)"

# arguments are found below
type="$(athena.arg 1)"
version="$(athena.arg 2)"

# clearing arguments from the stack
athena.pop_args 2

instances=1
instance_name="default"
declare -a docker_options=()
if athena.argument.argument_exists "--port" && athena.argument.argument_exists "--instances"; then
	athena.fatal "you cannot select --port and --instances at the same time!"
fi

if athena.argument.argument_exists "--port"; then
	athena.argument.get_argument_and_remove "--port" "port"
	docker_options=("-p" "$port:4444")
	instance_name=$port
fi

# if instances are specified then automatic port binding will be used (if dockerfile exposes ports)
if athena.argument.argument_exists "--instances"; then
	athena.argument.get_argument_and_remove "--instances" "instances"
	docker_options=("-P")
	instance_name="multiple-0"
fi

# add other docker options
athena.argument.get_arguments "args"
docker_options+=("${args[@]}")
image_name=$(athena.plugins.selenium.get_image_name $type)
for ((i=1; i<=$instances; i++));
do
	case $type in
		"hub")
			athena.plugins.selenium.start_hub "$image_name:$version" "$instance_name" "${docker_options[@]}"
			;;
		"firefox"|"firefox-debug"|"chrome"|"chrome-debug")
			athena.plugins.selenium.start_selenium_browser "$type" "$image_name:$version" "$instance_name" "${docker_options[@]}"
			;;
		"phantomjs")
			athena.plugins.selenium.start_phantomjs_browser "$image_name:$version" "$instance_name" "${docker_options[@]}"
			;;
		*)
			athena.fatal "type '$type' not supported!"
			;;
	esac
	instance_name="multiple-$i"
done
