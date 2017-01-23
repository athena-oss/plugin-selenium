function testcase_athena.plugins.selenium.get_container_name()
{
	bashunit.test.mock.outputs "athena.os.get_prefix" "myprefix"
	bashunit.test.mock.outputs "athena.os.get_instance" "1"

	bashunit.test.assert_output "athena.plugins.selenium.get_container_name" "myprefix-selenium-1"
	bashunit.test.assert_output "athena.plugins.selenium.get_container_name" "myprefix-selenium-1-mycontainer" "mycontainer"
	bashunit.test.assert_output "athena.plugins.selenium.get_container_name" "myprefix-selenium-1-mycontainer-myid" "mycontainer" "myid"
}

function testcase_athena.plugins.selenium.get_image_name()
{
	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.get_image_name"

	bashunit.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/hub" "hub"
	bashunit.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-firefox" "firefox"
	bashunit.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-firefox-debug" "firefox-debug"
	bashunit.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-chrome" "chrome"
	bashunit.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-chrome-debug" "chrome-debug"
	bashunit.test.assert_output "athena.plugins.selenium.get_image_name" "akeem/selenium-node-phantomjs" "phantomjs"

	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.get_image_name" "something"
}

function testcase_athena.plugins.selenium.start_component()
{
	local container_name="mycontainer"
	local image_name="myimage:1.3.4"
	local string_in_logs="some string"

	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component"
	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "$container_name" "$image_name"

	bashunit.test.mock.returns "athena.docker.is_container_running" 0
	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "$container_name" "$image_name" "$string_in_logs"

	bashunit.test.mock.returns "athena.docker.is_container_running" 1
	bashunit.test.mock.returns "athena.docker.run" 1
	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "$container_name" "$image_name" "$string_in_logs"

	bashunit.test.mock "athena.docker.run" "_echo_args"
	bashunit.test.mock "athena.color.print_info" "_void"
	bashunit.test.mock "athena.docker.run" "_echo_to_var"
	bashunit.test.mock "athena.docker.wait_for_string_in_container_logs" "_echo_to_var"
	local expected_output="$(cat <<EOF

-d --name $container_name $image_name
$container_name $string_in_logs
EOF
)"
	local actual_output=
	athena.plugins.selenium.start_component "$container_name" "$image_name" "$string_in_logs"
	bashunit.test.assert_value "$actual_output" "$expected_output"

	local expected_output="$(cat <<EOF

-d --name $container_name -v /opt/myapp $image_name
$container_name $string_in_logs
EOF
)"
	local actual_output=
	athena.plugins.selenium.start_component "$container_name" "$image_name" "$string_in_logs" -v /opt/myapp
	bashunit.test.assert_value "$actual_output" "$expected_output"
}

function testcase_athena.plugins.selenium.start_hub()
{
	bashunit.test.mock "athena.plugins.selenium.get_image_name" "_echo_args"
	bashunit.test.mock "athena.plugins.selenium.get_container_name" "_echo_args"
	bashunit.test.mock "athena.plugins.selenium.start_component" "_echo_args"

	local version="1.2.3"
	local instance_id="34"
	local expected_output="hub ${instance_id} hub:${version} Selenium Grid hub is up and running"
	bashunit.test.assert_output "athena.plugins.selenium.start_hub" "${expected_output}" "$version" "$instance_id"
	bashunit.test.assert_output "athena.plugins.selenium.start_hub" "${expected_output} -v /opt/myapp" "$version" "$instance_id" -v /opt/myapp
}

function testcase_athena.plugins.selenium.start_browser()
{
	bashunit.test.mock "athena.plugins.selenium.get_container_name" "_echo_args"
	bashunit.test.mock "athena.plugins.selenium.get_image_name" "_echo_args"
	bashunit.test.mock "athena.plugins.selenium.start_component" "_echo_args"

	local type="mytype"
	local version="1.2.3"
	local instance_id="134"
	local string_in_logs="my string in the logs"
	local expected_output="$type $instance_id ${type}:${version} $string_in_logs"
	bashunit.test.assert_output "athena.plugins.selenium.start_browser" "${expected_output}" "$type" "$version" "$instance_id" "$string_in_logs"
	bashunit.test.assert_output "athena.plugins.selenium.start_browser" "${expected_output} --link something:spinpans" "$type" "$version" "$instance_id" "$string_in_logs" --link something:spinpans
}

