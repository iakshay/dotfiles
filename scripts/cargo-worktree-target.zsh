# Auto-configure CARGO_TARGET_DIR and COMPOSE_PROJECT_NAME for git worktrees
function _set_cargo_target_dir() {
  # Check if we're in a git worktree
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local git_dir=$(git rev-parse --git-dir)
    
    # Check if this is a worktree (git-dir points to .git/worktrees/*)
    if [[ "$git_dir" == *".git/worktrees/"* ]]; then
      # Find main repo by resolving the commondir (which points to ../..)
      local common_git_dir=$(realpath "$git_dir/../..")
      local main_repo_path=$(dirname "$common_git_dir")
      local project_name=$(basename "$main_repo_path")
      
      # Set Docker Compose project name and directory based on main repo
      export COMPOSE_PROJECT_NAME="$project_name"
      export COMPOSE_PROJECT_DIR="$main_repo_path"
      
      if [[ -f "$main_repo_path/Cargo.toml" ]]; then
        export CARGO_TARGET_DIR="$main_repo_path/target"
      fi
    elif [[ -f "Cargo.toml" ]]; then
      # We're in the main repo with Cargo.toml
      export CARGO_TARGET_DIR="$(pwd)/target"
      # Set Docker Compose project name based on current directory
      export COMPOSE_PROJECT_NAME="$(basename "$(pwd)")"
    else
      # We're in a git repo but not a Rust project
      # Still set Docker Compose project name
      export COMPOSE_PROJECT_NAME="$(basename "$(pwd)")"
      # Clear CARGO_TARGET_DIR if we're not in a Rust project
      unset CARGO_TARGET_DIR
    fi
  else
    # Clear all variables if we're not in a git repo
    unset CARGO_TARGET_DIR
    unset COMPOSE_PROJECT_NAME
    unset COMPOSE_PROJECT_DIR
  fi
}

# Hook to run on directory change
autoload -U add-zsh-hook
add-zsh-hook chpwd _set_cargo_target_dir

# Run once for current directory
_set_cargo_target_dir