<?php

class View {
	private $context = array();

	function __construct() {
		$this->cleanArgs();
		$this->context['STATIC'] = $GLOBALS['static_dir'];
	}
	
	public function getHome() {
		$this->render('index.html');
	}

	public function getChart() {
		$this->context['CONTENT'] = $this->getStaticContent('sellmeier.php');
		$js = '<script src="js/chart.js"></script>';
		$js = $js . "\n";
		$js = $js . '<script src="js/sellmeier.js"></script>';
		$this->context['JS'] = $js;
		$this->render('index.html');
	}

	public function getSellmeier() {

	}

	public function getSellmeierData() {
		$sell = new Sellmeier();
		$sell->loadMaterialsData();

		// Make material selection if it exists
		if(isset($_GET['selection'])) {
			// Parse selection
			$selection = json_decode(urldecode($_GET['selection']));
			//print_r($selection);
			if(!$sell->selectMaterials($selection)) {
				$errors[] = new Error("Materials do not exist", 1);
			}
			// Parse legend
			$legend = array();
			if(isset($_GET['legend']) && is_array($_GET['legend']) && count($_GET['legend']) == count($selection)) {
				$legend = $_GET['legend'];
			} else {
				foreach($selection as $material => $array) {
					foreach($array as $key => $axis) {
						$legend[] = $material . " (axis " . $axis . ")";
					}
				}
			}
			$sell->legend($legend);

			// Parse title
			if(isset($_GET['title'])) {
				$title = $_GET['title'];
				$sell->title($title);
			}

			// Parse domain
			$xmin = .4;
			$xmax = 1;
			$step = .001;
			if(isset($_GET['xmin']) && isset($_GET['xmax']) && isset($_GET['step'])) {
				if(is_numeric($_GET['xmin']) && is_numeric($_GET['xmax']) && is_numeric($_GET['step'])) {
					$xmin = $_GET['xmin'] + 0;
					$xmax = $_GET['xmax'] + 0;
					$step = $_GET['step'] + 0;
				} else {
					$errors[] = new Error("Wavelength range must be a number", 2);
				}
			}
			$sell->setX($xmin, $xmax, $step);
			$sell->setY();
			// Output plot data
			echo $sell->getJson();
		} else {
			// Output materials list
			echo $sell->getMaterialsJson();
		}
	}

	private function cleanArgs() {

	}

	private function getStaticContent($page) {
		$content_path = $GLOBALS['content_dir'] . $page;
		return file_get_contents($content_path);
	}

	private function render($page) {
		$template_path = $GLOBALS['template_dir'] . $page;
		$template = file_get_contents($template_path);
		foreach($this->context as $var => $value) {
			$template = str_replace("{{ $var }}", $value, $template);
		}
		$output = preg_replace('/\{\{.+?\}\}/', '', $template);
		echo $output;
	}

}

?>