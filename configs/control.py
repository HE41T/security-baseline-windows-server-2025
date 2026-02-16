# configs/control.py

# กำหนด steps ที่ต้องการรัน (True = รัน, False = ข้าม)
ENABLED_STEPS = {
    "step1": True,   # Initial Audit
    "step2": True,   # Remediation
    "step3": True    # Final Audit
}

# หรือจะใช้แบบ list ก็ได้
# ENABLED_STEPS = ["step1", "step2", "step3"]
# ENABLED_STEPS = ["step2", "step3"]  # ข้าม step1