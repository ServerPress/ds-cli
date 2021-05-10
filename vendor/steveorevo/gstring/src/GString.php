<?php
/**
 * GString Class
 *
 * Implements OOP String handling with useful parsing functions. Strings
 * to be handled as objects and features my basic cross language parsing
 * functions del/get left/right, available in javascript, perl,
 * asp, php, realstudio, vb, lingo, etc. GPL or contact for commercial
 * lic. in a language near you ;-)
 *
 * Now a composer ready object based on Michael Scribellito's Java-like string
 * manipulation functions with no-conflict, existing class checking.
 */
namespace Steveorevo;

if ( class_exists( 'GString' ) ) return;
class GString {
	/**
	 * Character mask for trim functions
	 *
	 * " " (ASCII 32 (0x20)), an ordinary space.
	 * "\t" (ASCII 9 (0x09)), a tab.
	 * "\n" (ASCII 10 (0x0A)), a new line (line feed).
	 * "\r" (ASCII 13 (0x0D)), a carriage return.
	 * "\0" (ASCII 0 (0x00)), the NUL-byte.
	 * "\x0B" (ASCII 11 (0x0B)), a vertical tab.
	 */
	const TRIM_CHARACTER_MASK = " \t\n\r\0\x0B";
	/**
	 * Cached hash code for the string
	 *
	 * @access private
	 * @var int
	 */
	protected $hash = 0;
	/**
	 * Holds the value of the string object
	 *
	 * @access private
	 * @var string
	 */
	protected $value = "";

	/**
	 * Initizlizes a newly created String object.
	 *
	 * @access public
	 *
	 * @param string $original A string
	 * @param int $offset Initial offset
	 * @param int $length The length
	 *
	 * @throws StringIndexOutOfBoundsException If the offset and count arguments
	 * index characters outside the bounds of the value
	 */
	public function __construct( $original = "", $offset = null, $length = null ) {
		$value = (string) $original;
		if ( $offset !== null && $length !== null ) {
			if ( $offset < 0 ) {
				throw new GStringIndexOutOfBoundsException( $offset );
			}
			if ( $length < 0 ) {
				throw new GStringIndexOutOfBoundsException( $length );
			}
			if ( $offset > strlen( $value ) - $length ) {
				throw new GStringIndexOutOfBoundsException( $offset + $length );
			}
			$value = substr( $value, $offset, $length );
		}
		$this->value = $value;
	}

	/**
	 * Clones this string.
	 *
	 * @return \String a copy of $this.
	 */
	public function __clone() {
		return new GString( $this );
	}

	/**
	 * The value of this String is returned.
	 *
	 * @access public
	 * @return string the string itself.
	 */
	public function __toString() {
		return $this->value;
	}

	/**
	 * Returns the character at the specified index.
	 *
	 * @access public
	 *
	 * @param int $index The index of the character
	 *
	 * @return string the character at the specified index of this string.
	 * @throws StringIndexOutOfBoundsException
	 */
	public function charAt( $index ) {
		if ( $index < 0 || $index >= $this->length() ) {
			throw new GStringIndexOutOfBoundsException( $index );
		}

		return $this->value[ $index ];
	}

	/**
	 * Returns the character (Unicode code point) at the specified index.
	 *
	 * @access public
	 *
	 * @param int $index The index of the character
	 *
	 * @return int the character code of the character at the index.
	 */
	public function charCodeAt( $index ) {
		return ord( $this->charAt( $index ) );
	}

	/**
	 * Compares two strings lexicographically.
	 *
	 * @access public
	 *
	 * @param string $anotherString The string to be compared
	 *
	 * @return int the value 0 if strings are equal, 1 or -1.
	 */
	public function compareTo( $anotherString ) {
		return strcmp( $this->value, $anotherString );
	}

