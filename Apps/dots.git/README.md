
git init --bare $HOME/dotfiles
alias config='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME' (add this alias to .bashrc)
bash
config config --local status.showUntrackedFiles no

Basic usage example:

config add /path/to/file
config commit -m "A short message"
config push

to sync the files back down to a system :
config checkout
or in some cases _:
config pull origin main

# FROM BART

i read this article: 


Dotfiles: Best Way to Store in a Bare Git Repository

 

Disclaimer: the title is slightly hyperbolic, there are other proven solutions to the problem. I do think the technique below is very elegant though.

Recently I read about this amazing technique in an Hacker News thread on people's solutions to store their dotfiles. User StreakyCobra showed his elegant setup and ... It made so much sense! I am in the process of switching my own system to the same technique. The only pre-requisite is to install Git.

In his words the technique below requires:

No extra tooling, no symlinks, files are tracked on a version control system, you can use different branches for different computers, you can replicate you configuration easily on new installation.

The technique consists in storing a Git bare repository in a "side" folder (like $HOME/.cfg or $HOME/.myconfig) using a specially crafted alias so that commands are run against that repository and not the usual .git local folder, which would interfere with any other Git repositories around.
Starting from scratch

If you haven't been tracking your configurations in a Git repository before, you can start using this technique easily with these lines:

git init --bare $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bashrc

    The first line creates a folder ~/.cfg which is a Git bare repository that will track our files.
    Then we create an alias config which we will use instead of the regular git when we want to interact with our configuration repository.
    We set a flag - local to the repository - to hide files we are not explicitly tracking yet. This is so that when you type config status and other commands later, files you are not interested in tracking will not show up as untracked.
    Also you can add the alias definition by hand to your .bashrc or use the the fourth line provided for convenience.

I packaged the above lines into a snippet up on Bitbucket and linked it from a short-url. So that you can set things up with:

curl -Lks http://bit.do/cfg-init | /bin/bash

After you've executed the setup any file within the $HOME folder can be versioned with normal commands, replacing git with your newly created config alias, like:

config status
config add .vimrc
config commit -m "Add vimrc"
config add .bashrc
config commit -m "Add bashrc"
config push

Install your dotfiles onto a new system (or migrate to this setup)

If you already store your configuration/dotfiles in a Git repository, on a new system you can migrate to this setup with the following steps:

    Prior to the installation make sure you have committed the alias to your .bashrc or .zsh:

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

    And that your source repository ignores the folder where you'll clone it, so that you don't create weird recursion problems:

echo ".cfg" >> .gitignore

    Now clone your dotfiles into a bare repository in a "dot" folder of your $HOME:

git clone --bare <git-repo-url> $HOME/.cfg

    Define the alias in the current shell scope:

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

    Checkout the actual content from the bare repository to your $HOME:

config checkout

    The step above might fail with a message like:

error: The following untracked working tree files would be overwritten by checkout:
    .bashrc
    .gitignore
Please move or remove them before you can switch branches.
Aborting

This is because your $HOME folder might already have some stock configuration files which would be overwritten by Git. The solution is simple: back up the files if you care about them, remove them if you don't care. I provide you with a possible rough shortcut to move all the offending files automatically to a backup folder:

mkdir -p .config-backup && \
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}

    Re-run the check out if you had problems:

config checkout

    Set the flag showUntrackedFiles to no on this specific (local) repository:

config config --local status.showUntrackedFiles no

    You're done, from now on you can now type config commands to add and update your dotfiles:

config status
config add .vimrc
config commit -m "Add vimrc"
config add .bashrc
config commit -m "Add bashrc"
config push

Again as a shortcut not to have to remember all these steps on any new machine you want to setup, you can create a simple script, store it as Bitbucket snippet like I did, create a short url for it and call it like this:

curl -Lks http://bit.do/cfg-install | /bin/bash

For completeness this is what I ended up with (tested on many freshly minted Alpine Linux containers to test it out):

git clone --bare https://bitbucket.org/durdn/cfg.git $HOME/.cfg
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}
mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout
config config status.showUntrackedFiles no



but i did not understand the last part about check out and backup. can you try to explain that to me in more simple ways?

Sure. The last part of the article is about how to migrate your dotfiles to the new system.

The first step is to clone your dotfiles into a bare repository in a "dot" folder of your $HOME:

git clone --bare <git-repo-url> $HOME/.cfg

This will create a bare Git repository in the ~/.cfg folder. A bare repository is a Git repository that does not contain any working tree files. This means that it only contains the Git metadata, such as the commit history and the branches.

The next step is to define the alias config in the current shell scope:

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

This alias tells the shell to run the git command with the --git-dir and --work-tree options set to the ~/.cfg and ~ folders, respectively. This means that any git commands that you run will be executed against the bare repository in the ~/.cfg folder, but the changes will be made to the files in your home directory.

The third step is to checkout the actual content from the bare repository to your $HOME:

config checkout

This will checkout the latest version of the files from the bare repository to your home directory.

However, this step might fail with an error message if your home directory already contains some stock configuration files that would be overwritten by Git. The solution is to back up these files or remove them.

The article provides a script that you can use to automatically back up these files:

mkdir -p .config-backup && \
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}

This script first creates a backup folder called .config-backup in your home directory. Then, it runs the config checkout command and redirects the output to the standard error (stderr). The egrep command then filters the output of the config checkout command to only include the filenames of the files that would be overwritten. The awk command then prints the filenames of the files to be backed up. Finally, the xargs command moves the files to the backup folder.

