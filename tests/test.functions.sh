athena.plugin.require "selenium"

function testcase_athena.plugins.selenium.start_component()
{
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component"
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "name prefix"
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "name prefix" "docker image"
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "name prefix" "docker image" "instance id"

	athena.test.mock.returns "athena.docker.is_container_running" 0
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "name prefix" "docker image" "instance id"

	local name_prefix="my-container"
	local instance_id="1"
	local docker_image="myimage:latest"
	local string_in_logs="some string"
	local os_instance_id="1"
	local container_name="${name_prefix}-${instance_id}-${os_instance_id}"

	athena.test.mock.outputs "athena.os.get_instance" "$os_instance_id"
	athena.test.mock "athena.docker.is_container_running" "_echo_args"
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "$name_prefix" "$docker_image" "$instance_id" "$string_in_logs"

	athena.test.mock.returns "athena.docker.is_container_running" 1
	athena.test.mock "athena.color.print_info" "_void"
	athena.test.mock.returns "athena.docker.run" 1
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "$name_prefix" "$docker_image" "$instance_id" "$string_in_logs"

	local actual_output
	athena.test.mock "athena.docker.run" "_echo_to_var"
	athena.test.mock "athena.docker.wait_for_string_in_container_logs" "_echo_to_var"
	athena.plugins.selenium.start_component "$name_prefix" "$docker_image" "$instance_id" "$string_in_logs"

	local expected_output=$(cat -- <<EOF

-d --name $container_name $docker_image
$container_name $string_in_logs
EOF
)
	athena.test.assert_value "$actual_output" "$expected_output" "$name_prefix"

	actual_output=""
	athena.plugins.selenium.start_component "$name_prefix" "$docker_image" "$instance_id" "$string_in_logs" "--opt1" "--opt2"

	local expected_output=$(cat -- <<EOF

-d --name $container_name --opt1 --opt2 $docker_image
$container_name $string_in_logs
EOF
)
	athena.test.assert_value "$actual_output" "$expected_output" "$name_prefix"
}

function testcase_athena.plugins.selenium.start_hub()
{
	local name_prefix="myprefix"
	local docker_image="myimage:1.2.3"
	local instance_id="1"
	local string_in_logs="Selenium Grid hub is up and running"

	athena.test.mock.outputs "athena.plugins.selenium._type_prefix" "$name_prefix"
	athena.test.mock "athena.plugins.selenium.start_component" "_echo_args"
	athena.test.assert_output "athena.plugins.selenium.start_hub" "$name_prefix $docker_image $instance_id $string_in_logs" "$docker_image" "$instance_id"

	athena.test.assert_output "athena.plugins.selenium.start_hub" "$name_prefix $docker_image $instance_id $string_in_logs --opt1 --opt2" "$docker_image" "$instance_id" "--opt1" "--opt2"
}

function testcase_athena.plugins.selenium.start_browser()
{
	local name_prefix="myprefix"
	local docker_image="myimage:1.2.3"
	local instance_id="myinstance"
	local string_in_logs="Browser is registered"

	athena.test.mock.outputs "athena.plugins.selenium._type_prefix" "$name_prefix"
	athena.test.mock "athena.plugins.selenium.start_component" "_echo_args"
	athena.test.assert_output "athena.plugins.selenium.start_browser" "$name_prefix $docker_image $instance_id $string_in_logs" "browser" "$docker_image" "$instance_id" "$string_in_logs"

	athena.test.assert_output "athena.plugins.selenium.start_browser" "$name_prefix $docker_image $instance_id $string_in_logs --opt1 --opt2" "browser" "$docker_image" "$instance_id" "$string_in_logs" "--opt1" "--opt2"
}

function testcase_athena.plugins.selenium.start_selenium_browser()
{
	local type="firefox"
	local docker_image="selenium/sinpians:1.23"
	local instance_id="1"
	local string_in_logs="The node is registered to the hub and ready to use"
	athena.test.mock "athena.plugins.selenium.start_browser" "_echo_args"
	athena.test.assert_output "athena.plugins.selenium.start_selenium_browser" "$type $docker_image $instance_id $string_in_logs" "$type" "$docker_image" "$instance_id"
}

function testcase_athena.plugins.selenium.start_phantomjs_browser()
{
	local type="phantomjs"
	local docker_image="selenium/sinpians:1.23"
	local instance_id="1"
	local string_in_logs="Registered with grid hub"
	athena.test.mock "athena.plugins.selenium.start_browser" "_echo_args"
	athena.test.assert_output "athena.plugins.selenium.start_phantomjs_browser" "$type $docker_image $instance_id $string_in_logs" "$docker_image" "$instance_id"
}

