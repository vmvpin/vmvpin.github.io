import os
from datetime import datetime
from git import Repo

def pull():
    repo = Repo("C:\\Visual Pinball\\vmvpin.github.io")
    remote = repo.remote()
    remote.pull()

def push():
    repo = Repo("C:\\Visual Pinball\\vmvpin.github.io")
    remote = repo.remote()
    repo.git.add(u=True)
    if repo.is_dirty():
        repo.index.commit("Updated high scores md files")
    #remote.pull()
    #remote.push()

def getPath(loc):
    if os.path.exists('C:\\Visual Pinball'):
        if loc == 'text':
            return "C:\\Visual Pinball\\Hiscores\\Text\\"
        elif loc == 'scores':
            return "C:\\Visual Pinball\\vmvpin.github.io\\_games\\"
    else:
        if loc == 'text':
            return "./../texts/"
        elif loc == 'scores':
            return "./../scores/"

def header(md,name):
    md.write('---\n')
    md.write('layout: default\n')
    md.write(f'title: {name}\n')
    md.write(f'thumbnail: images/{name}.png\n')
    md.write(f'permalink: /games/{name}.html\n')
    md.write(f"date: {datetime.today().strftime('%Y-%m-%d')}\n")
    md.write('---\n')
    md.write('\n')

def normal(f,md):
    md.write(f'## High Scores \n')
    md.write('{:.scoreText}\n')
    md.write('\n')
    md.write(f'| Name | Score | \n')
    md.write(f'| :---- | ----: | \n')  
    for line in f:
        if line != '\n':
            md.write(f'| {line.strip()} ')
        else:
            md.write('| \n')
    md.write('| \n')
    md.write('{:.scoreText .table .td}')

def nba(f,md):
    new = False
    endTable = False
    for line in f:
        if line == '\n':
            if endTable:
                md.write('{:.scoreText .table .td}\n')
                endTable = False
            md.write(line)
            new = True
        elif new:
            md.write(f'## {line}')
            md.write('{:.scoreText}\n')
            md.write('\n')
            new = False
        elif len(line.split()) > 1: 
            if ')' in line.split()[0]:
                line = ' '.join(line.split()[1:])
            for entry in line.strip().split():
                md.write(f'| {entry} ')
            md.write('| \n')
            endTable = True
        else:
            md.write(line)
    if endTable:
        md.write('{:.scoreText .table .td}\n')

pull()

for file in os.listdir(getPath("text")):
    if file.endswith(".txt"):
        name = file.split('.')[0].split('-done')[0]
        md_path = f'{getPath("scores")}{name}.md'
        if not os.path.exists(md_path):
            with open(md_path,'x'): pass
        md = open(md_path,'a')
        md.truncate(0)
        header(md,name)
        md.write(f'# {name} \n')
        md.write('{:.neontext}\n')
        md.write('\n')
        with open(os.path.abspath(f'{getPath("text")}{file}'), 'r') as f:
            first = next(f)
            if 'High Scores' in first:
                normal(f,md)
            else:
                md.write(f'## {first}')
                md.write('{:.scoreText}\n')
                md.write('\n')
                nba(f,md)
print("Done updating, pushing to git")
push()