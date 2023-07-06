from git import Repo

repo = Repo("/Users/christian/Desktop/vpin/vmvpin.github.io")
repo.git.add("-A")
if repo.is_dirty():
    repo.index.commit("Updated images")
remote = repo.remote()
remote.push()