#!/bin/bash

if [[ -z "$HOMEBREW_BREW_FILE" ]]
then
  # we don't use odie here, because it's only available when this script is called from brew.
  echo "Error: $(basename "$0") must be called from brew!" >&2
  exit 1
fi

brew() {
  "$HOMEBREW_BREW_FILE" "$@"
}

which_git() {
  local which_git
  local active_developer_dir

  which_git="$(which git 2>/dev/null)"
  if [[ -n "$which_git" && "/usr/bin/git" = "$which_git" ]]
  then
    active_developer_dir="$('/usr/bin/xcode-select' -print-path 2>/dev/null)"
    if [[ -n "$active_developer_dir" && -x "$active_developer_dir/usr/bin/git" ]]
    then
      which_git="$active_developer_dir/usr/bin/git"
    else
      which_git=""
    fi
  fi
  echo "$which_git"
}

git_init_if_necessary() {
  if [[ ! -d ".git" ]]
  then
    git init -q
    git config --bool core.autocrlf false
    git config remote.origin.url https://github.com/Homebrew/homebrew.git
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
  fi

  if [[ "$(git remote show origin -n)" = *"mxcl/homebrew"* ]]
  then
    git remote set-url origin https://github.com/Homebrew/homebrew.git
    git remote set-url --delete origin ".*mxcl\/homebrew.*"
  fi
}

