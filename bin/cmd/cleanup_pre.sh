CMD_DESCRIPTION="Stops and removes the component(s) from the host machine."

athena.os.usage 1 "<all|type>" "$(cat <<EOF
    <all|type> ; Stops all components or a specific component type and removes
               ; their corresponding images.
EOF
)"

type=$(athena.arg 1)
types=()

athena.info "Do you want to stop all related containers for the type '$type' (Y/n)?"
read answer
if [[ "$answer" == "n" ]]; then
	athena.exit 0
fi

case "$type" in
	"all")
		athena.plugins.selenium.stop_all_hubs
		athena.plugins.selenium.stop_all_browsers
		types+=(hub firefox firefox-debug chrome chrome-debug phantomjs)
	;;
	"hub")
		athena.plugins.selenium.stop_all_hubs
		types+=(hub)
	;;
	"firefox"|"firefox-debug"|"chrome"|"chrome-debug"|"phantomjs")
		types+=("$type")
		athena.plugins.selenium.stop_all_browsers "$type"
	;;
	*)
		athena.fatal "Unrecognized component ${type}."
	;;
esac

for type_to_remove in "${types[@]}"; do
	athena.plugins.selenium.remove_images_of_type "$type_to_remove"
done
