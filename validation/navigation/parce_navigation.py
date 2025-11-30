import re
import json
import ast
import pandas as pd

logfile = "navigation_manual_dyn.txt"


rows = []

current_user = None

with open(logfile, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()

        # --- A) Capture user query ---
        m_user = re.search(r"Recieved message: (.*)", line)
        if m_user:
            current_user = m_user.group(1).strip()
            continue

        # --- B) Capture Agent Response for that user query ---
        if "Agent Response:" in line and current_user is not None:

            # 1) Extract tool name + args from tool_calls=[{...}]
            tool_name = None
            tool_args = None

            m_tool = re.search(
                r"tool_calls=\[\{'name': '([^']+)', 'args': (\{.*?\})",
                line
            )
            if m_tool:
                tool_name = m_tool.group(1)
                args_str = m_tool.group(2)
                try:
                    # args is a Python dict literal like {'goal_location': 'station_1'}
                    tool_args = ast.literal_eval(args_str)
                except Exception:
                    tool_args = args_str  # fallback to raw string


            # 2) Extract NAV2 JSON from ToolMessage(content='{"command": ... }', ...)
            nav2_status = None
            nav_time = None
            distance_remaining = None
            recoveries = None
            error_msg = None

            m_nav = re.search(
                r"ToolMessage\(content='({\"command\":.*?})'",
                line
            )
            if m_nav:
                json_str = m_nav.group(1)
                try:
                    nav = json.loads(json_str)
                    nav2_status = nav.get("nav2_status")
                    nav_time = nav.get("navigation_time_sec")
                    distance_remaining = nav.get("distance_remaining")
                    recoveries = nav.get("recoveries")
                    error_msg = nav.get("error_msg")
                except Exception as e:
                    print("JSON parse error:", e)
                    print("Offending JSON:", json_str)

            rows.append({
                "user_query": current_user,
                "tool_called": tool_name,
                "tool_args": tool_args,
                "nav2_status": nav2_status,
                "nav_time_sec": nav_time,
                "distance_remaining": distance_remaining,
                "recoveries": recoveries,
                "error_msg": error_msg,
            })

            # Reset for next interaction
            current_user = None

# Build DataFrame & save
df = pd.DataFrame(rows)
print("Parsed rows:", len(df))
print(df.head())

df.to_csv("navigation_parsed.csv", index=False)
print("Saved to navigation_parsed.csv")