	/**
	 * Compares two strings lexicographically, ignoring case differences.
	 *
	 * @access public
	 *
	 * @param string $anotherString The string to be compared
	 *
	 * @return int the value 0 if strings are equal, 1 or -1.
	 */
	public function compareToIgnoreCase( $anotherString ) {
		return strcasecmp( $this->value, $anotherString );
	}

	/**
	 * Concatenates the specified string(s) to the end of this string.
	 *
	 * @access public
	 * @return \String the resulting string.
	 */
	public function concat() {
		$value = $this->value;
		for ( $i = 0; $i < func_num_args(); $i ++ ) {
			$value .= (string) func_get_arg( $i );
		}

		return new GString( $value );
	}

	/**
	 * Returns true if, and only if, this string contains the specified string.
	 *
	 * @access public
	 *
	 * @param string $sequence The string to search for
	 *
	 * @return boolean true if the string contains the specified sequence.
	 */
	public function contains( $sequence ) {
		return $this->indexOf( $sequence ) > - 1;
	}

	/**
	 * Tests if this string ends with the specified suffix.
	 *
	 * @access public
	 *
	 * @param string $suffix The suffix
	 *
	 * @return boolean true if the string ends with the given suffix.
	 */
	public function endsWith( $suffix ) {
		$pattern = "/" . preg_quote( $suffix ) . "$/";

		return $this->matches( $pattern );
	}

	/**
	 * Compares this string to the specified string.
	 *
	 * @access public
	 *
	 * @param string $anotherString The string to compare this string against
	 *
	 * @return boolean true if the strings are equal.
	 */
	public function equals( $anotherString ) {
		if ( $this == $anotherString ) {
			return true;
		}

		return $this->compareTo( $anotherString ) == 0;
	}

	/**
	 * Compares this string to the specified string, ignoring case differences.
	 *
	 * @access public
	 *
	 * @param string $anotherString The string to compare this string against
	 *
	 * @return boolean true if the strings are equal.
	 */
	public function equalsIgnoreCase( $anotherString ) {
		return $this->compareToIgnoreCase( $anotherString ) == 0;
	}

	/**
	 * Returns a formatted string using the specified format string and arguments.
	 *
	 * @access public
	 *
	 * @param string $format A format string
	 * @param args Arguments referenced by the format specifiers in the format string
	 *
	 * @return \String a formatted string.
	 */
	public static function format( $format ) {
		if ( func_num_args() == 1 ) {
			return new GString( $format );
		}

		return new GString( call_user_func_array( "sprintf", func_get_args() ) );
	}

	/**
	 * Returns a hash code for this string.
	 *
	 * @access public
	 * @return int a hash code for this string.
	 */
	public function hashCode() {
		$h = $this->hash;
		$l = $this->length();
		if ( $h == 0 && $l > 0 ) {
			for ( $i = 0; $i < $l; $i ++ ) {
				$h = (int) ( 31 * $h + $this->charCodeAt( $i ) );
			}
			$this->hash = $h;
		}

		return $h;
	}

	/**
	 * Returns the index within this string of the first occurrence of the specified
	 * string, optionally starting the search at the specified index.
	 *
	 * @access public
	 *
	 * @param string $sequence A string
	 * @param int $fromIndex The index to start the search from
	 * @param boolean $ignoreCase If true, ignore case
	 *
	 * @return int the index of the first occurrence of the sequence.
	 */
	public function indexOf( $sequence, $fromIndex = 0, $ignoreCase = false ) {
		if ( $fromIndex < 0 ) {
			$fromIndex = 0;
		} else if ( $fromIndex >= $this->length() ) {
			return - 1;
		}
		if ( $ignoreCase == false ) {
			$index = strpos( $this->value, $sequence, $fromIndex );
		} else {
			$index = stripos( $this->value, $sequence, $fromIndex );
		}

		return $index === false ? - 1 : $index;
	}

