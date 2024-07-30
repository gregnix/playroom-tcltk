set auto_path [linsert $auto_path 0 [file normalize "../.." ]]

package require tclfpdf
namespace import  ::tclfpdf::*

set dirname [file dirname [info script]]
puts "start [info script]"
puts "auto_path add: [file normalize "../.." ]"
set tclfpdf_arg_fontpath ~/tclfpdf/font

puts "TCLFPDF_FONTPATH: $::tclfpdf::TCLFPDF_FONTPATH"
puts "TCLFPDF_USER_FONTPATH: $::tclfpdf::TCLFPDF_USER_FONTPATH"


Init;
puts "  after init"
puts "tclfpdf_arg_fontpath: $tclfpdf_arg_fontpath"
puts "fontpath: $::tclfpdf::fontpath"
puts "fontuserpath: $::tclfpdf::fontuserpath"


AddPage;
# Add a Unicode font (uses UTF-8)
AddFont "DejaVu" "" "DejaVuSansCondensed.ttf" 1;
SetFont "DejaVu" "" 14;
Write 8 "		-----
English: Hello World
Greek: Γειά σου κόσμος
Polish: Witaj świecie
Portuguese: Olá mundo
Spanish: Hola mundo
Russian: Здравствулте мир
Vietnamese: Xin chào thế giới
		------";

Output "testtclfpdf.pdf";
puts "\n$dirname"
puts [join  [glob *.*] \n]
puts "\nend [info script]"