rename_taps_dir_if_necessary() {
  local tap_dir
  local tap_dir_basename
  local user
  local repo

  for tap_dir in "$HOMEBREW_LIBRARY"/Taps/*
  do
    [[ -d "$tap_dir/.git" ]] || continue
    tap_dir_basename="${tap_dir##*/}"
    if [[ "$tap_dir_basename" = *"-"* ]]
    then
      # only replace the *last* dash: yes, tap filenames suck
      user="$(echo "${tap_dir_basename%-*}" | tr "[:upper:]" "[:lower:]")"
      repo="$(echo "${tap_dir_basename:${#user}+1}" | tr "[:upper:]" "[:lower:]")"
      mkdir -p "$HOMEBREW_LIBRARY/Taps/$user"
      mv "$tap_dir", "$HOMEBREW_LIBRARY/Taps/$user/homebrew-$repo"

      if [[ ${#${tap_dir_basename//[^\-]}} -gt 1 ]]
      then
        echo "Homebrew changed the structure of Taps like <someuser>/<sometap>." >&2
        echo "So you may need to rename $HOMEBREW_LIBRARY/Taps/$user/homebrew-$repo manually." >&2
      fi
    else
      echo "Homebrew changed the structure of Taps like <someuser>/<sometap>. " >&2
      echo "$tap_dir is an incorrect Tap path." >&2
      echo "So you may need to rename it to $HOMEBREW_LIBRARY/Taps/<someuser>/homebrew-<sometap> manually." >&2
    fi
  done
}

repo_var() {
  local repo_var

  repo_var="$1"
  if [[ "$repo_var" = "$HOMEBREW_REPOSITORY" ]]
  then
    repo_var=""
  else
    repo_var="${repo_var#"$HOMEBREW_LIBRARY/Taps"}"
    repo_var="$(echo -n "$repo_var" | tr -C "A-Za-z0-9" "_" | tr "[:lower:]" "[:upper:]")"
  fi
  echo "$repo_var"
}

upstream_branch() {
  local upstream_branch

  upstream_branch="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)"
  upstream_branch="${upstream_branch#refs/remotes/origin/}"
  [[ -z "$upstream_branch" ]] && upstream_branch="master"
  echo "$upstream_branch"
}

read_current_revision() {
  git rev-parse -q --verify HEAD
}

pop_stash() {
  [[ -z "$STASHED" ]] && return
  git stash pop "${QUIET_ARGS[@]}"
  if [[ -n "$HOMEBREW_VERBOSE" ]]
  then
    echo "Restoring your stashed changes to $DIR:"
    git status --short --untracked-files
  fi
  unset STASHED
}

pop_stash_message() {
  [[ -z "$STASHED" ]] && return
  echo "To restore the stashed changes to $DIR run:"
  echo "  'cd $DIR && git stash pop'"
  unset STASHED
}

reset_on_interrupt() {
  if [[ "$INITIAL_BRANCH" != "$UPSTREAM_BRANCH" && -n "$INITIAL_BRANCH" ]]
  then
    git checkout "$INITIAL_BRANCH"
  fi

  if [[ -n "$INITIAL_REVISION" ]]
  then
    git reset --hard "$INITIAL_REVISION" "${QUIET_ARGS[@]}"
  fi

  if [[ "$INITIAL_BRANCH" != "$UPSTREAM_BRANCH" && -n "$INITIAL_BRANCH" ]]
  then
    pop_stash
  else
    pop_stash_message
  fi

  exit 130
}

pull() {
  local DIR
  local TAP_VAR

  DIR="$1"
  cd "$DIR" || return
  TAP_VAR=$(repo_var "$DIR")
  unset STASHED

  # The upstream repository's default branch may not be master;
  # check refs/remotes/origin/HEAD to see what the default
  # origin branch name is, and use that. If not set, fall back to "master".
  INITIAL_BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null)"
  UPSTREAM_BRANCH="$(upstream_branch)"

  # Used for testing purposes, e.g., for testing formula migration after
  # renaming it in the currently checked-out branch. To test run
  # "brew update --simulate-from-current-branch"
  if [[ -n "$HOMEBREW_SIMULATE_FROM_CURRENT_BRANCH" ]]
  then
    INITIAL_REVISION="$(git rev-parse -q --verify "$UPSTREAM_BRANCH")"
    CURRENT_REVISION="$(read_current_revision)"
    export HOMEBREW_UPDATE_BEFORE"$TAP_VAR"="$INITIAL_REVISION"
    export HOMEBREW_UPDATE_AFTER"$TAP_VAR"="$CURRENT_REVISION"
    if ! git merge-base --is-ancestor "$INITIAL_REVISION" "$CURRENT_REVISION"
    then
      odie "Your HEAD is not a descendant of $UPSTREAM_BRANCH!"
    fi
    return
  fi

  trap reset_on_interrupt SIGINT

  if [[ -n "$(git status --untracked-files=all --porcelain 2>/dev/null)" ]]
  then
    if [[ -n "$HOMEBREW_VERBOSE" ]]
    then
      echo "Stashing uncommitted changes to $DIR."
      git status --short --untracked-files=all
    fi
    git -c "user.email=brew-update@localhost" \
        -c "user.name=brew update" \
        stash save --include-untracked "${QUIET_ARGS[@]}"
    git reset --hard "${QUIET_ARGS[@]}"
    STASHED="1"
  fi

  if [[ "$INITIAL_BRANCH" != "$UPSTREAM_BRANCH" && -n "$INITIAL_BRANCH" ]]
  then
    # Recreate and check out `#{upstream_branch}` if unable to fast-forward
    # it to `origin/#{@upstream_branch}`. Otherwise, just check it out.
    if git merge-base --is-ancestor "$UPSTREAM_BRANCH" "origin/$UPSTREAM_BRANCH" &>/dev/null
    then
      git checkout --force "$UPSTREAM_BRANCH" "${QUIET_ARGS[@]}"
    else
      git checkout --force -B "$UPSTREAM_BRANCH" "origin/$UPSTREAM_BRANCH" "${QUIET_ARGS[@]}"
    fi
  fi

  INITIAL_REVISION="$(read_current_revision)"
  export HOMEBREW_UPDATE_BEFORE"$TAP_VAR"="$INITIAL_REVISION"

  # ensure we don't munge line endings on checkout
  git config core.autocrlf false

  if [[ -n "$HOMEBREW_REBASE" ]]
  then
    git rebase "${QUIET_ARGS[@]}" "origin/$UPSTREAM_BRANCH"
  else
    git merge --no-edit --ff "${QUIET_ARGS[@]}" "origin/$UPSTREAM_BRANCH"
  fi

  export HOMEBREW_UPDATE_AFTER"$TAP_VAR"="$(read_current_revision)"

  trap '' SIGINT

  if [[ "$INITIAL_BRANCH" != "$UPSTREAM_BRANCH" && -n "$INITIAL_BRANCH" ]]
  then
    git checkout "$INITIAL_BRANCH" "${QUIET_ARGS[@]}"
    pop_stash
  else
    pop_stash_message
  fi

  trap - SIGINT
}

update-bash() {
  local option
  local DIR
  local UPSTREAM_BRANCH

  if [[ -z "$HOMEBREW_DEVELOPER" ]]
  then
    odie "This command is currently only for Homebrew developers' use."
  fi

  for option in "$@"
  do
    case "$option" in
      update|update-bash) shift ;;
      --help) brew update --help; exit $? ;;
      --verbose) HOMEBREW_VERBOSE=1 ;;
      --debug) HOMEBREW_DEBUG=1;;
      --rebase) HOMEBREW_REBASE=1 ;;
      --simulate-from-current-branch) HOMEBREW_SIMULATE_FROM_CURRENT_BRANCH=1 ;;
      --*) ;;
      -*)
        [[ "$option" = *v* ]] && HOMEBREW_VERBOSE=1;
        [[ "$option" = *d* ]] && HOMEBREW_DEBUG=1;
        ;;
      *)
        odie <<-EOS
