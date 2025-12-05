import uuid
from datetime import datetime
from loguru import logger

class SOSGenerator:
    """Generate SOS alert payload"""
    
    def __init__(self, config):
        self.config = config
    
    def generate_alert(self, video_path, location_data, severity="HIGH"):
        """
        Generate SOS alert with all required data
        
        Returns JSON payload for backend API
        """
        alert_id = str(uuid.uuid4())
        timestamp = datetime.now().isoformat()
        
        sos_payload = {
            "alert_id": alert_id,
            "timestamp": timestamp,
            "detection_method": "AI",
            "severity": severity,
            "location": {
                "latitude": location_data['latitude'],
                "longitude": location_data['longitude'],
                "location_name": location_data['location_name'],
                "camera_id": self.config['location']['camera_id']
            },
            "media": {
                "video_path": video_path,
                "duration": self.config['clip']['duration']
            },
            "status": "PENDING",
            "metadata": {
                "camera_type": location_data.get('camera_type', 'CCTV'),
                "coverage_area": location_data.get('coverage_area', 'Unknown')
            }
        }
        
        logger.info(f"SOS Alert generated: {alert_id}")
        return sos_payload