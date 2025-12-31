import unittest
import cv2
import yaml
from src.accident_detector import AccidentDetector

class TestAccidentDetector(unittest.TestCase):
    
    def setUp(self):
        with open('config/config.yaml', 'r') as f:
            self.config = yaml.safe_load(f)
        self.detector = AccidentDetector(self.config)
    
    def test_model_loading(self):
        """Test if model loads successfully"""
        self.assertIsNotNone(self.detector.model)
    
    def test_detection_on_sample(self):
        """Test detection on sample image"""
        # Load test image
        frame = cv2.imread('tests/sample_videos/test_frame.jpg')
        
        # Detect
        results = self.detector.detect_objects(frame)
        
        # Assert results exist
        self.assertIsNotNone(results)
    
    def test_accident_pattern_analysis(self):
        """Test accident pattern detection logic"""
        # This would require creating mock detection results
        pass

if __name__ == '__main__':
    unittest.main()