This command updates brew itself, and does not take formula names.
Use 'brew upgrade <formula>'.
EOS
        ;;
    esac
  done

  if [[ -n "$HOMEBREW_DEBUG" ]]
  then
    set -x
  fi

  # check permissions
  if [[ "$HOMEBREW_PREFIX" = "/usr/local" && ! -w /usr/local ]]
  then
    odie "/usr/local must be writable!"
  fi

  if [[ ! -w "$HOMEBREW_REPOSITORY" ]]
  then
    odie "$HOMEBREW_REPOSITORY must be writable!"
  fi

  if [[ -z "$(which_git)" ]]
  then
    brew install git
    if [[ -z "$(which_git)" ]]
    then
      odie "Git must be installed and in your PATH!"
    fi
  fi

  if [[ -z "$HOMEBREW_VERBOSE" ]]
  then
    QUIET_ARGS=(-q)
  else
    QUIET_ARGS=()
  fi

  # ensure GIT_CONFIG is unset as we need to operate on .git/config
  unset GIT_CONFIG

  chdir "$HOMEBREW_REPOSITORY"
  git_init_if_necessary
  # rename Taps directories
  # this procedure will be removed in the future if it seems unnecessary
  rename_taps_dir_if_necessary

  # kill all of subprocess on interrupt
  trap '{ pkill -P $$; wait; exit 130; }' SIGINT

  for DIR in "$HOMEBREW_REPOSITORY" "$HOMEBREW_LIBRARY"/Taps/*/*
  do
    [[ -d "$DIR/.git" ]] || continue
    cd "$DIR" || continue
    UPSTREAM_BRANCH="$(upstream_branch)"
    # the refspec ensures that the default upstream branch gets updated
    git fetch "${QUIET_ARGS[@]}" origin \
      "refs/heads/$UPSTREAM_BRANCH:refs/remotes/origin/$UPSTREAM_BRANCH" &
  done

  wait
  trap - SIGINT

  for DIR in "$HOMEBREW_REPOSITORY" "$HOMEBREW_LIBRARY"/Taps/*/*
  do
    [[ -d "$DIR/.git" ]] || continue
    pull "$DIR"
  done

  chdir "$HOMEBREW_REPOSITORY"
  brew update-report "$@"
  return $?
}
