if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded ncgi 1.4.1 [list source [file join $dir ncgi.tcl]]
