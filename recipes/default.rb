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

git "#{node['typo3']['shared_git_directory']}" do
  repository "#{node['typo3']['repository_url']}"
  # This is the very first revision in the repository.
  # It contains an empty commit, so it's equal to git clone --no-checkout
  revision "feffa595f3cf67d14db7727a1028eac550dc6ef6"
  action :sync
end

# Update existing TYPO3 core (the above sync does not work if the revision does not change)
execute "Update the shared Git directory" do
  cwd "#{node['typo3']['shared_git_directory']}"
  command <<-EOH
    git fetch origin
  EOH
  only_if { ::File.exists?("#{node['typo3']['shared_git_directory']}") }
end

# Create initial clone of TYPO3core
# Use git-new-workdir share the main ".git" folder between all versions
node['typo3']['install_branches'].each do |branch|
  destination_prefix = node['typo3']['base_directory'] + "/#{branch}"

  # Only clone the repository if explicitely requested
  if ::File.exists?("#{destination_prefix}.clone") and not ::File.exists?("#{destination_prefix}.git")

    execute "Create new TYPO3 working directory for version #{branch}" do
      cwd "#{node['typo3']['base_directory']}"
      command <<-EOH
        sh #{node['typo3']['path_git-new-workdir']} \
            #{node['typo3']['shared_git_directory']} \
            #{destination_prefix}.git
        touch #{destination_prefix}.cloned-by-chef
        rm #{destination_prefix}.clone
      EOH
    end

    execute "Create new local branch #{branch}" do
      cwd "#{destination_prefix}.git"
      command "git checkout #{branch} || git checkout -b #{branch} origin/#{branch}"
    end

  elsif ::File.exists?("#{destination_prefix}.git")

    # Only reset if managed by Chef
    if ::File.exists?("#{destination_prefix}.cloned-by-chef")

      # Update existing clone of TYPO3core (using git reset)
      execute "Update TYPO3core for version #{branch}" do
        cwd "#{destination_prefix}.git"
        command "git reset --hard origin/#{branch}"
      end
    else
      Chef::Log.debug("Skipping update of #{destination_prefix}.git: The repository is not managed by Chef.")
    end
  else
    Chef::Log.debug("Skipping clone of #{destination_prefix}.git: Missing clone file.")
  end

end
