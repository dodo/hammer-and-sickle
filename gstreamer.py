#!/usr/bin/env python
# -*- Mode: Python -*-
# vi:si:et:sw=4:sts=4:ts=4


import pygst
pygst.require('0.10')
import gst
import gobject
gobject.threads_init()

#
# Simple Src element created entirely in python
#

class png2video:
    def __init__(self):
        # The pipeline
        self.pipeline = gst.parse_launch(" ! ".join([
            "tcpserversrc name=tcpin",
            "queue",
            #"tee name=tcp",
            "capsfilter caps=\"image/png, width=320, height=240, framerate=20/1\"",
            "videorate",
            "capsfilter caps=\"image/png, framerate=25/1\"",
            "pngdec",
            "ffmpegcolorspace",
            "ffenc_mjpeg",
            "ffmux_mp4",
            "queue",
            "tcpserversink name=tcpout"
        ]))
        #]) + " tcp. ! fakesink name=fake" )
        self.pipeline.set_name("png2video")
        self.pipeline.auto_clock()

        # Create bus and connect several handlers
        self.bus = self.pipeline.get_bus()
        self.bus.add_signal_watch()
        self.bus.connect('message::eos', self.on_eos)
        self.bus.connect('message::error', self.on_error)

        # Get elements
        self.src  = self.pipeline.get_by_name('tcpin')
        self.sink = self.pipeline.get_by_name('tcpout')
        #self.fake = self.pipeline.get_by_name('fake')

        # Set properties
        self.src.set_property('num.buffers', 16384)
        self.src.set_property('blocksize', 16384)
        self.src.set_property('typefind', True)
        self.src.set_property('do-timestamp', True)
        self.src.set_property('port', 3030)
        self.sink.set_property('port', 3020)
        #self.fake.set_property('dump', True)

        # The MainLoop
        self.mainloop = gobject.MainLoop()

        # And off we go!
        self.pipeline.set_state(gst.STATE_PLAYING)
        self.mainloop.run()


    def on_eos(self, bus, msg):
        print 'on_eos', '-'*33
        self.mainloop.quit()


    def on_error(self, bus, msg):
        error = msg.parse_error()
        print 'on_error:', error[1]
        self.pipeline.set_state(gst.STATE_PLAYING)
        #self.mainloop.quit()


if __name__ == '__main__':
    png2video()
