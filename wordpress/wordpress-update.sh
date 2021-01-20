#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_base.sh

_wp_version="latest"
_wp_docroot=$(pwd)
_issue_no=""
wp_directories=(wp-admin/ wp-includes/)
wp_files=(index.php license.txt readme.html wp-activate.php wp-blog-header.php wp-comments-post.php wp-config-sample.php wp-links-opml.php wp-load.php wp-login.php wp-mail.php wp-settings.php wp-signup.php wp-trackback.php xmlrpc.php)


## WELCOME
program_title "Update WordPress to specific version"
display_info "How to at https://cactusthemes.com/blog/how-to-downgrade-upgrade-wordpress-to-specific-version/"


## VARIABLES
display_info "Browse all versions https://wordpress.org/download/releases/"
prompt_variable_not_null wp_version "Destination version?" "$_wp_version" 1 "$@"
prompt_variable_not_null wp_docroot "Docroot path" "$_wp_docroot" 2 "$@"
prompt_variable_not_null issue_no "Issue number" "$_issue_no" 3 "$@"


# PROGRAM
confirm_or_exit "Upgrade WordPress?"

wp_upgrade_zip_url="https://wordpress.org/wordpress-${wp_version}.zip"
wp_upgrade_dir="${wp_docroot}/wp-content/upgrade/"
wp_upgrade_zip_file="${wp_upgrade_dir}wordpress.zip"
wp_upgrade_zip_dir="${wp_upgrade_dir}wordpress/"

display_info "Remove core files"
for name in "${wp_directories[@]}"; do
    printf "${COLOR_DEFAULT_I}remove ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I}\n" "$name"
    rm -rf ${wp_docroot}/${name}
done
for name in "${wp_files[@]}"; do
    printf "${COLOR_DEFAULT_I}remove ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I}\n" "$name"
    rm -rf ${wp_docroot}/${name}
done

display_info "Download ${wp_version} version"
mkdir -p ${wp_upgrade_dir}
curl ${wp_upgrade_zip_url} > ${wp_upgrade_zip_file}

display_info "Unpack ${wp_version} version"
unzip ${wp_upgrade_zip_file} -d ${wp_upgrade_dir}
rm ${wp_upgrade_zip_file}

display_info "Install ${wp_version} version"
for name in "${wp_directories[@]}"; do
    printf "${COLOR_DEFAULT_I}move ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I}\n" "$name"
    mkdir -p "$wp_docroot/$name"
    mv ${wp_upgrade_zip_dir}${name}* ${wp_docroot}/${name}
done
for name in "${wp_files[@]}"; do
    printf "${COLOR_DEFAULT_I}move ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I}\n" "$name"
    mv "$wp_upgrade_zip_dir$name" "$wp_docroot/$name"
done
rm -rf ${wp_upgrade_zip_dir}


# PROGRAM
confirm_or_exit "Save changes in repository?"

display_info "Add to git"
git add "$wp_docroot"

display_info "Commit to git"
git commit -F- <<EOF
Upgrade to WordPress ${wp_version}

Issue: ${issue_no}
EOF


# END
color_reset
print_new_line
