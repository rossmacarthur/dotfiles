#!/usr/bin/env bash

set -e

###############################################################################
# main
###############################################################################

FILE_PUBLIC="public.asc"
FILE_SECRETS_ALL="secrets-all.gpg"
FILE_SECRETS_SUBS_ONLY="secrets-subs-only.gpg"
FILE_OWNERTRUST="ownertrust.txt"

usage_error() {
    printf "\033[1;31merror:\033[0m %s\n\n" "$1" >&2
    usage
    exit 1
}

error() {
    printf "\033[1;31merror:\033[0m %s\n" "$1" >&2
    exit 1
}

main_usage() {
    cat 1>&2 <<EOF
GPG wrapper for my personal GPG key management

Usage:
  $0 [COMMAND] [OPTIONS]

Options:
    -h, --help  Show this message and exit

Commands:
    fullgen  $FULLGEN_DESCRIPTION
    import   $IMPORT_DESCRIPTION
    extend   $EXTEND_DESCRIPTION
    rotate   $ROTATE_DESCRIPTION
EOF
}

main() {
    # Check we are on macOS
    if [[ "$(uname -s)" != "Darwin" ]]; then
        error "this script is intended for macOS only"
    fi

    # Check GnuPG is installed
    if ! command -v gpg &> /dev/null; then
        error "GnuPG is not installed. Please install it using Homebrew: 'brew install gnupg'"
    fi

    # Check PINEntry is installed
    if ! command -v pinentry-mac &> /dev/null; then
        error "PINEntry is not installed. Please install it using Homebrew: 'brew install pinentry-mac'"
    fi

    # Figure out the subcommand
    while test $# -gt 0; do
        case $1 in
            -h|--help) main_usage; exit 0 ;;
            fullgen) shift; fullgen_cmd "$@"; break;;
            import) shift; import_cmd "$@"; break;;
            extend) shift; extend_cmd "$@"; break;;
            rotate) shift; rotate_cmd "$@"; break;;
            *) usage_error "unknown command: $1";;
        esac
        shift
    done
    printf "\nComplete! ✨ 🍰 ✨\n"
}

###############################################################################
# fullgen
###############################################################################

FULLGEN_DESCRIPTION="Generate a GPG private key and subkeys in a RAM drive and export them"

fullgen_usage() {
    cat 1>&2 <<EOF
$FULLGEN_DESCRIPTION

Usage:
  $0 fullgen [OPTIONS] BACKUP

Arguments:
  BACKUP  Directory to export the GPG keys, typically on a flash drive or other
          removable media. This directory will be created if it does not exist,
          and should be writable by the current user.

Options:
  -h, --help                Show this message and exit
  -n, --name <NAME>         Name for the GPG key (default: "Ross MacArthur")
  -e, --email <EMAIL>       Email for the GPG key (default: "ross@macarthur.io")
      --expiry <EXPIRY>     The exact expiration month and day in the form MMDD
      --primary-years <Y>   Years for the primary key (default: 5)
      --subkey-years  <Y>   Years for the subkeys (default: 1)
EOF
}

fullgen_usage_error() {
    fullgen_usage
    printf "\n\033[1;31merror:\033[0m %s\n" "$1" >&2
    exit 1
}

fullgen_cmd() {
    local name="Ross MacArthur"
    local email="ross@macarthur.io"
    local expiry="0101"
    local primary_years=5
    local subkey_years=1
    local backup

    while test $# -gt 0
    do
        case $1 in
            -h|--help)
                fullgen_usage
                exit 0
                ;;
            -n|--name)
                shift
                if [ -z "$1" ]; then
                    fullgen_usage_error "--name option requires an argument"
                fi
                name="$1"
                ;;
            -e|--email)
                shift
                if [ -z "$1" ]; then
                    fullgen_usage_error "--email option requires an argument"
                fi
                email="$1"
                ;;
            --expiry)
                shift
                if [ -z "$1" ]; then
                    fullgen_usage_error "--expiry option requires an argument"
                fi
                if [[ ! "$1" =~ ^[0-9]{4}$ ]]; then
                    fullgen_usage_error "--expiry must be in the form MMDD (e.g., 0601 for June 1st)"
                fi
                expiry="$1"
                ;;
            --primary-years)
                shift
                if [ -z "$1" ]; then
                    fullgen_usage_error "--primary-years option requires an argument"
                fi
                primary_years="$1"
                ;;
            --subkey-years)
                shift
                if [ -z "$1" ]; then
                    fullgen_usage_error "--subkey-years option requires an argument"
                fi
                subkey_years="$1"
                ;;
            --*)
                fullgen_usage_error "unknown option: $1"
                ;;
            *)
                if [ -z "$backup" ]; then
                    backup="$1"
                else
                    fullgen_usage_error "too many arguments: expected one directory to export to"
                fi
                ;;
        esac
        shift
    done
    if [ -z "$backup" ]; then
        fullgen_usage_error "missing required argument: BACKUP directory"
    fi

    local primary_expiry="$(date -v+${primary_years}y +%Y)${expiry}T060000Z"
    local subkey_expiry="$(date -v+${subkey_years}y +%Y)${expiry}T060000Z"

    printf "Generating GPG key '%s <%s>'\n" "$name" "$email"
    printf "Primary key expiry: %s\n" "$primary_expiry"
    printf "Subkeys expiry: %s\n" "$subkey_expiry"
    read -r -p "Continue? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        error "Aborted"
    fi
    echo

    local disk="gpg-fullgen-$RANDOM"
    create_ram_disk "$disk"
    trap "nuke_ram_disk $disk" EXIT

    gpg_create_primary_key "$name" "$email" "$primary_expiry"
    gpg_add_sub_keys "$subkey_expiry"
    gpg_export "$backup"
}

