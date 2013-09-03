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

git "#{node['typo3']['base_directory']}/TYPO3core.git" do
  repository "#{node['typo3']['repository_url']}"
  # This is the very first revision in the repository.
  # It contains an empty commit, so it's equal to git clone --no-checkout
  revision "feffa595f3cf67d14db7727a1028eac550dc6ef6"
  #reference "master"
  action :sync
end

# Create initial clone of TYPO3core
# Use git-new-workdir share the main ".git" folder between all versions
node['typo3']['install_branches'].each do |branch|
  execute "Create new TYPO3 working directory for version #{branch}" do
    command <<-EOH
      sh /usr/share/doc/git/contrib/workdir/git-new-workdir \
          #{node['typo3']['shared_git_directory']} \
          #{node['typo3']['base_directory']}/#{branch}.git \
          #{branch}
      touch #{node['typo3']['base_directory']}/#{branch}.cloned-by-chef
      rm #{node['typo3']['base_directory']}/#{branch}.clone
    EOH
    not_if { ::File.exists?("#{node['typo3']['base_directory']}/#{branch}.git") }
    # Only clone the repository if explicitely requested
    only_if { ::File.exists?("#{node['typo3']['base_directory']}/#{branch}.clone") }
  end
end

# Update existing clone of TYPO3core (using git reset)
node['typo3']['install_branches'].each do |branch|
  execute "Update TYPO3core for version #{branch}" do
    command <<-EOH
      git reset --hard origin/#{branch}
    EOH
    cwd "#{node['typo3']['base_directory']}/#{branch}.git"
    # Only reset if managed by Chef
    only_if { ::File.exists?("#{node['typo3']['base_directory']}/#{branch}.git") && ::File.exists?("#{node['typo3']['base_directory']}/#{branch}.cloned-by-chef") }
  end
end
