SET CURRENTDIR="%cd%"
docker run -it --rm -p 4000:4000 -p 35729:35729 -v %CURRENTDIR%:/almighty-devdoc almighty-devdoc-builder
