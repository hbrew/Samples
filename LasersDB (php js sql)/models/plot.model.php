<?php

class Plot extends MySQL {
	public $title = '';
	public $xlabel = '';
	public $ylabel = '';
	public $legend = array();
	public $xdata = array();
	public $ydata = array();

	public function legend($str_array) {
		$this->legend = $str_array;
	}

	public function title($str) {
		$this->title = $str;
	}

	public function xlabel($str) {
		$this->xlabel = $str;
	}

	public function ylabel($str) {
		$this->ylabel = $str;
	}

	public function getY() {
		return $this->ydata;
	}

	public function getJson() {
		$output = array();
		$output[] = array_merge(array($this->ylabel), $this->legend);
		foreach($this->xdata as $i => $x) {
			$row = array($x);
			foreach($this->ydata as $key => $values) {
				$row[] = $values[$i];
			}
			$output[] = $row;
		}
		return json_encode($output);
	}
}



?>