	/**
	 * Returns the index within this string of the first occurrence of the specified
	 * string, ignoring case differences, optionally starting the search at the
	 * specified index.
	 *
	 * @access public
	 *
	 * @param string $sequence A string
	 * @param int $fromIndex The index to start the search from
	 *
	 * @return int the index of the first occurrence of the sequence.
	 */
	public function indexOfIgnoreCase( $sequence, $fromIndex = 0 ) {
		return $this->indexOf( $sequence, $fromIndex, true );
	}

	/**
	 * Returns true if, and only if, string length is 0.
	 *
	 * @access public
	 * @return boolean true if the length is 0.
	 */
	public function isEmpty() {
		return $this->length() == 0;
	}

	/**
	 * Returns a string of array elements joined with a specified string.
	 *
	 * @access public
	 *
	 * @param string $separator A string to join the arguments with
	 * @param array $elements Arguments to join
	 *
	 * @return \String the resulting string.
	 */
	public static function join( $separator, $elements = array() ) {
		return new GString( implode( $separator, $elements ) );
	}

	/**
	 * Returns the index within this string of the last occurrence of the specified
	 * string, searching backward starting at the specified index.
	 *
	 * @access public
	 *
	 * @param string $sequence A string
	 * @param int $fromIndex The index to start the search from
	 * @param boolean $ignoreCase If true, ignore case
	 *
	 * @return int the index of the first occurrence of the sequence.
	 */
	public function lastIndexOf( $sequence, $fromIndex = 0, $ignoreCase = false ) {
		if ( $fromIndex < 0 ) {
			$fromIndex = 0;
		} else if ( $fromIndex >= $this->length() ) {
			return - 1;
		}
		if ( $ignoreCase == false ) {
			$index = strrpos( $this->value, $sequence, $fromIndex );
		} else {
			$index = strripos( $this->value, $sequence, $fromIndex );
		}

		return $index === false ? - 1 : $index;
	}

	/**
	 * Returns the index within this string of the last occurrence of the specified
	 * string, ignoring case differences, searching backward starting at the
	 * specified index.
	 *
	 * @access public
	 *
	 * @param string $sequence A string
	 * @param int $fromIndex The index to start the search from
	 *
	 * @return int the index of the first occurrence of the sequence.
	 */
	public function lastIndexOfIgnoreCase( $sequence, $fromIndex = 0 ) {
		return $this->lastIndexOf( $sequence, $fromIndex, true );
	}

	/**
	 * Returns the length of this string.
	 *
	 * @access public
	 * @return int the length of this string.
	 */
	public function length() {
		return strlen( $this->value );
	}

	/**
	 * Tells whether or not this string matches the given regular expression.
	 *
	 * @access public
	 *
	 * @param string $regex The regular expression to which this string is to be matched
	 * @param array $matches This will be set to the results of the search
	 *
	 * @return boolean true if the string matches the given regular expression.
	 */
	public function matches( $regex, & $matches = null ) {
		$match = preg_match( $regex, $this->value, $matches );
		for ( $i = 0, $l = count( $matches ); $i < $l; $i ++ ) {
			$matches[ $i ] = new GString( $matches[ $i ] );
		}

		return $match == 1;
	}

	/**
	 * Returns the left padded string to a certain length with the specified string.
	 *
	 * @access public
	 *
	 * @param int $length The length to pad the string to
	 * @param string $padString The string to pad with
	 *
	 * @return \String the resulting string.
	 */
	public function padLeft( $length, $padString ) {
		return new GString( str_pad( $this->value, $length, $padString, STR_PAD_LEFT ) );
	}

	/**
	 * Returns the right padded string to a certain length with the specified string.
	 *
	 * @access public
	 *
	 * @param int $length The length to pad the string to
	 * @param string $padString The string to pad with
	 *
	 * @return \String the resulting string.
	 */
	public function padRight( $length, $padString ) {
		return new GString( str_pad( $this->value, $length, $padString, STR_PAD_RIGHT ) );
	}

