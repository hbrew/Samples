<?php

class Sellmeier extends Plot {
	private $materials = array();
	private $selection = array();
	private $db;

	function __construct() {
		$this->db = new MySQL;
		$this->title("N Vs. Wavelength");
		$this->xlabel("Wavelength (micrometers)");
		$this->ylabel("Index of Refraction");
	}

	public function setX($min, $max, $step) {
		$this->xdata = range($min, $max, $step);
	}

	public function loadMaterialsData() {
		$q = 'SELECT cat_name,sell_ax,a_sell,b_sell,c_sell,d_sell,e_sell FROM sellmeir';
		$result = $this->db->query($q);
		while($row = $result->fetch_assoc()) {
			foreach(array('a','b','c','d','e') as $key => $coeff) {
				$this->materials[$row['cat_name']][strval($row['sell_ax'])][$coeff] = $row[$coeff.'_sell'];
			}
		}
	}

	public function getMaterialsJson() {
		return json_encode($this->materials);
	}

	public function selectMaterials($array) {
		foreach($array as $name => $axis_array) {
			foreach($axis_array as $key => $axis) {
				$q = "SELECT a_sell,b_sell,c_sell,d_sell,e_sell FROM sellmeir WHERE cat_name='".$name."' AND sell_ax='".$axis."'";
				$result = $this->db->query($q);
				if($result->num_rows < 1) {
					return false;
				}
				$rows = $result->fetch_assoc();
				foreach(array('a','b','c','d','e') as $key => $coeff) {
					$this->selection[$name][$axis][$coeff] = $rows[$coeff.'_sell'];  
				}
			}
		}
		return true;
	}

	public function getSelection() {
		return $this->selection;
	}

	private function calcSellmeier($lambda, $a, $b, $c, $d, $e) {
		return sqrt(abs($a + $b*pow($lambda,2)/(pow($lambda,2) - $c) + $d*pow($lambda,2)/(pow($lambda,2) - $e)));
	}

	public function setY() {
		foreach($this->selection as $name => $axis_array) {
			foreach($axis_array as $axis => $coeffs) {
				$legend = $name.'.'.$axis;
				$this->ydata[$legend] = array();
				foreach($this->xdata as $x) {	
					$this->ydata[$legend][] = $this->calcSellmeier($x, 
						$coeffs['a'],
						$coeffs['b'],
						$coeffs['c'],
						$coeffs['d'],
						$coeffs['e']
					);
				}
			}
		}
	}


}

?>