<?php

ini_set('display_errors', 'On');
error_reporting(E_ALL | E_STRICT);

$errors = array();

//magic quotes logic
if (get_magic_quotes_gpc())
{
function stripslashes_deep($value)
{
    $value = is_array($value) ?
    array_map('stripslashes_deep', $value) :
    stripslashes($value);
    return $value;
}
$_POST = array_map('stripslashes_deep', $_POST);
$_GET = array_map('stripslashes_deep', $_GET);
$_COOKIE = array_map('stripslashes_deep', $_COOKIE);
$_REQUEST = array_map('stripslashes_deep', $_REQUEST);
}

$static_dir = 'static/';
$template_dir = $static_dir . 'html/';
$content_dir = 'content/';

?>