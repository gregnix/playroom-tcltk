package require TclMagick
# http://www.graphicsmagick.org/formats.html
# 

# Function to create a new empty image
proc create_empty_image {output_file width height color} {
    # Create a new wand object
    set wand [magick create wand]
    
    # Create a new image
    $wand ReadImage "xc:$color"  ;# "xc:" is a special image format for single-color images
    $wand ResizeImage $width $height cubic  ;# Resize the image to the desired size
    
    # Save the image
    $wand WriteImage $output_file
    
    # Clean up
    magick delete $wand
}

# Example usage
create_empty_image "empty_image.png" 800 600 "white"