	/**
	 * Compare two string regions.
	 *
	 * @access public
	 *
	 * @param int $offseta The starting offset of the subregion in this string
	 * @param string $str The string argument
	 * @param int $offsetb The starting offset of the subregion in the string argument
	 * @param int $length The number of characters to compare
	 * @param boolean $ignoreCase If true, ignore case
	 *
	 * @return int the value 0 if regions are equal, 1 or -1.
	 */
	public function regionCompare( $offseta, $str, $offsetb, $length, $ignoreCase = false ) {
		$a = $this->substring( $offseta );
		$b = new GString( $str );
		$b = $b->substring( $offsetb );
		if ( $ignoreCase == false ) {
			return strncmp( $a, $b, $length );
		} else {
			return strncasecmp( $a, $b, $length );
		}
	}

	/**
	 * Compare two string regions, ignoring case differences.
	 *
	 * @access public
	 *
	 * @param int $offseta The starting offset of the subregion in this string
	 * @param string $str The string argument
	 * @param int $offsetb The starting offset of the subregion in the string argument
	 * @param int $length The number of characters to compare
	 *
	 * @return int the value 0 if regions are equal, 1 or -1.
	 */
	public function regionCompareIgnoreCase( $offseta, $str, $offsetb, $length ) {
		return $this->regionCompare( $offseta, $str, $offsetb, $length, true );
	}

	/**
	 * Tests if two string regions are equal.
	 *
	 * @access public
	 *
	 * @param int $offseta The starting offset of the subregion in this string
	 * @param string $str The string argument
	 * @param int $offsetb The starting offset of the subregion in the string argument
	 * @param int $length The number of characters to compare
	 *
	 * @return bool true if the regions match.
	 */
	public function regionMatches( $offseta, $str, $offsetb, $length ) {
		return $this->regionCompare( $offseta, $str, $offsetb, $length ) == 0;
	}

	/**
	 * Tests if two string regions are equal, ignoring case differences.
	 *
	 * @access public
	 *
	 * @param int $offseta The starting offset of the subregion in this string
	 * @param string $str The string argument
	 * @param int $offsetb The starting offset of the subregion in the string argument
	 * @param int $length The number of characters to compare
	 *
	 * @return bool true if the regions match.
	 */
	public function regionMatchesIgnoreCase( $offseta, $str, $offsetb, $length ) {
		return $this->regionCompareIgnoreCase( $offseta, $str, $offsetb, $length ) == 0;
	}

	/**
	 * Returns a new GString resulting from replacing all occurrences of the search
	 * string with the replacement string.
	 *
	 * @access public
	 *
	 * @param string $search The old string
	 * @param string $replacement The new GString
	 * @param int $count This will be set to the number of replacements performed
	 *
	 * @return \String the resulting string.
	 */
	public function replace( $search, $replacement, & $count = 0 ) {
		return new GString( str_replace( $search, $replacement, $this->value, $count ) );
	}

	/**
	 * Replaces each substring of this string that matches the given regular
	 * expression with the given replacement.
	 *
	 * @access public
	 *
	 * @param string $regex The regular expression to which this string is to be matched
	 * @param string $replacement The string to be substituted for each match
	 * @param int $limit The limit threshold
	 * @param int $count This will be set to the number of replacements performed
	 *
	 * @return \String the resulting string.
	 */
	public function replaceAll( $regex, $replacement, $limit = - 1, & $count = 0 ) {
		return new GString( preg_replace( $regex, $replacement, $this->value, $limit, $count ) );
	}

	/**
	 * Replaces the first substring of this string that matches the given regular
	 * expression with the given replacement.
	 *
	 * @access public
	 *
	 * @param string $regex The regular expression to which this string is to be matched
	 * @param string $replacement The string to be substituted for the first match
	 *
	 * @return \String the resulting string.
	 */
	public function replaceFirst( $regex, $replacement ) {
		return $this->replaceAll( $regex, $replacement, 1 );
	}

