import yaml
import time
from loguru import logger
from src.video_processor import VideoProcessor
from src.accident_detector import AccidentDetector
from src.video_clipper import VideoClipper
from src.location_handler import LocationHandler
from src.sos_generator import SOSGenerator
from src.api_client import APIClient

# Configure logging
logger.add(
    "logs/accident_detection.log",
    rotation="1 day",
    retention="7 days",
    level="INFO"
)

class AccidentDetectionSystem:
    """Main system orchestrator"""
    
    def __init__(self, config_path="config/config.yaml"):
        # Load configuration
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)
        
        # Initialize components
        self.video_processor = VideoProcessor(self.config)
        self.accident_detector = AccidentDetector(self.config)
        self.video_clipper = VideoClipper(self.config)
        self.location_handler = LocationHandler(self.config)
        self.sos_generator = SOSGenerator(self.config)
        self.api_client = APIClient(self.config)
        
        logger.info("Accident Detection System initialized")
    
    def run(self):
        """Main detection loop"""
        logger.info("Starting accident detection...")
        
        # Start video stream
        if not self.video_processor.start_stream():
            logger.error("Failed to start video stream")
            return
        
        try:
            # Process frames
            for frame, frame_count in self.video_processor.get_frames():
                
                # Detect objects
                results = self.accident_detector.detect_objects(frame)
                
                # Analyze for accident patterns
                is_accident, score = self.accident_detector.analyze_accident_patterns(results)
                
                # Validate accident
                if self.accident_detector.validate_accident(is_accident):
                    logger.critical("🚨 ACCIDENT DETECTED! 🚨")
                    
                    # Handle accident
                    self.handle_accident_detection()
                    
                    # Cooldown to avoid duplicate alerts
                    time.sleep(30)
                
                # Optional: Display annotated frame
                # annotated = self.accident_detector.draw_detections(frame, results)
                # cv2.imshow('Detection', annotated)
                # if cv2.waitKey(1) & 0xFF == ord('q'):
                #     break
                
        except KeyboardInterrupt:
            logger.info("Detection stopped by user")
        except Exception as e:
            logger.error(f"Error in detection loop: {e}")
        finally:
            self.video_processor.stop_stream()
            logger.info("Accident detection stopped")
    
    def handle_accident_detection(self):
        """Handle detected accident - create SOS alert"""
        try:
            # 1. Extract video clip
            logger.info("Extracting accident video clip...")
            clip_frames = self.video_processor.get_buffered_clip(
                pre_seconds=self.config['clip']['pre_buffer'],
                post_seconds=self.config['clip']['post_buffer']
            )
            
            # 2. Save video clip
            video_path = self.video_clipper.save_clip(
                clip_frames,
                self.config['location']['camera_id']
            )
            
            if not video_path:
                logger.error("Failed to save accident clip")
                return
            
            # 3. Get location data
            location_data = self.location_handler.get_location()
            
            if not location_data:
                logger.error("No location data available")
                return
            
            # 4. Generate SOS alert
            sos_payload = self.sos_generator.generate_alert(
                video_path=video_path,
                location_data=location_data,
                severity="HIGH"
            )
            
            # 5. Send to backend API
            success, response = self.api_client.send_sos_alert(sos_payload)
            
            if success:
                logger.success("✅ SOS alert sent to ambulance services!")
                logger.info(f"Response: {response}")
            else:
                logger.error("❌ Failed to send SOS alert")
                
        except Exception as e:
            logger.error(f"Error handling accident: {e}")

def main():
    """Entry point"""
    logger.info("=" * 60)
    logger.info("IERAS - AI Accident Detection Module")
    logger.info("=" * 60)
    
    # Create system instance
    system = AccidentDetectionSystem()
    
    # Run detection
    system.run()

if __name__ == "__main__":
    main()