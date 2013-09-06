default['typo3']['base_directory'] = "/var/www/typo3"

default['typo3']['repository_url'] = "git://git.typo3.org/Packages/TYPO3.CMS.git"

default['typo3']['install_branches'] = %w{
  TYPO3_4-7
  TYPO3_6-1
}

if node['platform'] == 'debian' && node['platform_version'].to_f < 6 then
  default['typo3']['path_git-new-workdir'] = "/usr/share/doc/git-core/contrib/workdir/git-new-workdir"
else
  default['typo3']['path_git-new-workdir'] = "/usr/share/doc/git/contrib/workdir/git-new-workdir"
end

default['typo3']['shared_git_directory'] = "#{node['typo3']['base_directory']}/TYPO3core.git"