###############################################################################
# import
###############################################################################

IMPORT_DESCRIPTION="Import GPG keys from a backup into the GPG keyring"

import_usage() {
    cat 1>&2 <<EOF
$IMPORT_DESCRIPTION

Usage:
  $0 import [OPTIONS] BACKUP

Arguments:
    BACKUP  The directory containing the GPG keys to import

Options:
  -h, --help             Show this message and exit
      --include-primary  Include the primary key in the import
EOF
}

import_usage_error() {
    import_usage
    printf "\n\033[1;31merror:\033[0m %s\n" "$1" >&2
    exit 1
}

import_cmd() {
    local backup
    local include_primary=false

    while test $# -gt 0
    do
        echo $1
        case $1 in
            -h|--help)
                import_usage
                exit 0
                ;;
            --include-primary)
                include_primary=true
                ;;
            --*)
                import_usage_error "unknown option: $1"
                ;;
            *)
                if [ -z "$backup" ]; then
                    backup="$1"
                else
                    import_usage_error "too many arguments: expected one directory to import"
                fi
                ;;
        esac
        shift
    done
    if [ -z "$backup" ]; then
        import_usage_error "missing required argument: BACKUP directory"
    fi

    if [ $include_primary = true ]; then
        gpg_import "$backup"
    else
        gpg_import_subs_only "$backup"
    fi
}

###############################################################################
# extend
###############################################################################

EXTEND_DESCRIPTION="Extend the expiration date of the GPG subkeys and re-export"

extend_usage() {
    cat 1>&2 <<EOF
$EXTEND_DESCRIPTION

Usage:
  $0 extend [OPTIONS] BACKUP

Arguments:
    BACKUP  Directory containing the backup to extend

Options:
    -h, --help             Show this message and exit
        --expiry <EXPIRY>  The exact expiration month and day in the form MMDD
        --years  <Y>       Years for the subkeys (default: 1)
EOF
}

extend_usage_error() {
    extend_usage
    printf "\n\033[1;31merror:\033[0m %s\n" "$1" >&2
    exit 1
}

extend_cmd() {
    local backup
    local expiry="0101"
    local years=1

    while test $# -gt 0
    do
        case $1 in
            -h|--help)
                extend_usage
                exit 0
                ;;
            --expiry)
                shift
                if [ -z "$1" ]; then
                    extend_usage_error "--expiry option requires an argument"
                fi
                if [[ ! "$1" =~ ^[0-9]{4}$ ]]; then
                    extend_usage_error "--expiry must be in the form MMDD (e.g., 0601 for June 1st)"
                fi
                expiry="$1"
                ;;
            --years)
                shift
                if [ -z "$1" ]; then
                    extend_usage_error "--years option requires an argument"
                fi
                years="$1"
                ;;
            --*)
                extend_usage_error "unknown option: $1"
                ;;
            *)
                if [ -z "$backup" ]; then
                    backup="$1"
                else
                    extend_usage_error "too many arguments: expected one directory to extend"
                fi
                ;;
        esac
        shift
    done
    if [ -z "$backup" ]; then
        extend_usage_error "missing required argument: BACKUP directory"
    fi

    local subkey_expiry="$(date -v+${years}y +%Y)${expiry}T060000Z"

    local disk="gpg-extend-$RANDOM"
    create_ram_disk "$disk"
    trap "nuke_ram_disk $disk" EXIT

    gpg_import "$backup"
    key=$(gpg_primary_fgr)
    gpg --quick-set-expire "$key" "$subkey_expiry" '*'
    gpg_export "$backup"
}

###############################################################################
# rotate
###############################################################################

ROTATE_DESCRIPTION="Rotate the GPG keys by generating new subkeys and re-export them"

rotate_usage() {
    cat 1>&2 <<EOF
$ROTATE_DESCRIPTION

Usage:
  $0 rotate [OPTIONS] BACKUP

Arguments:
    BACKUP  Directory containing the backup to rotate

Options:
  -h, --help               Show this message and exit
      --expiry <EXPIRY>    The exact expiration month and day in the form %M%D
      --subkey-years  <Y>  Years for the subkeys (default: 1)

EOF
}

