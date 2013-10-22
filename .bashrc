
##### Detect host #####

# supported hosts:
# zen main nsto brubeck ndojo.nfshost.com nbs.nfshost.com
# partial support:
# vbox
host=$(hostname)


##### Detect distro #####

if [[ $host =~ (zen|main|nsto) ]]; then
  distro="ubuntu"
elif [[ $host =~ (nfshost) ]]; then
  distro="freebsd"
elif [[ $host =~ (brubeck) ]]; then
  distro="debian"
elif [[ $host =~ (vbox) ]]; then
  distro="cygwin"
# Do your best to detect the distro
# Uses info from http://www.novell.com/coolsolutions/feature/11251.html
# and http://en.wikipedia.org/wiki/Uname
else
  kernel=$(uname -s | tr '[:upper:]' '[:lower:]')
  if [[ $kernel =~ freebsd ]]; then
    distro="freebsd"
  elif [[ $kernel =~ bsd$ ]]; then
    distro="bsd"
  elif [[ $kernel =~ darwin ]]; then
    distro="mac"
  elif [[ $kernel =~ cygwin ]]; then
    distro="cygwin"
  elif [[ $kernel =~ mingw ]]; then
    distro="mingw"
  elif [[ $kernel =~ sunos ]]; then
    distro="solaris"
  elif [[ $kernel =~ haiku ]]; then
    distro="haiku"
  elif [[ $kernel =~ linux ]]; then
    if [ -f /etc/os-release ]; then
      distro=$(grep '^NAME' /etc/os-release | sed -E 's/^NAME="([^"]+)"$/\1/g' | tr '[:upper:]' '[:lower:]')
    fi
    if [[ ! $distro ]]; then
      distro=$(ls /etc/*-release | sed -E 's#/etc/([^-]+)-release#\1#' | head -n 1)
    fi
    if [[ ! $distro ]]; then
      if [ -f /etc/debian_version ]; then
        distro="debian"
      elif [ -f /etc/redhat_version ]; then
        distro="redhat"
      elif [ -f /etc/slackware-version ]; then
        distro="slackware"
      fi
    fi
    if [[ ! $distro ]]; then
      distro="linux"
    fi
  else
    distro="unknown"
  fi
fi



#################### System default stuff ####################


# All comments in this block are from Ubuntu's default .bashrc
if [[ $distro == "ubuntu" ]]; then

  # ~/.bashrc: executed by bash(1) for non-login shells.
  # examples: /usr/share/doc/bash/examples/startup-files (in package bash-doc)

  # If not running interactively, don't do anything
  case $- in
      *i*) ;;
        *) return;;
  esac

  # make less more friendly for non-text input files, see lesspipe(1)
  [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

  # "alert" Sends notify-send notification with exit status of last command
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

  # enable programmable completion features (you don't need to enable
  # this if it's already enabled in /etc/bash.bashrc and /etc/profile
  # sources /etc/bash.bashrc).
  if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
  fi


# All comments in this block are from brubeck's default .bashrc
elif [[ $distro == "debian" ]]; then

  # System wide functions and aliases
  # Environment stuff goes in /etc/profile

  # By default, we want this to get set.
  umask 002

  if ! shopt -q login_shell ; then # We're not a login shell
    if [ -d /etc/profile.d/ ]; then
      for i in /etc/profile.d/*.sh; do
        if [ -r "$i" ]; then
          . $i
        fi
      unset i
      done
    fi
  fi

  # system path augmentation
  test -f /afs/bx.psu.edu/service/etc/env.sh && . /afs/bx.psu.edu/service/etc/env.sh

  # make afs friendlier-ish
  if [ -d /afs/bx.psu.edu/service/etc/bash.d/ ]; then
    for file in /afs/bx.psu.edu/service/etc/bash.d/*.bashrc; do
    . $file
    done
  fi

fi


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'



#################### My stuff ####################


home=$(echo $HOME | sed -E 's#/$##g')
if [[ $host =~ (zen|main) ]]; then
  bashrc_dir="$home/aa/code/bash/bashrc"
elif [[ $host =~ (nsto|brubeck|nfshost|vbox) ]]; then
  bashrc_dir="$home/code/bashrc"
fi


##### Bash options #####

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
HISTSIZE=2000       # max # of lines to keep in active history
HISTFILESIZE=2000   # max # of lines to record in history file
shopt -s histappend # append to the history file, don't overwrite it
# check the window size after each command and update LINES and COLUMNS.
shopt -s checkwinsize
# Make "**" glob all files and subdirectories recursively
shopt -s globstar


##### Aliases #####

if [[ $host =~ (main|zen|nsto|brubeck|vbox) ]]; then
  alias lsl='ls -lFhAb --color=auto --group-directories-first'
  alias lsld='ls -lFhAbd --color=auto --group-directories-first'
else
  # long options don't work on nfshost (freebsd)
  alias lsl='ls -lFhAb'
  alias lsld='ls -lFhAbd'
fi
alias mv="mv -i"
alias cp="cp -i"
alias trash='trash-put'
alias targ='tar -zxvpf'
alias tarb='tar -jxvpf'

alias awkt="awk -F '\t' -v OFS='\t'"
alias pingg='ping -c 1 google.com'
alias curlip='curl icanhazip.com'
alias rsynca='rsync -e ssh --delete -zavXA'
alias kerb='kinit nick@BX.PSU.EDU'
if [[ $host =~ (nfshost) ]]; then
  alias vib='vim ~/.bash_profile'
else
  alias vib='vim ~/.bashrc'
fi

alias minecraft="cd ~/src/minecraft && java -Xmx400M -Xincgc -jar $home/src/minecraft_server.jar nogui"
alias minelog='ssh vps "tail src/minecraft/server.log"'
alias mineme='ssh vps "cat src/minecraft/server.log" | grep -i nick | tail'
alias minelist="ssh vps 'screen -S minecraft -X stuff \"list
\"; sleep 1; tail src/minecraft/server.log'"
alias minemem='ssh vps "if pgrep -f java > /dev/null; then pgrep -f java | xargs ps -o %mem; fi"'

if [[ $host =~ (nfshost) ]]; then
  alias errlog='less +G /home/logs/error_log'
elif [[ $host =~ (nsto) ]]; then
  alias errlog='less +G /var/www/logs/error.log'
elif [[ $host =~ (main|zen) ]]; then
  alias errlog='less +G /var/log/syslog'
fi
alias temp="sensors | extract Physical 'Core 1' | sed 's/(.*)//' | grep -P '\d+\.\d'"
alias proxpn='cd ~/src/proxpn_mac/config && sudo openvpn --user me --config proxpn.ovpn'
alias mountf='mount | perl -we '"'"'printf("%-25s %-25s %-25s\n","Device","Mount Point","Type"); for (<>) { if (m/^(.*) on (.*) type (.*) \(/) { printf("%-25s %-25s %-25s\n", $1, $2, $3); } }'"'"''
alias blockedips="grep 'UFW BLOCK' /var/log/ufw.log | sed -E 's/.* SRC=([0-9a-f:.]+) .*/\1/g' | sort -g | uniq -c | sort -rg -k 1"
if [[ $host =~ (nfshost) ]]; then
  alias updaterc="cd $bashrc_dir && git pull && cd -"
else
  alias updaterc="git --work-tree=$bashrc_dir --git-dir=$bashrc_dir/.git pull"
fi
if [[ $host =~ (zen) ]]; then
  alias logtail='ssh home "~/bin/logtail.sh 100" | less +G'
  logrep () { ssh home "cd ~/0utbox/annex/Work/PSU/Nekrutenko/misc/chatlogs/galaxy-lab; grep -r $@"; }
elif [[ $host =~ (main) ]]; then
  alias logtail='~/bin/logtail.sh 100 | less +G'
  logrep () { cd ~/0utbox/annex/Work/PSU/Nekrutenko/misc/chatlogs/galaxy-lab; grep -r $@; }
fi


##### Functions #####

bak () { cp "$1" "$1.bak"; }
# no more "cd ../../../.." (from http://serverfault.com/a/28649)
up () { 
    local d="";
    for ((i=1 ; i <= $1 ; i++)); do
        d=$d/..;
    done;
    d=$(echo $d | sed 's#^/##');
    if [ -z "$d" ]; then
        d=..;
    fi;
    cd $d
}
vix () {
  if [ -e $1 ]; then
    vim $1
  else
    touch $1; chmod +x $1; vim $1
  fi
}
calc () {
  if [ "$1" ]; then
    python -c "from math import *; print $1"
  else
    python -i -c "from math import *"
  fi
}
wcc () { echo -n "$@" | wc -c; }
if which lynx > /dev/null; then
  lgoog () {
    local query=$(echo "$@" | sed -E 's/ /+/g')
    local output=$(lynx -dump "http://www.google.com/search?q=$query")
    local end=$(echo "$output" | grep -n '^References' | cut -f 1 -d ':')
    echo "$output" | head -n $((end-2))
  }
fi
if which lower.b > /dev/null; then
  lc () { echo "$1" | lower.b; }
else
  lc () { echo "$1" | tr '[:upper:]' '[:lower:]'; }
fi
pg () {
    if pgrep -f $@ > /dev/null; then
        pgrep -f $@ | xargs ps -o user,pid,stat,rss,%mem,pcpu,args --sort -pcpu,-rss;
    fi
}
parents () {
  pid=$$
  while [[ "$pid" -gt 0 ]]; do
    ps -o comm= -p $pid
    pid=$(ps -o ppid= -p $pid)
  done
}
# readlink except it just returns the input path if it's not a link
deref () {
  local file="$1"
  if [ ! -e "$file" ]; then
    file=$(which "$file")
  fi
  local deref=$(readlink -f "$file")
  if [[ "$deref" ]]; then
    echo $deref
  else
    echo $1
  fi
}
# this requires deref()!
vil () { vi $(deref "$1"); }
getip () {
  # IPv6 too! (Only the non-MAC address-based one.)
  last=""
  ifconfig | while read line; do
    if [ ! "$last" ]; then
      dev=$(echo "$line" | sed -r 's/^(\S+)\s+.*$/\1/g')
    fi
    if [[ "$line" =~ 'inet addr' ]]; then
      echo -ne "$dev:\t"
      echo "$line" | sed -r 's/^\s*inet addr:\s*([0-9.]+)\s+.*$/\1/g'
    fi
    if [[ "$line" =~ 'inet6 addr' && "$line" =~ Scope:Global$ ]]; then
      ip=$(echo "$line" | sed -r 's/^\s*inet6 addr:\s*([0-9a-f:]+)[^0-9a-f:].*$/\1/g')
      if [[ ! "$ip" =~ ff:fe.*:[^:]+$ ]]; then
        echo -e "$dev:\t$ip"
      fi
    fi
    last=$line
  done
}
# doesn't work on nfshost (FreeBSD) because it currently needs full regex
if [[ $host =~ (zen|main|nsto) ]]; then
  longurl () {
    url="$1"
    while [ "$url" ]; do
      echo "$url"
      echo -n "$url" | sed -r 's#^https?://([^/]+)/?.*$#\1#g' | xclip -sel clip
      line=$(curl -sI "$url" | grep -P '^[Ll]ocation:\s' | head -n 1)
      url=$(echo "$line" | sed -r 's#^[Ll]ocation:\s+(\S.*\S)\s*$#\1#g')
    done
  }
# so apparently curl has the -L option
else
  longurl () {
    echo "$1"; curl -LIs "$1" | grep '^[Ll]ocation' | cut -d ' ' -f 2
  }
fi

# Get totals of a specified column
sumcolumn () {
  if [ ! "$1" ] || [ ! "$2" ]; then
    echo 'USAGE: $ cutsum 3 file.csv'
    return
  fi
  awk -F '\t' '{ tot+=$'"$1"' } END { print tot }' "$2"
}
# Get totals of all columns in stdin or in all filename arguments
sumcolumns () {
  perl -we 'my @tot; my $first = 1;
  while (<>) {
    next if (m/[a-z]/i); # skip lines with non-numerics
    my @fields = split("\t");
    if ($first) { $first = 0; for my $field (@fields) { push(@tot, $field) }
    } else { for ($i = 0; $i < @tot; $i++) { $tot[$i] += $fields[$i] } }
  } print join("\t", @tot)."\n"'
}
showdups () {
  cat "$1" | while read line; do
    notfirst=''
    grep -n "^$line$" "$1" | while read line; do
      if [ "$notfirst" ]; then echo "$line"; else notfirst=1; fi
    done
  done
}
repeat () {
  if [[ $# -lt 2 ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
    echo "USAGE: repeat [string] [number of repeats]" 1>&2
    return
  fi
  i=0; while [ $i -lt $2 ]; do
    echo -n "$1"; i=$((i+1))
  done
}
oneline () {
  echo "$1" | tr -d '\n'
}
wifimac () {
  iwconfig 2> /dev/null | sed -nE 's/^.*access point: ([a-zA-Z0-9:]+)\s*$/\1/pig'
}
wifissid () {
  iwconfig 2> /dev/null | sed -nE 's/^.*SSID:"(.*)"\s*$/\1/pig'
}
wifiip () {
  getip | sed -nE 's/^wlan0:\s*([0-9:.]+)$/\1/pig'
}
bintoascii () {
  for i in $( seq 0 8 ${#1} ); do echo -n $(python -c "print chr($((2#${1:$i:8})))"); done; echo
}


##### Bioinformatics #####

alias rdp='java -Xmx1g -jar ~/bin/MultiClassifier.jar'
alias gatk="java -jar ~/bin/GenomeAnalysisTK.jar"
#alias qsh='source $home/src/qiime_software/activate.sh'
alias readsfa='grep -Ec "^>"'
readsfq () {
  echo "$(wc -l $1 |  cut -f 1 -d ' ')/4" | bc
}
gatc () {
  echo "$1" | sed -E 's/[^GATCNgatcn]//g'
}
revcomp () {
  echo "$1" | tr 'ATGCatgc' 'TACGtacg' | rev
}
mothur_report () {
  local total=$(readsfa "$1.fasta")
  local quality=$(readsfa "mothur-work/$1.trim.fasta")
  local dedup=$(readsfa "mothur-work/$1.trim.unique.fasta")
  echo -e "$total\t$quality\t$dedup"
  quality=$(echo "100*$quality/$total" | bc)
  dedup=$(echo "100*$dedup/$total" | bc)
  echo -e "100%\t$quality%\t$dedup%"
}



##### Other #####

# Stuff I don't want to post publicly on Github.
# Still should be universal, not machine-specific.
if [ -f ~/.bashrc_private ]; then
  source ~/.bashrc_private
fi

export PS1="\e[0;36m[\d]\e[m \e[0;32m\u@\h:\w\e[m\n\$ "
if [[ $host =~ (zen) ]]; then
  export PATH=$PATH:~/bin:~/bx/code
fi

# if it's a remote shell, change $PS1 prompt format and enter a screen
if [[ -n $SSH_CLIENT || -n $SSH_TTY ]]; then
# if [[ $(ps -o comm= -p $PPID) == "sshd" ]]; then
  export PS1="[\d] \u@\h:\w\n\$ "
  # if not already in a screen, enter one (IMPORTANT to avoid infinite loops)
  # also check that stdout is attached to a real terminal with -t 1
  if [[ ! "$STY" && -t 1 ]]; then
    # Don't export PATH again if in a screen.
    if [[ $host =~ (nsto|brubeck) ]]; then
      export PATH=$PATH:~/bin:~/code
    elif [[ $host =~ (zen|main|nfshost) ]]; then
      export PATH=$PATH:~/bin
    fi
    if [[ $host =~ (nfshost) ]]; then
      true  # no screen there
    elif [[ $host =~ (brubeck) ]]; then
      exec ~/code/pagscr-me.sh '-RR -S auto'
    else
      exec screen -RR -S auto
    fi
  fi
fi
