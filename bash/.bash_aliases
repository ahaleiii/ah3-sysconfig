# ls
# A - all minus . and ..
# l - long format
# h - display the size from 'l' in human readable format
alias d='ls -Alh'

# check disk space
alias diskspace='df -h'

alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias reset-update-clock='echo "sudo hwclock --hctosys # https://askubuntu.com/a/1169203" && sudo hwclock --hctosys'

# Display Message of the Day
# https://askubuntu.com/a/319532
alias display-motd='for i in /etc/update-motd.d/*; do $i; done'
