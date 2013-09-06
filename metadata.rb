name             'typo3'
maintainer       'TYPO3 Association'
maintainer_email 'michael.stucki@typo3.org'
license          'MIT'
description      'Clone TYPO3 CMS to a server, and keep it updated'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'

depends "git"

attribute "typo3/base_directory",
  :display_name => "Base Directory",
  :description => "Base directory where TYPO3 CMS Core will be cloned inside",
  :default => "/var/www/typo3"

attribute "typo3/repository_url",
  :display_name => "Git repository URL",
  :description => "Git repository URL for TYPO3 CMS core",
  :default => "git://git.typo3.org/Packages/TYPO3.CMS.git"

attribute "typo3/install_branches",
  :display_name => "Branches to install",
  :description => "These branches will be installed and updated using Chef",
  :type => "array",
  :default => [ "TYPO3_4-7", "TYPO3_6-1" ]

attribute "typo3/path_git-new-workdir",
  :display_name => "Location of the \"git-new-workdir\" helper script",
  :description => "This script is used to create a new working copy. It creates symlinks to the shared Git directory, which can save a lot of disk space.",
  :default => "/usr/share/doc/git/contrib/workdir/git-new-workdir"

attribute "typo3/shared_git_directory",
  :display_name => "Location of the shared TYPO3 CMS core directory",
  :description => "TYPO3 CMS core will be cloned into this directory. Other projects will share the .git subfolder of it using symlinks.",
  :default => "\#{node['typo3']['base_directory']}/TYPO3core.git"
