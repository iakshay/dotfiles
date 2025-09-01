#!/usr/bin/env zsh
# Multi-project worktree manager with Claude support
# 
# ASSUMPTIONS & SETUP:
# - Your git projects live in: ~/projects/
# - Worktrees will be created in: ~/projects/worktrees/<project>/<branch>
# - New branches will be named: <your-username>/<feature-name>
#
# DIRECTORY STRUCTURE EXAMPLE:
# ~/projects/
# ├── my-app/              (main git repo)
# ├── another-project/     (main git repo)
# └── worktrees/
#     ├── my-app/
#     │   ├── feature-x/   (worktree)
#     │   └── bugfix-y/    (worktree)
#     └── another-project/
#         └── new-feature/ (worktree)
#
# CUSTOMIZATION:
# To use different directories, modify these lines in the w() function:
#   local projects_dir="$HOME/projects"
#   local worktrees_dir="$HOME/projects/worktrees"
#
# INSTALLATION:
# 1. Add to your .zshrc (in this order):
#    fpath=(~/.zsh/completions $fpath)
#    autoload -U compinit && compinit
#
# 2. Copy this entire script to your .zshrc (after the lines above)
#
# 3. Restart your terminal or run: source ~/.zshrc
#
# 4. Test it works: w <TAB> should show your projects
#
# If tab completion doesn't work:
# - Make sure the fpath line comes BEFORE the w function in your .zshrc
# - Restart your terminal completely
#
# USAGE:
#   w <project> <worktree>              # cd to worktree (creates if needed)
#   w <project> <worktree> <command>    # run command in worktree
#   w <command>                         # run command in current worktree (auto-detected)
#   w                                   # show current worktree info (auto-detected)
#   w --list                            # list all worktrees
#   w --rm <project> <worktree>         # remove worktree
#   w --root <project>                  # cd to main repository root
#
# EXAMPLES:
#   w myapp feature-x                   # cd to feature-x worktree
#   w myapp feature-x claude            # run claude in worktree
#   w myapp feature-x gst               # git status in worktree
#   w myapp feature-x gcmsg "fix: bug"  # git commit in worktree
#   w --root myapp                      # cd to main myapp repository
#   w gst                               # git status in current worktree (auto-detected)
#   w claude                            # run claude in current worktree (auto-detected)

