#
# Cookbook Name:: typo3
# Recipe:: typo3core
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

base_directory       = node['typo3']['base_directory']
git_new_workdir      = node['typo3']['path_git-new-workdir']
shared_git_directory = node['typo3']['shared_git_directory'].gsub(/.git$/, '')

#####################################
# Maintain the shared TYPO3 core
#####################################

destination          = shared_git_directory + ".git"
clone_file           = shared_git_directory + ".clone"
marker_file          = shared_git_directory + ".cloned-by-chef"

if ::File.exists?(clone_file) and not ::File.exists?(destination)

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
      touch #{marker_file}
      rm #{clone_file}
    EOH
  end

elsif ::File.exists?(destination)

  # Only reset if managed by Chef
  if ::File.exists?(marker_file)

    # Update existing TYPO3 core (the above sync does not work if the revision does not change)
    # Additionally, update the remote repository URL in case it was changed
    execute "Update the shared Git directory" do
      cwd destination
      umask 0022
      command <<-EOH
        git config remote.origin.url "#{node['typo3']['repository_url']}"
        git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
        git fetch origin
      EOH
    end
  else
    Chef::Log.debug("Skipping update of #{destination}: The repository is not managed by Chef.")
  end
else
  Chef::Log.debug("Skipping clone of #{destination}: Missing clone file.")
end
