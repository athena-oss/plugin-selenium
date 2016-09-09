CMD_DESCRIPTION="Starts the component(s)."

athena.usage 2 "<type> <version> [--port=<port>|--instances=<nr_of_instances>] [<docker_options>...]" "$(cat <<EOF
    <type>                          ; Type of component (hub, firefox, firefox-debug, chrome, chrome-debug and phantomjs).
    <version>                       ; Version of the component. Check the documentation on how to get a list of available versions.
	[--skip-hub]                    ; Dont link automatically with local selenium hub container.
	[--skip-proxy]                  ; Dont link automatically with local proxy container.
	[--link-hub=<container_name>]   ; Link with the nodes with selenium hub <container_name>. (link name: hub)
	[--link-proxy=<container_name>] ; Link with the nodes with proxy <container_name>. (link name: athena-proxy)
    [--port=<port>]                 ; Specifies which port to be exposed on the host machine.
    [--instances=<nr_of_instances>] ; Start <nr_of_instances> intances in parallel.
EOF
)"

# arguments are found below
type="$(athena.arg 1)"
version="$(athena.arg 2)"

# clearing arguments from the stack
athena.pop_args 2

if athena.argument.argument_exists "--port" && athena.argument.argument_exists "--instances"; then
	athena.fatal "You cannot select --port and --instances at the same time..."
fi

docker_options=()
instance_id=
if athena.argument.argument_exists "--port"; then
	athena.argument.get_argument_and_remove "--port" "port"
	docker_options=("-p" "$port:4444")
	instance_id=$port
fi

instances=1
if athena.argument.argument_exists "--instances"; then
	athena.argument.get_argument_and_remove "--instances" "instances"
	docker_options=("-P")
fi

if [[ "$type" != "hub" ]]; then
	athena.plugins.selenium.add_link_to_docker_options "hub" "hub"
	athena.plugins.selenium.add_link_to_docker_options "proxy" "athena-proxy"
fi

# add other docker options
athena.argument.get_arguments "args"
docker_options+=("${args[@]}")
for ((i=1; i<=$instances; i++));
do
	case $type in
		"hub")
			athena.plugins.selenium.start_hub "$version" "$instance_id" "${docker_options[@]}"
			;;
		"firefox"|"firefox-debug"|"chrome"|"chrome-debug")
			athena.plugins.selenium.start_selenium_browser "$type" "$version" "$instance_id" "${docker_options[@]}"
			;;
		"phantomjs")
			athena.plugins.selenium.start_phantomjs_browser "$version" "$instance_id" "${docker_options[@]}"
			;;
		*)
			athena.fatal "Grid component '$type' not supported..."
			;;
	esac
	instance_id=$i
done