# Multi-project worktree manager
w() {
    local projects_dir="$HOME/Projects"
    local worktrees_dir="$HOME/worktrees"
    
    # Handle special flags
    if [[ "$1" == "--list" ]]; then
        echo "=== All Worktrees ==="
        if [[ -d "$worktrees_dir" ]]; then
            for project in $worktrees_dir/*(/N); do
                project_name=$(basename "$project")
                echo "\n[$project_name]"
                for wt in $project/*(/N); do
                    echo "  • $(basename "$wt")"
                done
            done
        fi
        return 0
    elif [[ "$1" == "--root" ]]; then
        shift
        local project="$1"
        if [[ -z "$project" ]]; then
            echo "Usage: w --root <project>"
            return 1
        fi
        # Check if project exists
        if [[ ! -d "$projects_dir/$project" ]]; then
            echo "Project not found: $projects_dir/$project"
            return 1
        fi
        # Navigate to the main repository root
        cd "$projects_dir/$project"
        return 0
    elif [[ "$1" == "--rm" ]]; then
        shift
        local project="$1"
        local worktree="$2"
        if [[ -z "$project" || -z "$worktree" ]]; then
            echo "Usage: w --rm <project> <worktree>"
            return 1
        fi
        local wt_path="$worktrees_dir/$project/$worktree"
        if [[ ! -d "$wt_path" ]]; then
            echo "Worktree not found: $wt_path"
            return 1
        fi
        (cd "$projects_dir/$project" && git worktree remove "$wt_path")
        return $?
    fi
    
    # Normal usage: w <project> <worktree> [command...]
    local project="$1"
    local worktree="$2"
    local command=()
    
    # Handle case where only one argument is provided - could be a command
    if [[ -n "$1" && -z "$2" ]]; then
        # Try to auto-detect current location first
        local current_path="$PWD"
        local detected_project=""
        local detected_worktree=""
        
        # Check if we're in a worktree directory
        if [[ "$current_path" =~ "$worktrees_dir/([^/]+)/([^/]+)" ]]; then
            detected_project="${match[1]}"
            detected_worktree="${match[2]}"
            # First argument is likely a command
            project="$detected_project"
            worktree="$detected_worktree"
            command=("$1")
            shift 1
        else
            # Not in a worktree, treat as normal project/worktree args
            shift 2
        fi
    else
        shift 2
    fi
    
    # Add any remaining arguments to command
    command+=("$@")
    
    # Auto-detect project and worktree from current path if not provided
    if [[ -z "$project" || -z "$worktree" ]]; then
        local current_path="$PWD"
        local detected_project=""
        local detected_worktree=""
        
        # Check if we're in a worktree directory
        if [[ "$current_path" =~ "$worktrees_dir/([^/]+)/([^/]+)" ]]; then
            detected_project="${match[1]}"
            detected_worktree="${match[2]}"
        # Check if we're in a main project directory
        elif [[ "$current_path" =~ "$projects_dir/([^/]+)" ]]; then
            detected_project="${match[1]}"
            # If in main repo, suggest using --root instead
            if [[ -z "$project" && -z "$worktree" ]]; then
                echo "You're in the main repository. Use 'w --root $detected_project' or specify a worktree."
                return 1
            fi
        fi
        
        # Use detected values if arguments are missing
        if [[ -z "$project" && -n "$detected_project" ]]; then
            project="$detected_project"
        fi
        if [[ -z "$worktree" && -n "$detected_worktree" ]]; then
            worktree="$detected_worktree"
        fi
        
        # If we still don't have both project and worktree, show usage
        if [[ -z "$project" || -z "$worktree" ]]; then
            echo "Usage: w <project> <worktree> [command...]"
            echo "       w --list"
            echo "       w --rm <project> <worktree>"
            echo "       w --root <project>"
            echo ""
            echo "Auto-detection: Run 'w' from within a worktree to auto-detect project/worktree"
            return 1
        fi
        
        echo "Auto-detected: project='$project' worktree='$worktree'"
    fi
    
    # Check if project exists
    if [[ ! -d "$projects_dir/$project" ]]; then
        echo "Project not found: $projects_dir/$project"
        return 1
    fi
    
    # Determine worktree path
    local wt_path="$worktrees_dir/$project/$worktree"
    
    # If worktree doesn't exist, create it
    if [[ ! -d "$wt_path" ]]; then
        echo "Creating new worktree: $worktree"
        
        # Ensure worktrees directory exists
        mkdir -p "$worktrees_dir/$project"
        
        # Determine branch name (use current username prefix)
        local branch_name="$worktree"
        
        # Check if branch exists locally
        if (cd "$projects_dir/$project" && git show-ref --verify --quiet "refs/heads/$branch_name"); then
            echo "Branch '$branch_name' exists locally. Creating worktree from it."
            (cd "$projects_dir/$project" && git worktree add "$wt_path" "$branch_name") || {
                echo "Failed to create worktree from existing branch. It might be checked out already."
                return 1
            }
        else
            echo "Branch '$branch_name' does not exist locally. Creating new branch and worktree."
            # Create the worktree with a new branch
            (cd "$projects_dir/$project" && git worktree add "$wt_path" -b "$branch_name") || {
                echo "Failed to create worktree and new branch."
                return 1
            }
        fi
    fi
    
    # Execute based on number of arguments
    if [[ ${#command[@]} -eq 0 ]]; then
        # No command specified - just cd to the worktree
        cd "$wt_path"
    else
        # Command specified - run it in the worktree without cd'ing
        local old_pwd="$PWD"
        cd "$wt_path"
        eval "${command[@]}"
        local exit_code=$?
        cd "$old_pwd"
        return $exit_code
    fi
}

# Setup completion if not already done
if [[ ! -f ~/.zsh/completions/_w ]]; then
    mkdir -p ~/.zsh/completions
    cat > ~/.zsh/completions/_w << 'EOF'
#compdef w

_w() {
    local curcontext="$curcontext" state line
    typeset -A opt_args
    
    local projects_dir="$HOME/Projects"
    local worktrees_dir="$HOME/Projects"
    
    # Define the main arguments
    _arguments -C \
        '(--rm --root)--list[List all worktrees]' \
        '(--list --root)--rm[Remove a worktree]' \
        '(--list --rm)--root[Change to main repository root]' \
        '1: :->project' \
        '2: :->worktree' \
        '3: :->command' \
        '*:: :->command_args' \
        && return 0
    
    case $state in
        project)
            if [[ "${words[1]}" == "--list" ]]; then
                # No completion needed for --list
                return 0
            fi
            
            if [[ "${words[1]}" == "--root" ]]; then
                # For --root, only suggest projects
                local -a projects
                for dir in $projects_dir/*(N/); do
                    if [[ -d "$dir/.git" ]]; then
                        projects+=(${dir:t})
                    fi
                done
                _describe -t projects 'project' projects && return 0
            fi
            
            # Get list of projects (directories in ~/projects that are git repos)
            local -a projects
            for dir in $projects_dir/*(N/); do
                if [[ -d "$dir/.git" ]]; then
                    projects+=(${dir:t})
                fi
            done
            
            _describe -t projects 'project' projects && return 0
            ;;
            
        worktree)
            local project="${words[2]}"
            
            if [[ -z "$project" ]]; then
                return 0
            fi
            
            # Skip worktree completion for --root command
            if [[ "${words[1]}" == "--root" ]]; then
                return 0
            fi
            
            local -a worktrees
            
            # Check for existing worktrees
            if [[ -d "$worktrees_dir/$project" ]]; then
                for wt in $worktrees_dir/$project/*(N/); do
                    worktrees+=(${wt:t})
                done
            fi
            
            if (( ${#worktrees} > 0 )); then
                _describe -t worktrees 'existing worktree' worktrees
            else
                _message 'new worktree name'
            fi
            ;;
            
        command)
            # Suggest common commands when user has typed project and worktree
            local -a common_commands
            common_commands=(
                'claude:Start Claude Code session'
                'gst:Git status'
                'gaa:Git add all'
                'gcmsg:Git commit with message'
                'gp:Git push'
                'gco:Git checkout'
                'gd:Git diff'
                'gl:Git log'
                'npm:Run npm commands'
                'yarn:Run yarn commands'
                'make:Run make commands'
            )
            
            _describe -t commands 'command' common_commands
            
            # Also complete regular commands
            _command_names -e
            ;;
            
        command_args)
            # Let zsh handle completion for the specific command
            words=(${words[4,-1]})
            CURRENT=$((CURRENT - 3))
            _normal
            ;;
    esac
}

_w "$@"
EOF
    # Add completions to fpath if not already there
    fpath=(~/.zsh/completions $fpath)
fi

# Initialize completions (already done in .zshrc, skip redundant call)
