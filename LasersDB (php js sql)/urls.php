<?php

require('views.php');

$page = '';
if (isset($_GET['page'])) {
	$page = $_GET['page'];
}
$view = new View;
if($page == '' || $page == 'home') {
	$view->getHome();
}
elseif($page == 'chart') {
	$view->getChart();
}
elseif($page == 'sellmeier') {
	$view->getSellmeierData();
}

?>