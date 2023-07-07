from git import Repo

repo = Repo("/Users/christian/Desktop/vpin/vmvpin.github.io")
remote = repo.remote()
repo.git.add("-A")
if repo.is_dirty():
    repo.index.commit("Updated high scores")
remote.pull()
remote.push()