import subprocess


class Tmux:

    def __init__(self, session_name):
        self.session_name = session_name

    def start_tmux_session(self):
        """
        Start a new tmux session.
        """
        subprocess.run(["tmux", "new-session", "-d", "-s", self.session_name])

    def send_command_to_tmux(self, command):
        """
        Send a command to a tmux session.
        """
        subprocess.run(["tmux", "send-keys", "-t", self.session_name, command, "Enter"])

    def list_tmux_sessions(self):
        """
        List all tmux sessions.
        """
        result = subprocess.run(["tmux", "list-sessions"], capture_output=True, text=True)
        print(f"{result.stdout}")

    def attach_to_tmux_session(self):
        """
        Attach to an existing tmux session.
        """
        subprocess.run(["tmux", "attach-session", "-t", self.session_name])

    def detach_tmux_session(self):
        """
        Detach from a tmux session.
        """
        subprocess.run(["tmux", "detach", "-s", self.session_name])

    def kill_session(self):
        """
        Kill a tmux session.
        """
        subprocess.run(["tmux", "kill-session", "-t", self.session_name])
