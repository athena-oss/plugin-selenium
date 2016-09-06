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

case "$type" in
	"all")
		athena.plugins.selenium.stop_all_hubs
		athena.plugins.selenium.stop_all_browsers
	;;
	"hub")
		if [ -n "$port" ]; then
			athena.plugins.selenium.stop_hub "$port"
		elif [ -n "$instance_nr" ]; then
			athena.plugins.selenium.stop_hub "multiple-$instance_nr"
		else
			athena.plugins.selenium.stop_all_hubs
		fi
	;;
	"firefox"|"firefox-debug"|"chrome"|"chrome-debug"|"phantomjs")
		if [ -n "$port" ]; then
			athena.plugins.selenium.stop_browser "$type" "$port"
		elif [ -n "$instance_nr" ]; then
			athena.plugins.selenium.stop_browser "$type" "multiple-$instance_nr"
		else
			athena.plugins.selenium.stop_all_browsers "$type"
		fi
	;;
	*)
		athena.fatal "Unrecognized component ${type}."
	;;
esac
