package require TclMagick


# Function to create a new empty image
proc create_empty_image {output_file width height color} {
 # Create a new wand object
 set wand [magick create wand]
 # Create a new image
 $wand ReadImage "xc:$color"
 # "xc:" is a special image format for single-color images
 $wand ResizeImage $width $height cubic
 # Save the image
 $wand WriteImage $output_file
 # Clean up
 magick delete $wand
}

# convert picture.png picture.jpg
proc convert {oldname newname} {
 set wand [magick create wand]
 $wand ReadImage $oldname
 $wand WriteImage $newname
 magick delete $wand
}

# crop
proc crop {file cropfile width height x y} {
 set wand [magick create wand]
 $wand ReadImage $file
 $wand CropImage $width $height $x $y
 $wand WriteImage $cropfile
 magick delete $wand
}


####################################################
# Examples
###################################################
if {[info script] eq $argv0} {
 # new pictures
 create_empty_image "empty_white.png" 800 600 "white"
 create_empty_image "empty_blue.png" 800 600 "blue"
 create_empty_image "empty_red.png" 800 600 "red"


 #crop with proc
 set width 100
 set height 100
 set x 50
 set y 50
 crop empty_red.png empty_red_crop.png $width $height $x $y

 # convert with proc
 foreach ext {jpg gif pdf} {
  convert empty_blue.png empty_blue.$ext
 }
 # convert without proc
 set wand [magick create wand]
 $wand ReadImage empty_red.png
 foreach ext {jpg gif pdf} {
  $wand WriteImage empty_red.$ext
 }
 magick delete $wand

 # Resize without proc
 set wand [magick create wand]
 $wand ReadImage empty_red.png
 $wand ResizeImage 512 280 cubic
 $wand WriteImage empty_red-512_280.png
 magick delete $wand

 # Blur
 set wand [magick create wand]
 $wand ReadImage empty_red.png
 $wand BlurImage 0 1
 $wand WriteImage empty_red_Blur.png
 magick delete $wand

 # Rotate
 set wand [magick create wand]
 $wand ReadImage empty_red.png
 set bg_pixel [magick create pixel]
 $bg_pixel SetColor "white"
 $wand RotateImage $bg_pixel 45
 $wand WriteImage empty_red_Rotate.png
 magick delete $wand
 magick delete $bg_pixel

 # Composite
 set wand [magick create wand]
 $wand ReadImage empty_red.png
 set cwand [$wand clone]
 set bg [magick create pixel]
 $bg SetColor rgb(0%,0%,100%)
 $cwand rotate $bg 5
 $cwand CompositeImage $wand add 10 10
 $cwand WriteImage empty_red_Composite.png
 magick delete $wand $cwand $bg
 # Composite
 set wand1 [magick create wand]
 set wand2 [magick create wand]
 $wand1 ReadImage empty_red.png
 $wand2 ReadImage empty_blue.png
 $wand1 composite $wand2 difference
 $wand2 composite $wand1 difference
 # this results in 24 bit depth image
 $wand1 WriteImage empty_red_diff.png
 $wand2 WriteImage empty_blue_diff.png
 magick delete  $wand1 $wand2

 # setPixel
 # parts of it from TclMagick/tests
 set width 100
 set height 100
 set x 50
 set y 50
 # new blank picture
 # xc:$color" from
 # http://www.graphicsmagick.org/formats.html
 set wand [magick create wand]
 set color white
 $wand ReadImage "xc:$color"
 $wand ResizeImage $width $height cubic
 # Create the binary data for red pixels
 # Each pixel requires 3 bytes (RGB),  80x10 pixels
 set red_pixel_data [string repeat [binary format c* {255 0 0}] [expr 80 * 10]]
 $wand SetPixels 0 0 80 10 "RGB" char $red_pixel_data
 $wand WriteImage empty-wr1.png
 # GetPixel
 set extracted_pixels [$wand GetPixels 10 5 80 10 "RGB" char]
 # Paste the extracted region to a new location
 $wand SetPixels 20 30 80 10 "RGB" char $extracted_pixels
 $wand WriteImage empty-wr2.png
 set pixel_color [$wand GetPixels 15 7 1 1 "RGB" char]
 binary scan $pixel_color c* rgb_values
 set red [lindex $rgb_values 0]
 set green [lindex $rgb_values 1]
 set blue [lindex $rgb_values 2]
 puts "Color of pixel at (15, 7): red=$red, green=$green, blue=$blue"
 
 magick delete $wand

 # copy with clone?
 # set cwand [$wand clone]


}

