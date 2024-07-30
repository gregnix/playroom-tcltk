tclmagick

+ http://www.graphicsmagick.org/TclMagick/doc/TclMagick.html
+ http://www.graphicsmagick.org/TclMagick/doc/
+ https://sourceforge.net/projects/graphicsmagick/
+ https://sourceforge.net/p/graphicsmagick/mailman/graphicsmagick-tclmagick/
+ http://www.graphicsmagick.org/GraphicsMagick.html
+ http://www.graphicsmagick.org/formats.html
+ http://www.graphicsmagick.org/programming.html
+ https://wiki.tcl-lang.org/page/TclMagick

Debian with Graphicsmagick
```
#tcl-dev and tk-dev are already installed
sudo apt install graphicsmagick-imagemagick-compat
sudo apt install graphicsmagick-libmagick-dev-compat

#from  a  directory for the source
sudo apt-get source graphicsmagick-libmagick-dev-compat

mkdir build/TclMagick
cd build/TclMagick
../../src//graphicsmagick-1.4+really1.3.43/TclMagick/configure
# or a absolute path
make
sudo make install
(/usr/lib/TclMagick0.46)

```