function testcase_athena.plugins.selenium._type_prefix()
{
	athena.test.assert_output "athena.plugins.selenium._type_prefix" "athena-selenium-hub" "hub"
	athena.test.assert_output "athena.plugins.selenium._type_prefix" "athena-selenium-node-firefox" "firefox"
	athena.test.assert_output "athena.plugins.selenium._type_prefix" "athena-selenium-node-firefox-debug" "firefox-debug"
	athena.test.assert_output "athena.plugins.selenium._type_prefix" "athena-selenium-node-chrome" "chrome"
	athena.test.assert_output "athena.plugins.selenium._type_prefix" "athena-selenium-node-chrome-debug" "chrome-debug"
	athena.test.assert_output "athena.plugins.selenium._type_prefix" "athena-selenium-node-phantomjs" "phantomjs"

	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium._type_prefix" "i-dont-exist"
}

function testcase_athena.plugins.selenium.stop_component()
{
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.stop_component"
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.stop_component" "mycontainer"

	local container_name="mycontainer"
	local instance_id="1"
	local os_instance_id="1"
	athena.test.mock "athena.docker.stop_container" "_echo_args"
	athena.test.mock.outputs "athena.os.get_instance" "$os_instance_id"
	athena.test.assert_output "athena.plugins.selenium.stop_component" "${container_name}-${instance_id}-${os_instance_id}" "$container_name" "$instance_id"
}

function testcase_athena.plugins.selenium.stop_hub()
{
	local instance_id="myid"
	athena.test.mock "athena.color.print_info" "_void"
	athena.test.mock "athena.plugins.selenium.stop_component" "_echo_args"
	athena.test.assert_output "athena.plugins.selenium.stop_hub" "athena-selenium-hub $instance_id" "$instance_id"
}

function testcase_athena.plugins.selenium.stop_browser()
{
	local type="phantomjs"
	local instance_id="myid"
	athena.test.mock "athena.color.print_info" "_void"
	athena.test.mock "athena.plugins.selenium.stop_component" "_echo_args"
	athena.test.assert_output "athena.plugins.selenium.stop_browser" "athena-selenium-node-${type} ${instance_id}" "$type" "$instance_id"
}

function testcase_athena.plugins.selenium.stop_all_hubs()
{
	athena.test.mock "athena.docker.stop_all_containers" "_echo_args"
	athena.test.mock "athena.color.print_info" "_void"
	athena.test.assert_output "athena.plugins.selenium.stop_all_hubs" "athena-selenium-hub"
}

function testcase_athena.plugins.selenium.stop_all_browsers()
{
	athena.test.mock "athena.color.print_info" "_void"
	athena.test.mock "athena.docker.stop_all_containers" "_echo_args"
	athena.test.assert_output "athena.plugins.selenium.stop_all_browsers" "athena-selenium-node"

	local type="myphantom"
	athena.test.assert_output "athena.plugins.selenium.stop_all_browsers" "athena-selenium-node-$type" "$type"
}

function testcase_athena.plugins.selenium.get_image_name()
{
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/hub" "hub"
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-firefox" "firefox"
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-firefox-debug" "firefox-debug"
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-chrome" "chrome"
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-chrome-debug" "chrome-debug"
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "akeem/selenium-node-phantomjs" "phantomjs"

	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.get_image_name" "something"
}

function testcase_athena.plugins.selenium.remove_images_of_type()
{
	local type="mytype"
	local docker_image="some/image"
	athena.test.mock.outputs "athena.plugins.selenium.get_image_name" "$docker_image"
	athena.test.mock.outputs "athena.docker.images" "${docker_image}:1.23 ${docker_image}:5.01"
	athena.test.mock "athena.color.print_info" "_void"
	athena.test.mock "athena.docker.rmi" "_echo_args"

	local actual_output="$(echo y | athena.plugins.selenium.remove_images_of_type)"
	local expected_output=$(cat <<EOF
-f $docker_image:1.23
-f $docker_image:5.01
EOF
)
	athena.test.assert_value "$actual_output" "$expected_output"

	athena.test.mock.outputs "athena.docker.images" "${docker_image}:1.23"
	local actual_output="$(echo n | athena.plugins.selenium.remove_images_of_type)"
	athena.test.assert_value "$actual_output" ""
}

function _void()
{
	return 0
}

function _echo_args()
{
	echo $@
	return 0
}

function _echo_to_var()
{
	actual_output=$(cat <<EOF
$actual_output
$@
EOF
)
}
