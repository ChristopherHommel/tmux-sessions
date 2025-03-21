import json
from sessions import Sessions
from tmux import Tmux

JSON_FILE = './sessions.json'


def read_json():
    """
    Load the json file and read the data into Sessions
    :return: a list of Sessions
    """
    sessions = []
    with open(JSON_FILE, 'r') as file:
        data = json.load(file)

        for session in data:
            sessions.append(
                Sessions(session['id'],
                         session['session_name'],
                         session['start_up'],
                         session["execute_commands"],
                         session['system_commands']))

        file.close()

    return sessions


def execute_sessions(session):
    """
    Execute the sessions
    :param session: the session to execute
    """
    print(session.__repr__())

    #
    # First drop this session if it exists.
    # I won't drop your sessions that sessions.json does not know about
    #
    tmux = Tmux(session.get_session_name())

    try:
        tmux.kill_session()
    except Exception as e:
        print("Session does not exist", e)

    if not session.get_start_up():
        print(f"{session.get_session_name()} Session not set to start up.")
        return

    tmux.start_tmux_session()

    if not session.get_execute_commands():
        print(f"{session.get_session_name()} Session started but commands not run.")
        return

    for system_commands in range(len(session.get_system_commands())):
        command = session.get_system_commands()[system_commands]
        tmux.send_command_to_tmux(command)


def tmux_usages():
    """
    Shows list of commands helpful to this context
    :return:
    """
    print("|")
    print("|____Attach to a session")
    print("|    |____tmux a <session_name>")
    print("|")
    print("|____Detach from this session")
    print("|    |____ctrl+b d")
    print("|")
    print("|____List sessions from a tmux session")
    print("|    |____ctrl+b s")
    print("|    |")
    print("|    |____Kill a session from this list")
    print("|        |____: kill-session")
    print("|")
    print("|____Enter scroll mode")
    print("|    |____ctrl+b [")
    print("|")
    print("|____Open a new pane")
    print("|    |____ctrl+b %")
    print("|")
    print("|____Resize a pane")
    print("|    |____ctrl+b :")
    print("|    |____resize-pane -x 50")
    print("|")

    return   

def main():
    sessions = read_json()

    print(f"\nFound {len(sessions)} sessions\n")

    for i in range(len(sessions)):
        execute_sessions(sessions[i])

    print("+------------------------------------------------------------+")
    print("Finished building sessions")
    print(tmux_usages())
    print("+------------------------------------------------------------+")


if __name__ == '__main__':
    main()
