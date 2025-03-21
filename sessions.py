class Sessions:
    """
        e.x:
            "id": 1,
            "session_name": "Example Server",
            "start_up": true,
            "execute_commands": true,
            "system_commands": "cd /home/username/, ./gradlew bootRun"

    id: id of the process
    name: name of the session
    start_up: should this start a session
    execute_commands: should this execute commands
    system_commands: the commands to run
    """

    def __init__(self, id, session_name, start_up, execute_commands, system_commands):
        self.id = id
        self.session_name = session_name
        self.start_up = start_up
        self.execute_commands = execute_commands
        self.system_commands = system_commands

    def __repr__(self):
        return (f"Sessions(id={self.id}, "
                f"session_name={self.session_name}, "
                f"start_up={self.start_up}, "
                f"system_commands={self.system_commands})")

    def get_id(self):
        return self.id

    def get_session_name(self):
        return self.session_name

    def get_start_up(self):
        return self.start_up

    def get_execute_commands(self):
        return self.execute_commands

    def get_system_commands(self):
        return self.system_commands
