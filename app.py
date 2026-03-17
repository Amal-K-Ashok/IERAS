from flask import Flask, render_template, request, jsonify, session, redirect, url_for
from supabase_client import supabase

app = Flask(__name__)
app.secret_key = "your-secret-key-change-this"

# ---------------- LOGIN ----------------
@app.route("/", methods=["GET", "POST"])
def hospital_login():
    if request.method == "POST":
        hospital_id = request.form.get("hospital_id", "").strip()

        try:
            hospital_id_int = int(hospital_id)
        except ValueError:
            return render_template("login.html", error="❌ Invalid Hospital ID format")

        response = (
            supabase
            .table("hospital")
            .select("*")
            .eq("Hos_id", hospital_id_int)
            .execute()
        )

        if not response.data:
            return render_template("login.html", error="❌ Hospital ID not found")

        hospital = response.data[0]
        session["hospital_id"] = hospital_id_int
        session["hospital_name"] = hospital.get("Hos_name", "")

        return redirect(url_for("dashboard"))

    return render_template("login.html")


# ---------------- LOGOUT ----------------
@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("hospital_login"))


# ---------------- DASHBOARD ----------------
@app.route("/dashboard")
def dashboard():
    if "hospital_id" not in session:
        return redirect(url_for("hospital_login"))

    hospital_id = session["hospital_id"]
    hospital_name = session.get("hospital_name", "")

    # Fetch ALL rows for this hospital — filter null status_hos in Python
    response = (
        supabase
        .table("ambulance_tracking")
        .select("*")
        .eq("Hos_id", hospital_id)
        .order("updated_at", desc=True)
        .execute()
    )

    all_cases = response.data or []
    print(f"DEBUG: hospital_id={hospital_id}, total rows fetched={len(all_cases)}")
    for c in all_cases:
        print(f"  tracking_id={c.get('tracking_id')}  status_hos={repr(c.get('status_hos'))}")

    # Show only rows where status_hos is null/empty
    cases = [c for c in all_cases if c.get("status_hos") in (None, "", "null", "NULL")]
    print(f"DEBUG: pending cases after filter={len(cases)}")

    return render_template(
        "dashboard.html",
        hospital_id=hospital_id,
        hospital_name=hospital_name,
        cases=cases
    )


# ---------------- CASE DETAIL API ----------------
@app.route("/case_detail/<tracking_id>")
def case_detail(tracking_id):
    if "hospital_id" not in session:
        return jsonify({"error": "Unauthorized"}), 401

    response = (
        supabase
        .table("ambulance_tracking")
        .select("*")
        .eq("tracking_id", tracking_id)
        .order("updated_at", desc=True)
        .limit(1)
        .execute()
    )

    if not response.data:
        return jsonify({"error": "Not found"}), 404

    return jsonify(response.data[0])


# ---------------- ACCEPT / REJECT ----------------
@app.route("/hospital_response", methods=["POST"])
def hospital_response():
    if "hospital_id" not in session:
        return jsonify({"error": "Unauthorized"}), 401

    data = request.get_json()
    tracking_id = data.get("tracking_id")
    status = data.get("response")  # "ACCEPTED" or "REJECTED"
    hospital_id = session["hospital_id"]

    if status not in ("ACCEPTED", "REJECTED"):
        return jsonify({"message": "Invalid status"}), 400

    location_res = (
        supabase
        .table("ambulance_tracking")
        .select("latitude, longitude")
        .eq("tracking_id", tracking_id)
        .order("updated_at", desc=True)
        .limit(1)
        .execute()
    )

    if not location_res.data:
        return jsonify({"message": "Location not found"}), 404

    latitude = location_res.data[0]["latitude"]
    longitude = location_res.data[0]["longitude"]

    supabase.table("ambulance_tracking") \
        .update({"status_hos": status}) \
        .eq("tracking_id", tracking_id) \
        .execute()

    supabase.table("case_history").insert({
        "tracking_id": tracking_id,
        "Hos_id": hospital_id,
        "status": status,
        "latitude": latitude,
        "longitude": longitude
    }).execute()

    return jsonify({"message": f"Case {status}", "status": status})


# ---------------- LIVE LOCATION API ----------------
@app.route("/get_location/<tracking_id>")
def get_location(tracking_id):
    response = (
        supabase
        .table("ambulance_tracking")
        .select("latitude, longitude")
        .eq("tracking_id", tracking_id)
        .order("updated_at", desc=True)
        .limit(1)
        .execute()
    )

    if not response.data:
        return jsonify({})

    row = response.data[0]
    return jsonify({"latitude": row["latitude"], "longitude": row["longitude"]})


# ---------------- HOSPITAL LOCATION API ----------------
@app.route("/get_hospital_location")
def get_hospital_location():
    if "hospital_id" not in session:
        return jsonify({"error": "Unauthorized"}), 401

    hospital_id = session["hospital_id"]
    response = (
        supabase
        .table("hospital")
        .select("latitude, longitude, Hos_name")
        .eq("Hos_id", hospital_id)
        .execute()
    )

    if not response.data:
        return jsonify({})

    return jsonify(response.data[0])


# ---------------- HISTORY ----------------
@app.route("/history")
def hospital_history():
    if "hospital_id" not in session:
        return redirect(url_for("hospital_login"))

    hospital_id = session["hospital_id"]
    hospital_name = session.get("hospital_name", "")

    response = (
        supabase
        .table("case_history")
        .select("*")
        .eq("Hos_id", hospital_id)
        .order("created_at", desc=True)
        .execute()
    )

    return render_template(
        "history.html",
        history=response.data or [],
        hospital_id=hospital_id,
        hospital_name=hospital_name
    )

# ---------------- LIVE TRACK PAGE ----------------
@app.route("/live_track/<tracking_id>")
def live_track(tracking_id):
    if "hospital_id" not in session:
        return redirect(url_for("hospital_login"))

    hospital_id = session["hospital_id"]
    hospital_name = session.get("hospital_name", "")

    return render_template(
        "live_track.html",
        tracking_id=tracking_id,
        hospital_id=hospital_id,
        hospital_name=hospital_name
    )
if __name__ == "__main__":
    app.run(debug=True)