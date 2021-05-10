<?php

namespace Steveorevo;

/**
 * Thrown by GString methods to indicate that an index is either negative or
 * greater than the size of the string.
 */
class GStringIndexOutOfBoundsException extends \Exception {
	/**
	 * Constructs a new GStringIndexOutOfBoundsException class with an argument
	 * indicating the illegal index.
	 *
	 * @access public
	 *
	 * @param int $index the illegal index
	 */
	public function __construct( $index ) {
		parent::__construct( "GString index out of range: " . $index, null, null );
	}
}
