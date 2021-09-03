#!/bin/sh
#
# (c) 2021 Alex Wicks | github.com/aw1cks 
#
# This file is part of shell-util: github.com/aw1cks/shell-util
#
# shell-util is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# shell-util is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with shell-util. If not, see <http://www.gnu.org/licenses/>.

set -e

# Consts
RESET='\033[0m'
BOLD='\033[1m'

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'

# $1 -> enum [ 
#   "info"
#   "warn"
#   "error"
# ]
# Description: Type of message to be logged
# Example: 'info'
LOG_TYPE="${1}"

# $2 -> string
# Description: Message to be logged
# Example: 'Hello, world!'
MSG="${2}"

validate_input() {
  case "${LOG_TYPE}" in
    'info'|'warn'|'error' ) ;;
    * ) return 1;;
  esac

  if [ -z "${MSG}" ]
  then
    return 2
  fi
}

set_colors() {
  case "${LOG_TYPE}" in
    'info') 
      export ARROW_COLOR="${CYAN}"
      export TEXT_COLOR="${GREEN}"
      ;;
    'warn')
      export ARROW_COLOR="${RED}"
      export TEXT_COLOR="${YELLOW}"
      ;;
    'error') 
      export ARROW_COLOR="${YELLOW}"
      export TEXT_COLOR="${RED}"
      ;;
  esac
}

print() {
  arrow_str='==>'
  printf '%b%b%s%b %b%s%b\n' "${BOLD}" "${ARROW_COLOR}" "${arrow_str}" "${RESET}" "${TEXT_COLOR}" "${MSG}" "${RESET}"
}

validate_input
set_colors
print
