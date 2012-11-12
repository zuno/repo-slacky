# Register gstreamer-plugins
if [ -x usr/bin/gst-inspect ]; then
  usr/bin/gst-inspect 1> dev/null 2> dev/null
else
  echo "Cannot find't gst-inspect, this should be part of gstreamer."
  echo "Run 'gst-inspect' after you have installed gstreamer to register the plugins"
fi
