import re
import json
import ast
import pandas as pd

# 1) Point this to your SEQUENCE log file
# Example:
# logfile = r"C:\Users\Ana\Documents\navigation_seq.txt"
logfile = "navigation_seq_dyn.txt"

rows = []

current_user = None
interaction_id = 0

with open(logfile, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()

        # --- A) Capture user query (used for context) ---
        m_user = re.search(r"Recieved message: (.*)", line)
        if m_user:
            current_user = m_user.group(1).strip()
            continue

        # --- B) When we see an Agent Response, parse ALL tool_calls in it ---
        if "Agent Response:" in line and current_user is not None:
            interaction_id += 1  # one per user query
            agent_line = line

            # --- 1) Find ALL tool_calls in this Agent Response ---
            tool_calls = []
            for m in re.finditer(
                r"tool_calls=\[\{'name': '([^']+)', 'args': (\{.*?\})",
                agent_line
            ):
                tool_name = m.group(1)
                args_str = m.group(2)
                pos = m.start()

                try:
                    tool_args = ast.literal_eval(args_str)
                except Exception:
                    tool_args = args_str  # if parsing fails, keep as string

                tool_calls.append({
                    "name": tool_name,
                    "args": tool_args,
                    "pos": pos,
                })

            # --- 2) Find ALL Nav2 ToolMessages in this Agent Response ---
            # Only those with content starting with {"command": ...}
            nav_msgs = []
            for m in re.finditer(
                r"ToolMessage\(content='({\"command\":.*?})', name='([^']+)'",
                agent_line
            ):
                json_str = m.group(1)
                nav_name = m.group(2)
                pos = m.start()
                try:
                    nav = json.loads(json_str)
                except Exception as e:
                    print("JSON parse error:", e)
                    print("Offending JSON:", json_str)
                    nav = {}

                nav_msgs.append({
                    "name": nav_name,
                    "pos": pos,
                    "data": nav,
                    "used": False,
                })

            # --- 3) For each tool_call, create one row and attach Nav2 if available ---
            for tc in tool_calls:
                tc_name = tc["name"]
                tc_args = tc["args"]
                tc_pos = tc["pos"]

                nav2_status = None
                nav_time = None
                distance_remaining = None
                recoveries = None
                error_msg = None

                # Only try to match Nav2 data for tools that actually use Nav2
                # (e.g., move_to_goal; you can extend this list if needed)
                if tc_name in ["move_to_goal", "turn_robot"]:
                    # Find the first nav_msg after this tool_call with matching name
                    best_idx = None
                    best_pos = None
                    for i, nm in enumerate(nav_msgs):
                        if nm["used"]:
                            continue
                        if nm["name"] != tc_name:
                            continue
                        if nm["pos"] > tc_pos:
                            if best_pos is None or nm["pos"] < best_pos:
                                best_pos = nm["pos"]
                                best_idx = i

                    if best_idx is not None:
                        nav_msgs[best_idx]["used"] = True
                        nav = nav_msgs[best_idx]["data"]
                        nav2_status = nav.get("nav2_status")
                        nav_time = nav.get("navigation_time_sec")
                        distance_remaining = nav.get("distance_remaining")
                        recoveries = nav.get("recoveries")
                        error_msg = nav.get("error_msg")

                rows.append({
                    "interaction_id": interaction_id,
                    "user_query": current_user,
                    "tool_name": tc_name,
                    "tool_args": tc_args,
                    "nav2_status": nav2_status,
                    "nav_time_sec": nav_time,
                    "distance_remaining": distance_remaining,
                    "recoveries": recoveries,
                    "error_msg": error_msg,
                })

            # Done with this Agent Response
            current_user = None

# --- 4) Save to CSV ---
df = pd.DataFrame(rows)
print("Parsed tool_calls:", len(df))
print(df.head())

df.to_csv("navigation_seq_parsed.csv", index=False)
print("Saved to navigation_seq_parsed.csv")
