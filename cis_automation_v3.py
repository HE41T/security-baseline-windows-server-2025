# =================================================================================
# CIS Automation Tool for Ubuntu 24.04 Hardening
# ---------------------------------------------------------------------------------
# This script automates the Audit, Remediation, and Final Validation of security
# controls based on CIS benchmarks. It utilizes SSH/SFTP for remote execution
# and generates structured HTML reports for compliance tracking.
# =================================================================================

import paramiko
import os
import platform
import json
import datetime
import time
import sys
from jinja2 import Template
from configs.cis_config import CIS_TASKS
from configs.control import ENABLED_STEPS

# =================================================================================
# HELPER FUNCTIONS FOR SECTION PARSING
# =================================================================================

def parse_input_to_sections(selection_str):
    """
    แปลง string เช่น "1, 2, 17-19" หรือ "Section 1, Section 2" 
    ให้เป็น set ของตัวเลข [1, 2, 17, 18, 19]
    """
    if not selection_str or not selection_str.strip():
        return None  # ถ้า Input ว่าง ให้ถือว่าเลือกทั้งหมด
        
    target_sections = set()
    
    # ลบคำว่า "Section" และช่องว่างออก
    clean_str = selection_str.lower().replace("section", "").replace(" ", "")
    parts = clean_str.split(",")
    
    for part in parts:
        if not part: continue
        
        if "-" in part:
            # กรณีช่วง เช่น 17-19
            try:
                start, end = part.split("-")
                target_sections.update(range(int(start), int(end) + 1))
            except ValueError:
                print(f"Warning: รูปแบบผิดพลาด '{part}'")
        else:
            # กรณีตัวเลขเดี่ยว
            try:
                target_sections.add(int(part))
            except ValueError:
                print(f"Warning: ไม่ใช่ตัวเลข '{part}'")
                
    return target_sections

# =================================================================================
# MAIN AUTOMATION CLASS
# =================================================================================

