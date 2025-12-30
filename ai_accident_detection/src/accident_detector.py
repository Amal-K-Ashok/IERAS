from ultralytics import YOLO
import cv2
import numpy as np
from loguru import logger

class AccidentDetector:
    """Detect accidents using YOLOv8"""
    
    def __init__(self, config):
        self.config = config
        self.model_path = config['model']['path']
        self.confidence = config['model']['confidence_threshold']
        self.device = config['model']['device']
        self.classes_of_interest = config['detection']['classes_of_interest']
        self.accident_threshold = config['detection']['accident_threshold']
        
        # Load model
        self.model = YOLO(self.model_path)
        logger.info(f"YOLOv8 model loaded from {self.model_path}")
        
        # For validation
        self.detection_history = []
        self.validation_frames = config['detection']['validation_frames']
    
    def detect_objects(self, frame):
        """Detect objects in frame using YOLO"""
        results = self.model(frame, conf=self.confidence, device=self.device)
        return results[0]  # First result
    
    def analyze_accident_patterns(self, results):
        """
        Analyze detection results for accident patterns
        
        Accident indicators:
        - Unusual object positions/overlaps
        - Sudden appearance of people on road
        - Vehicles at odd angles
        - Multiple vehicles in close proximity
        """
        boxes = results.boxes
        
        if boxes is None or len(boxes) == 0:
            return False, 0.0
        
        accident_score = 0.0
        total_checks = 0
        
        # Get detected objects
        detected_objects = []
        for box in boxes:
            cls = int(box.cls[0])
            conf = float(box.conf[0])
            xyxy = box.xyxy[0].cpu().numpy()
            
            class_name = self.model.names[cls]
            
            if class_name in self.classes_of_interest:
                detected_objects.append({
                    'class': class_name,
                    'confidence': conf,
                    'bbox': xyxy
                })
        
        if len(detected_objects) < 2:
            return False, 0.0
        
        # Check 1: Vehicle overlaps (collision)
        vehicles = [obj for obj in detected_objects if obj['class'] in ['car', 'truck', 'bus', 'motorcycle']]
        if len(vehicles) >= 2:
            for i in range(len(vehicles)):
                for j in range(i + 1, len(vehicles)):
                    iou = self._calculate_iou(vehicles[i]['bbox'], vehicles[j]['bbox'])
                    if iou > 0.3:  # Significant overlap
                        accident_score += 0.4
                        total_checks += 1
        
        # Check 2: People near vehicles (potential victim)
        people = [obj for obj in detected_objects if obj['class'] == 'person']
        if len(people) > 0 and len(vehicles) > 0:
            for person in people:
                for vehicle in vehicles:
                    distance = self._calculate_distance(person['bbox'], vehicle['bbox'])
                    if distance < 100:  # Close proximity
                        accident_score += 0.3
                        total_checks += 1
        
        # Check 3: Vehicle orientation (unusual angles)
        # This would require more advanced analysis with pose estimation
        # For now, we'll use a simplified check
        
        # Normalize score
        if total_checks > 0:
            accident_score = min(accident_score / total_checks, 1.0)
        
        is_accident = accident_score >= self.accident_threshold
        
        return is_accident, accident_score
    
    def validate_accident(self, is_accident):
        """Validate accident across multiple frames to reduce false positives"""
        self.detection_history.append(is_accident)
        
        # Keep only recent detections
        if len(self.detection_history) > self.validation_frames:
            self.detection_history.pop(0)
        
        # Require accident detection in majority of recent frames
        if len(self.detection_history) >= self.validation_frames:
            accident_count = sum(self.detection_history)
            validation_threshold = self.validation_frames * 0.6  # 60% of frames
            
            if accident_count >= validation_threshold:
                logger.warning(f"ACCIDENT VALIDATED! ({accident_count}/{self.validation_frames} frames)")
                self.detection_history.clear()  # Reset after detection
                return True
        
        return False
    
    def _calculate_iou(self, box1, box2):
        """Calculate Intersection over Union"""
        x1_min, y1_min, x1_max, y1_max = box1
        x2_min, y2_min, x2_max, y2_max = box2
        
        # Intersection area
        inter_x_min = max(x1_min, x2_min)
        inter_y_min = max(y1_min, y2_min)
        inter_x_max = min(x1_max, x2_max)
        inter_y_max = min(y1_max, y2_max)
        
        if inter_x_max < inter_x_min or inter_y_max < inter_y_min:
            return 0.0
        
        inter_area = (inter_x_max - inter_x_min) * (inter_y_max - inter_y_min)
        
        # Union area
        box1_area = (x1_max - x1_min) * (y1_max - y1_min)
        box2_area = (x2_max - x2_min) * (y2_max - y2_min)
        union_area = box1_area + box2_area - inter_area
        
        return inter_area / union_area if union_area > 0 else 0.0
    
    def _calculate_distance(self, box1, box2):
        """Calculate distance between box centers"""
        center1 = [(box1[0] + box1[2]) / 2, (box1[1] + box1[3]) / 2]
        center2 = [(box2[0] + box2[2]) / 2, (box2[1] + box2[3]) / 2]
        
        distance = np.sqrt((center1[0] - center2[0])**2 + (center1[1] - center2[1])**2)
        return distance
    
    def draw_detections(self, frame, results):
        """Draw bounding boxes on frame for visualization"""
        annotated_frame = results.plot()
        return annotated_frame