function testcase_athena.plugins.selenium.start_selenium_browser()
{
	bashunit.test.mock "athena.plugins.selenium.start_browser" "_echo_args"

	local type="mytype"
	local version="1.4.5"
	local instance_id="533"
	local expected_output="$type $version $instance_id The node is registered to the hub and ready to use"

	bashunit.test.assert_output "athena.plugins.selenium.start_selenium_browser" "$expected_output" "$type" "$version" "$instance_id"
	bashunit.test.assert_output "athena.plugins.selenium.start_selenium_browser" "$expected_output --someoption" "$type" "$version" "$instance_id" --someoption
}

function testcase_athena.plugins.selenium.start_phantomjs_browser()
{
	bashunit.test.mock "athena.plugins.selenium.start_browser" "_echo_args"

	local version="1.4.5"
	local instance_id="533"
	local expected_output="phantomjs $version $instance_id Registered with grid hub"

	bashunit.test.assert_output "athena.plugins.selenium.start_phantomjs_browser" "$expected_output" "$version" "$instance_id"
	bashunit.test.assert_output "athena.plugins.selenium.start_phantomjs_browser" "$expected_output --someoption" "$version" "$instance_id" --someoption
}

function testcase_athena.plugins.selenium.stop_components()
{
	bashunit.test.mock "athena.plugins.selenium.get_container_name" "_echo_args"
	bashunit.test.mock "athena.docker.stop_all_containers" "_echo_args"

	bashunit.test.assert_output "athena.plugins.selenium.stop_components" "--global"
	bashunit.test.assert_output "athena.plugins.selenium.stop_components" "firefox --global" "firefox"
	bashunit.test.assert_output "athena.plugins.selenium.stop_components" "firefox 1 --global" "firefox" "1"
}

function testcase_athena.plugins.selenium.add_link_to_docker_options()
{
	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.add_link_to_docker_options"
	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.add_link_to_docker_options" "hub"

	athena.argument.set_arguments "--skip-hub" "hub"
	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.add_link_to_docker_options" "hub" "hub"

	local container_name="mycontainer"
	athena.argument.set_arguments "--link-hub=${container_name}"
	bashunit.test.mock.returns "athena.docker.is_container_running" 1
	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.add_link_to_docker_options" "hub" "hub"

	docker_options=()
	athena.argument.set_arguments "--link-hub=${container_name}"
	bashunit.test.mock.returns "athena.docker.is_container_running" 0
	bashunit.test.mock "athena.color.print_info" "_void"
	athena.plugins.selenium.add_link_to_docker_options "hub" "hub"
	bashunit.test.assert_value "${docker_options[*]}" "--link ${container_name}:hub"

	athena.argument.set_arguments
	bashunit.test.mock.returns "athena.docker.is_container_running" 1
	bashunit.test.mock "athena.color.print_debug" "_void"
	bashunit.test.assert_exit_code.expects_fail "athena.plugins.selenium.add_link_to_docker_options"

	docker_options=()
	container_name="acontainer"
	bashunit.test.mock "athena.plugin.require" "_void"
	bashunit.test.mock.outputs "athena.plugins.proxy.get_container_name" "$container_name"
	bashunit.test.mock.returns "athena.docker.is_container_running" 0
	athena.plugins.selenium.add_link_to_docker_options "proxy" "athena-proxy"
	bashunit.test.assert_value "${docker_options[*]}" "--link ${container_name}:athena-proxy"

	docker_options=()
	athena.plugins.selenium.add_link_to_docker_options "hub" "hub-spinpans"
	bashunit.test.assert_value "${docker_options[*]}" "--link ${container_name}:hub-spinpans"
}

function _void()
{
	return 0
}

function _echo_args()
{
	echo $@
}

function _echo_to_var()
{
	actual_output=$(cat <<EOF
$actual_output
$@
EOF
)
}
