if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded imap4 0.4 [list source [file join $dir imap4.tcl]]
