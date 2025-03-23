#!/bin/bash
#
# Installs dependencies for this project
#
# Usage:
#     ./install.sh <-t>
#
# Options:
#     -t Pipe output logs to a file (tee)
#
# +------------------------------------------------------+
# | Who          | Date       | Version | Comments       |
# | Chris Hommel | 21-03-2025 | 1       | Initial set up |
# |              |            |         |                |
# |              |            |         |                |
# |              |            |         |                |
# |              |            |         |                |
# |              |            |         |                |
# |              |            |         |                |
# +------------------------------------------------------+
#
#

PIPE_TO_FILE=0
LOG_FILE="./install-log.txt"

write_options(){
    write_log "Options:"
    write_log "    <-t> Pipe output to file"
    write_log "    <-?> Print options"
}

write_log(){
    if [ $PIPE_TO_FILE -eq 1 ]; then
        echo "$1" >> "$LOG_FILE"
    else
        echo "$1"
    fi
}

write_error(){
    local message="$1"
    write_log "$message"
    local length=${#message}
    local line=$(printf '%*s' "$length" '' | tr ' ' '^')
    write_log "$line"
}

parse_args(){
    for arg in "$@"; do
        case "$arg" in
            -t)
            write_log "Pipe to file turned on, writing to $LOG_FILE"
            PIPE_TO_FILE=1
            ;;
            -?)
            writeOptions
            ;;
            *)
            writeOptions
            ;;
        esac
    done

    write_log "Starting install"
    return 0
}

parse_args "$@"

check_and_install_python(){
    if command -v python3 &>/dev/null; then
        local python_version=$(python3 --version)
        write_log "Found $python_version"
        return 0
    else
        write_log "Python 3 is not installed"

        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y python3-full
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y python3-full
        elif command -v yum &>/dev/null; then
            sudo yum install -y python3-full
        else
            write_error "Could not find a package manager"
            return 1
        fi

        if command -v python3 &>/dev/null; then
            local python_version=$(python3 --version)
            write_log "Successfully installed $python_version"
            return 0
        else
            write_error "Failed to install Python 3"
            return 1
        fi
    fi
}

check_and_install_python_venv(){
    local python_version=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1-2)
    local venv_package="python${python_version}-venv"

    if python3 -m venv test_venv &>/dev/null; then
        write_log "Python venv module is working properly"
        rm -rf test_venv
        return 0
    else
        write_log "Python venv module not found, installing ${venv_package}"

        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y "${venv_package}"
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y "${venv_package}"
        elif command -v yum &>/dev/null; then
            sudo yum install -y "${venv_package}"
        else
            write_error "Could not find a package manager"
            return 1
        fi

        if python3 -m venv test_venv &>/dev/null; then
            write_log "Successfully installed ${venv_package}"
            rm -rf test_venv
            return 0
        else
            write_error "Failed to install ${venv_package}"
            return 1
        fi
    fi
}

check_and_install_pip3(){
    if command -v pip3 &>/dev/null; then
        local pip_version=$(pip3 --version)
        write_log "Found $pip_version"
        return 0

    else
        write_log "pip3 is not installed"

        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y python3-pip
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y python3-pip
        elif command -v yum &>/dev/null; then
            sudo yum install -y python3-pip
        else
            write_error "Could not find a package manager"
            return 1
        fi

        if command -v pip3 &>/dev/null; then
            local pip_version=$(pip3 --version)
            write_log "Successfully installed pip3: $pip_version"
            return 0
        else
            write_error "Failed to install pip3"
            return 1
        fi
    fi
}

install_python_dependencies(){
    if ! command -v pip3 &>/dev/null; then
        write_error "pip3 is not installed"
        return 1
    fi

    write_log "Creating a virtual environment"
    python3 -m venv .venv

    if [ $? -ne 0 ]; then
        write_error "Failed to create virtual environment"
        return 1
    fi

    write_log "Activating virtual environment"
    source .venv/bin/activate

    if [ -f "requirements.txt" ]; then
        write_log "Installing dependencies from requirements.txt in virtual environment"
        pip3 install -r requirements.txt
    fi

    if [ $? -eq 0 ]; then
        write_log "Python dependencies installed successfully in virtual environment"
        deactivate
        return 0
    else
        write_error "Failed to install Python dependencies"
        deactivate
        return 1
    fi
}

install_tmux(){
    if command -v tmux &>/dev/null; then
        local tmux_version=$(tmux -V)
        write_log "Found $tmux_version"
        return 0
    else
        write_log "Tmux not found not on system, installing"

        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y tmux
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y tmux
        elif command -v yum &>/dev/null; then
            sudo yum install -y tmux
        else
            write_error "Could not find a package manager"
            return 1
        fi

        if command -v tmux &>/dev/null; then
            local tmux_version=$(tmux -V)
            write_log "Successfully installed $tmux_version"
            return 0
        else
            write_error "Failed to install tmux"
            return 1
        fi
    fi
}

main(){
    if [ "$(id -u)" -ne 0 ] && ! command -v sudo &>/dev/null; then
        write_error "This script requires root"
        return 1
    fi

    check_and_install_python
    check_and_install_python_venv
    check_and_install_pip3
    install_python_dependencies
    install_tmux

    chmod +x "$PWD/tmux-sessions/run.sh"
    "$PWD/tmux-sessions/run.sh"


    if [ $? -ne 0 ]; then
        write_error "Build script failed"
        return 1
    fi

    return 0
}

main