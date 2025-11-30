import re
import ast
import os
import pandas as pd

# === 1) Add your log file paths here ===
# Example if they’re in the same folder as this script:
# logfiles = ["navigation_manual.txt", "navigation_seq.txt"]
logfiles = [
    r"mapping_dyn_manual.txt",
    r"mapping_dyn_seq.txt",
]


def parse_logs_for_feedback(filenames):
    rows = []

    for logfile in filenames:
        interaction_id = 0
        current_user = None

        with open(logfile, "r", encoding="utf-8") as f:
            for raw_line in f:
                line = raw_line.strip()

                # --- A) User query line ---
                m_user = re.search(r"Recieved message: (.*)", line)
                if m_user:
                    current_user = m_user.group(1).strip()
                    continue

                # --- B) Agent Response block for that user query ---
                if "Agent Response:" in line and current_user is not None:
                    interaction_id += 1
                    agent_line = line

                    # 1) Find ALL tool_calls in this Agent Response
                    tool_calls = []
                    for m in re.finditer(
                        r"tool_calls=\[\{'name': '([^']+)', 'args': (\{.*?\})",
                        agent_line
                    ):
                        name = m.group(1)
                        args_str = m.group(2)
                        pos = m.start()  # position in the line, used for ordering

                        try:
                            args = ast.literal_eval(args_str)
                        except Exception:
                            args = args_str  # keep raw if parsing fails

                        tool_calls.append({
                            "name": name,
                            "args": args,
                            "pos": pos,
                        })

                    # 2) Find ALL AI feedback messages (AIMessage with non-empty content)
                    #    We skip the planning AIMessage that has tool_calls in additional_kwargs.
                    ai_msgs = []
                    for m in re.finditer(
                        r"AIMessage\(content='(.*?)', additional_kwargs=\{\}",
                        agent_line
                    ):
                        content = m.group(1)
                        if content.strip() == "":
                            continue
                        pos = m.start()
                        ai_msgs.append({
                            "content": content,
                            "pos": pos,
                        })

                    # sort by position in the line
                    tool_calls.sort(key=lambda x: x["pos"])
                    ai_msgs.sort(key=lambda x: x["pos"])

                    # 3) For each tool_call, attach the nearest following AI feedback
                    for i, tc in enumerate(tool_calls):
                        tc_pos = tc["pos"]
                        next_pos = tool_calls[i + 1]["pos"] if i + 1 < len(tool_calls) else None

                        chosen_feedback = None
                        for am in ai_msgs:
                            if am["pos"] > tc_pos and (next_pos is None or am["pos"] < next_pos):
                                chosen_feedback = am["content"]
                                break

                        rows.append({
                            "source_file": os.path.basename(logfile),
                            "interaction_id": interaction_id,
                            "user_query": current_user,
                            "tool_name": tc["name"],
                            "agent_feedback": chosen_feedback,
                            # optional: keep args if you want them later
                            "tool_args": tc["args"],
                        })

                    # reset for next interaction
                    current_user = None

    return pd.DataFrame(rows)


if __name__ == "__main__":
    df = parse_logs_for_feedback(logfiles)

    print("Parsed tool calls:", len(df))
    print(df.head())

    # Save everything to one CSV
    df.to_csv("agent_tools_feedback.csv", index=False)
    print("Saved to agent_tools_feedback.csv")
