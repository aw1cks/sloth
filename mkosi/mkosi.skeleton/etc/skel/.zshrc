HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
bindkey -e

autoload -Uz promptinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	  promptinit;
  else
	    promptinit -C;
fi;
setopt PROMPT_SUBST

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	        compinit;
	else
		        compinit -C;
fi;
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select

alias ls='ls --color=auto'
PS1='[%n@%m %~]%# '