class CISAutomation:
    def __init__(self, host_config, target_sections=None):
        self.host = host_config["host"]
        self.user = host_config["user"]
        self.password = host_config["password"]
        self.target_sections = target_sections  # รับค่า Section ที่ต้องการรัน (Set of Ints หรือ None)
        
        # Ensure the base logs directory exists for centralizing all audit outputs
        self.log_dir = "logs"
        if not os.path.exists(self.log_dir):
            os.makedirs(self.log_dir)
        
        self.report_dir = "reports"
        if not os.path.exists(self.report_dir):
            os.makedirs(self.report_dir)

        self.host_report_dir = os.path.join(self.report_dir, self.host.replace(" ", "_"))
        if not os.path.exists(self.host_report_dir):
            os.makedirs(self.host_report_dir)

        self.host_log_dir = os.path.join(self.log_dir, self.host.replace(" ", "_"))
        if not os.path.exists(self.host_log_dir):
            os.makedirs(self.host_log_dir)
        
        # Generate a unique log filename using the current timestamp for precise tracking
        current_time = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        self.log_file = os.path.join(self.host_log_dir, f"{current_time}.log")
        
        # Initialize the SSH client with Paramiko, setting-up the host key policy
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.sftp = None
        
        # Structure the results dictionary to capture execution flow and summarized metrics
        self.results = {
            "host_ip": self.host,
            "timestamp": current_time,
            "tasks": [],
            "summary": {
                "step1_pass": 0,
                "step1_fail": 0,
                "step2_pass": 0,
                "step2_fail": 0,
                "step3_pass": 0,
                "step3_fail": 0,
                "total_tasks": 0,
                "completed_tasks": 0
            }
        }
    
    def log(self, message, is_script_output=False):
        """บันทึก log ไปทั้งไฟล์และแสดงผลหน้าจอ"""
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        
        # Format the log entry: Add indentation for raw script outputs
        if is_script_output:
            lines = message.split('\n')
            indented_message = "\n".join([f"      | {line}" for line in lines if line.strip()])
            formatted_msg = indented_message
        else:
            formatted_msg = f"[{timestamp}] {message}"
        
        # Mirror logs to both console and the host-specific log file
        print(formatted_msg)
        with open(self.log_file, "a", encoding="utf-8") as f:
            f.write(formatted_msg + "\n")
    
    def connect(self):
        """เชื่อมต่อ SSH"""
        try:
            self.log(f"กำลังเชื่อมต่อกับ ({self.host})...")
            
            # Establish an SSH session using the provided credentials
            self.ssh.connect(
                hostname=self.host,
                username=self.user,
                password=self.password,
                timeout=10
            )
            
            # Open an SFTP session to handle script deployment tasks
            self.sftp = self.ssh.open_sftp()
            self.log(f"เชื่อมต่อสำเร็จกับ {self.host}")
            return True
        except Exception as e:
            self.log(f"ERROR: ไม่สามารถเชื่อมต่อกับ {self.host}: {str(e)}")
            return False

    def close_connections(self):
        """ปิดการเชื่อมต่อ SSH และ SFTP อย่างปลอดภัย"""
        try:
            if self.sftp:
                self.sftp.close()
            if self.ssh:
                self.ssh.close()
            self.log("ปิดการเชื่อมต่อ SSH เรียบร้อยแล้ว")
        except Exception as e:
            pass
    
    def exec_remote_script(self, local_path):
        """รันสคริปต์บนเครื่องปลายทาง"""
        remote_temp = "C:/Users/natagon.sir/Desktop/cis_temp_exec.ps1"
        
        if not os.path.exists(local_path):
            self.log(f"ERROR: File not found: {local_path}")
            return 404, f"Local file not found: {local_path}"
        
        try:
            # Transfer the local shell script to the remote directory via SFTP
            self.sftp.put(local_path, remote_temp)
            
            # Execute the remote script
            stdin, stdout, stderr = self.ssh.exec_command(f"powershell.exe -ExecutionPolicy Bypass -File {remote_temp}")
            
            exit_status = stdout.channel.recv_exit_status()
            
            # Retrieve consolidated output and error streams for logging and analysis
            out_content = stdout.read().decode().strip()
            err_content = stderr.read().decode().strip()
            
            combined_output = out_content + "\n" + err_content
            clean_output = combined_output.strip()
            
            return exit_status, clean_output
            
        except Exception as e:
            return 500, f"Execution error: {str(e)}"
    
    def _execute_step(self, task_id, step_key, script_type, task_result):
        """Execute a specific step (audit or remediation)"""
        step_num = step_key[-1]
        step_status_key = f"step{step_num}_status"
        step_output_key = f"step{step_num}_output"
        summary_pass_key = f"step{step_num}_pass"
        summary_fail_key = f"step{step_num}_fail"
        
        # Decide between running an audit script or remediation script
        if script_type == "audit":
            script_file = f"./audit/a{task_id}.ps1"
            step_messages = {
                "1": "กำลังเริ่มต้นตรวจสอบ...",
                "3": "กำลังตรวจสอบสุดท้าย..."
            }
            result_messages = {
                "1": "ผลเริ่มต้นตรวจสอบ",
                "3": "ผลตรวจสอบสุดท้าย"
            }
        else:  # Remediation step logic
            script_file = f"./remedtation/r{task_id}.ps1"
            step_messages = {"2": "กำลังแก้ไข..."}
            result_messages = {"2": "ผลการแก้ไข"}
        
        self.log(f"  [STEP {step_num}] {step_messages.get(step_num, '')}")
        exit_code, output = self.exec_remote_script(script_file)
        
        if output:
            self.log(output, is_script_output=True)
        
        # Interpret exit code 0 as a successful pass
        step_status = "PASS" if exit_code == 0 else "FAIL"
        task_result[step_status_key] = step_status
        task_result[step_output_key] = output
        
        # Update the host-level summary statistics
        if step_status == "PASS":
            self.results["summary"][summary_pass_key] += 1
        else:
            self.results["summary"][summary_fail_key] += 1
        
        self.log(f"    -> {result_messages.get(step_num, '')}: {step_status}")
    
    def _determine_final_status(self, task_result):
        """Determine final status based on enabled steps"""
        if ENABLED_STEPS.get("step3"):
            return task_result["step3_status"]
        if ENABLED_STEPS.get("step2"):
            return task_result["step2_status"]
        return task_result["step1_status"]
    
    def _get_status_icon(self, status):
        """Get icon for status"""
        if status == "PASS":
            return "[PASS]"
        if status == "FAIL":
            return "[FAIL]"
        return "[SKIP]"
    
    def _process_task(self, task, task_idx, total_tasks):
        """Process a single task through all steps"""
        task_id = task["id"]
        task_desc = task["desc"]
        
        self.log(f"\n[{task_idx}/{total_tasks}] CONTROL: {task_id} - {task_desc}")
        
        task_result = {
            "id": task_id,
            "description": task_desc,
            "step1_status": "SKIP",
            "step1_output": "",
            "step2_status": "SKIP",
            "step2_output": "",
            "step3_status": "SKIP",
            "step3_output": "",
            "row_class": "even" if task_idx % 2 == 0 else "odd"
        }

        # STEP 1: Initial Audit
        if ENABLED_STEPS.get("step1", False):
            self._execute_step(task_id, "step1", "audit", task_result)
        else:
            self.log("  [STEP 1] ข้าม (ตาม configs/control.py)")
        
        # STEP 2: Remediation
        if ENABLED_STEPS.get("step2", False):
            self._execute_step(task_id, "step2", "remedtation", task_result)
        else:
            self.log("  [STEP 2] ข้าม (ตาม configs/control.py)")
        
        # STEP 3: Final Audit
        if ENABLED_STEPS.get("step3", False):
            self._execute_step(task_id, "step3", "audit", task_result)
        else:
            self.log("  [STEP 3] ข้าม (ตาม configs/control.py)")
        
        # Aggregate the task results
        self.results["tasks"].append(task_result)
        self.results["summary"]["completed_tasks"] += 1
        
        final_status = self._determine_final_status(task_result)
        status_icon = self._get_status_icon(final_status)
        self.log(f"*** {task_id} เสร็จสมบูรณ์: [{status_icon}]")
        time.sleep(1)

    def run_flow(self):
        """รัน CIS hardening workflow"""
        self.log(f"\n{'='*60}")
        self.log(f"เริ่ม CIS Hardening Enforcer บน {self.host}")
        
        # แสดง Section ที่เลือก
        if self.target_sections:
            self.log(f"โหมดการทำงาน: เฉพาะ Section {sorted(list(self.target_sections))}")
        else:
            self.log("โหมดการทำงาน: รันทั้งหมด (All Sections)")
        self.log(f"{'='*60}")
        
        # -----------------------------------------------------
        # FILTER TASKS BASED ON SECTION INPUT
        # -----------------------------------------------------
        enabled_tasks = []
        for t in CIS_TASKS:
            if not t["enabled"]:
                continue
            
            # ถ้าไม่มีการระบุ Section (None) ให้รันทั้งหมด
            if self.target_sections is None:
                enabled_tasks.append(t)
                continue
                
            # ดึงเลข Section จาก ID (เช่น "1.1.1" -> 1)
            try:
                task_section = int(t['id'].split('.')[0])
                if task_section in self.target_sections:
                    enabled_tasks.append(t)
            except (ValueError, IndexError):
                # กรณี Format ID ผิดพลาด ให้ข้าม หรือ Log เตือน
                self.log(f"Warning: ข้าม Task ID ที่รูปแบบไม่ถูกต้อง: {t['id']}")
                continue

        total_tasks = len(enabled_tasks)
        self.results["summary"]["total_tasks"] = total_tasks
        
        if total_tasks == 0:
            self.log("ไม่พบ tasks ที่ตรงกับเงื่อนไขการค้นหา")
            return self.results
        
        try:
            # Process each enabled control
            for task_idx, task in enumerate(enabled_tasks, 1):
                self._process_task(task, task_idx, total_tasks)
        except KeyboardInterrupt:
            self.log("\n[!] ผู้ใช้ยกเลิกการทำงาน (Ctrl+C)")
            self.close_connections()
            raise # ส่งต่อให้ run_all_hosts จัดการ
        
        # Clean up
        self.close_connections()
        
        self.log(f"\n{'='*60}")
        self.log(f"Automation เสร็จสมบูรณ์สำหรับ {self.host}")
        self.log(f"บันทึกไฟล์: {self.log_file}")
        self.log(f"{'='*60}")
        
        return self.results

    
    def generate_host_report(self):
        """สร้าง HTML report สำหรับ host นี้"""
        template_path = "templates/report_templatev1.html"
        if not os.path.exists(template_path):
            self.log(f"ERROR: Template not found: {template_path}")
            return None
            
        try:
            with open(template_path, "r", encoding="utf-8") as f:
                template_content = f.read()
            
            template = Template(template_content)
            
            html_content = template.render(
                host=self.results,
                summary=self.results["summary"]
            )
            
            report_file = os.path.join(
                self.host_report_dir, 
                f"report_{self.results['timestamp']}.html"
            )
            
            with open(report_file, "w", encoding="utf-8") as f:
                f.write(html_content)
            
            self.log(f"สร้างรายงาน HTML: {report_file}")
            
            results_json = os.path.join(self.host_log_dir, "results.json")
            with open(results_json, "w") as f:
                json.dump(self.results, f, indent=2)
                
            return report_file
            
        except Exception as e:
            self.log(f"ERROR generating report: {str(e)}")
            return None