	/**
	 * Returns a new GString resulting from replacing all occurrences of the search
	 * string with the replacement string, ignoring case differences.
	 *
	 * @access public
	 *
	 * @param string $search The old string
	 * @param string $replacement The new GString
	 * @param int $count This will be set to the number of replacements performed
	 *
	 * @return \String the resulting string.
	 */
	public function replaceIgnoreCase( $search, $replacement, & $count = 0 ) {
		return new GString( str_ireplace( $search, $replacement, $this->value, $count ) );
	}

	/**
	 * Returns a new GString that is the reverse of this string.
	 *
	 * @access public
	 * @return \String the string, reversed.
	 */
	public function reverse() {
		return new GString( strrev( $this->value ) );
	}

	/**
	 * Splits this string around matches of the given regular expression.
	 *
	 * @access public
	 *
	 * @param string $regex The delimiting regular expression
	 * @param int $limit The result threshold
	 *
	 * @return array the resulting array of strings.
	 */
	public function split( $regex, $limit = - 1 ) {
		$parts = preg_split( $regex, $this->value, $limit );
		for ( $i = 0, $l = count( $parts ); $i < $l; $i ++ ) {
			$parts[ $i ] = new GString( $parts[ $i ] );
		}

		return $parts;
	}

	/**
	 * Tests if this string starts with the specified prefix, optionally checking
	 * for a match at the specified index.
	 *
	 * @access public
	 *
	 * @param string $prefix The prefix
	 * @param int $fromIndex Where to begin looking in this string
	 *
	 * @return boolean true if the string starts with the given prefix.
	 */
	public function startsWith( $prefix, $fromIndex = 0 ) {
		$pattern = "/^" . preg_quote( $prefix ) . "/";

		return $this->substring( $fromIndex )->matches( $pattern );
	}

	/**
	 * Returns a new GString that is a substring of this string.
	 *
	 * @access public
	 *
	 * @param int $beginIndex The beginning index, inclusive
	 * @param int $endIndex The ending index, exclusive
	 *
	 * @return \String the specified substring.
	 * @throws StringIndexOutOfBoundsException
	 */
	public function substring( $beginIndex, $endIndex = null ) {
		if ( $beginIndex < 0 ) {
			throw new GStringIndexOutOfBoundsException( $beginIndex );
		} else if ( $beginIndex == $this->length() ) {
			return new GString( "" );
		}
		if ( $endIndex === null ) {
			$length = $this->length() - $beginIndex;
			if ( $length < 0 ) {
				throw new GStringIndexOutOfBoundsException( $length );
			}
			if ( $beginIndex == 0 ) {
				return $this;
			} else {
				return new GString( $this->value, $beginIndex, $length );
			}
		} else {
			if ( $endIndex > $this->length() ) {
				throw new GStringIndexOutOfBoundsException( $endIndex );
			}
			$length = $endIndex - $beginIndex;
			if ( $length < 0 ) {
				throw new GStringIndexOutOfBoundsException( $length );
			}
			if ( $beginIndex == 0 && $endIndex == $this->length() ) {
				return $this;
			} else {
				return new GString( $this->value, $beginIndex, $length );
			}
		}
	}

	/**
	 * Converts this string to a new character array.
	 *
	 * @access public
	 *
	 * @param int $chunkSize The length of the chunk
	 *
	 * @return array a character array whose length is the length of this string.
	 */
	public function toCharArray( $chunkSize = 1 ) {
		return str_split( $this->value, $chunkSize );
	}

	/**
	 * Converts all of the characters in this String to lower case.
	 *
	 * @access public
	 * @return \String the string, converted to lowercase.
	 */
	public function toLowerCase() {
		return new GString( strtolower( $this->value ) );
	}

	/**
	 * Converts all of the characters in this String to upper case.
	 *
	 * @access public
	 * @return \String the string, converted to uppercase.
	 */
	public function toUpperCase() {
		return new GString( strtoupper( $this->value ) );
	}

