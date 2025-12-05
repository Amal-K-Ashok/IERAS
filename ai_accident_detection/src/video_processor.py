import cv2
import numpy as np
from collections import deque
from loguru import logger

class VideoProcessor:
    """Process video input and extract frames"""
    
    def __init__(self, config):
        self.config = config
        self.source = config['video']['input_source']
        self.frame_skip = config['video']['frame_skip']
        self.resolution = tuple(config['video']['resolution'])
        self.frame_buffer = deque(maxlen=300)  # Store last 10 seconds at 30fps
        
    def start_stream(self):
        """Initialize video capture"""
        try:
            self.cap = cv2.VideoCapture(self.source)
            
            if not self.cap.isOpened():
                raise Exception(f"Cannot open video source: {self.source}")
            
            # Set resolution
            self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, self.resolution[0])
            self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, self.resolution[1])
            
            self.fps = int(self.cap.get(cv2.CAP_PROP_FPS))
            logger.info(f"Video stream started: {self.source} @ {self.fps} FPS")
            
            return True
        except Exception as e:
            logger.error(f"Failed to start video stream: {e}")
            return False
    
    def get_frames(self):
        """Generator that yields frames"""
        frame_count = 0
        
        while True:
            ret, frame = self.cap.read()
            
            if not ret:
                logger.warning("End of video stream or read error")
                break
            
            # Store frame in buffer for clipping
            self.frame_buffer.append(frame.copy())
            
            # Skip frames for performance
            if frame_count % self.frame_skip == 0:
                yield frame, frame_count
            
            frame_count += 1
    
    def get_buffered_clip(self, pre_seconds=3, post_seconds=7):
        """Extract clip from buffer around accident time"""
        pre_frames = int(pre_seconds * self.fps)
        post_frames = int(post_seconds * self.fps)
        
        # Get frames from buffer
        total_frames = pre_frames + post_frames
        if len(self.frame_buffer) < total_frames:
            clip_frames = list(self.frame_buffer)
        else:
            clip_frames = list(self.frame_buffer)[-total_frames:]
        
        return clip_frames
    
    def stop_stream(self):
        """Release video capture"""
        if self.cap:
            self.cap.release()
            logger.info("Video stream stopped")