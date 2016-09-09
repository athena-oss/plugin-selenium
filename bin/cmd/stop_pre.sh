CMD_DESCRIPTION="Stops the component(s)"

athena.os.usage 1 "<all|type> [--port=<port>|--instance=<instance_nr>]" "$(cat <<EOF
    <all|type>                 ; Stops all components or a specific component type:
                               ; hub, firefox, firefox-debug, chrome, chrome-debug, phantomjs
    [--port=<port>]            ; Stop a component in a specific port. If not specified, all
                               ; components of <type> will be stopped.
                               ; (this option is mutually exclusive with --instance)
    [--instance=<instance_nr>] ; If the <type> was started with --instances=<nr_of_instances>
                               ; the <instance_nr> must be specified to access an instance
                               ; so in case 'start --instances=3' was called before --instance
                               ; can be 0,1 or 2
                               ; (this option is mutually exclusive with --port)
EOF
)"

type=$(athena.arg 1)
athena.argument.pop_arguments 1

instance_id=
if athena.argument.argument_exists "--port"; then
	athena.argument.get_argument_and_remove "--port" "instance_id"
elif athena.argument.argument_exists "--instance"; then
	athena.argument.get_argument_and_remove "--instance" "instance_id"
fi

if [[ -n "$instance_id" ]]; then
	athena.info "Criteria: port or instance id of ${instance_id} set..."
fi

case "$type" in
	"all")
		athena.info "Stopping all components..."
		athena.plugins.selenium.stop_components
	;;
	"hub")
		athena.info "Stopping hub..."
		athena.plugins.selenium.stop_components "hub" $instance_id
	;;
	"firefox"|"firefox-debug"|"chrome"|"chrome-debug"|"phantomjs")
		athena.info "Stopping ${type}..."
		athena.plugins.selenium.stop_components "$type" $instance_id
	;;
	*)
		athena.fatal "Unrecognized component ${type}."
	;;
esac
