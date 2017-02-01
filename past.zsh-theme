# Past Zsh theme

_PROMPT_CACHE_FILE="$HOME/.zsh_prompt_cache"
_PROMPT_CACHE_TIMEOUT="40"

function _time_to_color_level
{
  (( inteval = ( $1 + $2 ) % 48 ))
  if [[ $inteval -ge 24 ]]; then
    inteval=$(( 48 - $inteval ))
  fi
  if [[ $inteval -ge 14 ]]; then
    echo 1
  elif [[ $inteval -ge 8 ]]; then
    echo 2
  elif [[ $inteval -ge 4 ]]; then
    echo 3
  elif [[ $inteval -ge 1 ]]; then
    echo 4
  else
    echo 5
  fi
}

function _color_code
{
  local time_value=$(( $1 * 2 + $2 / 30 ))
  echo $(( $(_time_to_color_level $time_value 0) * 36 + $(_time_to_color_level $time_value 16) * 6 + $(_time_to_color_level $time_value 32) + 16 ))
}

function _time_color_code
{
  echo $(_color_code $(date +%H) $(date +%M))
}

function _gen_cache_file
{
  local last_seconds
  if [ -v 1 ]; then # _gen_cache_file init
    last_seconds="-$_PROMPT_CACHE_TIMEOUT"
  else
    last_seconds=$SECONDS
  fi

  local time_color_code=$(_time_color_code)

  echo "last_seconds=$last_seconds time_color_code=$time_color_code" > "$_PROMPT_CACHE_FILE"
}

function _print_prompt_first_line
{
  local time_color_code=$1
  local line2_first_color_code=$2
  echo "%U$fg[black]%(!.$bg[red].$bg[green]) %n $bg[blue] %M ${reset_color}$(git_prompt_info)\\033[38;5;0;48;5;${time_color_code}m %D{%H:%M} $reset_color"$'\n'"%(!.$fg[red].$fg[green])\\033[48;5;${line2_first_color_code}m◤${reset_color}"
}

function _print_prompt
{
  eval $(cat "$_PROMPT_CACHE_FILE") # read cache value
  local prompt="%{\\033[48;5;0;38;5;${time_color_code}m%} %c %{$reset_color%(0?.$fg[black].$fg[white])%} >%{$reset_color%} "
  if [[ $(( SECONDS - last_seconds )) -ge $_PROMPT_CACHE_TIMEOUT ]]; then
    prompt="%{$(_print_prompt_first_line $time_color_code 0)%}${prompt}"
    _gen_cache_file
  fi

  echo $prompt
}

# init
_gen_cache_file init

# output
PROMPT='$(_print_prompt)'

ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg_bold[green]%}✔"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg_bold[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_PREFIX="%{$bg[cyan]%}${fg[black]} "
ZSH_THEME_GIT_PROMPT_SUFFIX=" %{$reset_color%}"

