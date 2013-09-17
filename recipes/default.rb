#
# Cookbook Name:: typo3
# Recipe:: default
#
# Copyright 2013, Michael Stucki / TYPO3 Association
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

include_recipe 'git'

base_directory       = node['typo3']['base_directory']
git_new_workdir      = node['typo3']['path_git-new-workdir']
shared_git_directory = node['typo3']['shared_git_directory'].gsub(/.git$/, '')

destination          = shared_git_directory + ".git"
clonefile            = shared_git_directory + ".clone"
markerfile           = shared_git_directory + ".cloned-by-chef"

#####################################
# Maintain the shared TYPO3 core
#####################################

if ::File.exists?(clonefile) and not ::File.exists?(destination)

  # Make a fresh clone
  git destination do
    repository node['typo3']['repository_url']
    # This is the very first revision in the TYPO3 CMS repository.
    # It contains an empty commit, so it's equal to git clone --no-checkout
    revision "feffa595f3cf67d14db7727a1028eac550dc6ef6"
    action :sync
  end

  # Fix permissions
  execute "Fix permissions on #{destination}" do
    command "chmod -R a+rX #{destination}"
  end

  # Cleanup
  execute "Add marker file to #{destination}" do
    cwd node['typo3']['base_directory']
    umask 0022
    command <<-EOH
      touch markerfile
      rm clonefile
    EOH
  end

elsif ::File.exists?(destination)

  # Only reset if managed by Chef
  if ::File.exists?(markerfile)

    # Update existing TYPO3 core (the above sync does not work if the revision does not change)
    execute "Update the shared Git directory" do
      cwd destination
      umask 0022
      command "git fetch origin"
    end
  else
    Chef::Log.debug("Skipping update of #{destination}: The repository is not managed by Chef.")
  end
else
  Chef::Log.debug("Skipping clone of #{destination}: Missing clone file.")
end


#####################################
# Maintain clones of TYPO3 versions
#####################################

node['typo3']['install_branches'].each do |branch|
  source             = shared_git_directory + ".git"
  destination        = base_directory + "/" + branch + ".git"
  clonefile          = base_directory + "/" + branch + ".clone"
  markerfile         = base_directory + "/" + branch + ".cloned-by-chef"

  # Only clone the repository if explicitely requested
  if ::File.exists?(clonefile) and not ::File.exists?(destination)

    # Create initial clone of TYPO3core
    # Use git-new-workdir share the main ".git" folder between all versions
    execute "Create new TYPO3 working directory for version #{branch}" do
      cwd base_directory
      umask 0022
      command <<-EOH
        sh #{git_new_workdir} #{source} #{destination}
        touch #{markerfile}
        rm #{clonefile}
      EOH
    end

    execute "Create new local branch #{branch}" do
      cwd destination
      umask 0022
      command "git checkout #{branch} || git checkout -b #{branch} origin/#{branch}"
    end

  elsif ::File.exists?(destination)

    # Only reset if managed by Chef
    if ::File.exists?(markerfile)

      # Update existing clone of TYPO3core (using git reset)
      execute "Update TYPO3core for version #{branch}" do
        cwd destination
        umask 0022
        command "git reset --hard origin/#{branch}"
      end
    else
      Chef::Log.debug("Skipping update of #{destination}: The repository is not managed by Chef.")
    end
  else
    Chef::Log.debug("Skipping clone of #{destination}: Missing clone file.")
  end

end