	/**
	 * Returns a copy of the string, with leading and trailing whitespace omitted.
	 *
	 * @access public
	 *
	 * @param string $characterMask optional characters to strip
	 *
	 * @return \String a copy of this string with leading and trailing white space removed.
	 */
	public function trim( $characterMask = self::TRIM_CHARACTER_MASK ) {
		return new GString( trim( $this->value, $characterMask ) );
	}

	/**
	 * Returns a copy of the string, with leading whitespace omitted.
	 *
	 * @access public
	 *
	 * @param string $characterMask optional characters to strip
	 *
	 * @return \String a copy of this string with leading white space removed.
	 */
	public function trimLeft( $characterMask = self::TRIM_CHARACTER_MASK ) {
		return new GString( ltrim( $this->value, $characterMask ) );
	}

	/**
	 * Returns a copy of the string, with trailing whitespace omitted.
	 *
	 * @access public
	 *
	 * @param string $characterMask optional characters to strip
	 *
	 * @return \String a copy of this string with trailing white space removed.
	 */
	public function trimRight( $characterMask = self::TRIM_CHARACTER_MASK ) {
		return new GString( rtrim( $this->value, $characterMask ) );
	}

	/**
	* Deletes the right most string from the found search string
	* starting from right to left, including the search string itself.
	*
	* @access public
	* @return string
	*/
	public function delRightMost( $sSearch ) {
		$sSource = $this->value;
		for ( $i = strlen( $sSource ); $i >= 0; $i = $i - 1 ) {
			$f = strpos( $sSource, $sSearch, $i );
			if ( $f !== false ) {
				return new GString( substr( $sSource, 0, $f ) );
				break;
			}
		}

		return new GString( $sSource );
	}

	/**
	* Deletes the left most string from the found search string
	* starting from left to right, including the search string itself.
	*
	* @access public
	* @return string
	*/
	public function delLeftMost( $sSearch ) {
		$sSource = $this->value;
		for ( $i = 0; $i < strlen( $sSource ); $i = $i + 1 ) {
			$f = strpos( $sSource, $sSearch, $i );
			if ( $f !== false ) {
				return new GString( substr( $sSource, $f + strlen( $sSearch ), strlen( $sSource ) ) );
				break;
			}
		}

		return new GString( $sSource );
	}

	/**
	* Returns the right most string from the found search string
	* starting from right to left, excluding the search string itself.
	*
	* @access public
	* @return string
	*/
	public function getRightMost( $sSearch ) {
		$sSource = $this->value;
		for ( $i = strlen( $sSource ); $i >= 0; $i = $i - 1 ) {
			$f = strpos( $sSource, $sSearch, $i );
			if ( $f !== false ) {
				return new GString( substr( $sSource, $f + strlen( $sSearch ), strlen( $sSource ) ) );
			}
		}

		return new GString( $sSource );
	}

	/**
	* Returns the left most string from the found search string
	* starting from left to right, excluding the search string itself.
	*
	* @access public
	* @return string
	*/
	public function getLeftMost( $sSearch ) {
		$sSource = $this->value;
		for ( $i = 0; $i < strlen( $sSource ); $i = $i + 1 ) {
			$f = strpos( $sSource, $sSearch, $i );
			if ( $f !== false ) {
				return new GString( substr( $sSource, 0, $f ) );
				break;
			}
		}

		return new GString( $sSource );
	}

	/**
	* Returns left most string by the given number of characters.
	*
	* @access public
	* @return string
	*/
	public function left( $chars ) {
		return new GString( substr( $this->value, 0, $chars ) );
	}

	/**
	* Returns right most string by the given number of characters.
	*
	* @access public
	* @return string
	*/
	public function right( $chars ) {
		return new GString( substr( $this->value, ( $chars * - 1 ) ) );
	}
}

if ( ! function_exists( "GString" ) ) {
	/**
	 * Wrapper for creating a new GString.
	 *
	 * @param mixed $str The string.
	 *
	 * @return \GString
	 */
	function GString( $str = "" ) {
		if ( $str instanceof GString ) {
			return clone $str;
		}

		return new GString( $str );
	}
}
