import cv2
import os
from datetime import datetime
from loguru import logger

class VideoClipper:
    """Extract and save accident video clips"""
    
    def __init__(self, config):
        self.config = config
        self.save_path = config['clip']['save_path']
        self.fps = 30  # Default FPS
        
        # Create output directory
        os.makedirs(self.save_path, exist_ok=True)
    
    def save_clip(self, frames, camera_id):
        """Save frames as video clip"""
        if len(frames) == 0:
            logger.error("No frames to save")
            return None
        
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"accident_{camera_id}_{timestamp}.mp4"
        filepath = os.path.join(self.save_path, filename)
        
        # Get frame dimensions
        height, width = frames[0].shape[:2]
        
        # Create video writer
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(filepath, fourcc, self.fps, (width, height))
        
        # Write frames
        for frame in frames:
            out.write(frame)
        
        out.release()
        
        logger.info(f"Accident clip saved: {filepath}")
        return filepath