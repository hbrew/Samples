<?php
include_once('conn.php');

function refractionIndex($lambda, $a, $b, $c, $d, $e) {
	return sqrt($a + $b*pow($lambda,2)/(pow($lambda,2) - $c) + $d*pow($lambda,2)/(pow($lambda,2) - $e));
}

function sellmeierCoeffs($cat_names, $mysqli) {
	// Set up array for saving data
	$materials = array();
	foreach($cat_names as $name) {
		$materials[$name] = array(
			'a' => 0,
			'b' => 0,
			'c' => 0,
			'd' => 0,
			'e' => 0
		);
	}

	// SQL calls
	foreach ($materials as $cat_name => $value) {
		$q = 'SELECT a_sell,b_sell,c_sell,d_sell,e_sell FROM sellmeir WHERE cat_name="'.$cat_name.'" LIMIT 1';
		$result = $mysqli->query($q);
		$row = $result->fetch_assoc();
		$materials[$cat_name]['a'] = $row['a_sell'];
		$materials[$cat_name]['b'] = $row['b_sell'];
		$materials[$cat_name]['c'] = $row['c_sell'];
		$materials[$cat_name]['d'] = $row['d_sell'];
		$materials[$cat_name]['e'] = $row['e_sell'];
	}

	return $materials;
}

// Materials to analyze
$cat_names = array('Al2O3', 'BaY2F8', 'LaCl3');

// Wavelength range in micrometers
$lambda_min = .2;
$d_lambda = .01;
$lambda_max = 1;
$lambdas = range($lambda_min, $lambda_max, $d_lambda);

$materials = sellmeierCoeffs($cat_names, $mysqli);
$refractions = array();
foreach($materials as $name => $coeffs) {
	$refractions[$name] = array();
	foreach($lambdas as $lambda) {		
		$refractions[$name][] = refractionIndex($lambda, 
			$coeffs['a'],
			$coeffs['b'],
			$coeffs['c'],
			$coeffs['d'],
			$coeffs['e']
		);
	}
}

$output = array();
$output[] = array_merge(array('Wavelength'), $cat_names);
foreach($lambdas as $key => $lambda) {
	$row = array($lambda);
	foreach($cat_names as $name) {
		$row[] = $refractions[$name][$key];
	}
	$output[] = $row;
}
echo json_encode($output);








?>