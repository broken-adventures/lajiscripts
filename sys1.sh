REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "alpine")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Alpine")
PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update" "apk update -f")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "apk add -f")

CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)"
	"$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)"
	"$(lsb_release -sd 2>/dev/null)"
	"$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)"
	"$(grep . /etc/redhat-release 2>/dev/null)"
	"$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')"
)

for i in "${CMD[@]}"; do
	SYS="$i" && [[ -n $SYS ]] && break
done

for ((int=0; int<${#REGEX[@]}; int++)); do
	[[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && [[ -n $SYSTEM ]] && break
done
[[ -z $SYSTEM ]] && red "not support" && exit 1

type -P curl >/dev/null 2>&1 || (${PACKAGE_INSTALL[int]} curl) || (${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} curl)
type -P wget >/dev/null 2>&1 || (${PACKAGE_INSTALL[int]} wget) || (${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} wget)
type -P socat >/dev/null 2>&1 || (${PACKAGE_INSTALL[int]} curl) || (${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} socat)
type -P binutils >/dev/null 2>&1 || (${PACKAGE_INSTALL[int]} wget) || (${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} binutils)
