CMD_DESCRIPTION="Starts a shell inside the component."

athena.usage 1 "<type> [--port=<port>|--instance=<instance_nr>]" "$(cat <<EOF
    <type>                     ; Starts shell in the specific <type> (hub, firefox, ...) or
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
instance_id=
if athena.argument.argument_exists "--port"; then
	athena.argument.get_argument_and_remove "--port" "instance_id"
elif athena.argument.argument_exists "--instance"; then
	athena.argument.get_argument_and_remove "--instance" "instance_id"
fi

if ! athena.docker.is_container_running "$container_name"; then
	athena.os.exit_with_msg "Container '$container_name' isn't running.."
fi

container_name=$(athena.plugins.selenium.get_container_name "$type" $instance_id)
athena.info "Placing you into the container '$container_name'..."
athena.docker.exec -ti "$container_name" /usr/bin/env bash
