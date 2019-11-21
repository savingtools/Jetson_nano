from .camera import Camera
import atexit
import cv2
import numpy as np
import threading
import traitlets


class USBCamera(Camera):
    
    capture_fps = traitlets.Integer(default_value=30).tag(config=True)
    capture_width = traitlets.Integer(default_value=640).tag(config=True)
    capture_height = traitlets.Integer(default_value=480).tag(config=True) 
    capture_device = traitlets.Integer(default_value=0).tag(config=True)
    capture_flip = traitlets.Integer(default_value=0).tag(config=True)
    
    def __init__(self, *args, **kwargs):
        super(USBCamera, self).__init__(*args, **kwargs)
        try:
            self.cap = cv2.VideoCapture(self._gst_str(), cv2.CAP_GSTREAMER)

            re , image = self.cap.read()
            
            if not re:
                raise RuntimeError('Could not read image from camera.')
            
        except:
            raise RuntimeError(
                'Could not initialize camera.  Please see error trace.')

        atexit.register(self.cap.release)
                
    def _gst_str(self):
        return 'v4l2src device=/dev/video{} ! video/x-raw, width=(int){}, height=(int){}, framerate=(fraction){}/1 ! nvvidconv flip-method={} ! videoconvert !  video/x-raw, , format=(string)BGR ! appsink'.format(self.capture_device, self.capture_width, self.capture_height, self.capture_fps , self.capture_flip)
    
    def _read(self):
        re, image = self.cap.read()
        if re:
            image_resized = cv2.resize(image,(int(self.width),int(self.height)))
            return image_resized
        else:
            raise RuntimeError('Could not read image from camera')
