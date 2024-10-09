import sys

def parse_terminal_input():
    commands = []
    current_command = []

    for line in sys.stdin:
        line = line.strip()

        # If the line starts with the prompt, we process the previous command
        if line.startswith("❯"):
            # if current_command:
                # Join the current command and add it to the list of commands
            if cmd := line[1:].strip():
                commands.append(cmd)
                # current_command = []
        else:
            pass
            # Add the current line to the ongoing command
            # current_command.append(line)

    # Add the last command if any
    # if current_command:
        # commands.append(" ".join(current_command))

    return commands

if __name__ == "__main__":
    print("Enter terminal input (Ctrl+D to stop):")
    commands = parse_terminal_input()
    print(f"Parsed commands ({len(commands)}):")
    for cmd in commands:
        print(cmd)