rotate_usage_error() {
    rotate_usage
    printf "\n\033[1;31merror:\033[0m %s\n" "$1" >&2
    exit 1
}

rotate_cmd() {
    local backup
    local expiry="0101"
    local subkey_years=1

    while test $# -gt 0
    do
        case $1 in
            -h|--help)
                rotate_usage
                exit 0
                ;;
            --expiry)
                shift
                if [ -z "$1" ]; then
                    rotate_usage_error "--expiry option requires an argument"
                fi
                if [[ ! "$1" =~ ^[0-9]{4}$ ]]; then
                    rotate_usage_error "--expiry must be in the form MMDD (e.g., 0601 for June 1st)"
                fi
                expiry="$1"
                ;;
            --subkey-years)
                shift
                if [ -z "$1" ]; then
                    rotate_usage_error "--subkey-years option requires an argument"
                fi
                subkey_years="$1"
                ;;
            --*)
                rotate_usage_error "unknown option: $1"
                ;;
            *)
                if [ -z "$backup" ]; then
                    backup="$1"
                else
                    rotate_usage_error "too many arguments: expected one directory to rotate"
                fi
                ;;
        esac
        shift
    done
    if [ -z "$backup" ]; then
        rotate_usage_error "missing required argument: BACKUP directory"
    fi

    local subkey_expiry="$(date -v+${subkey_years}y +%Y)${expiry}T060000Z"

    local disk="gpg-rotate-$RANDOM"
    create_ram_disk "$disk"
    trap "nuke_ram_disk $disk" EXIT

    gpg_import "$backup"

    if ! gpg --list-keys --with-colons \
      | awk -F: '$1=="sub" || $1=="ssb" { if ($2 !~ /e/) exit 1 }'
    then
        printf "\nSubkeys are not yet expired, continuing will just create more subkeys...\n"
        read -r -p "Continue? (y/N): " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            error "Aborted"
        fi
    fi

    gpg_add_sub_keys "$subkey_expiry"
    gpg_export "$backup"
}

###############################################################################
# utils
###############################################################################

create_ram_disk() {
    local disk=$1
    diskutil erasevolume HFS+ "$disk" $(hdiutil attach -nomount ram://$((2 * 1024 * 1024)))
    chmod 700 "/Volumes/$disk"
    export GNUPGHOME=/Volumes/$disk
    cat > "$GNUPGHOME/gpg-agent.conf" <<EOF
pinentry-program $(which pinentry-mac)
default-cache-ttl 3600
max-cache-ttl 7200
EOF
    gpgconf --kill gpg-agent
}

nuke_ram_disk() {
    local disk=$1
    diskutil eject force "/Volumes/$disk"
}

gpg_create_primary_key() {
    local name="$1"
    local email="$2"
    local primary_expiry="$3"
    gpg --batch --yes --expert --full-generate-key <<EOF
Key-Type: eddsa
Key-Curve: ed25519
Key-Usage: cert
Name-Real: $name
Name-Email: $email
Expire-Date: $primary_expiry
%commit
EOF
}

gpg_primary_fgr() {
    gpg --list-keys --with-colons | awk -F: '$1=="pub"{getline; if($1=="fpr"){print $10; exit}}'
}

gpg_add_sub_keys() {
    local subkey_expiry=$1
    key=$(gpg_primary_fgr)
    if [ -z "$key" ]; then
        error "failed to find primary key fingerprint"
    fi
    gpg --quick-add-key "$key" ed25519 sign $subkey_expiry     # signing subkey
    gpg --quick-add-key "$key" cv25519 encrypt $subkey_expiry  # encryption subkey
    gpg --quick-add-key "$key" ed25519 auth $subkey_expiry     # authentication subkey
    gpg --list-secret-keys
}

gpg_import() {
    local backup=$1
    gpg --import "$backup/$FILE_PUBLIC"
    gpg --import "$backup/$FILE_SECRETS_ALL"
    gpg --import-ownertrust "$backup/$FILE_OWNERTRUST"
}

gpg_import_subs_only() {
    local backup=$1
    gpg --import "$backup/$FILE_PUBLIC"
    gpg --import "$backup/$FILE_SECRETS_SUBS_ONLY"
    gpg --import-ownertrust "$backup/$FILE_OWNERTRUST"
}

gpg_export() {
    local backup=$1
    mkdir -p "$backup"
    chmod 700 "$backup"
    gpg --armor --export $key > "$backup/$FILE_PUBLIC"
    gpg --armor --export-secret-keys $key > "$backup/$FILE_SECRETS_ALL"
    gpg --armor --export-secret-subkeys $key > "$backup/$FILE_SECRETS_SUBS_ONLY"
    gpg --export-ownertrust > "$backup/$FILE_OWNERTRUST"
    printf "\nGPG keys exported to %s\n" "$backup"
}

###############################################################################

main "$@"
