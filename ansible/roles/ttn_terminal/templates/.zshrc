# The following lines were added by compinstall
zstyle :compinstall filename '/home/nschieder/.zshrc'

autoload -Uz compinit
compinit

# Shell settings
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch notify
bindkey -e

# Keypad
# 0 . Enter
bindkey -s "^[Op" "0"
bindkey -s "^[Ol" "."
bindkey -s "^[OM" "^M"
# 1 2 3
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
# 4 5 6
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
# 7 8 9
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
# # + -  * /
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"

# Antigen
source ~/.antigen.zsh
antigen use oh-my-zsh
antigen bundle git
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen apply

# Default Env Vars
export ANSIBLE_NOCOWS=1
export PATH="$PATH:$HOME/.local/bin:$HOME/go/bin"
export SPACE_PROMPT_COLOR={{ttn_terminal_color}}

# PROMPT
zmodload zsh/parameter  # Needed to access jobstates variable for NUM_JOBS

space_prompt_render() {
    # Use length of jobstates array as number of jobs. Expansion fails inside
    # quotes so we set it here and then use the value later on.
    NUM_JOBS=$#jobstates
    PROMPT="$("space-prompt" -status=$STATUS -duration=${SPACE_PROMPT_DURATION-} -jobs="$NUM_JOBS")"
}

# Will be run before every prompt draw
space_prompt_precmd() {
    # Save the status, because commands in this pipeline will change $?
    STATUS=$?

    # Compute cmd_duration, if we have a time to consume, otherwise clear the
    # previous duration
    if [[ -n "${SPACE_PROMPT_START_TIME+1}" ]]; then
        SPACE_PROMPT_END_TIME=$(date +%s%N)
        SPACE_PROMPT_DURATION=$((SPACE_PROMPT_END_TIME - SPACE_PROMPT_START_TIME))
        unset SPACE_PROMPT_START_TIME
    else
        unset SPACE_PROMPT_DURATION
    fi

    # Render the updated prompt
    space_prompt_render
}
space_prompt_preexec() {
    SPACE_PROMPT_START_TIME=$(date +%s%N)
}

# If precmd/preexec arrays are not already set, set them. If we don't do this,
# the code to detect whether space_prompt_precmd is already in precmd_functions will
# fail because the array doesn't exist (and same for space_prompt_preexec)
[[ -z "${precmd_functions+1}" ]] && precmd_functions=()
[[ -z "${preexec_functions+1}" ]] && preexec_functions=()

# If space_prompt precmd/preexec functions are already hooked, don't double-hook them
# to avoid unnecessary performance degradation in nested shells
if [[ -z ${precmd_functions[(re)space_prompt_precmd]} ]]; then
    precmd_functions+=(space_prompt_precmd)
fi
if [[ -z ${preexec_function[(re)space_prompt_preexec]} ]]; then
    preexec_functions+=(space_prompt_preexec)
fi

# Set up a function to redraw the prompt if the user switches vi modes
zle-keymap-select() {
    space_prompt_render
    zle reset-prompt
}

SPACE_PROMPT_START_TIME=$(date +%s%N)
zle -N zle-keymap-select
