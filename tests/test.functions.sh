athena.plugin.require "selenium"

function testcase_athena.plugins.selenium.get_container_name()
{
	athena.test.mock.outputs "athena.os.get_prefix" "myprefix"
	athena.test.mock.outputs "athena.os.get_instance" "1"

	athena.test.assert_output "athena.plugins.selenium.get_container_name" "myprefix-selenium-1"
	athena.test.assert_output "athena.plugins.selenium.get_container_name" "myprefix-selenium-1-mycontainer" "mycontainer"
	athena.test.assert_output "athena.plugins.selenium.get_container_name" "myprefix-selenium-1-mycontainer-myid" "mycontainer" "myid"
}

function testcase_athena.plugins.selenium.get_image_name()
{
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.get_image_name"

	athena.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/hub" "hub"
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-firefox" "firefox"
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-firefox-debug" "firefox-debug"
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-chrome" "chrome"
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "selenium/node-chrome-debug" "chrome-debug"
	athena.test.assert_output "athena.plugins.selenium.get_image_name" "akeem/selenium-node-phantomjs" "phantomjs"

	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.get_image_name" "something"
}

function testcase_athena.plugins.selenium.start_component()
{
	local container_name="mycontainer"
	local image_name="myimage:1.3.4"
	local string_in_logs="some string"

	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component"
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "$container_name" "$image_name"

	athena.test.mock.returns "athena.docker.is_container_running" 0
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "$container_name" "$image_name" "$string_in_logs"

	athena.test.mock.returns "athena.docker.is_container_running" 1
	athena.test.mock.returns "athena.docker.run" 1
	athena.test.assert_exit_code.expects_fail "athena.plugins.selenium.start_component" "$container_name" "$image_name" "$string_in_logs"

	athena.test.mock "athena.docker.run" "_echo_args"
	athena.test.mock "athena.color.print_info" "_void"
	athena.test.mock "athena.docker.run" "_echo_to_var"
	athena.test.mock "athena.docker.wait_for_string_in_container_logs" "_echo_to_var"
	local expected_output="$(cat <<EOF

-d --name $container_name $image_name
$container_name $string_in_logs
EOF
)"
	local actual_output=
	athena.plugins.selenium.start_component "$container_name" "$image_name" "$string_in_logs"
	athena.test.assert_value "$actual_output" "$expected_output"

	local expected_output="$(cat <<EOF

-d --name $container_name -v /opt/myapp $image_name
$container_name $string_in_logs
EOF
)"
	local actual_output=
	athena.plugins.selenium.start_component "$container_name" "$image_name" "$string_in_logs" -v /opt/myapp
	athena.test.assert_value "$actual_output" "$expected_output"
}

function testcase_athena.plugins.selenium.start_hub()
{
	athena.test.mock "athena.plugins.selenium.get_image_name" "_echo_args"
	athena.test.mock "athena.plugins.selenium.get_container_name" "_echo_args"
	athena.test.mock "athena.plugins.selenium.start_component" "_echo_args"

	local version="1.2.3"
	local instance_id="34"
	local expected_output="hub ${instance_id} hub:${version} Selenium Grid hub is up and running"
	athena.test.assert_output "athena.plugins.selenium.start_hub" "${expected_output}" "$version" "$instance_id"
	athena.test.assert_output "athena.plugins.selenium.start_hub" "${expected_output} -v /opt/myapp" "$version" "$instance_id" -v /opt/myapp
}

function testcase_athena.plugins.selenium.start_browser()
{
	athena.test.mock "athena.plugins.selenium.get_container_name" "_echo_args"
	athena.test.mock "athena.plugins.selenium.get_image_name" "_echo_args"
	athena.test.mock "athena.plugins.selenium.start_component" "_echo_args"

	local type="mytype"
	local version="1.2.3"
	local instance_id="134"
	local string_in_logs="my string in the logs"
	local expected_output="$type $instance_id ${type}:${version} $string_in_logs"
	athena.test.assert_output "athena.plugins.selenium.start_browser" "${expected_output}" "$type" "$version" "$instance_id" "$string_in_logs"
	athena.test.assert_output "athena.plugins.selenium.start_browser" "${expected_output} --link something:spinpans" "$type" "$version" "$instance_id" "$string_in_logs" --link something:spinpans
}

function testcase_athena.plugins.selenium.start_selenium_browser()
{
	athena.test.mock "athena.plugins.selenium.start_browser" "_echo_args"

	local type="mytype"
	local version="1.4.5"
	local instance_id="533"
	local expected_output="$type $version $instance_id The node is registered to the hub and ready to use"

	athena.test.assert_output "athena.plugins.selenium.start_selenium_browser" "$expected_output" "$type" "$version" "$instance_id"
	athena.test.assert_output "athena.plugins.selenium.start_selenium_browser" "$expected_output --someoption" "$type" "$version" "$instance_id" --someoption
}

function testcase_athena.plugins.selenium.start_phantomjs_browser()
{
	athena.test.mock "athena.plugins.selenium.start_browser" "_echo_args"

	local version="1.4.5"
	local instance_id="533"
	local expected_output="phantomjs $version $instance_id Registered with grid hub"

	athena.test.assert_output "athena.plugins.selenium.start_phantomjs_browser" "$expected_output" "$version" "$instance_id"
	athena.test.assert_output "athena.plugins.selenium.start_phantomjs_browser" "$expected_output --someoption" "$version" "$instance_id" --someoption
}

function testcase_athena.plugins.selenium.stop_components()
{
	athena.test.mock "athena.plugins.selenium.get_container_name" "_echo_args"
	athena.test.mock "athena.docker.stop_all_containers" "_echo_args"

	athena.test.assert_output "athena.plugins.selenium.stop_components" "--global"
	athena.test.assert_output "athena.plugins.selenium.stop_components" "firefox --global" "firefox"
	athena.test.assert_output "athena.plugins.selenium.stop_components" "firefox 1 --global" "firefox" "1"
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
