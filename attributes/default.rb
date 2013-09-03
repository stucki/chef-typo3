default['typo3']['base_directory'] = "/var/www/typo3"

default['typo3']['repository_url'] = "git://git.typo3.org/Packages/TYPO3.CMS.git"

default['typo3']['install_branches'] = %w{
  TYPO3_4-7
  TYPO3_6-1
}

# Currently, only shared Git repositories work
#default['typo3']['share_git'] = true 
default['typo3']['shared_git_directory'] = "#{node['typo3']['base_directory']}/TYPO3core.git"
