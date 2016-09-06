CMD_DESCRIPTION="Starts a shell inside the component."

athena.usage 1 "<type|component_name> [--port=<port>|--instance=<instance_nr>]" "$(cat <<EOF
    <type|component_name>      ; Starts shell in the specific <type> (hub, firefox, ...) or
                               ; in the <component_name> like seen in 'athena info' output
    [--port=<port>]            ; In case the <type> to access was not started without a port
                               ; the <port> needs to be specified
                               ; (this option is mutually exclusive with --instance)
    [--instance=<instance_nr>] ; If the <type> was started with --instances=<nr_of_instances>
                               ; the <instance_nr> must be specified to access an instance
                               ; so in case 'start --instances=3' was called before --instance
                               ; can be 0,1 or 2
                               ; (this option is mutually exclusive with --port)
EOF
)"

type="$(athena.arg 1)"
port=""
instance_nr=""

if athena.argument.argument_exists "--port"; then
	athena.argument.get_argument_and_remove "--port" "port"
fi

if athena.argument.argument_exists "--instance"; then
	athena.argument.get_argument_and_remove "--instance" instance_nr
fi

if [ -n "$port" -a -n "$instance_nr" ]; then
	athena.fatal "you cannot select --port and --instance at the same time!"
fi

port=${port:-default}

# athena.arg(1) == component name
if athena.docker.is_container_running "$type"; then
	container_name=$type
else
	if [ -n "$instance_nr" ]; then
		container_name="$(athena.plugins.selenium._type_prefix $type)-multiple-$instance_nr-$(athena.os.get_instance)"
	else
		container_name="$(athena.plugins.selenium._type_prefix $type)-$port-$(athena.os.get_instance)"
	fi

	if ! athena.docker.is_container_running "$container_name"; then
		athena.os.exit_with_msg "container '$container_name' isn't running"
	fi
fi


athena.info "placing you into the container '$container_name'"
athena.docker.exec -ti "$container_name" /usr/bin/env bash