def generate_summary_report(all_results):
    """สร้าง summary report รวมทุก host"""
    template_path = "templates/summary_templatev1.html"
    if not os.path.exists(template_path):
        print(f"ERROR: Template not found: {template_path}")
        return None
        
    try:
        with open(template_path, "r", encoding="utf-8") as f:
            template_content = f.read()
        
        template = Template(template_content)
        
        total_summary = {
            "total_hosts": len(all_results),
            "total_tasks": 0,
            "step1_pass": 0,
            "step1_fail": 0,
            "step2_pass": 0,
            "step2_fail": 0,
            "step3_pass": 0,
            "step3_fail": 0
        }
        
        for result in all_results:
            total_summary["total_tasks"] += result["summary"]["total_tasks"]
            total_summary["step1_pass"] += result["summary"]["step1_pass"]
            total_summary["step1_fail"] += result["summary"]["step1_fail"]
            total_summary["step2_pass"] += result["summary"]["step2_pass"]
            total_summary["step2_fail"] += result["summary"]["step2_fail"]
            total_summary["step3_pass"] += result["summary"]["step3_pass"]
            total_summary["step3_fail"] += result["summary"]["step3_fail"]
        
        html_content = template.render(
            hosts=all_results,
            summary=total_summary,
            timestamp=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        )
        
        report_dir = "reports"
        summary_dir = os.path.join(report_dir, "summary")
        os.makedirs(summary_dir, exist_ok=True)

        summary_file = os.path.join(
            summary_dir,
            f"summary_{datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.html"
        )
        
        with open(summary_file, "w", encoding="utf-8") as f:
            f.write(html_content)
        
        print(f"\n{'#'*80}")
        print(f"สรุปรายงานทั้งหมด: {summary_file}")
        print(f"{'#'*80}")
        
        if platform.system() == "Windows":
            time.sleep(1)
            os.startfile(summary_file)
        return summary_file
        
    except Exception as e:
        print(f"ERROR generating summary: {str(e)}")
        return None

