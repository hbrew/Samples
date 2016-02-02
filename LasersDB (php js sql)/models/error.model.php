<?php

class Error {
	private $message = "";
	private $priority = 0;

	public function __construct($message, $priority = 0) {
		$this->message = $message;
		$this->priority = $priority;
		$this->handle();
	}

	private function handle() {
		if ($this->priority = 1) {
			exit($this->message);
		}
		echo $this->message;
	}
}

?>