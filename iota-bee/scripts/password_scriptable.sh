#!/usr/bin/expect -f

# As Bee password tool is interactive this script enables to fetch passwort salt and hash.
# Requirements: 'expect' must be installed on system

set PASSWORD [lindex $argv 0]

set timeout -1
spawn ./password_scriptable_wrapper.sh ${PASSWORD}

expect "Password: "
send -- "${PASSWORD}\n"

expect "Re-enter password: "
send -- "${PASSWORD}\n"

expect eof