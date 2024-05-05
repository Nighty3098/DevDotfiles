if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

eval "$(starship init zsh)"


# ZSH_THEME="apple"
# ZSH_THEME="powerlevel10k/powerlevel10k"


plugins=(git
         zsh-syntax-highlighting
         zsh-autosuggestions
         github)

source $ZSH/oh-my-zsh.sh
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

if (( ! ${fpath[(I)/usr/local/share/zsh/site-functions]} )); then
  FPATH=/usr/local/share/zsh/site-functions:$FPATH
fi

alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias t="tmux"
alias n="nvim"
alias sm="htop"
alias fm="ranger"
alias la="lsd -al"
alias l="lsd -a"
alias fetch="neofetch"
alias ga="git add ."
alias gs="git status -s"
alias gc="(){git commit -m $1}"
alias gp="git push"

alias c="clear"
alias e="exit"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

