from git import Repo

repo = Repo("C:\\Visual Pinball\\vmvpin.github.io")
remote = repo.remote()
repo.git.add()
if repo.is_dirty():
    repo.index.commit("Updated high scores")
remote.pull()
remote.push()