Once you have backed up the files, you can run the config checkout command again to checkout the latest version of the files from the bare repository.

The final step is to set the flag showUntrackedFiles to no on this specific (local) repository:

config config --local status.showUntrackedFiles no

This will tell Git not to show untracked files when you run the status command.

I hope this explanation is more clear. Let me know if you have any other questions.
Kilder

    github.com/CKolkey/.config 

Søg efter relaterede emner
profilbillede
i already ran config add, commit, push for some files it worked fine. .. but i never ran the checkout command... did i mess up?

It's possible that you did mess up, but it's hard to say for sure without more information.

The config checkout command is used to checkout the latest version of the files from the bare repository to your home directory. If you didn't run this command, then the files in your home directory may not be the latest version.

The config add, commit, and push commands are used to add, commit, and push changes to the bare repository. These commands will work even if you didn't run the config checkout command, but the changes will not be reflected in the files in your home directory.

If you want to make sure that the files in your home directory are the latest version, then you should run the config checkout command.

Here are the steps to checkout the latest version of the files from the bare repository to your home directory:

    Run the following command:

config checkout

    If you are prompted to overwrite any files, then answer yes.

    The latest version of the files will be checked out to your home directory.

You can also run the config status command to see if the files in your home directory are the latest version. If the config status command does not show any untracked files, then the files in your home directory are the latest version.

If you are still having trouble, then you can post more information about your setup and the errors that you are getting. I will try to help you further.
profilbillede
ahh that is what it is for... no i am fine.. because it was the first run so the files on github where empty or not existing.. but now i understand how to sync the files down to a system if i need that... iwth the checkout command?! nice!!

I see. Yes, the config checkout command is used to sync the files from the bare repository to your home directory. It is a useful command to know if you ever need to restore your dotfiles to a previous state.

I'm glad that I could help you understand how it works. Let me know if you have any other questions.
profilbillede
ok then please explain the stuff about backing up some files that was already there? i did'nt understand that either

Sure. The article mentioned that you might need to back up some files that were already in your home directory before you ran the config checkout command. This is because the config checkout command will overwrite any files that have the same name in the bare repository and your home directory.

For example, if you have a file called .vimrc in your home directory and you run the config checkout command, the .vimrc file in the bare repository will be overwritten by the .vimrc file in your home directory.

If you have any files that you don't want to be overwritten, you can back them up before you run the config checkout command. You can use the cp command to copy the files to a backup folder.

For example, to back up the .vimrc file, you would run the following command:

cp .vimrc ~/.config-backup

This will copy the .vimrc file to the ~/.config-backup folder.

Once you have backed up the files, you can run the config checkout command. If the config checkout command overwrites any files, you can restore the backed up files.

I hope this explanation is more clear. Let me know if you have any other questions.
profilbillede
so the local files in the home dir super seeds the files in the repo?

Yes, that's correct. The local files in your home directory supersede the files in the repo. This is because the config checkout command will overwrite any files that have the same name in the bare repository and your home directory.

If you want to keep the files in the repo, you can use the config add command to add the files to the staging area and then commit the changes. This will create a new commit in the repo that contains the files from your home directory.

For example, to add the .vimrc file to the staging area, you would run the following command:

config add .vimrc

Then, to commit the changes, you would run the following command:

config commit -m "Add .vimrc"

This will create a new commit in the repo that contains the .vimrc file from your home directory.

I hope this explanation is clear. Let me know if you have any other questions.
profilbillede
i just tried to change a file on github.com (one of the files in the repo) and then ran config checkout but the changes i made on github.com did not get pulled to my local system... why?

That's strange. The config checkout command should pull the latest changes from the repo to your local system.

There are a few things that could be causing this:

    The changes you made on GitHub may not have been pushed to the remote repo yet.
    The config checkout command may not have been run with the correct options.
    There may be a problem with your local Git configuration.

To troubleshoot this, you can try the following:

    Make sure that the changes you made on GitHub have been pushed to the remote repo. You can do this by going to the repo on GitHub and clicking on the "commits" tab. The commits should be listed in reverse chronological order, with the most recent commit at the top.
    Make sure that you are running the config checkout command with the correct options. The correct options are:

config checkout

If you are using any other options, then they may be preventing the command from pulling the latest changes.
3. Check your local Git configuration. You can do this by running the following command:

git config --list

This will list all of the settings in your local Git configuration. If there are any settings that are incorrect, then they may be causing the problem.

If you have tried all of these things and you are still having problems, then you can post more information about your setup and the errors that you are getting. I will try to help you further.

I hope this helps!
profilbillede
config checkout
M	.bash_aliases
Se andre kladder

The output of the config checkout command indicates that the file .bash_aliases has been modified. This means that the file has been changed since the last time you ran the config checkout command.

If you want to keep the changes that have been made to the file, you can run the config add command to add the file to the staging area and then commit the changes. This will create a new commit in the repo that contains the changes to the file.

For example, to add the .bash_aliases file to the staging area, you would run the following command:

config add .bash_aliases

Then, to commit the changes, you would run the following command:

config commit -m "Update .bash_aliases"

This will create a new commit in the repo that contains the changes to the .bash_aliases file.

If you do not want to keep the changes that have been made to the file, you can run the config checkout --force command. This will overwrite the file in your home directory with the version of the file in the repo.

For example, to overwrite the .bash_aliases file with the version of the file in the repo, you would run the following command:

config checkout --force .bash_aliases

This will overwrite the file in your home directory with the version of the file in the repo, even if the file in your home directory has been modified since the last time you ran the config checkout command.

I hope this helps!

