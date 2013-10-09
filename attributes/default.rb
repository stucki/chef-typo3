# Base directory where TYPO3 CMS Core will be cloned inside
default['typo3']['base_directory'] = "/var/www/typo3"

# Git repository URL
default['typo3']['repository_url'] = "git://git.typo3.org/Packages/TYPO3.CMS.git"

# Branches to install (define as strings or array of <name> / <reference>)
default['typo3']['install_branches'] = %w{
  TYPO3_4-7
  TYPO3_6-1
}

# Alternatively, install_branches can also hold pairs of <branch name> / <reference>
# FIXME: Support simple arrays of strings again. For now, overwrite the values from above and use a hash by default.
default['typo3']['install_branches'] = {
  'TYPO3_4-7' => 'origin/TYPO3_4-7',
  'TYPO3_6-1' => 'origin/TYPO3_6-1',
}

# Unset or override these values
#override['typo3']['install_branches'] = {
#  'TYPO3_4-7' => false,
#  'TYPO3_6-1' => 'TYPO3_6-1-0',
#}

# Location of the "git-new-workdir" helper script
if node['platform'] == 'debian' && node['platform_version'].to_f < 6 then
  default['typo3']['path_git-new-workdir'] = "/usr/share/doc/git-core/contrib/workdir/git-new-workdir"
else
  default['typo3']['path_git-new-workdir'] = "/usr/share/doc/git/contrib/workdir/git-new-workdir"
end

# Location of the shared TYPO3 CMS core directory
default['typo3']['shared_git_directory'] = "#{node['typo3']['base_directory']}/TYPO3core.git"

# Check for *.clone files before cloning
default['typo3']['check_clone_file'] = false
