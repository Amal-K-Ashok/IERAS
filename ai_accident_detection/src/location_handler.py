import json
from loguru import logger

class LocationHandler:
    """Handle GPS location extraction"""
    
    def __init__(self, config):
        self.config = config
        self.camera_id = config['location']['camera_id']
        self.locations_file = config['location']['camera_locations_file']
        
        # Load camera locations
        self.camera_locations = self._load_camera_locations()
    
    def _load_camera_locations(self):
        """Load camera GPS coordinates from file"""
        try:
            with open(self.locations_file, 'r') as f:
                locations = json.load(f)
            logger.info(f"Loaded {len(locations)} camera locations")
            return locations
        except Exception as e:
            logger.error(f"Failed to load camera locations: {e}")
            return {}
    
    def get_location(self, camera_id=None):
        """Get GPS coordinates for camera"""
        cam_id = camera_id or self.camera_id
        
        if cam_id in self.camera_locations:
            location = self.camera_locations[cam_id]
            logger.info(f"Location for {cam_id}: {location['location_name']}")
            return location
        else:
            logger.warning(f"No location data for camera: {cam_id}")
            return None