def validate_all_connections(hosts):
    """
    ตรวจสอบการเชื่อมต่อ SSH ของทุกโฮสต์ก่อนเริ่มทำงาน
    Returns: True ถ้าผ่านหมด, False ถ้ามีเครื่องใดเครื่องหนึ่งไม่ผ่าน
    """
    print(f"\n{'='*80}")
    print(f"PRE-FLIGHT CHECK: Checking SSH Connectivity for {len(hosts)} hosts...")
    print(f"{'='*80}")
    
    all_connected = True
    failed_hosts = []

    for i, host_config in enumerate(hosts, 1):
        print(f"[{i}/{len(hosts)}] Checking {host_config['host']}...", end=" ")
        
        # สร้าง Instance ชั่วคราวเพื่อเทส connection
        temp_automator = CISAutomation(host_config)
        
        if temp_automator.connect():
            print("OK ✓")
            temp_automator.close_connections()
        else:
            print("FAILED ✗")
            all_connected = False
            failed_hosts.append(host_config['host'])
    
    print("-" * 80)
    
    if not all_connected:
        print("\n[!!!] CRITICAL ERROR: Connection check failed for the following hosts:")
        for fh in failed_hosts:
            print(f" - {fh}")
        print("\nStopping execution because 'SSH Check Pass All' condition was not met.")
        return False
    
    print("\n[✓] All hosts are reachable. Proceeding to automation tasks.")
    return True

