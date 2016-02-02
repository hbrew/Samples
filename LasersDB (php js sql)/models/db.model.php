<?php

class MySQL {
	private $host = 'localhost';
	private $username = 'hunter';
	private $password = '';
	private $database = '';
	private $mysqli;

	function __construct() {
		$this->mysqli = new mysqli($this->host, $this->username, $this->password, $this->database);
		/* check connection */
		if (mysqli_connect_errno()) {
		    printf("Connect failed: %s\n", mysqli_connect_error());
		    exit();
		}
	}

	protected function query($q) {
		$result = $this->mysqli->query($q);
		return $result;
	}

	protected function close() {
		$this->mysqli->close();
	}

}

?>
