if {0} {
    experimental:

    mkdir go-tcl-pipe
    cd go-tcl-pipe/
    go mod init go-tcl-pipe
    code server.go

    # visual code editor

    go build -o server server.go
    chmod +x server
}
    
proc start_server {} {
    set chan [open "|./server" r+]
    fconfigure $chan -buffering line -blocking 0 -encoding utf-8
    puts "Server started with channel: $chan"
    return $chan
}

proc send_command {chan cmd} {
    puts "Sending command: $cmd"
    puts $chan $cmd
    flush $chan

    set response ""
    while {1} {
        if {[gets $chan line] >= 0} {
            puts "Received line: $line"
            append response $line "\n"
            if {[string trim $line] eq "ok"} {
                break
            }
        } elseif {[eof $chan]} {
            break
        }
    }
    return $response
}

set chan [start_server]

# Set multiple cells
puts "Setting cell A1 to 'Hello'"
puts "Response: [send_command $chan "set A1 Hello"]"

puts "Setting cell B2 to 'World'"
puts "Response: [send_command $chan "set B2 World"]"

# Get values from cells
puts "Getting value from cell A1"
puts "Response: [send_command $chan "get A1"]"

puts "Getting value from cell B2"
puts "Response: [send_command $chan "get B2"]"

# Save the file
puts "Saving file as test.xlsx"
puts "Response: [send_command $chan "save test.xlsx"]"

# Attempt to get a value from a non-existent cell
puts "Getting value from cell C3"
puts "Response: [send_command $chan "get C3"]"

# Close the server
puts "Closing server"
puts "Response: [send_command $chan "close"]"

close $chan

if {0} {
Output:

Server started with channel: file5
Setting cell A1 to 'Hello'
Sending command: set A1 Hello
Received line: Server started
Received line: Enter command: Setting cell A1 to Hello
Received line: ok
Response: Server started
Enter command: Setting cell A1 to Hello
ok

Setting cell B2 to 'World'
Sending command: set B2 World
Received line: Enter command: Setting cell B2 to World
Received line: ok
Response: Enter command: Setting cell B2 to World
ok

Getting value from cell A1
Sending command: get A1
Received line: Enter command: Hello
Received line: ok
Response: Enter command: Hello
ok

Getting value from cell B2
Sending command: get B2
Received line: Enter command: World
Received line: ok
Response: Enter command: World
ok

Saving file as test.xlsx
Sending command: save test.xlsx
Received line: Enter command: Saving file as test.xlsx
Received line: ok
Response: Enter command: Saving file as test.xlsx
ok

Getting value from cell C3
Sending command: get C3
Received line: Enter command: 
Received line: ok
Response: Enter command: 
ok

Closing server
Sending command: close
Received line: Enter command: closing server
Received line: ok
Response: Enter command: closing server
ok


}
