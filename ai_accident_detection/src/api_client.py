import requests
import json
from loguru import logger

class APIClient:
    """Send SOS alerts to backend API"""
    
    def __init__(self, config):
        self.config = config
        self.backend_url = config['api']['backend_url']
        self.timeout = config['api']['timeout']
        self.retry_attempts = config['api']['retry_attempts']
    
    def send_sos_alert(self, sos_payload):
        """
        Send SOS alert to backend API
        
        POST /api/sos
        """
        headers = {
            'Content-Type': 'application/json'
        }
        
        for attempt in range(self.retry_attempts):
            try:
                response = requests.post(
                    self.backend_url,
                    json=sos_payload,
                    headers=headers,
                    timeout=self.timeout
                )
                
                if response.status_code == 200 or response.status_code == 201:
                    logger.success(f"SOS alert sent successfully: {sos_payload['alert_id']}")
                    return True, response.json()
                else:
                    logger.error(f"API error: {response.status_code} - {response.text}")
                    
            except requests.exceptions.Timeout:
                logger.warning(f"Request timeout (attempt {attempt + 1}/{self.retry_attempts})")
            except requests.exceptions.RequestException as e:
                logger.error(f"Request failed: {e}")
            
            if attempt < self.retry_attempts - 1:
                logger.info("Retrying...")
        
        logger.error(f"Failed to send SOS alert after {self.retry_attempts} attempts")
        return False, None
    
    def upload_video(self, video_path):
        """
        Upload video file to backend (if needed)
        
        This could be to cloud storage or backend server
        """
        # Implementation depends on backend requirements
        # Could use multipart/form-data or upload to S3/Cloud Storage
        pass