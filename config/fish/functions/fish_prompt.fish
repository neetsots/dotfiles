function fish_prompt
  # Cache exit status
  set -l last_status $status

  # Just calculate these once, to save a few cycles when displaying the prompt
  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
  end
  if not set -q __fish_prompt_char
    switch (id -u)
      case 0
	set -g __fish_prompt_char '#'
      case '*'
	set -g __fish_prompt_char '>'
    end
  end

  # Setup colors
  set -l normal (set_color normal)
  set -l orange (set_color ffa06e)
  set -l grey (set_color ae9e99)
  set -l white  (set_color f3f1f1)
  set -l blue   (set_color 6ecdff)

  # Configure __fish_git_prompt
  set -g __fish_git_prompt_char_stateseparator ' '
  set -g __fish_git_prompt_color white
  set -g __fish_git_prompt_color_flags orange
  set -g __fish_git_prompt_color_prefix grey
  set -g __fish_git_prompt_color_suffix grey
  set -g __fish_git_prompt_showdirtystate true
  set -g __fish_git_prompt_showuntrackedfiles true
  set -g __fish_git_prompt_showstashstate true
  set -g __fish_git_prompt_show_informative_status true

  # Line 1
  echo -n $grey'┌['$white$USER$grey'@'$orange$__fish_prompt_hostname$grey']'$white'-'$grey'('$blue$PWD$grey')'
  echo

  # Line 2
  echo -n $grey'└'$__fish_prompt_char $normal
end
