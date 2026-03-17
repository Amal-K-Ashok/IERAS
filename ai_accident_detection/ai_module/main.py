import cv2
import uuid
from config import CAMERA_ID, CAMERA_LAT, CAMERA_LON
from supabase_client import supabase
from accident_detector import detect_accident
from video_clipper import extract_clip

VIDEO_PATH = "test_video.mp4"

cap = cv2.VideoCapture(VIDEO_PATH)
frame_count = 0

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    frame_count += 1

    accident, severity = detect_accident(frame_count)

    if accident:
        print("🚨 Accident Detected!")

        clip_name = f"accident_{uuid.uuid4()}.mp4"
        extract_clip(VIDEO_PATH, frame_count-30, frame_count+30, clip_name)

        # Upload video to Supabase Storage
        with open(clip_name, "rb") as f:
            supabase.storage.from_("videos").upload(clip_name, f)

        video_url = supabase.storage.from_("videos").get_public_url(clip_name)

        # Insert data into database
        supabase.table("accidents").insert({
            "camera_id": CAMERA_ID,
            "latitude": CAMERA_LAT,
            "longitude": CAMERA_LON,
            "severity": severity,
            "video_url": video_url
        }).execute()

        break

cap.release()
