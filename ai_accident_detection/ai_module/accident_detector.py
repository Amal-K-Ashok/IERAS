def detect_accident(frame_count):
    # Simulated detection
    if frame_count == 150:
        return True, "HIGH"
    return False, None