def run_all_hosts():
    """รัน automation สำหรับทุก host"""
    config_file = "configs/hosts.json"
    if not os.path.exists(config_file):
        print(f"ERROR: Config file not found: {config_file}")
        return []
        
    try:
        with open(config_file, "r") as f:
            config = json.load(f)
        
        hosts = config.get("hosts", [])
        
        if not hosts:
            print("No hosts configured")
            return []
            
    except Exception as e:
        print(f"ERROR loading config: {str(e)}")
        return []
    
    # ---------------------------------------------------------
    # STEP 0: Section Selection (รับค่า Section จากผู้ใช้)
    # ---------------------------------------------------------
    print(f"\n{'='*80}")
    print("CIS SELECTION MENU")
    print(f"{'='*80}")
    print("ตัวอย่าง: 1, 2, 5 (เฉพาะ section นั้น) หรือ 17-19 (ช่วง) หรือกด Enter เพื่อรันทั้งหมด")
    section_input = input("เลือก Section ที่ต้องการรัน: ")
    
    target_sections = parse_input_to_sections(section_input)
    
    if target_sections:
        print(f"-> Selected Sections: {sorted(list(target_sections))}")
    else:
        print("-> Selected Mode: Run ALL Sections")

    # ---------------------------------------------------------
    # STEP 1: Validate Connections (Pre-flight Check)
    # ---------------------------------------------------------
    if not validate_all_connections(hosts):
        return []

    # ---------------------------------------------------------
    # STEP 2: Main Execution Loop
    # ---------------------------------------------------------
    all_results = []
    
    print(f"\n{'#'*80}")
    print(f"เริ่ม CIS Automation สำหรับ {len(hosts)} เครื่อง")
    print(f"*** กด Ctrl+C เพื่อหยุดการทำงาน ***")
    print(f"{'#'*80}\n")
    
    try:
        for i, host_config in enumerate(hosts, 1):
            print(f"\n[เครื่องที่ {i}/{len(hosts)}] {host_config['host']}")
            print("-" * 50)
            
            # ส่ง target_sections เข้าไปใน class ด้วย
            automator = CISAutomation(host_config, target_sections=target_sections)
            
            # เชื่อมต่ออีกครั้งสำหรับการทำงานจริง
            if automator.connect():
                results = automator.run_flow()
                report_file = automator.generate_host_report()
                all_results.append(results)
                print(f"\n✓ เสร็จสิ้นสำหรับ {host_config['host']}")
                if report_file:
                    print(f"  รายงาน: {report_file}")
            else:
                print(f"\n✗ ล้มเหลวสำหรับ {host_config['host']} (Connection Lost)")
            
            print("-" * 50)
            
    except KeyboardInterrupt:
        print("\n\n" + "!"*60)
        print(" STOPPED: โปรแกรมถูกบังคับหยุดโดยผู้ใช้ (Ctrl+C)")
        print("!"*60 + "\n")
        sys.exit(1)
    
    if all_results:
        generate_summary_report(all_results)
    
    return all_results

if __name__ == "__main__":
    run_all_hosts()